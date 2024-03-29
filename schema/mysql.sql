BEGIN;

CREATE TABLE IF NOT EXISTS country_codes (
    recordtype varchar(1),
    countrycode varchar(2),
    countrydescription text
);

CREATE TABLE IF NOT EXISTS document_control_codes (
    recordtype text,
    doctype varchar(4),
    doctypedescription text,
    classcodedescription text,
    party1type text,
    party2type text,
    party3type text
);

CREATE TABLE IF NOT EXISTS property_type_codes (
    recordtype text,
    propertytype varchar(2) not null,
    typedescription text
);

CREATE TABLE IF NOT EXISTS real_property_legals (
    documentid varchar(18) not null,
    recordtype text,
    borough integer,
    block integer,
    lot integer,
    easement boolean,
    partiallot text,
    airrights boolean,
    subterraneanrights boolean,
    propertytype text,
    streetnumber text,
    streetname text,
    unit text,
    goodthroughdate text
);

CREATE TABLE IF NOT EXISTS real_property_master (
    documentid varchar(18) not null,
    recordtype text,
    crfn bigint,
    borough integer,
    doctype text,
    docdate text,
    docamount numeric,
    recordedfiled text,
    modifieddate text,
    reelyear integer,
    reelnbr integer,
    reelpage integer,
    perctransferred numeric,
    goodthroughdate text
);

CREATE TABLE IF NOT EXISTS real_property_parties (
    documentid varchar(18) not null,
    recordtype text,
    partytype integer,
    name text,
    address1 text,
    address2 text,
    country tinytext,
    city text,
    state tinytext,
    zip text,
    goodthroughdate text
);

CREATE TABLE IF NOT EXISTS real_property_references (
    documentid varchar(18) not null,
    recordtype text,
    referencebycrfn text,
    referencebydocid text,
    referencebyreelyear integer,
    referencebyreelborough integer,
    referencebyreelnbr integer,
    referencebyreelpage integer,
    not_used_1 boolean,
    not_used_2 boolean,
    goodthroughdate timestamp
);

CREATE TABLE IF NOT EXISTS ucc_collateral_codes (
    recordtype text,
    ucccollateralcode char(1),
    codedescription text
);

COMMIT;
