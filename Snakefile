## Snakefile - Mariel Boatlift
##
## @alexjenni

LOGALL = "2>&1"  # put 2 (errors) wherever 1 goes (standard log)

# --- Import a config file --- #
configfile: "config.yaml"

# --- Iterable Lists --- #
MSAS =  glob_wildcards(config["src_data_specs"] +
            "subset_msa_{iFile}.json").iFile
EDUCS = glob_wildcards(config["src_data_specs"] +
            "subset_edu_{iFile}.json").iFile
MIAMI = ['miami']
CONTROLS= list(set(MSAS) - set(MIAMI))
OUTCOME =['log_weekly_wage']
print("List of control groups:")
print(MSAS)
print(EDUCS)
print(CONTROLS)

# --- Build Rules --- #
rule all:
    input:
        graphs = expand(config["out_figures"] +
                     "trend_log_wage_{iEduc}_miami_vs_{iControl}.pdf",
                     iEduc    = EDUCS,
                     iControl = CONTROLS),
        tables = expand(config["out_tables"] +
                     "table_did_{iEduc}-{iControl}.txt",
                     iEduc    = EDUCS,
                     iControl = CONTROLS)

# Tables
rule make_tabs :
    input:
        script    = config["src_tables"] + "table_did.R",
        estimates = config["out_analysis"] +
                    "estimates_did_log_wage_{iEduc}-{iControl}.rds"
    output:
        tex =config["out_tables"] + "table_did_{iEduc}-{iControl}.txt"
    params:
        filepath  = config["out_analysis"]
    log:
        config["log"] + "table_did_{iEduc}-{iControl}.Rout"
    shell:
        "Rscript {input.script} \
            --filepath {params.filepath} \
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
