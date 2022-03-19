# Acuitas Utilities Package

A collection of convenience packages for Acuitas employees. Probably not useful if you don't work for Acuitas Health. You can install this package with: `remotes::install_github("acuitas-health/ahUtils")` from within R. Or, if you have cloned the repo, you can install via make using `make install`.

Either way, install this package from GitHub or it will not work on RStudio Connect.

Although intended for use by Acuitas Health staff, others are welcome to use this package or grab any bits of code from it which may be useful to them. Several of the functions here, such as `import_data()` and `open_con()` are theoritically generic but they rely on templates which are not available publicly and require specific variables to be in the project config.yml and the user's .Renviron file.

## Provided Functions:

Full documentation is available for each function after loading the package with `library(ahUtils).

- `app_control`: Should the app/report run? Sets global variables run_flag and email_flag. If there are warnings/errors, it will also create some text output for the user/report. This is technically a terrible function because it is all about the side effects.
- `clean_stratifications()`: The stratification columnn is used to name output files. This function cleans these names of special characters which could cause problems in a file name.
- `extract_urls()`: Extracts URLs from a string.
- `find_strat_col()`: Finds the stratification column in `data` based on the
  settings in config.yml.
- `get_stratifications()`: Extracts the unique list of stratification values
  from the stratification column.
- `import_data()`: Imports data from a SQL query. Uses config.yml and .Renviron
  for all parts of the connection.
- `open_con()`: Creates a DBI connection object. This function is used
  internally of `import_data()` but can be used separately as well. Uses
  config.yml and .Renviron for all parts of the connection.
- `read_description()`: Reads a R DESCRIPTION file and extracts dependencies.
- `report_config`: Returns a tibble of report configurations for inclusion in reports.
- `send_email()`: Sends emails to people in the recipients list.
- `set_config_value()`: Sets the value of any parameter in a config.yml file.
- `validate_config()`: Validates an Acuitas config.yml. Tries to prevent errors
  such as inappropriate values, missing parameters, etc.
