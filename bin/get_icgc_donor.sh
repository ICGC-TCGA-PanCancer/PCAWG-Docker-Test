#!/bin/bash

donor=$1
tumor=$2
normal=$3

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
data_dir="$base_dir/data"
donor_dir="$data_dir/$donor"
tmp_dir="$data_dir/tmp/"
tumor_tmp="$tmp_dir/$donor/tumor"
normal_tmp="$tmp_dir/$donor/normal"

icgc_client="$base_dir/icgc-storage-client-1.0.21/bin/icgc-storage-client"

mkdir -p $tumor_tmp
mkdir -p $normal_tmp
mkdir -p $donor_dir

echo "Downloading tumor data for $donor. Tumor: $tumor - Normal: $normal"

echo "Downloading tumor BAM: $tumor"
$icgc_client --profile aws  download --object-id $tumor  --output-dir $tumor_tmp
mv $tumor_tmp/*.bam/* "$donor_dir/tumor.bam"
mv $tumor_tmp/*.bam.bai/* "$donor_dir/tumor.bam.bai"
mv $tumor_tmp/*.bam.bas/* "$donor_dir/tumor.bam.bas"

echo "Downloading normal BAM: $normal"
$icgc_client --profile aws  download --object-id $normal  --output-dir $normal_tmp
mv $normal_tmp/*.bam/* "$donor_dir/normal.bam"
mv $normal_tmp/*.bam.bai/* "$donor_dir/normal.bam.bai"
mv $normal_tmp/*.bam.bas/* "$donor_dir/normal.bam.bas"
