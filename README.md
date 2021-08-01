# Thompson Sampling for RI Text Messages

## Requirements

### Software

To run the code in this repository, you will need Python 3.8+ and R 4.0.2+ pre-installed.

In Python, we use [`poetry`](https://python-poetry.org/) to manage our dependencies. In R, we use [`renv`](https://rstudio.github.io/renv/articles/renv.html).
To install these dependency managers, you can run (assumes Mac or Linux; see tools' documentation for other operating systems):

```bash
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 -
Rscript -e 'if(!requireNamespace("remotes")){install.packages("remotes");remotes::install_github("rstudio/renv")} else {remotes::install_github("rstudio/renv")}'
```

Once these are installed, you can install all dependencies with

```bash
poetry install
Rscript -e 'renv::restore()'
```

Alternatively, the included `Dockerfile` will create a working environment with all these dependencies already installed.

### Census API

In order to run some of this code, you will also need a [Census API Key](https://api.census.gov/data/key_signup.html). Once you have the key, copy the `.env.sample` file to `.env` and fill in your API key in the specified location.

## Code layout

Our code can generally be divided into four sections:
* Random sampling strategy
* Preparation of data for analysis
* Actual analysis
* Tests

The first two take place in Jupyter notebooks using Python (`src/notebooks/100_sampling` and `src/notebooks/200_analysis`). The last takes place in R at `src/R`.

### 100_sampling

To recreate our week-over-week sampling strategy, run the notebooks in `src/notebooks/100_sampling`. These may be accessed through a Jupyter notebook
which you can start by running `poetry run jupyter notebook`.

### 200_analysis

To recreate our data preparation, run the notebooks in `src/notebooks/200_analysis`. These may be accessed through a Jupyter notebook
which you can start by running `poetry run jupyter notebook`.

### 300_wrangling

There is a little bit of prework to convert the output of the Python scripts to that expected by the R scripts. This is automatically run by `make all`.

### 400_analysis

To make the report and all associated figures (each in their own file `src/R/400_analysis/output`). These are all automatically run by `make all`.

See the `Makefile` for the dependencies between files.

### Tests

Several tests have been written in the `tests` folder. They may be run with `poetry run py.test`.

## License

MIT
