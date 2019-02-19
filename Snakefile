## Snakefile - Mariel Boatlift
##
## @alexjenni

LOGALL = "2>&1"  # put 2 (errors) wherever 1 goes (standard log)

# --- Import a config file --- #
configfile: "config.yaml"

# --- Iterable Lists --- #


# --- Build Rules --- #

rule all:
    input:
        data = config["out_data"] + "cps_borjas_renamed.csv"

rule rename_vars:
    input:
        script = config["src_data_mgt"] + "rename_variables.R",
        data   = config["src_data"] + "cps_77-93_men.dta"
    output:
        data = config["out_data"] + "cps_borjas_renamed.csv"
    log:
        config["log"] + "rename_vars.Rout"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --out {output.data} > {log} {LOGALL}"
