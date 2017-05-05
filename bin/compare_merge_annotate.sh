#!/bin/bash
donor=$1

TAB="	"

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
data_dir="$base_dir/data/$donor/"
result_dir="$base_dir/tests/Merge-Annotate/$donor/output"
tmp_dir="$base_dir/tmp/Merge-Annotate"

[[ -d $tmp_dir ]] || mkdir -p $tmp_dir

for provider in broad dkfz muse sanger; do
	if [ -f $result_dir/$donor.$provider.oxoG.annotated.vcf ]; then
		orig_list="$tmp_dir/orig.$provider.vcf"
		new_list="$tmp_dir/new.$provider.vcf"

		zcat "$data_dir/$provider.oxoG.annotated.vcf.gz" |grep -v "^#" | sort > $orig_list
		cat "$result_dir/$donor.$provider.oxoG.annotated.vcf" |grep -v "^#" | sort > $new_list
		
		extra_lines_c=$(comm -2 -3 $new_list $orig_list | wc -l)
		common_lines_c=$(comm -1 -2 $new_list $orig_list | wc -l)
		missing_lines_c=$(comm -1 -3 $new_list $orig_list | wc -l)

		extra_lines_ex=$(comm -2 -3 $new_list $orig_list | head -n 3 | sed 's/^/* /')
		missing_lines_ex=$(comm -1 -3 $new_list $orig_list | head -n 3 | sed 's/^/* /')

		if [[ $common_lines_c -eq 0 && $extra_lines_c -eq 0 && $missing_lines_ex -eq 0 ]]; then
			(>&2 echo "No result for $type using $workflow")
		else
		  
			echo
			echo "Comparison of Merge-Annotate for $donor provider $provider"
			echo "---"
			echo "Common: $common_lines_c"
			echo "Extra: $extra_lines_c"
			[[ $extra_lines_c -gt 0 ]] && echo "    - Example: " && echo "$extra_lines_ex"
			echo "Missing: $missing_lines_c"
			[[ $missing_lines_c -gt 0 ]] && echo "    - Example: " && echo "$missing_lines_ex"
			echo
		fi

	fi
done
