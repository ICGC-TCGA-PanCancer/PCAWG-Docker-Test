#!/bin/bash

workflow=$1
donor=$2

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
directory="$base_dir/tests/$workflow/$donor/"
output_dir="$directory/output/"
PCAWG_dir="$base_dir/PCAWG/"

aliquote=$(grep $donor "${PCAWG_dir}/donor_wgs_samples" | cut -f 2)

tmp_dir="$base_dir/tmp"
orig_vcf="$tmp_dir/${donor}.orig.vcf"
new_vcf="$tmp_dir/${donor}.${workflow}.vcf"

orig_list="${orig_vcf}.${workflow}.list"
new_list="${new_vcf}.list"


[[ -f $tmp_dir ]] || mkdir -p $tmp_dir

# GET ORIGINAL VCF FILE FROM TGZ
if [[ ! -f $orig_vcf ]]; then
	old_pwd=$PWD
	cd $tmp_dir
	tar_vcf_file="preliminary_final_release/snv_mnv/${aliquote}.annotated.snv_mnv.vcf.gz"
	tar xvfz "$PCAWG_dir/SNV_MNV_Mar28.tgz" $tar_vcf_file
	zcat $tar_vcf_file >> "$orig_vcf"
        rm -Rf "preliminary_final_release/"
	cd $old_pwd
fi

# GET NEW VCF FILE WORKFLOW OUTPUT
case $workflow in
  	DKFZ)
       		workflow_result_vcf="$output_dir/${donor}.somatic.snv.mnv.vcf.gz"
		zcat "$workflow_result_vcf" > "$new_vcf"
		vcf_pattern="dkfz"
	;;
  	Sanger)
       		workflow_result_tar="$output_dir/${donor}.somatic.snv.mnv.tar.gz"
       		workflow_result_vcf="$output_dir/${donor}.somatic.snv.mnv.tar.gz"
		vcf_pattern="sanger"
	;;
  	BWA-Mem)
       		workflow_result_vcf="$output_dir/${donor}.somatic.snv.mnv.vcf.gz"
		zcat "$workflow_result_vcf" > "$new_vcf"
		vcf_pattern="dkfz"
	;;

esac

# EXTRACT MUTATIONS FROM BOTH FILES
grep $vcf_pattern $orig_vcf | cut -f 1,2,4 | tr '\t' ':' | sort > $orig_list
grep PASS $new_vcf | cut -f 1,2,4 | tr '\t' ':' | sort > $new_list

extra_lines_c=$(comm -2 -3 $new_list $orig_list | wc -l)
missing_lines_c=$(comm -1 -3 $new_list $orig_list | wc -l)
extra_lines_ex=$(comm -2 -3 $new_list $orig_list | head -n 3|tr '\n' ','|sed 's/,$//')
missing_lines_ex=$(comm -1 -3 $new_list $orig_list | head -n 3|tr '\n' ','|sed 's/,$//')

echo "Comparison for $donor using $workflow"
echo "---"
echo "Extra: $extra_lines_c. Example: $extra_lines_ex"
echo "Missing: $missing_lines_c. Example: $missing_lines_ex"
echo
