ACRIS Downloader
================

This Makefile downloads NYC property transfer data and loads it into a MySQL database.

It's designed for people who know how to use MySQL, but don't necessarily want to slog through downloading huge files, manually setting up a schema and importing the those files.

The Department of Finance supposedly updates the online records regularly, you might use this Makefile, along with a cron job, to regularly update a mirror of their database.

If you want to use other database software, you already probably know enough to customize the Makefile. It shouldn't be harder than changing a few flags.

## Requirements

At least 10 GB of free disk space for the data and:

* [csvkit](http://csvkit.readthedocs.org)
* MySQL

## Installation

Download this repository and open the folder in your terminal.

See below for more detailed installation instructions.

## Downloading the data

Check that you have mysql up and running on your machine, and a user capable of creating databases. Don't use root!

Run the following command:
````
$ make USER=myuser PASS=mypass
````

(If you don't want to type your password in plaintext, you can leave off the PASS argument. You'll just have to enter your password many times.)

This will run the following tasks:
* download the ACRIS real property datasets in CSV format (it will be slow)
* dedupe the CSVs and reformat them slightly
* generate schemas for the new MySQL tables
* Create a new MySQL database (`acris`) and import the data into several tables
* Add indices to sensible fields in each table. You may find it profitable to add more indices yourself.

If the downloads are interrupted, just run the command again. That's the power of make!

By default, only the real property datasets will be downloaded. To download and create tables for the personal property datasets:
```
$ make personal USER=myuser PASS=mypass
```

To only download the real property data without loading it into MySQL:
````
$ make download
````

The ACRIS dataset also includes voluminous cross-reference and remarks files that aren't downloaded by default. To download them and load into MySQL:
````
$ make real_complete USER=mysqluser PASS=mysqlpass
$ make personal_complete USER=mysqluser PASS=mysqlpass
````

### Using an existing database

If you want to add the data to tables in an existing database, run:
````
$ make DATABASE=mydb USER=myuser PASS=mypass
````

If you have other connection requirements:
````
$ make DATABASE=mydb USER=myuser PASS=mypass SQLFLAGS="--host=example.com --port=123"
````

## Known issues

There's a bug in how csvkit <=0.9.1 handles fields that contain only the letter 'A' - they're converted into dates. This will break the recordtype column in certain tables.

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

## Installing Prerequisites

If you don't have MySQL installed, [start here](https://dev.mysql.com/doc/refman/5.5/en/osx-installation.html).

To install csvkit, follow the instructions in the [csvkit docs](http://csvkit.readthedocs.org), or try one of these:

```
# If you have admin privileges
$ sudo make install

# If you don't have admin privileges. Might not work.
$ make install INSTALLFLAGS=--user
```

## License

[General Public License version 3](https://www.gnu.org/licenses/gpl.html)
