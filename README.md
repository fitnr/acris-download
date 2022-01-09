ACRIS Downloader
================

This Makefile downloads NYC property transfer data and optionally loads it into a database.

It's designed for people who know how to use databases, but don't necessarily want to slog through downloading huge files, manually setting up a schema and importing the those files.

Currently, SQLite, MySQL and PostGreSQL are supported. If you want to use other database software, you already probably know enough to customize the Makefile. It shouldn't be harder than changing a few flags.

## The data

The ACRIS data set is big and complicated, see `ACRIS Datasets` below for some explanatory notes.

The Department of Finance supposedly updates the online records regularly, so you might use this Makefile, along with a cron job, to regularly update a mirror of their database.

## Requirements

At least 10 GB of free disk space for the data and:

* MySQL, SQLite or PostgreSQL

## Installation

### Local

Download (or `git clone`) this repository and open the folder in your terminal.

## Downloading the data

Run the following command:
````
make download
````

The `data/` folder will slowly fill up with files. Go out for happy hour, this will take some time. If you want to work directly with CSVs, you're done.

### Docker

Dockerfiles are available for both MySQL and PostgreSQL. The most convienient way to run them is probably with the included docker-compose files.
These will write the table data to the `docker/` directory.

```
docker compose -f docker-compose.mysql.yml up
# or
docker compose -f docker-compose.psql.yml up
```

You can choose a particular dataset with the `ACRIS_DATASET`  environment variable, see `docker-compose.mysql.yml` for options, e.g:
```
ACRIS_DATASET=mysql_personal docker-compose -f docker-compose.mysql.yml run --rm acris-download
```

#### Direct DB access
```
docker compose -f docker-compose.mysql.yml up
docker compose exec -it db mysql -ppass
```
```
docker compose -f docker-compose.psql.yml up
docker compose exec -it db psql -U postgres
```

#### PhpMyAdmin access
```
docker-compose up adminer
```

In a browser, go to http://localhost:8080.

When finished with either access method, shut down:

```
docker-compose down
```

To reset the database, delete ./data/mysql/
To reset the downloads, delete ./data/downloads/

## MySQL

