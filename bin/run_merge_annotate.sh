#!/bin/bash

donor=$1
workflow="Merge-Annotate"

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
resource_dir="$base_dir/resources/"
directory="$base_dir/tests/$workflow/$donor/"
delly_dir="$base_dir/tests/Delly/$donor/output/"
output_dir="$directory/output/"
data_dir="$base_dir/data/$donor/"
tumor_bam="$data_dir/tumor.bam"
normal_bam="$data_dir/normal.bam"
consensus_vcf="$data_dir/consensus.vcf"
consensus_filter_vcf="$data_dir/consensus.filter.vcf"

mkdir -p "$directory"
mkdir -p "$output_dir"

for provider in broad dkfz muse sanger; do
	cat $base_dir/etc/$workflow.json.template | sed "s#\\[DATA-DIR\\]#$data_dir#g;s#\\[PROVIDER\\]#$provider#g;s#\\[DONOR-DIR\\]#$data_dir#g;s#\\[CONSENSUS-FILTER-VCF\\]#$consensus_filter_vcf#g;s#\\[CONSENSUS-VCF\\]#$consensus_vcf#g;s#\\[DELLY-DIR\\]#$delly_dir#g;s#\\[RESOURCE-DIR\\]#$resource_dir#g;s#\\[OUTPUT-DIR\\]#$output_dir#g;s#\\[DONOR\\]#$donor#g;s#\\[TUMOR-BAM\\]#$tumor_bam#g;s#\\[NORMAL-BAM\\]#$normal_bam#g;s#\\[TYPE\\]#$type#g;s#\\[UNALIGNED\\]#$unaligned_json#g" > $directory/Dockstore.json

	cd "$directory"

	cwl="$(grep $workflow "$base_dir/etc/workflows" | cut -f 2)"

	echo "Running:"
	echo "cd $directory && dockstore tool launch --script --entry "$cwl"  --json Dockstore.json"
	(cd "$directory" && dockstore tool launch --script --entry $cwl --json Dockstore.json)
done
