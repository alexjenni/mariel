## Snakefile - Mariel Boatlift
##              Replicate some results from Borjas (2015)
##
## @alexjenni @mventu

LOGALL = "2>&1"  # put 2 (errors) wherever 1 goes (standard log)

# --- Import a config file --- #
configfile: "config.yaml"

# --- Dictionaries --- #
MSAS =  glob_wildcards(config["src_data_specs"] +
            "subset_msa_{iFile}.json").iFile
EDUCS = glob_wildcards(config["src_data_specs"] +
            "subset_edu_{iFile}.json").iFile
MIAMI = ['miami']
CONTROLS= list(set(MSAS) - set(MIAMI))

# --- Build Rules --- #

## paper : builds Rmd to pdf
rule paper:
    input:
        paper = config["src_paper"] + "paper.Rmd",
        runner = config["src_lib"] + "knit_rmd.R",
        figures = expand(config["out_figures"] + "trend_log_wage_{iEduc}_miami_vs_{iControl}.pdf",
                        iEduc = EDUCS,
                        iControl = CONTROLS),
        table = expand(config["out_tables"] + "table_did_{iEduc}.tex",
                        iEduc = EDUCS)
    output:
        pdf = "alex_miriam_pp4rs_assignment.pdf"
    log:
        config["log"] + "paper.Rout"
    shell:
        "Rscript {input.runner} {input.paper} {output.pdf} \
            > {log} 2>&1"

# Tables
## make_tabs : construct regression tables
rule make_tabs :
    input:
        script    = config["src_tables"] + "table_did_{iEduc}.R",
        estimates = expand(config["out_analysis"] +
                    "estimates_did_log_wage_{iEduc}-{iControl}.rds",
                    iEduc = EDUCS,
                    iControl = CONTROLS)
    output:
        tex =config["out_tables"] + "table_did_{iEduc}.tex"
    params:
        filepath  = config["out_analysis"],
        model_exp = "estimates_did_log_wage_{iEduc}-*.rds"
    log:
        config["log"] + "table_did_{iEduc}.Rout"
    shell:
        "Rscript {input.script} \
            --filepath {params.filepath} \
            --models {params.model_exp} \
            --out {output.tex} > {log} {LOGALL}"

## estimate_did: Estimate DiD regression
rule estimate_did:
    input:
        script  = config["src_analysis"] + "estimate_did.R",
        data    = config["out_data"] + "cps_77-93_men_clean.csv",
        subset  = config["src_data_specs"] + "subset_edu_{iEduc}.json",
        control = config["src_data_specs"] + "subset_msa_{iControl}.json"
    output:
        estimates = config["out_analysis"] +
                    "estimates_did_log_wage_{iEduc}-{iControl}.rds"
    log:
        config["log"] + "estimate_did_log_wage_{iEduc}-{iControl}.Rout"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --subset {input.subset} \
            --control {input.control} \
            --out {output.estimates} > {log} {LOGALL}"

# Figures
## plot_trend: Plot trends in log wage
rule plot_trend:
    input:
        script      = config["src_figures"] + "plot_trend.R",
        data_miami  = config["out_analysis"] + "cps_trend_{iEduc}-miami.csv",
        data_control= config["out_analysis"] + "cps_trend_{iEduc}-{iControl}.csv"
    output:
        fig         = config["out_figures"] + "trend_log_wage_{iEduc}_miami_vs_{iControl}.pdf"
    log:
        config["log"] + "plot_trend_log_wage_{iEduc}_miami_vs_{iControl}.Rout"
    shell:
        "Rscript {input.script} \
            --data_miami {input.data_miami} \
            --data_control {input.data_control} \
            --out {output.fig} > {log} {LOGALL}"

## compute_wage_trend: Compute trend in log wage by subgroup
rule compute_wage_trend:
    input:
        script  = config["src_analysis"] + "compute_wage_trend.R",
        data    = config["out_data"] + "cps_77-93_men_clean.csv",
        subset1 = config["src_data_specs"] + "subset_edu_{iEdu}.json",
        subset2 = config["src_data_specs"] + "subset_msa_{iMsa}.json"
    output:
        out = config["out_analysis"] + "cps_trend_{iEdu}-{iMsa}.csv"
    log:
        config["log"] + "compute_wage_trend_{iEdu}-{iMsa}.Rout"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --subset1 {input.subset1} \
            --subset2 {input.subset2} \
            --out {output.out} > {log} {LOGALL}"

# Data cleaning
## clean_cps: Clean data set and rename variables
rule clean_cps:
    input:
        script = config["src_data_mgt"] + "clean_cps.R",
        data   = config["src_data"] + "cps_77-93_men.csv"
    output:
        out = config["out_data"] + "cps_77-93_men_clean.csv"
    log:
        config["log"] + "clean_cps.Rout"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --out {output.out} > {log} {LOGALL}"

# --- R package resolution --- #

## find_packages      : looks for R packages used across all scripts
rule find_packages:
    output:
        "REQUIREMENTS.txt"
    shell:
        "bash find_r_packages.sh"

## install_packages   : installs missing R packages
rule install_packages:
    input:
        script = config["src_lib"] + "install_r_packages.R",
        requirements = "REQUIREMENTS.txt"
    shell:
        "Rscript {input.script}"
