ACRIS Downloader
================

This Makefile downloads NYC property transfer data and loads it into a MySQL database.

## Requirements

* csvkit
* mysql

## How to

Download this repository and open the folder in your terminal. Check that you have csvkit installed by typing:

````
which csvsql
````

If the result is blank, install csvkit:

````
make install
````

If that doesn't work, try one of these:

```
sudo make install
pip install --user csvkit
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


