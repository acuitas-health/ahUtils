# Acuitas Ad Hoc Template Package

The actual template is available here:
https://gitlab.com/acuitas-health/ad-hoc-template

You can install this package with:
`devtools::install_gitlab("acuitas-public/acuitasadhoc")` from within R. Or, if
you have the template downloaded, `make install_custom_packages` from the shell.
The latter is possibly safer, because it ALSO makes sure you have devtools
installed because you can't install this without devtools, sorry.

`devtools::install_github("Choens/acuitasadhoc")`

This package provides useful support functions for the Acuitas Ad Hoc Template.

## Useful SQL Queries

I legit need to find a better place for these . . . . 


Create the table in Dev and Prod:

```sql
DROP TABLE AHDSSandbox.dbo.ReportsEmailLog

CREATE TABLE AHDSSandbox.dbo.ReportsEmailLog (
    date_sent date NULL,
    customer varchar(255) NULL,
    report varchar(255) NULL,
    report_description varchar(1024) NULL,
    stratification varchar(255) NULL,
    report_name varchar(512) NULL,
    recipient varchar(512) NULL,
    created_dt date NULL,
    sent int NULL
);
```

And to look at what we've got:

```sql
select * from AHDSSandbox.dbo.ReportsEmailLog rel
```

And to delete all the data:

```sql
delete from AHDSSandbox.dbo.ReportsEmailLog;
```
