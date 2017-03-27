#!/bin/bash

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
resource_dir="$base_dir/resources"
tmp_dir="$base_dir/tmp"

mkdir -p $tmp_dir $resource_dir

(cd $resource_dir; wget "http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz"; wget "http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz.fai"; zcat hs37d5.fa.gz > hs37d5.fa; rm hs37d5.fa.gz)

