# Testing environment

## Introduction

These are scripts to help run tests

## Preparation

To use GNOS put your token key in `etc/keyfile.txt` since that is where my scripts will try to find it

### Download the DKFZ resources

```sh
bin/get_dkfz_resources.sh
```

### Download the Test data

Dowload the test sample HCC1143 and place it in the data directory

```sh
bin/get_test_resources.sh
```
### Get Donor using ICGC

Go to [https://dcc.icgc.org](https://dcc.icgc.org) query for a donor e.g. [DO50398](https://dcc.icgc.org/donors/DO50398). Find the files from the
table of files with `Data Type` *Aligned Reads* and `Strategy` *WGS* e.g. [FI31031](https://dcc.icgc.org/repositories/files/FI31031) and follow the link.
Get the `Object ID` e.g. e09a49a8-6381-55ca-ad62-46290e5b7590. Then type the following command

```sh
bin/get_icgc_donor.sh DO50398 e09a49a8-6381-55ca-ad62-46290e5b7590 78d071c5-a0f5-5bd1-8e05-9850bf326e93
```

IMPORTANT: Make sure you put the Tumor Object ID first and the Normal Object ID second

ERROR: This now raises an error:

```
ERROR: Command error: Unrecognized field "projectCode" (class org.icgc.dcc.storage.client.metadata.Entity), not marked as ignorable (4 known properties: "id", "createdTime", "gnosId", "fileName"])
 at [Source: https://meta.icgc.org/entities/e09a49a8-6381-55ca-ad62-46290e5b7590; line: 1, column: 159] (through reference chain: org.icgc.dcc.storage.client.metadata.Entity["projectCode"])
```

### Get Donor using GNOS

Go to [https://dcc.icgc.org](https://dcc.icgc.org) query for a donor e.g. [DO50398](https://dcc.icgc.org/donors/DO50398). Find the files from the
table of files with `Data Type` *Aligned Reads* and `Strategy` *WGS* e.g. [FI31031](https://dcc.icgc.org/repositories/files/FI31031) and follow the link.
Get the `Submitter Bundle ID` e.g. e09a49a8-6381-55ca-ad62-46290e5b7590. Then type the following command

```sh
bin/get_gnos_donor.sh DO50398 e09a49a8-6381-55ca-ad62-46290e5b7590 78d071c5-a0f5-5bd1-8e05-9850bf326e93
```

IMPORTANT: Make sure you put the Tumor Submitter Bundle ID first and the Normal Submitter Bundle ID second

ERROR: This now raises an error:

```
ERROR: Command error: Unrecognized field "projectCode" (class org.icgc.dcc.storage.client.metadata.Entity), not marked as ignorable (4 known properties: "id", "createdTime", "gnosId", "fileName"])
 at [Source: https://meta.icgc.org/entities/e09a49a8-6381-55ca-ad62-46290e5b7590; line: 1, column: 159] (through reference chain: org.icgc.dcc.storage.client.metadata.Entity["projectCode"])
```

## Run the test

Decide on the workflow and sample. Workflows are Sanger, DKFZ, and Delly, and samples can be the test sample HCC1143 or any of the donors you prepared

```sh
bin/run_test.sh DKFZ HCC1143
```

or

```sh
bin/run_test.sh Delly DO50398
```

The results will be under `tests/<workflow>/<sample>/output/<sample>.*` for example `tests/Sanger/HCC1143/output/HCC1143.somatic.snv.mnv.tar.gz`

IMPORTANT: I still havent worked out what the `*.bedpe*` file is for DKFZ exactly is and how to produce it
