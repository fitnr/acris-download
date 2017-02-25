# ACRIS downloader
# Make tasks for downloading real estate property transactions from NYC's open data site
# Copyright (C) 2015-16 Neil Freeman

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

API = https://data.cityofnewyork.us/api/views

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

DATA = $(EXTRAS) \
	$(PERSONAL_BASIC) \
	$(PERSONAL_REF) \
	$(REAL_BASIC) \
	$(REAL_REF)

RAWS = $(foreach a,$(DATA),data/$a.raw)

IDX_document_control_codes = doctype
IDX_country_codes          = countrycode
IDX_property_type_codes    = propertytype
IDX_ucc_collateral_codes   = ucccollateralcode

IDX_personal_property_legals  = documentid
IDX_personal_property_master  = documentid
IDX_personal_property_parties = documentid
IDX_personal_property_references = documentid
IDX_personal_property_remarks = documentid

IDX_real_property_legals  = documentid
IDX_real_property_master  = documentid
IDX_real_property_parties = documentid
IDX_real_property_references = documentid
IDX_real_property_remarks = documentid

DATABASE = acris

HOST = localhost
PASSFLAG = -p

MYSQL = mysql -u '$(USER)' $(PASSFLAG)$(PASS) -h $(HOST) $(MYSQLFLAGS)

PSQL = psql -U "$(USER)" $(PSQLFLAGS)

SQLITE = sqlite3 $(DATABASE).db

CSVSQLFLAGS = --tables $* --no-constraints --no-inference

CURLFLAGS = --progress-bar

.PHONY: clean install download \
	sqlite sqlite_% \
	psql psql_% \
	mysql mysql_%

download: $(foreach a,$(REAL_BASIC) $(EXTRAS),data/$a.csv)

sqlite: $(foreach a,$(REAL_BASIC),sqlite_$a) | sqlite_extras
sqlite_real_complete: $(foreach a,$(REAL_REF),sqlite_$a) | sqlite
sqlite_personal: $(foreach a,$(PERSONAL_BASIC),sqlite_$a) | sqlite_extras
sqlite_personal_complete: $(foreach a,$(PERSONAL_REF),sqlite_$a) | sqlite_personal
sqlite_extras: $(foreach a,$(EXTRAS),sqlite_$a)

mysql: $(foreach a,$(REAL_BASIC),mysql_$a) | mysql_extras
mysql_real_complete: $(foreach a,$(REAL_REF),mysql_$a) | mysql
mysql_personal: $(foreach a,$(PERSONAL_BASIC),mysql_$a) | mysql_extras
mysql_personal_complete: $(foreach a,$(PERSONAL_REF),mysql_$a) | mysql_personal
mysql_extras: $(foreach a,$(EXTRAS),mysql_$a)

psql: $(foreach a,$(REAL_BASIC),psql_$a) | psql_extras
psql_real_complete: $(foreach a,$(REAL_REF),psql_$a) | psql
psql_personal: $(foreach a,$(PERSONAL_BASIC),psql_$a) | psql_extras
psql_personal_complete: $(foreach a,$(PERSONAL_REF),psql_$a) | psql_personal
psql_extras: $(foreach a,$(EXTRAS),psql_$a)

# MySQL
mysql_%: data/%.csv | mysql_create
	$(MYSQL) $(DATABASE) \
		-e "DROP TABLE IF EXISTS $*;"

	head -n1000 $< | \
	csvsql -i mysql --tables $* | \
	mysql $(DATABASE) -u $(USER) -p$(PASS) -h $(HOST)
	
	$(MYSQL) $(DATABASE) \
		-e "ALTER TABLE $* ADD INDEX $*_idx ($(IDX_$*))"

	$(MYSQL) $(DATABASE) -u $(USER) -p$(PASS) -h $(HOST) --local-infile \
		-e "LOAD DATA LOCAL INFILE '$<' INTO TABLE $(DATABASE).$* \
		FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n' \
		IGNORE 1 LINES;"

mysql_create: ; $(MYSQL) -e "CREATE DATABASE IF NOT EXISTS $(DATABASE)"

# SQLite
sqlite_%: data/%.csv
	head -n1000 $< | \
		csvsql $(CSVSQLFLAGS) --db sqlite:///$(DATABASE).db
	$(SQLITE) "CREATE INDEX $*_idx ON $* ($(IDX_$*))"
	tail -n+2 $< | $(SQLITE) -separator , '.import /dev/stdin $*'

# Postgres
psql_%: data/%.csv | psql_create
	head -n1000 $< | \
		csvsql $(CSVSQLFLAGS) --db postgresql://$(USER):$(PASS)@$(HOST)/$(DATABASE)
	tail -n+2 $< | \
		$(PSQL) $(DATABASE) -c "COPY $* FROM STDIN DELIMITER ',' CSV QUOTE '\"';"

psql_create:
	$(PSQL) -c "CREATE DATABASE $(DATABASE)" || echo "$(DATABASE) probably exists"

# Data download
# Try to get pretty column names by deleting spaces, periods, slashes, replacing '%' with 'perc'.
# replace MM/DD/YYYY with YYYY-MM-DD
# Dedupe files using sort because uniq seems to choke on 1GB+ files
data/%.csv: data/%.raw
	{ \
	head -n1 $< | \
		awk '{ gsub(/[ \.\/]/, ""); sub("%", "perc"); sub("\#", "nbr"); print; }' | \
		tr '[:upper:]' '[:lower:]'; \
	tail -n+2 $< | \
		sort --unique | \
		sed -e 's/,\([01][0-9]\)\/\([0123][0-9]\)\/\([0-9]\{4\}\)/,\3-\1-\2/g'; \
	} > $@

.INTERMEDIATE: data/%.raw
$(RAWS): data/%.raw: | data
	curl $(CURLFLAGS) -G -L -o $@ $(API)/$($*)/rows.csv -d accessType=DOWNLOAD

data: ; mkdir -p $@

mysql_clean: | clean
	$(MYSQL) -e "DROP DATABASE IF EXISTS $(DATABASE)"

sqlite_clean: | clean
	rm -rf data $(DATABASE).db

psql_clean: | clean
	$(PSQL) -c "DROP DATABASE $(DATABASE)"

clean: ; rm -rf data

install: requirements.txt
	pip install $(INSTALLFLAGS) --requirement=$<
