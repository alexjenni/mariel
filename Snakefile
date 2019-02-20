## Snakefile - Mariel Boatlift
##
## @alexjenni

LOGALL = "2>&1"  # put 2 (errors) wherever 1 goes (standard log)

# --- Import a config file --- #
configfile: "config.yaml"

# --- Iterable Lists --- #
# CONTROL_SUBSET = glob_wildcards(config["src_data_specs"] + "{iFile}.json").iFile
# CONTROL_SUBSET = list(filter(lambda x: x.endswith("_plus_miami"), CONTROL_SUBSET))

# EDUC_SUBSET = glob_wildcards(config["src_data_specs"] + "{iFile}.json").iFile
# EDUC_SUBSET = list(filter(lambda x: x.startswith("subset_educ"), EDUC_SUBSET))
EDUC_SUBSET = ["no_high_school",
               "high_school_and_more"]
NON_HISP = config["src_data_specs"] + "subset_non_hispanic.json"


# --- Build Rules --- #

rule all:
    input:
        data = expand(config["out_data"] +
                    "cps_trend_{iEduc}.csv",
                    iEduc= EDUC_SUBSET)

rule compute_wage_trend:
    input:
        script = config["src_analysis"] + "compute_wage_trend.R",
        data = config["out_data"] + "cps_borjas_renamed.csv",
        subset = config["src_data_specs"] + "subset_{iEduc}.json"
    output:
        out = config["out_data"] + "cps_trend_{iEduc}.csv"
    log:
        config["log"] + "compute_wage_trend_{iEduc}.Rout"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --subset {input.subset} \
            --out {output.out} > {log} {LOGALL}"


rule rename_vars:
    input:
        script = config["src_data_mgt"] + "rename_variables.R",
        data   = config["src_data"] + "cps_77-93_men.csv"
    output:
        out = config["out_data"] + "cps_borjas_renamed.csv"
    log:
        config["log"] + "rename_vars.Rout"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --out {output.out} > {log} {LOGALL}"
