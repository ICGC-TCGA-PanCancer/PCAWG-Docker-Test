#!/bin/bash

workflow=$1
donor=$2

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
directory="$base_dir/tests/$workflow/$donor/"
output_dir="$directory/output/"
PCAWG_dir="$base_dir/PCAWG/"

release_file="$PCAWG_dir/release_may2016.v1.2.tsv"

aliquote=$(grep $donor "${PCAWG_dir}/donor_wgs_samples" | cut -f 2)

tmp_dir="$base_dir/tmp"
orig_vcf="$tmp_dir/${donor}.${workflow}.orig.vcf.gz"
new_vcf="$tmp_dir/${donor}.${workflow}.vcf.gz"

orig_list="${orig_vcf}.list"
new_list="${new_vcf}.list"


[[ -f $tmp_dir ]] || mkdir -p $tmp_dir


# GET ORIGINAL VCF FILE FROM GNOS
if [[ ! -f $orig_vcf ]]; then
	case $workflow in
		DKFZ)
			workflow_tag="dkfz_embl"
		;;
		Sanger)
			workflow_tag="sanger"
		;;
		BWA-Mem)
		;;
	esac
	gnos_column=$(head -n 1 $release_file  |tr '\t' '\n' | nl |grep ${workflow_tag}_variant_calling_gnos_id|cut -f 1)
	gnos_id=$(grep $donor $release_file  | cut -f $gnos_column)
	echo "Downloading VCF for donor $donor, GNOS id: $gnos_id"
	$base_dir/bin/get_gnos_vcf.sh $gnos_id $orig_vcf
fi

# GET NEW VCF FILE WORKFLOW OUTPUT
case $workflow in
  	DKFZ)
       		workflow_result_vcf="$output_dir/${donor}.somatic.snv.mnv.vcf.gz"
		cp "$workflow_result_vcf" "$new_vcf"
		vcf_pattern="dkfz"
	;;
  	Sanger)
       		workflow_result_tar="$output_dir/${donor}.somatic.snv.mnv.tar.gz"
		tar_tmp="$tmp_dir/tar/"
		mkdir -p $tar_tmp
                (cd $tar_tmp; tar xvfz $workflow_result_tar; cp `find -name *muts.ids.vcf.gz` $new_vcf)
		rm -Rf $tar_tmp
	;;
  	BWA-Mem)
       		workflow_result_vcf="$output_dir/${donor}.somatic.snv.mnv.vcf.gz"
		zcat "$workflow_result_vcf" > "$new_vcf"
		vcf_pattern="dkfz"
	;;

esac

# EXTRACT MUTATIONS FROM BOTH FILES
zcat "$orig_vcf" | grep -v "#"| cut -f 1,2,5 | tr '\t' ':' | sort > $orig_list
zcat "$new_vcf" | grep -v "#"| cut -f 1,2,5 | tr '\t' ':' | sort > $new_list

extra_lines_c=$(comm -2 -3 $new_list $orig_list | wc -l)
common_lines_c=$(comm -1 -2 $new_list $orig_list | wc -l)
missing_lines_c=$(comm -1 -3 $new_list $orig_list | wc -l)
extra_lines_ex=$(comm -2 -3 $new_list $orig_list | head -n 3|tr '\n' ','|sed 's/,$//')
missing_lines_ex=$(comm -1 -3 $new_list $orig_list | head -n 3|tr '\n' ','|sed 's/,$//')

echo
echo "Comparison for $donor using $workflow"
echo "---"
echo "Common: $common_lines_c"
echo "Extra: $extra_lines_c"
[[ $extra_lines_c -gt 0 ]] && echo "    - Example: $extra_lines_ex"
echo "Missing: $missing_lines_c"
[[ $missing_lines_c -gt 0 ]] && echo "    - Example: $missing_lines_ex"
echo
