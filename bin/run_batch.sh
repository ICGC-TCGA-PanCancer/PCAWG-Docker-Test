#!/bin/bash 
workflows=$1
donor_file=$2

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))

for line in $(cat $donor_file); do
	donor=$(echo $line|cut -f 1 -d',')
	tumor_obj=$(echo $line|cut -f 2 -d',')
	tumor_sub=$(echo $line|cut -f 3 -d',')
	normal_obj=$(echo $line|cut -f 4 -d',')
	normal_sub=$(echo $line|cut -f 5 -d',')

        echo $base_dir/bin/get_gnos_donor.sh $donor $tumor_sub $normal_sub

	for workflow in $(echo $workflows|sed 's/,/\n/'); do
		[[ $workflow == 'BWA-Mem' ]] && echo $base_dir/bin/prepare_unaligned.sh $donor 
		[[ $workflow == 'DKFZ' ]] && echo $base_dir/bin/run_test.sh Delly $donor 
		echo $base_dir/bin/run_test.sh $workflow $donor 
		echo $base_dir/bin/compare_result.sh $workflow $donor 
                echo rm -Rf $base_dir/test/$workflow/$donor
		[[ $workflow == 'DKFZ' ]] && echo rm -Rf $base_dir/test/Delly/$donor
	done

	echo rm -Rf $base_dir/data/$donor
        
done
