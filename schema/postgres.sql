BEGIN;

CREATE SCHEMA IF NOT EXISTS :schema;

SET search_path TO :schema;

CREATE TABLE IF NOT EXISTS country_codes (
    recordtype text,
    countrycode text,
    countrydescription text
);

CREATE TABLE IF NOT EXISTS document_control_codes (
    recordtype text,
    doctype text,
    doctypedescription text,
    classcodedescription text,
    party1type text,
    party2type text,
    party3type text
);

CREATE TABLE IF NOT EXISTS property_type_codes (
    recordtype text,
    propertytype text,
    typedescription text
);

CREATE TABLE IF NOT EXISTS real_property_legals (
    documentid bigint,
    recordtype text,
    borough int,
    block int,
    lot int,
    easement boolean,
    partiallot text,
    airrights boolean,
    subterraneanrights boolean,
    propertytype text,
    streetnumber text,
    streetname text,
    unit text,
    goodthroughdate date
);

CREATE TABLE IF NOT EXISTS real_property_master (
    documentid bigint not null,
    recordtype text,
    crfn bigint,
    borough integer,
    doctype text,
    docdate date,
    docamount numeric,
    recordedfiled date,
    modifieddate date,
    reelyear int,
    reelnbr int,
    reelpage int,
    perctransferred numeric,
    goodthroughdate date
);

CREATE TABLE IF NOT EXISTS real_property_parties (
    documentid bigint,
    recordtype text,
    partytype integer,
    name text,
    address1 text,
    address2 text,
    country text,
    city text,
    state text,
    zip text,
    goodthroughdate date
);

CREATE TABLE IF NOT EXISTS real_property_references (
    documentid bigint,
    recordtype text,
    referencebycrfn text,
    referencebydocid text,
    referencebyreelyear integer,
    referencebyreelborough integer,
    referencebyreelnbr integer,
    referencebyreelpage integer,
    not_used_1 boolean,
    not_used_2 boolean,
    goodthroughdate timestamp without time zone
);

CREATE TABLE IF NOT EXISTS ucc_collateral_codes (
    recordtype text,
    ucccollateralcode text,
    codedescription text
);

COMMIT;
