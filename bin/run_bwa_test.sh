#!/bin/bash

donor=$1

workflow="BWA-Mem"

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
resource_dir="$base_dir/resources/"
data_dir="$base_dir/data/$donor/"
consensus_vcf="$data_dir/consensus.vcf"

for type in normal tumor; do
	unaligned_dir="$data_dir/${type}_unaligned_bams"
	orig_bam="$data_dir/${type}.bam"
	directory="$base_dir/tests/$workflow/$donor/$type"
	output_dir="$directory/output/"

	unaligned_json=""
        for id in $(java -Xmx8G -jar $base_dir/lib/picard/picard.jar ViewSam INPUT=$orig_bam HEADER_ONLY=true | grep "^@RG"|tr '\t' '\n'|grep ^PU |cut -f 3 -d:); do
		file=$(ls $unaligned_dir/*|grep $id)
		echo $file

		unaligned_single=$(cat <<-EOF
		  {\\n  "path":"${file}",\\n  "class":"File"\\n  },\\n
		EOF
		)
		unaligned_json="${unaligned_json}${unaligned_single}"
	done
	unaligned_json=${unaligned_json%,\\n}

	mkdir -p "$directory"
	mkdir -p "$output_dir"

	cat $base_dir/etc/$workflow.json.template | sed "s#\\[CONSENSUS-VCF\\]#$consensus_vcf#g;s#\\[DELLY-DIR\\]#$delly_dir#g;s#\\[RESOURCE-DIR\\]#$resource_dir#g;s#\\[OUTPUT-DIR\\]#$output_dir#g;s#\\[DONOR\\]#$donor#g;s#\\[TUMOR-BAM\\]#$tumor_bam#g;s#\\[NORMAL-BAM\\]#$normal_bam#g;s#\\[UNALIGNED\\]#$unaligned_json#g" > $directory/Dockstore.json

	cwl="$(grep $workflow "$base_dir/etc/workflows" | cut -f 2)"


	echo "Running BWA-Mem for $donor $type:"
	echo "cd $directory && dockstore tool launch --script --entry "$cwl"  --json Dockstore.json"
	(cd "$directory" && dockstore tool launch --script --entry $cwl --json Dockstore.json)
done
