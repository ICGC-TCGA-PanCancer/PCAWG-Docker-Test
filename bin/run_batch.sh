#!/bin/bash 
workflows=$1
donor_file=$2
target_donor=$3

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))

for line in $(cat $donor_file); do
	donor=$(echo $line|cut -f 1 -d',')
	tumor_obj=$(echo $line|cut -f 2 -d',')
	tumor_sub=$(echo $line|cut -f 3 -d',')
	normal_obj=$(echo $line|cut -f 4 -d',')
	normal_sub=$(echo $line|cut -f 5 -d',')
        
        if [ -z $target_donor -o $target_donor == $donor ]; then

		[[ ! -d  $base_dir/data/$donor ]] && $base_dir/bin/get_gnos_donor.sh $donor $tumor_sub $normal_sub

		for workflow in $(echo $workflows|sed 's/,/\n/'); do
			result_file=$base_dir/${donor}.${workflow}.comparison.txt
			log_dir=$base_dir/${donor}.${workflow}.log

			echo > "$result_file"
			echo > "$log_dir"

			[[ $workflow == 'BWA-Mem' ]] && [[ ! -f $base_dir/data/$donor/normal.unaligned.bam ]] && $base_dir/bin/prepare_unaligned.sh $donor &>> "$log_dir"
			[[ $workflow == 'DKFZ' ]] && [[ ! -f  $base_dir/tests/Delly/$donor ]] && $base_dir/bin/run_test.sh Delly $donor &>> "$log_dir"

			[[ ! -d  $base_dir/tests/$workflow/$donor/output ]] && $base_dir/bin/run_test.sh $workflow $donor &>> "$log_dir"

			for type in  germline.snv.mnv germline.indel germline.sv germline.cnv somatic.snv.mnv somatic.indel somatic.sv somatic.cnv; do
				 bin/compare_result_type.sh $workflow $donor $type 2>> "$log_dir"  | tee -a "$result_file" 
			done;	

			rm -Rf $base_dir/tests/$workflow/$donor/datastore

			[[ $workflow == 'DKFZ' ]] && rm -Rf $base_dir/tests/Delly/$donor/datastore
		done

		#rm -Rf $base_dir/data/$donor
	fi
done
