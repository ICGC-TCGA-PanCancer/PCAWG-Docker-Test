#!/bin/bash

donor=$1
workflow="Consensus"

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
donor_dir="$base_dir/data/$donor/"
directory="$base_dir/tests/$workflow/$donor/"
output_dir="$directory/output/"

tmp_dir="$base_dir/tmp"
orig_vcf="$tmp_dir/${donor}.${workflow}.orig.vcf.gz"
new_vcf="$tmp_dir/${donor}.${workflow}.vcf.gz"

orig_list="${orig_vcf}.list"
new_list="${new_vcf}.list"



[[ -f $tmp_dir ]] || mkdir -p $tmp_dir


# GET ORIGINAL VCF FILE 

cp "$donor_dir/consensus.vcf.gz" $orig_vcf

# GET NEW VCF FILE WORKFLOW OUTPUT

cp "$output_dir/$donor.consensus.vcf.gz" $new_vcf

# EXTRACT MUTATIONS FROM BOTH FILES
rm $orig_list
rm $new_list
for caller in broad dkfz muse sanger; do
	zcat "$orig_vcf" | grep -v "#"| grep $caller| cut -f 1,2,4,5 | tr '\t' ':' | sed "s/$/:$caller/g" | sort >> $orig_list
	zcat "$new_vcf" | grep -v "#"| grep $caller | cut -f 1,2,4,5 | tr '\t' ':' | sed "s/$/:$caller/g" | sort >> $new_list
done

extra_lines_c=$(comm -2 -3 $new_list $orig_list | wc -l)
common_lines_c=$(comm -1 -2 $new_list $orig_list | wc -l)
missing_lines_c=$(comm -1 -3 $new_list $orig_list | wc -l)

extra_lines_ex=$(comm -2 -3 $new_list $orig_list | head -n 3|tr '\n' ','|sed 's/,$//')
missing_lines_ex=$(comm -1 -3 $new_list $orig_list | head -n 3|tr '\n' ','|sed 's/,$//')

if [[ $common_lines_c -eq 0 && $extra_lines_c -eq 0 && $missing_lines_ex -eq 0 ]]; then
	(>&2 echo "No result for $type using $workflow")
else
  
	echo
	echo "Comparison of $type for $donor using $workflow"
	echo "---"
	echo "Common: $common_lines_c"
	echo "Extra: $extra_lines_c"
	[[ $extra_lines_c -gt 0 ]] && echo "    - Example: $extra_lines_ex"
	echo "Missing: $missing_lines_c"
	[[ $missing_lines_c -gt 0 ]] && echo "    - Example: $missing_lines_ex"
	echo
fi
