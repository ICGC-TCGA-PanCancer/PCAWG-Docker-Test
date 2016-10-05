#!/bin/bash

donor="HCC1143"
base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
data_dir="$base_dir/data"
donor_dir="$data_dir/$donor"
tmp_dir="$data_dir/tmp"


mkdir -p $donor_dir $tmp_dir

#(cd $tmp_dir; wget "https://s3-eu-west-1.amazonaws.com/wtsi-pancancer/testdata/HCC1143_ds.tar"; tar xvf HCC1143_ds.tar)
mv "$tmp_dir/HCC1143_ds/$donor.bam" "$donor_dir/tumor.bam"
mv "$tmp_dir/HCC1143_ds/$donor.bam.bai" "$donor_dir/tumor.bam.bai"
mv "$tmp_dir/HCC1143_ds/$donor.bam.bas" "$donor_dir/tumor.bam.bas"

mv "$tmp_dir/HCC1143_ds/${donor}_BL.bam" "$donor_dir/normal.bam"
mv "$tmp_dir/HCC1143_ds/${donor}_BL.bam.bai" "$donor_dir/normal.bam.bai"
mv "$tmp_dir/HCC1143_ds/${donor}_BL.bam.bas" "$donor_dir/normal.bam.bas"

