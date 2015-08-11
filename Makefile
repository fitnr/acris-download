# Download slugs for data files on https://data.cityofnewyork.us
real_property_legals     = 8h5j-fqxa
real_property_master     = bnx9-e6tj
real_property_parties    = 636b-3b5g
real_property_references = pwkr-dpni
real_property_remarks    = 9p4w-7npp

personal_property_legals     = uqqa-hym2
personal_property_master     = sv7x-dduq
personal_property_parties    = nbbg-wtuz
personal_property_references = 6y3e-jcrc
personal_property_remarks    = fuzi-5ks9

country_codes          = j2iz-mwzu
document_control_codes = 7isb-wh4c
property_type_codes    = 94g4-w6xz
ucc_collateral_codes   = q9kp-jvxv

TABLES = real_property_legals \
		 real_property_master \
		 real_property_parties \
		 country_codes \
		 document_control_codes \
		 property_type_codes \
		 ucc_collateral_codes

PERSONAL = personal_property_legals \
		   personal_property_master \
		   personal_property_parties \

MORE = real_property_references \
	   real_property_remarks \
	   personal_property_references \
	   personal_property_remarks

DATABASE = acris
PASS = 
MYSQL = mysql --user='$(USER)' -p$(PASS)

.PHONY: all create clean install mysql-%

all: $(foreach a,$(TABLES),mysql-$a)

personal: $(foreach a,$(PERSONAL),mysql-$a)

more: $(foreach a,$(MORE),mysql-$a)

mysql-%: %.csv %.sql | create
	$(MYSQL) --execute "DROP TABLE IF EXISTS $(DATABASE).$*;"
	$(MYSQL) --database $(DATABASE) < $*.sql

	$(MYSQL) --execute "LOAD DATA LOCAL INFILE '$<' INTO TABLE $(DATABASE).$* \
	FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n' IGNORE 1 LINES"

# Try to get pretty column names by deleting spaces, periods, slashes, replacing '%' with 'perc'.
#
%.sql: %.csv
	{ head -n1 $< | perl -pe 's/([A-Z])/\l\1/g' | sed -e 's/[\.\/ ]//g' -e 's/%/perc/g' -e 's/\#/nbr/g' ; \
	tail -n+2 $< | head -n 4096 ; } | \
	csvsql -i mysql --tables $* > $@

# replace MM/DD/YYYY with YYYY-MM-DD
#
%.csv:
	curl --compressed https://data.cityofnewyork.us/api/views/$($*)/rows.csv?accessType=DOWNLOAD | \
	sed -e 's/,\([0-9]\{2\}\)\/\([0-9]\{2\}\)\/\([0-9]\{4\}\)/,\3-\1-\2/g' > $@

create: ; $(MYSQL) --execute "CREATE DATABASE IF NOT EXISTS $(DATABASE)"

clean: ; $(MYSQL) --execute "DROP DATABASE IF EXISTS $(DATABASE)"

install: ; pip install $(INSTALLFLAGS) csvkit
