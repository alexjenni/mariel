# Replicate Borjas Figure 2 and parts of Figures 3a and Table 5a

## What this repo does

We replicate (roughly) some figures and difference-in-difference estimates from _The wage impact of the Marielitos: a reappraisal_ (Borjas, 2015). The replicated results are:
 1. Figure 2
 2. The Card placebo and Miami series in Figure 3A
 3. Columns "Card placebo" and "All cities" of Table 5A of the working paper.

In addition to those results, which are computed using the subsample of high-school dropouts, we also provide analogous results for high-school graduates. We do not replicate exactly the original coefficients because we use a different reference year for the Consumer Price Index (CPI) and are not able to reproduce exactly some of the sample restrictions of the original study. Nevertheless, the results are quantitatively very similar.

You can find the original paper in doc/Borjas_2015_WP.

Our weapons of choice are:

* `Snakemake` to manage the build and dependencies
* `R` for statistical analysis
* `LaTeX` to compile the paper in a pdf document

## How to Build this repo
Download the repository onto your computer. Then, download the raw dataset (cps_77-93.csv) from https://www.dropbox.com/s/2cxjtqgxmdeclke/cps_77-93_men.csv?dl=0 and place it in *src/data*.

If you have Snakemake, R and LaTeX installed, navigate your terminal to this directory.

### Installing Missing R packages

To ensure all R libraries are installed, type

```
snakemake install_packages
```
into a your terminal and press `RETURN`.

If you modify the packages used in this repo, you should rerun this command to store package updates in the `REQUIREMENTS.txt`.

### Building the Output
Type:

```
snakemake
```

into your terminal and press `RETURN`

This will build the project to completion. The output is our wonderful paper alex_miriam_pp4rs_assignment.pdf.

## Install instructions

### Installing `R`

* Install the latest version of `R` by following the instructions
  [here](https://pp4rs.github.io/installation-guide/r/).

### Installing `Snakemake`

This project uses `Snakemake` to execute our research workflow.
You can install snakemake as follows:
* Install Snakemake from the command line (needs pip, and Python)
    ```
    pip install snakemake
    ```
    * If you haven't got Python installed click [here](https://pp4rs.github.io/installation-guide/python/) for instructions

* Windows and old Mac OSX users: you may need to manually install the `datrie` package if you are getting errors. Using conda, this seems to work best:

    ```
    conda install datrie
    ```


### Installing `LaTeX`

* For users who don't have `LaTeX` on their computer, we recommend to install the latest version of `TinyTeX` by by opening `RStudio` and entering the following in the console:
    ```
    install.packages("tinytex")
    tinytex::install_tinytex()  # install TinyTeX
    ```

## References
Borjas, George J. The Wage Impact of the Marielitos: A Reappraisal. No. w21588. _National Bureau of Economic Research_, 2015.
