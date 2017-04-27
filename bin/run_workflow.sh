#!/bin/bash 
workflows=$1
donors=$2

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
icgc_dir="$base_dir/ICGC"

function get_aligned_bams {
	local donor=$1
	local download_type=$2
	[[ "x$download_type" == "x" ]] && download_type='gnos'

	if [ ! -f  $base_dir/data/$donor/normal.bam ]; then
		local donor_id_dir="$icgc_dir/$donor/ID"

		if [ "$download_type" == 'gnos' ]; then
			tumor_sub=$(cut -f 2 $donor_id_dir/Aligned*tumour*)
			normal_sub=$(cut -f 2 $donor_id_dir/Aligned*Normal*)
			$base_dir/bin/get_gnos_donor.sh $donor $tumor_sub $normal_sub
		else
			tumor_obj=$(cut -f 1 $donor_id_dir/Aligned*tumour*)
			normal_obj=$(cut -f 1 $donor_id_dir/Aligned*Normal*)
			$base_dir/bin/get_icgc_donor.sh $donor $tumor_obj $normal_obj
		fi
	fi
}

function get_unaligned_bams {
	local donor=$1
	if [ ! -f $base_dir/data/$donor/normal_unaligned_bams ]; then 
           	$base_dir/bin/download_unaligned.sh $donor
	fi
}


function get_consensus_vcf {
	local donor=$1

	if [ ! -f $base_dir/data/$donor/consensus.vcf ]; then
		local donor_id_dir="$icgc_dir/$donor/ID"

		consensus_vcf_sub=$(cut -f 2 $donor_id_dir/SSM*consensus*)
		$base_dir/bin/get_gnos_vcf.sh $consensus_vcf_sub $base_dir/data/$donor/consensus.vcf.gz  
                cp  $base_dir/data/$donor/consensus.vcf.gz $base_dir/data/$donor/consensus.vcf.gz.tmp
                gunzip  $base_dir/data/$donor/consensus.vcf.gz
                mv  $base_dir/data/$donor/consensus.vcf.gz.tmp  $base_dir/data/$donor/consensus.vcf.gz 
		grep -v "LOWSUPPORT\|OXOG" $base_dir/data/$donor/consensus.vcf | sed 's/bPcr\|bSeq//g' > $base_dir/data/$donor/consensus.filter.vcf
	fi
}

function get_sv_vcf {
	local donor=$1

	if [ ! -f $base_dir/data/$donor/brass.SV.vcf.gz ]; then
		$base_dir/bin/get_donor_SV.sh $donor
	fi
}

for donor in $(echo $donors | tr ',' '\n'); do
	echo "=Processing DONOR: $donor"

	# QUERY ICGC FOR DONOR FILES
	$base_dir/bin/get_icgc_files.sh $donor 1>&2
	
	for workflow in $(echo $workflows | tr ',' '\n'); do
		echo "==Processing $workflow for $donor"

		# DOWNLOAD DATA
		case $workflow in
		DKFZ|Sanger|Delly)
			get_aligned_bams $donor
			;;
		BWA-Mem)
			get_aligned_bams $donor
			get_unaligned_bams $donor
			;;
		BiasFilter)
			get_consensus_vcf $donor
			;;
		Merge-Annotate)
			get_aligned_bams $donor
			get_consensus_vcf $donor
			;;
		SV-Merge)
			get_sv_vcf $donor
			;;
		esac 1>&2
		
		# RUN
		
		case $workflow in
		DKFZ)
			[[ ! -d  $base_dir/tests/Delly/$donor/output ]] && $base_dir/bin/run_test.sh Delly $donor 
			[[ ! -d  $base_dir/tests/$workflow/$donor/output ]] && $base_dir/bin/run_test.sh $workflow $donor 
			;;
		Sanger|Delly|BiasFilter|Merge-Annotate|SV-Merge)
			[[ ! -d  $base_dir/tests/$workflow/$donor/output ]] && $base_dir/bin/run_test.sh $workflow $donor 
			;;
		BWA-Mem)
			[[ ! -d  $base_dir/tests/$workflow/$donor/normal ]] && $base_dir/bin/run_bwa_test.sh $donor 
			;;
		esac 1>&2

		# EVALUATE

		case $workflow in
		DKFZ|Sanger|Delly)
			for type in  germline.snv.mnv germline.indel germline.sv germline.cnv somatic.snv.mnv somatic.indel somatic.sv somatic.cnv; do
				 bin/compare_result_type.sh $workflow $donor $type 
			done;	
			;;
		BWA-Mem)
			bin/compare_bwa_bam.sh $base_dir/tests/$workflow/$donor/normal/output/${donor}.*.bam $base_dir/data/$donor/normal.bam 
			bin/compare_bwa_bam.sh $base_dir/tests/$workflow/$donor/tumor/output/${donor}.*.bam $base_dir/data/$donor/tumor.bam 
			;;
		BiasFilter)
			bin/compare_bias_filter.sh $donor
			;;
		Merge-Annotate)
			;;
		SV-Merge)
			bin/compare_consensus_SV.sh $donor
			;;
		esac
		
		# CLEANUP

		rm -Rf $base_dir/tests/$workflow/$donor/datastore 1>&2
		rm -Rf $base_dir/tests/$workflow/$donor/*/datastore 1>&2

		[[ $workflow == 'DKFZ' ]] && rm -Rf $base_dir/tests/Delly/$donor/datastore 1>&2

	done
done
