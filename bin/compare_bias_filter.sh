#!/bin/bash
donor=$1

TAB="	"

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
original_vcf="$base_dir/data/$donor/consensus.vcf"
new_vcf="$base_dir/tests/BiasFilter/$donor/output/${donor}.somatic.snv.mnv.vcf"
directory="$base_dir/tests/$workflow/$donor/"
tmp_dir="$base_dir/tmp/Bias_Filter_compare"


mkdir -p $tmp_dir

grep OXOG $original_vcf | cut -f 1,2,4,5 | sort > $tmp_dir/${donor}.orig
grep OXOG $new_vcf | cut -f 1,2,4,5 | sort > $tmp_dir/${donor}.new

echo "Differences in OXOG filtered variants"
diff $tmp_dir/${donor}.orig $tmp_dir/${donor}.new
