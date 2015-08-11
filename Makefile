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

REFERENCES = personal_property_references real_property_references

REMARKS = personal_property_remarks real_property_remarks

IDX_document_control_codes = doctype
IDX_country_codes          = countrycode
IDX_property_type_codes    = propertytype
IDX_ucc_collateral_codes   = ucccolleralcode

IDX_documentid = personal_property_legals \
	personal_property_master \
	personal_property_parties \
	real_property_legals \
	real_property_master \
	real_property_parties \
	real_property_remarks \
	personal_property_remarks

DATABASE = acris
PASS = 
MYSQL = mysql --user='$(USER)' -p$(PASS)

.PHONY: all real personal more create clean install download index-% mysql-%

all: real

real: $(foreach a,$(TABLES),index-$a)

personal: $(foreach a,$(PERSONAL),index-$a)

references: $(foreach a,$(REFERENCES),index-$a)

remarks: $(foreach a,$(REMARKS),index-$a)

download: $(foreach a,$(TABLES),$a.csv)

index-country_codes index-document_control_codes index-property_type_codes index-ucc_collateral_codes: index-%: mysql-%
	$(MYSQL) --execute "ALTER TABLE $(DATABASE).$* ADD INDEX $*_idx $(IDX_$*)"

$(addprefix index-,$(IDX_documentid)): index-%: mysql-%
	$(MYSQL) --execute "ALTER TABLE $(DATABASE).$* ADD INDEX $*_did (documentid)"

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
# Dedupe files using sort because uniq seems to choke on 1GB+ files
%.csv: %.raw
	sort --unique --reverse $< | \
	sed -e 's/,\([01][0-9]\)\/\([0123][0-9]\)\/\([0-9]\{4\}\)/,\3-\1-\2/g' > $@

.INTERMEDIATE: %.raw
%.raw:
	curl --compressed -o $@ https://data.cityofnewyork.us/api/views/$($*)/rows.csv?accessType=DOWNLOAD

create: ; $(MYSQL) --execute "CREATE DATABASE IF NOT EXISTS $(DATABASE)"

clean: ; $(MYSQL) --execute "DROP DATABASE IF EXISTS $(DATABASE)"

install: ; pip install $(INSTALLFLAGS) csvkit
