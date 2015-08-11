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


