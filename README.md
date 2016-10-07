# Testing environment

## Introduction

These are scripts to help run tests

## Preparation

To use GNOS put your token key in `etc/keyfile.txt` since that is where my scripts will try to find it. For the ICGC download client put your token into the ```icgc-storage-client-1.0.19/conf/application.properties``` file

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

### Get Donor using GNOS

Go to [https://dcc.icgc.org](https://dcc.icgc.org) query for a donor e.g. [DO50398](https://dcc.icgc.org/donors/DO50398). Find the files from the
table of files with `Data Type` *Aligned Reads* and `Strategy` *WGS* e.g. [FI31031](https://dcc.icgc.org/repositories/files/FI31031) and follow the link.
Get the `Submitter Bundle ID` e.g. 136d60db-bd21-4fbc-9a28-59ea70c06f27. Then type the following command

```sh
bin/get_gnos_donor.sh DO50398 136d60db-bd21-4fbc-9a28-59ea70c06f27 0bef43a2-352a-42c6-99ff-d97e2675a527
```

IMPORTANT: Make sure you put the Tumor Submitter Bundle ID first and the Normal Submitter Bundle ID second

## Run the test

Decide on the workflow and sample. Workflows are Sanger, DKFZ, and Delly, and samples can be the test sample HCC1143 or any of the donors you prepared

```sh
bin/run_test.sh DKFZ HCC1143
```

or

```sh
bin/run_test.sh Delly DO50398
```

Note that to run DKFZ you need to have ran Delly before so the bedpe file is produced

```sh
bin/run_test.sh DKFZ DO50398
```

The results will be under `tests/<workflow>/<sample>/output/<sample>.*` for example `tests/Sanger/HCC1143/output/HCC1143.somatic.snv.mnv.tar.gz`
After the process is finished you may want to remove the directory `tests/<workflow>/<sample>/datadir/` since it holds a copy of the input files.
