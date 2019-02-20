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

SUBSET =  glob_wildcards(config["src_data_specs"] +
            "subset_{iFile}.json").iFile

print(SUBSET)

# --- Build Rules --- #

rule all:
    input:
        graph = config["out_analysis"] + "cps_trend_no_high_school.pdf",
        data_fig = expand(config["out_data"] +
                    "cps_trend_{iSubset}.csv",
                    iSubset= SUBSET),
        data_reg = config["out_data"] + "cps_did_no_hs_card.csv"

# rule estimate_did:
#     input:
#         script = config["src_analysis"] + "estimate_did_card.R",
#         data   = config["out_data"] + "cps_77-93_men_clean.csv"
#     output:
#         estimates = config["out_analysis"] + "did_estimates_card.rds"
#     log:
#         config["log"] + "estimate_did_card.Rout"
#     shell:
#         "Rscript {input.script} \
#             --data {input.data} \
#             --out {output.estimates} > {log} {LOGALL}"

rule make_did_data:
    input:
        script = config["src_analysis"] + "make_did_data.R",
        data   = config["out_data"] + "cps_77-93_men_clean.csv"
    output:
        out    = config["out_data"] + "cps_did_no_hs_card.csv"
    log:
        config["log"] + "cps_did_no_hs_card.Rout"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --out {output.out} > {log} {LOGALL}"

rule graphs:
    input:
        script            = config["src_analysis"] + "plot_trend.R",
        data              = config["out_data"] + "cps_trend_no_high_school_not_miami.csv"
    output:
        out               = config["out_analysis"] + "cps_trend_no_high_school.pdf"
    log:
        config["log"] + "plot_trend.Rout"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --out {output.out} > {log} {LOGALL}"


rule compute_wage_trend:
    input:
        script      = config["src_analysis"] + "compute_wage_trend.R",
        data        = config["out_data"] + "cps_77-93_men_clean.csv",
        subset      = config["src_data_specs"] + "subset_{iSubset}.json"
    output:
        out = config["out_data"] + "cps_trend_{iSubset}.csv"
    log:
        config["log"] + "compute_wage_trend_{iSubset}.Rout"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --subset {input.subset} \
            --out {output.out} > {log} {LOGALL}"


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