Check that you have mysql up and running on your machine, and a user capable of creating databases. Don't use root! You can use these [environment variables](https://dev.mysql.com/doc/refman/8.0/en/environment-variables.html) for setting mysql connection parameters:
- `MYSQL_HOST`
- `MYSQL_DATABASE` - defaults to `acris`
- `MYSQLFLAGS` - add flags to the `mysql` command
- `MYSQL_PWD` (use a [config file](https://dev.mysql.com/doc/refman/8.0/en/option-files.html) instead of this, if possible)

To specify a local user, the config file mentioned above works best. If that's not available, set the `MYSQLFLAGS` environment variable to the user flag, e.g.:
```
export MYSQLFLAGS=-uroot
```

### Commands

````
make mysql
````
This will run the following tasks:
* download the ACRIS real property datasets in CSV format (it will be slow)
* dedupe the CSVs and reformat them slightly
* generate schemas for the new MySQL tables
* Create a new MySQL database (`acris`) and import the data into several tables
* Add indices to sensible fields in each table. You may find it profitable to add more indices yourself.

If the downloads are interrupted, just run the command again. That's the power of make!

By default, only the real property datasets will be downloaded. To download and create tables for the personal property datasets:
```
make mysql_personal
```

The ACRIS dataset also includes voluminous cross-reference and remarks files that aren't downloaded by default. To download them and load into MySQL:
````
make mysql_real_complete
make mysql_personal_complete
````

## SQLite
This command will create `acris.db`, a database containing the real property datasets.
```
make sqlite
```

Download and load even more data into `acris.db`:
````
make sqlite_real_complete
make sqlite_personal_complete
````

## PostgreSQL

Use the standard Postgres environment variables to specify the connection.

```
make psql PGHOST=my.server.com PGUSER=myuser PGDATABASE=mydb
```

By default, the data will be loaded into a schema named `acris`. You can specify another schema with the `PGSCHEMA` environment variable.

Even more:
````
make psql_real_complete
make psql_personal_complete
````

Add custom connection paramaters:
````
make psql_real_complete
````

## Testing

If you want to test your setup without downloading the multi-GB ACRIS datasets, truncated sample data is available in the `tests/` directory. Copy the files in `tests/data/` to `data/` to get a sense of how the process works.

## ACRIS Datasets

(The following is a reformatted version of a [document published by NYC Department of Finance](https://data.cityofnewyork.us/api/assets/D7E1317A-C45E-4617-A593-668E07DA5234?download=true).)

ACRIS has two types of documents:

_Real Property Records_ include documents in the Deeds and Other Conveyance, Mortgages & Instruments and other documents classes in ACRIS. These documents typically impact rights to real property and as such follow the real property rather than an individual.

_Personal Property Records_ include documents in the UCC and Federal Liens class in ACRIS. These documents typically impact rights to personal property associated with real property and as such follow the individual party rather than the real property.

Each _Real Property Record_ or _Personal Property Record_ contains:

-   A master record
-   Zero or more lot(property) records
-   Zero or more party records
-   Zero or more cross-reference records
-   Zero or more remarks records

The `Document ID` in the master record is used to link all other record types to a master record. To find all of the lot (property) records associated with a master record, simply retrieve all records in the
property dataset with the same “Document ID” as the selected master record. The same process should be repeated for Party, Cross Reference and Remark records.

### Real property records

- [Real Property Master](http://data.cityofnewyork.us/City-Government/ACRIS-Real-Property-Master/bnx9-e6tj) (document details)
- [Real Property Legals](http://data.cityofnewyork.us/City-Government/ACRIS-Real-Property-Legals/8h5j-fqxa) (property details)
- [Real Property Parties](http://data.cityofnewyork.us/City-Government/ACRIS-Real-Property-Parties/636b-3b5g)  (party names and addresses)
- [Real Property References](http://data.cityofnewyork.us/City-Government/ACRIS-Real-Property-References/pwkr-dpni)
- [Real Property Remarks](http://data.cityofnewyork.us/City-Government/ACRIS-Real-Property-Remarks/9p4w-7npp)

### Personal property records

- [Personal Property Master](http://data.cityofnewyork.us/City-Government/ACRIS-Personal-Property-Master/sv7x-dduq) (document details)
- [Personal Property Legals](http://data.cityofnewyork.us/City-Government/ACRIS-Personal-Property-Legals/uqqa-hym2) (property details)
- [Personal Property Parties](http://data.cityofnewyork.us/City-Government/ACRIS-Personal-Property-Parties/nbbg-wtuz) (party names and addresses)
- [Personal Property References](http://data.cityofnewyork.us/City-Government/ACRIS-Personal-Property-References/6y3e-jcrc)
- [Personal Property Remarks](http://data.cityofnewyork.us/City-Government/ACRIS-Personal-Property-Remarks/fuzi-5ks9)

### Code mappings

In ACRIS, documents are stored with codes representing longer descriptions that are displayed on images generated by ACRIS and in Document Search. The translation from these codes is done via the following code look up tables:

- [Document Control Codes](http://data.cityofnewyork.us/City-Government/ACRIS-Document-Control-Codes/7isb-wh4c) - codes in the real and personal property master datasets
- [UCC Collateral Codes](http://data.cityofnewyork.us/City-Government/ACRIS-Country-Codes/j2iz-mwzu) - codes in the personal property master dataset
- [Property Types Codes](http://data.cityofnewyork.us/City-Government/ACRIS-Property-Types-Codes/94g4-w6xz) - codes in the personal and real property legals datasets
- [States Codes](http://data.cityofnewyork.us/City-Government/ACRIS-States-Codes/5c9e-33xj) - codes in the real and personal parties property datasets
- [Country Codes](http://data.cityofnewyork.us/City-Government/ACRIS-UCC-Collateral-Codes/q9kp-jvxv) - codes in the real and personal parties property datasets

## Example query

This example query selects all the transactions for a particular property in Brooklyn. Multiple joins are required to the `real_property_parties` table, as there are two (or more) parties per transaction.

```mysql
SELECT
    streetnumber,
    streetname,
    documentid,
    c.description,
    m.recordtype,
    d.doctypedescription,
    docdate,
    docamount,
    d.party1type,
    p1.name party1name,
    d.party2type,
    p2.name party2name
FROM real_property_legals a
    LEFT JOIN real_property_master m USING (documentid)
    LEFT JOIN real_property_parties p1 USING (documentid)
    LEFT JOIN real_property_parties p2 USING (documentid)
    LEFT JOIN property_type_codes c USING (propertytype)
    LEFT JOIN document_control_codes d USING (doctype)
WHERE a.lot = 65
    AND a.borough = 3
    AND a.block = 429
    and p1.partytype = 1
    AND p2.partytype = 2;
```

## Known issues

There's a bug in how csvkit <=0.9.1 handles fields that contain only the letter 'A' - they're converted into dates. This will break the recordtype column in certain tables.

## License

[General Public License version 3](https://www.gnu.org/licenses/gpl.html)
