ACRIS Downloader
================

This Makefile downloads NYC property transfer data and loads it into a MySQL database.

It's designed for people who know how to use MySQL, but don't necessarily want to slog through downloading huge files, manually setting up a schema and importing the those files.

The Department of Finance supposedly updates the online records regularly, you might use this Makefile, along with a cron job, to regularly update a mirror of their database.

If you want to use another database, you already probably know enough to edit the Makefile.

## Requirements

* [csvkit](http://csvkit.readthedocs.org)
* MySQL

## Installing

(If you don't have MySQL installed, [start here](https://dev.mysql.com/doc/refman/5.5/en/osx-installation.html))

Download this repository and open the folder in your terminal. Check that you have csvkit installed by typing:

````
$ which csvsql
````

If the result is blank, install csvkit:

````
$ make install
````

If that doesn't work, try one of these or follow the instructions in the [csvkit docs](http://csvkit.readthedocs.org):

```
$ sudo make install
$ make install INSTALLFLAGS=--user
```

## Downloading the data

Check that you have mysql up and running on your machine, and a user capable of creating databases.

Run the following command:

````
make USER=mysqluser PASS=mysqlpass
````

This will download the ACRIS database (it will be slow), and then import it into SQL.

By default, only the master list of transactions and the parties files will be downloaded. To download the the remarks, references and legal tables, use:

```
make more USER=mysqluser PASS=mysqlpass
```
Read on for the distinction between real and personal property datasets.


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

Master record            [ACRIS - Real Property Master](http://data.cityofnewyork.us/City-Government/ACRIS-Real-Property-Master/bnx9-e6tj)
Document Details for Real Property Related Documents Recorded in ACRIS

Lot(property) record     [ACRIS - Real Property Legals](http://data.cityofnewyork.us/City-Government/ACRIS-Real-Property-Legals/8h5j-fqxa)
Property Details for Real Property Related Documents Recorded in ACRIS

Party record             [ACRIS - Real Property Parties](http://data.cityofnewyork.us/City-Government/ACRIS-Real-Property-Parties/636b-3b5g)
Party Names for Real Property Related Documents Recorded in ACRIS

Cross-reference record   [ACRIS - Real Property References](http://data.cityofnewyork.us/City-Government/ACRIS-Real-Property-References/pwkr-dpni)
Document Cross References for Real Property Related Documents Recorded in ACRIS

Remarks record           [ACRIS - Real Property Remarks](http://data.cityofnewyork.us/City-Government/ACRIS-Real-Property-Remarks/9p4w-7npp)
Document Remarks for Real Property Related Documents Recorded in ACRIS

### Personal property records

Master record            [ACRIS - Personal Property Master](http://data.cityofnewyork.us/City-Government/ACRIS-Personal-Property-Master/sv7x-dduq)
Document Details for Personal Property Related Documents Recorded in ACRIS

Lot(property) record     [ACRIS - Personal Property Legals](http://data.cityofnewyork.us/City-Government/ACRIS-Personal-Property-Legals/uqqa-hym2)
Property Details for Personal Property Related Documents Recorded in ACRIS

Party record             [ACRIS - Personal Property Parties](http://data.cityofnewyork.us/City-Government/ACRIS-Personal-Property-Parties/nbbg-wtuz)
Party Names for Personal Property Related Documents Recorded in ACRIS

Cross-reference record   [ACRIS - Personal Property References](http://data.cityofnewyork.us/City-Government/ACRIS-Personal-Property-References/6y3e-jcrc)
Document Cross References for Personal Property Related Documents Recorded in ACRIS

Remarks record           [ACRIS - Personal Property Remarks](http://data.cityofnewyork.us/City-Government/ACRIS-Personal-Property-Remarks/fuzi-5ks9)
Document Remarks for Personal Property Related Documents Recorded in ACRIS

### Code mappings

In ACRIS, documents are stored with codes representing longer descriptions that are displayed on images generated by ACRIS and in Document Search. The translation from these codes is done via the following code datasets:

[ACRIS - Document Control Codes](http://data.cityofnewyork.us/City-Government/ACRIS-Document-Control-Codes/7isb-wh4c)
ACRIS Document Type and Class Code mappings for Codes in the ACRIS Real and Personal Property Master Datasets

[ACRIS - UCC Collateral Codes](http://data.cityofnewyork.us/City-Government/ACRIS-Country-Codes/j2iz-mwzu)
ACRIS Collateral Type mapping for Codes in the ACRIS Personal Property Master Dataset

[ACRIS - Property Types Codes](http://data.cityofnewyork.us/City-Government/ACRIS-Property-Types-Codes/94g4-w6xz)
ACRIS State mapping for Codes in the ACRIS Real and Personal Property Legals Datasets

[ACRIS - States Codes](http://data.cityofnewyork.us/City-Government/ACRIS-States-Codes/5c9e-33xj)
ACRIS State mapping for Codes in the ACRIS Real and Personal Parties Property Datasets

[ACRIS - Country Codes](http://data.cityofnewyork.us/City-Government/ACRIS-UCC-Collateral-Codes/q9kp-jvxv)
ACRIS Countries mapping for Codes in the ACRIS Real and Personal Parties Property Datasets
