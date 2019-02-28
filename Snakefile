## Snakefile - Mariel Boatlift
##
## @alexjenni @mventu

LOGALL = "2>&1"  # put 2 (errors) wherever 1 goes (standard log)

from pathlib import Path

# --- Import a config file --- #
configfile: "config.yaml"

# --- Iterable Lists --- #
MSAS =  glob_wildcards(config["src_data_specs"] +
            "subset_msa_{iFile}.json").iFile
EDUCS = glob_wildcards(config["src_data_specs"] +
            "subset_edu_{iFile}.json").iFile
FIGS = glob_wildcards(config["out_figures"] +
            "{iFile}.pdf").iFile

MIAMI = ['miami']
CONTROLS= list(set(MSAS) - set(MIAMI))
OUTCOME =['log_weekly_wage']


# --- Build Rules --- #
rule all:
    input:
        #graphs = expand(config["out_figures"] +
        #             "trend_log_wage_{iEduc}_miami_vs_{iControl}.pdf",
        #             iEduc    = EDUCS,
        #             iControl = CONTROLS),
        #tables = expand(config["out_tables"] +
        #             "table_did_{iEduc}.tex",
        #             iEduc    = EDUCS),
        paper = config["out_paper"] + "paper.pdf",
    output:
        paper = "pp4rs_assignment.pdf"
    shell:
        "cp {input.paper} {output.paper}"
        #"Move-Item -Path {input.paper} -Destination {input.paper}"


#Paper    : builds tex file instead of Rmd file, DON'T DELETE, IT COULD BE USEFUL IN LIFE
#rule tex2pdf:
    #input:
    #    tex = "paper.tex"
    #output:
    #    pdf = "paper.pdf"
    #run:
    #    shell("pdflatex paper.tex")

# Paper              : builds Rmd to pdf
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
        pdf = config["out_paper"] + "paper.pdf"
    log:
        config["log"] + "paper.Rout"
    shell:
        "Rscript {input.runner} {input.paper} {output.pdf} \
            > {log} 2>&1"

# Tables
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
rule graphs:
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
rule rename_vars:
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
