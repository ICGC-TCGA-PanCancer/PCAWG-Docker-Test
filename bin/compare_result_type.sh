#!/bin/bash

workflow=$1
donor=$2
type=$3

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
directory="$base_dir/tests/$workflow/$donor/"
output_dir="$directory/output/"
PCAWG_dir="$base_dir/PCAWG/"

release_file="$PCAWG_dir/release_may2016.v1.2.tsv"

aliquote=$(grep $donor "${PCAWG_dir}/donor_wgs_samples" | cut -f 2)

tmp_dir="$base_dir/tmp"
orig_vcf="$tmp_dir/${donor}.${workflow}.orig.${type}.vcf.gz"
new_vcf="$tmp_dir/${donor}.${workflow}.${type}.vcf.gz"

orig_list="${orig_vcf}.list"
new_list="${new_vcf}.list"



[[ -f $tmp_dir ]] || mkdir -p $tmp_dir


# GET ORIGINAL VCF FILE FROM GNOS
if [[ ! -f $orig_vcf ]]; then
	case $workflow in
		DKFZ|Delly)
			workflow_tag="dkfz_embl"
		;;
		Sanger)
			workflow_tag="sanger"
		;;
		BWA-Mem)
			echo "Not implemented"
			exit -1
		;;
	esac
	#gnos_column=$(head -n 1 $release_file  |tr '\t' '\n' | nl |grep ${workflow_tag}_variant_calling_gnos_id|cut -f 1| tr -s '\n' ' '| sed 's/^\s*//;s/\s\s*/,/g')
	gnos_column=$(head -n 1 $release_file  |tr '\t' '\n' | nl |grep ${workflow_tag}_variant_calling_gnos_id|cut -f 1)
	gnos_id=$(grep $donor $release_file  | cut -f $gnos_column)
	$base_dir/bin/get_gnos_type_vcf.sh $gnos_id $orig_vcf $type
fi

# GET NEW VCF FILE WORKFLOW OUTPUT
case $workflow in
  	DKFZ|Delly)
                if [ "$type" == "somatic.sv" -o "$type" == "germline.sv" ]; then
			workflow_result_vcf="${output_dir/DKFZ/Delly}/${donor}.delly.${type}.vcf.gz"
		else
			workflow_result_vcf="$output_dir/${donor}.${type}.vcf.gz"
 		fi
                if [ ! -f "$workflow_result_vcf" ]; then
			echo "File not found $workflow_result_vcf"
			exit -1
		fi
		cp "$workflow_result_vcf" "$new_vcf"
		vcf_pattern="dkfz"
	;;
  	Sanger)
       		workflow_result_tar="$output_dir/${donor}.${type}.tar.gz"
		tar_tmp="$tmp_dir/tar/"
		mkdir -p $tar_tmp
                (cd $tar_tmp; tar xvfz $workflow_result_tar &> /dev/null ; cp `find -name *.vcf.gz|grep -v ".ids."` $new_vcf)
		rm -Rf $tar_tmp
	;;
  	BWA-Mem)
		echo "Not implemented"
		exit -1
	;;

esac

# EXTRACT MUTATIONS FROM BOTH FILES
zcat "$orig_vcf" | grep -v "#"| cut -f 1,2,4,5 | tr '\t' ':' | sort > $orig_list
zcat "$new_vcf" | grep -v "#"| cut -f 1,2,4,5 | tr '\t' ':' | sort > $new_list

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
