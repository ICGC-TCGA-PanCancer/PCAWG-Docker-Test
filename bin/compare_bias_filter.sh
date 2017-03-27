#!/bin/bash
donor=$1

TAB="	"

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
original_vcf="$base_dir/data/$donor/consensus.vcf"
new_vcf="$base_dir/tests/BiasFilter/$donor/output/${donor}.somatic.snv.mnv.vcf"
directory="$base_dir/tests/$workflow/$donor/"
tmp_dir="$base_dir/tmp/Bias_Filter_compare"


mkdir -p $tmp_dir

for tag in bPcr bSeq; do
        new_list=$tmp_dir/${donor}.$tag.new
        orig_list=$tmp_dir/${donor}.$tag.orig

	grep $tag $original_vcf | grep -v LOWSUPPORT | grep -v OXOG | grep -v "^#" | cut -f 1,2,4,5 | sort > $orig_list
	grep $tag $new_vcf | grep -v "^#" | cut -f 1,2,4,5 | sort > $new_list

	extra_lines_c=$(comm -2 -3 $new_list $orig_list | wc -l)
	common_lines_c=$(comm -1 -2 $new_list $orig_list | wc -l)
	missing_lines_c=$(comm -1 -3 $new_list $orig_list | wc -l)
	extra_lines_ex=$(comm -2 -3 $new_list $orig_list | head -n 3| tr '\t' ':' | tr '\n' ','|sed 's/,$//')
	missing_lines_ex=$(comm -1 -3 $new_list $orig_list | head -n 3| tr '\t' ':' | tr '\n' ','|sed 's/,$//')

	echo
	echo "Comparison for $donor tag $tag"
	echo "---"
	echo "Common: $common_lines_c"
	echo "Extra: $extra_lines_c"
	[[ $extra_lines_c -gt 0 ]] && echo "    - Example: $extra_lines_ex"
	echo "Missing: $missing_lines_c"
	[[ $missing_lines_c -gt 0 ]] && echo "    - Example: $missing_lines_ex"
	echo
done

