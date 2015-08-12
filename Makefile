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

PERSONAL_BASIC = personal_property_legals \
	personal_property_master \
	personal_property_parties \

REAL_BASIC = real_property_legals \
	real_property_master \
	real_property_parties

PERSONAL_REF = personal_property_references personal_property_remarks

REAL_REF = real_property_references real_property_remarks

EXTRAS = country_codes \
	document_control_codes \
	property_type_codes \
	ucc_collateral_codes

IDX_document_control_codes = doctype
IDX_country_codes          = countrycode
IDX_property_type_codes    = propertytype
IDX_ucc_collateral_codes   = ucccollateralcode

IDX_personal_property_legals  = documentid
IDX_personal_property_master  = documentid
IDX_personal_property_parties = documentid
IDX_personal_property_remarks = documentid

IDX_real_property_legals  = documentid
IDX_real_property_master  = documentid
IDX_real_property_parties = documentid
IDX_real_property_remarks = documentid

DATABASE = acris
PASS = 
SQL = mysql --user='$(USER)' -p$(PASS)

f = data

.PHONY: all real_property personal_property create clean install download

all: $(foreach a,$(REAL_BASIC) $(EXTRAS),$f/$a.mysql)

real_complete: all $(foreach a,$(REAL_REF),$f/$a.mysql)

personal: $(foreach a,$(PERSONAL_BASIC) $(EXTRAS),$f/$a.mysql)

personal_complete: personal $(foreach a,$(PERSONAL_REF),$f/$a.mysql)

download: $(foreach a,$(REAL_BASIC) $(EXTRAS),$f/$a.csv)

$f/%.mysql: $f/%.csv $f/%.sql | create
	$(SQL) --execute "DROP TABLE IF EXISTS $(DATABASE).$*;"
	$(SQL) --database $(DATABASE) < $(word 2,$^)
	$(SQL) --execute "ALTER TABLE $(DATABASE).$* ADD INDEX $*_idx ($(IDX_$*))"

	$(SQL) --execute "LOAD DATA LOCAL INFILE '$<' INTO TABLE $(DATABASE).$* \
	FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n' IGNORE 1 LINES"

	@touch $@

$f/%.sql: $f/%.csv
	head -n 4096 $< | csvsql -i mysql --tables $* > $@

# Try to get pretty column names by deleting spaces, periods, slashes, replacing '%' with 'perc'.
# replace MM/DD/YYYY with YYYY-MM-DD
# Dedupe files using sort because uniq seems to choke on 1GB+ files
$f/%.csv: $f/%.raw
	{ head -n 1 $< | \
	awk '{ gsub(/[ \.\/]/, ""); gsub("%", "perc"); gsub("\#", "nbr"); print tolower; }' ; \
	tail -n+2 $< | \
	sort --unique | \
	sed -e 's/,\([01][0-9]\)\/\([0123][0-9]\)\/\([0-9]\{4\}\)/,\3-\1-\2/g' ; \
	} > $@

.INTERMEDIATE: $f/%.raw
$f/%.raw: | $f
	curl -o $@ https://data.cityofnewyork.us/api/views/$($*)/rows.csv?accessType=DOWNLOAD

$f: ; mkdir -p $@

create: ; $(SQL) --execute "CREATE DATABASE IF NOT EXISTS $(DATABASE)"

clean:
	$(SQL) --execute "DROP DATABASE IF EXISTS $(DATABASE)"
	rm -rf data

install: requirements.txt
	pip install $(INSTALLFLAGS) --requirement=$<
