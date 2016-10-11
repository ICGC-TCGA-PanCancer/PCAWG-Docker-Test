#!/bin/bash

donor=$1
tumor=$2
normal=$3

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
data_dir="$base_dir/data"
donor_dir="$data_dir/$donor"
tmp_dir="$data_dir/tmp"
tumor_tmp="$tmp_dir/$donor/tumor"
normal_tmp="$tmp_dir/$donor/normal"

gnos_client="gtdownload -c $base_dir/etc/keyfile.txt -vv"

mkdir -p $tumor_tmp
mkdir -p $normal_tmp
mkdir -p $donor_dir

echo "Downloading tumor data for $donor. Tumor: $tumor - Normal: $normal"

echo "Downloading tumor BAM: $tumor"
(cd $tumor_tmp; $gnos_client https://gtrepo-ebi.annailabs.com/cghub/data/analysis/download/$tumor)
mv $tumor_tmp/*/*.bam "$donor_dir/tumor.bam"
mv $tumor_tmp/*/*.bam.bai "$donor_dir/tumor.bam.bai"
mv $tumor_tmp/*/*.bam.bas "$donor_dir/tumor.bam.bas"

echo "Downloading normal BAM: $normal"
(cd $normal_tmp; $gnos_client https://gtrepo-ebi.annailabs.com/cghub/data/analysis/download/$normal)
mv $normal_tmp/*/*.bam "$donor_dir/normal.bam"
mv $normal_tmp/*/*.bam.bai "$donor_dir/normal.bam.bai"
mv $normal_tmp/*/*.bam.bas "$donor_dir/normal.bam.bas"
