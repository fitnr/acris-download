CREATE TABLE IF NOT EXISTS country_codes (
    recordtype varchar,
    countrycode varchar,
    countrydescription varchar
);

CREATE TABLE IF NOT EXISTS document_control_codes (
    recordtype varchar,
    doctype varchar,
    doctypedescription varchar,
    classcodedescription varchar,
    party1type varchar,
    party2type varchar,
    party3type varchar
);

CREATE TABLE IF NOT EXISTS property_type_codes (
    recordtype varchar,
    propertytype varchar,
    typedescription varchar
);

CREATE TABLE IF NOT EXISTS real_property_legals (
    documentid bigint,
    recordtype varchar,
    borough integer,
    block integer,
    lot integer,
    easement boolean,
    partiallot varchar,
    airrights boolean,
    subterraneanrights boolean,
    propertytype varchar,
    streetnumber varchar,
    streetname varchar,
    unit varchar,
    goodthroughdate date
);

CREATE TABLE IF NOT EXISTS real_property_master (
    documentid bigint not null,
    recordtype varchar,
    crfn bigint,
    borough integer,
    doctype varchar,
    docdate date,
    docamount numeric,
    recordedfiled date,
    modifieddate date,
    reelyear integer,
    reelnbr integer,
    reelpage integer,
    perctransferred numeric,
    goodthroughdate date
);

CREATE TABLE IF NOT EXISTS real_property_parties (
    documentid bigint,
    recordtype varchar,
    partytype integer,
    name varchar,
    address1 varchar,
    address2 varchar,
    country varchar,
    city varchar,
    state varchar,
    zip varchar,
    goodthroughdate date
);

CREATE TABLE IF NOT EXISTS real_property_references (
    documentid bigint,
    recordtype varchar,
    referencebycrfn varchar,
    referencebydocid varchar,
    referencebyreelyear integer,
    referencebyreelborough integer,
    referencebyreelnbr integer,
    referencebyreelpage integer,
    not_used_1 boolean,
    not_used_2 boolean,
    goodthroughdate timestamp
);

CREATE TABLE IF NOT EXISTS ucc_collateral_codes (
    recordtype varchar,
    ucccollateralcode varchar,
    codedescription varchar
);
