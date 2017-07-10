# Testing environment

## Introduction

These are scripts to help test the PCAWG variant calling infrastructure by running the
pipelines and scripts and evaluating their results. The pipelines included are the BWA-Mem
BAM aligner, several variant caller pipelines for SNV, indels, and SV, and some
post-processing scripts to further annotate and filter the results. The scripts take care
of downloading the input data and the officially released result files, running the
pipeline over the input data and comparing the result with the officially release result
files. 

These scripts attempt to cover the complete workflow of analysis of the PCAWG variant
calling infrastructure; but since it's not yet complete they do not attempt to run it
start-to-finish, but rather test each step separately. In other words, for each step we
take the inputs from the official submitted results (since fortunately these intermediate
results are still available) not by the results produced by this scripts for the previous
step. This might change once all the steps are made available, and it should be easy to
adapt them so that they run as a complete workflow.

A few clarifications about notation. The term 'workflow' is used also to refer to each
individual step; it will not be used that way in this document, but you might find it used
inside the scripts to refer to the individual docker tools that implement each step. The
term 'test' is also used to refer to running a particular step or 'workflow' over a donor.

## Preparation

There are a few things to prepare before running these scripts. They involve setting up
the credentials to download data from GNOS and ICGC and also downloading some resource
files that the different steps might need. Once this is set up they scripts will take
care of downloading the necessary donor data and results to run and evaluate the different
steps.

### Setup credentials for GNOS and ICGC

To use GNOS put your token key in `etc/keyfile.txt` since that is where the scripts will
try to find it. For the ICGC download client put your token into the
```icgc-storage-client-1.0.19/conf/application.properties``` file

### Download the DKFZ resources

```sh
bin/get_dkfz_resources.sh
```

### Download the Consensus workflow resources

```sh
bin/get_consensus_resources.sh
```

### Download the Test data

Download the test sample HCC1143 and place it in the data directory

```sh
bin/get_test_resources.sh
```

## Running tests

The simplest way to run tests is to use the ```bin/run_workflow.sh``` script which will
take care of running in batch a set of steps over a set of donors. For each step it will
make sure it has downloaded the necessary input files for the donor at hand, and the
corresponding official results to evaluate it against.

The syntax is simply:

```sh
bin/run_workflow.sh <Steps> <Donors> [<download_type>]
```

for example

```sh
bin/run_workflow.sh DKFZ,BiasFilter,Merge-Annotate,SV-Merge,Consensus,Sanger DO52621,DO12814 icgc
```

The last parameter ```download_type``` can be ```icgc``` or ```gnos``` and is
used to specify the backend used to download the donor BAM files (it defaults
to gnos). Note that other donor data such as some intermediate workflow result
files are tied to specific backends, and thus specifying a different one here
has no consequence for those data.

The previous command with output through STDOUT the evaluation results and through STDERR
different log outputs, so its a good idea to redirect them as is done here:

```sh
bin/run_workflow.sh DKFZ,BiasFilter,Merge-Annotate,SV-Merge,Consensus,Sanger DO52621 icgc
> DO52621.evaluation 2> DO52621.log
```

## Overview of the scripts

There are three main types of scripts: for downloading input and validation data
(bin/get_*.sh), for running the test (bin/run_*.sh), and for evaluating the result
(bin/compare_*.sh). There are a few more scripts that are not used anymore regarding
the BWA-Mem aligner.

We have seen the ```bin/run_workflow.sh``` which is the master script that runs all other
scripts. It's worth reading it to get a sense of how these scripts work as a whole.

The second must important script is the ```bin/run_test.sh``` that is in charge of running
most of the steps, which basically entails configuring the Dockstore.json from its
template and running the Dockstore command. The templates can be found in the  ```etc/```
directory and have several placeholder strings that get instantiated for each donor. The
final Dockstore.json file is placed on a directory called ```tests/<step>/<donor>``` i.e
```tests/Sanger/DO52621/```, where the dockstore client is run, producing a subdirectory
called ```output``` where the results are found. The ```bin/run_workflow.sh``` will check
for the existance of the ```tests/<step>/<donor>/output``` directory to decide if the step
needs to be run or is already available; this means you need to remove the directory if
you want ```bin/run_workflow.sh``` to run the test again.

Not all steps are run using the  ```bin/run_test.sh```, some require some extra work and
have their own 'run' scripts.

The evaluation of the results of a test is performed by the compare scripts. There is one
compare script for each of the different steps. The most elaborate of all is the
```bin/compare_result_type.sh``` which evaluates the core variant caller pipelines by
meassuring the overlaps of variants called against the officially submitted. The variants
considered include SNV, Indels and SV for germline and somatic calls, and the script takes
care of gathering the official calls for each type of variant from GNOS using the
```bin/get_gnos_type_vcf.sh``` script.

There are a number of script that gather input data and results that are called at various
points. Some we have used in a previous section to download some resources that will be
used by particular steps. Others download donor data and results that serve as evaluation
or as input to these steps; we have seen the ```bin/download_genes_type.vcf``` which is
called inside a compare script. 

Two particularly interesting download scripts are the ones that download the donor BAM
files ```bin/get_gnos_donor.sh``` and ```bin/get_icgc_donor.sh```. These two can be used
interchangably to get the BAM files for a particular donor. The need to be provided with
the file ids for the tumor and normal files as can be found in the ICGC data portal. These
ids are now extracted automatically by the scripts so that there is no longer need to
check the web-site. See the appendix anyway to read more about it.

There is no need to use any script other than ```bin/run_workflow.sh``` but its good to
check the other scripts to see how they work. The basic idea is that files are downloaded
and placed in regular locations so that they can be linked into the Dockstore.json file to
run steps, and then to compare the result. We have seen that when we run steps we can find
the results in ```tests/<step>/<donor>``` while the input data and official results for
each donor are placed in ```data/<donor>```. 

## Apendix

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

### Running individual tests

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

The results will be under `tests/<workflow>/<sample>/output/<sample>.*` for
example `tests/Sanger/HCC1143/output/HCC1143.somatic.snv.mnv.tar.gz`

After the process is finished you may want to remove the directory
`tests/<workflow>/<sample>/datadir/` since it holds a copy of the input files.

### Running BWA-Mem over unaligned BAMs

The BWA-Mem workflow is a very special case in our scripts. It is the only
script that aligns BAM files so it needs an unaligned BAM file as input.
Unfortunately these unaligned BAM files are not generally available but an
exception has been made for the donors DO46792, DO51057, and DO52707, which are
served at the DKFZ GNOS instance (this should change soon). This script suite
will only work for those donors. 

Alternatively one can test the workflow by un-aligning the already aligned
ones, to do this you need to use the scripts ```bin/prepare_unaligned.sh```
which also requires you to install picard tools using the
```bin/install_picard.sh``` script.

Un-aligned BAMs will unfortunately not be identical to the original not aligned
BAM files, since reads will not be in the same order, thus some small
percentage of the reads will have different alignment. This is expected.




