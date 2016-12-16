#!/bin/bash

vcf_id=$1
filename=$2
type=$3

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
tmp_dir="$base_dir/tmp/$vcf_id"

gnos_client="gtdownload -c $base_dir/etc/keyfile.txt -vv"

(>&2 echo "Downloading VCF: $vcf_id")
mkdir -p $tmp_dir
(cd $tmp_dir; $gnos_client https://gtrepo-ebi.annailabs.com/cghub/data/analysis/download/$vcf_id)

cp $tmp_dir/*/*${type//./*}*.vcf.gz $filename


