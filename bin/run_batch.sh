#!/bin/bash 
workflows=$1
donor_file=$2
target_donor=$3

[[ -z $target_donor ]] && target_donor='all'

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))

for line in $(cat $donor_file); do
	donor=$(echo $line|cut -f 1 -d',')
	tumor_obj=$(echo $line|cut -f 2 -d',')
	tumor_sub=$(echo $line|cut -f 3 -d',')
	normal_obj=$(echo $line|cut -f 4 -d',')
	normal_sub=$(echo $line|cut -f 5 -d',')
	consensus_vcf_obj=$(echo $line|cut -f 6 -d',')
	consensus_vcf_sub=$(echo $line|cut -f 7 -d',')
        
        if [ $target_donor == "all" -o $target_donor == $donor ]; then
                echo "Processing donor: $donor"

		[[ ! -d  $base_dir/data/$donor/normal.bam ]] && $base_dir/bin/get_gnos_donor.sh $donor $tumor_sub $normal_sub
		#[[ ! -d  $base_dir/data/$donor/normal.bam ]] && $base_dir/bin/get_icgc_donor.sh $donor $tumor_obj $normal_obj

		for workflow in $(echo $workflows|sed 's/,/\n/'); do
			result_file=$base_dir/${donor}.${workflow}.comparison.txt
			log_dir=$base_dir/${donor}.${workflow}.log

			echo > "$result_file"
			echo > "$log_dir"

                        # Prepare

			[[ $workflow == 'BWA-Mem' ]] && [[ ! -f $base_dir/data/$donor/normal_unaligned_bams ]] && $base_dir/bin/download_unaligned.sh $donor &>> "$log_dir"

			[[ $workflow == 'DKFZ' ]] && [[ ! -f  $base_dir/tests/Delly/$donor ]] && $base_dir/bin/run_test.sh Delly $donor &>> "$log_dir"

			[[ $workflow == 'BiasFilter' ]] && [[ ! -f $base_dir/data/$donor/consensus.vcf ]] && $base_dir/bin/get_gnos_vcf.sh $consensus_vcf_sub $base_dir/data/$donor/consensus.vcf.gz  &>> "$log_dir" && gunzip  $base_dir/data/$donor/consensus.vcf.gz &>> "$log_dir" 

			[[ $workflow == 'BiasFilter' ]] && [[ ! -f $base_dir/data/$donor/consensus.filter.vcf ]] && grep -v "LOWSUPPORT\|OXOG" $base_dir/data/$donor/consensus.vcf | sed 's/bPcr\|bSeq//g' > $base_dir/data/$donor/consensus.filter.vcf 2>> "$log_dir"

                        # Run

			[[ ! -d  $base_dir/tests/$workflow/$donor/output ]] && $base_dir/bin/run_test.sh $workflow $donor &>> "$log_dir"

                        # Evaluate

			[[ $workflow == 'BWA-Mem' ]] && bin/compare_bwa_bam.sh $base_dir/tests/$workflow/$donor/output/${donor}.merged_output.bam $base_dir/data/$donor/tumor.bam $base_dir/data/$donor/normal.bam | tee -a "$result_file"

			[[ $workflow == 'BiasFilter' ]] && bin/compare_bias_filter.sh $donor

			if [ $workflow == 'Sanger' -o $workflow == 'DKFZ' -o $workflow == 'Delly' ]; then
				for type in  germline.snv.mnv germline.indel germline.sv germline.cnv somatic.snv.mnv somatic.indel somatic.sv somatic.cnv; do
					 bin/compare_result_type.sh $workflow $donor $type 2>> "$log_dir"  | tee -a "$result_file" 
				done;	
			fi

                        # Cleanup

			rm -Rf $base_dir/tests/$workflow/$donor/datastore

			[[ $workflow == 'DKFZ' ]] && rm -Rf $base_dir/tests/Delly/$donor/datastore
		done

		#rm -Rf $base_dir/data/$donor
	fi
done
