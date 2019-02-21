## Snakefile - Mariel Boatlift
##
## @alexjenni

LOGALL = "2>&1"  # put 2 (errors) wherever 1 goes (standard log)

# --- Import a config file --- #
configfile: "config.yaml"

# --- Iterable Lists --- #
SUBSETS =  glob_wildcards(config["src_data_specs"] +
            "subset_{iFile}.json").iFile
CONTROLS = glob_wildcards(config["src_data_specs"] +
            "subset_no_high_school_{iFile}.json").iFile
CONTROLS.remove('miami')                    # remove miami from


# --- Build Rules --- #
rule all:
    input:
        graph = expand(config["out_figures"] +
                    "trend_log_wage_no_hs_vs_{iControl}.pdf",
                    iControl= CONTROLS),
        data_fig = expand(config["out_data"] +
                    "cps_trend_{iSubset}.csv",
                    iSubset= SUBSETS),
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
#
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
        script      = config["src_figures"] + "plot_trend.R",
        data_miami  = config["out_data"] + "cps_trend_no_high_school_miami.csv",
        data_control= config["out_data"] + "cps_trend_no_high_school_{iControl}.csv"
    output:
        fig         = config["out_figures"] + "trend_log_wage_no_hs_vs_{iControl}.pdf"
    log:
        config["log"] + "plot_trend_log_wage_no_hs_miami_vs_{iControl}.Rout"
    shell:
        "Rscript {input.script} \
            --data_miami {input.data_miami} \
            --data_control {input.data_control} \
            --out {output.fig} > {log} {LOGALL}"

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
