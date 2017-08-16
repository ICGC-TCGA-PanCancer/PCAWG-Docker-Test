#!/bin/bash

workflow=$1
donor=$2
type=$3

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
consensus_resources="$base_dir/resources/consensus"

mkdir -p "$directory"
mkdir -p "$output_dir"

unaligned_json=""
if [ -n ${type} ]
then
	for file in $(find $data_dir -name $type.unaligned.*)
	do
		unaligned_single=$(cat <<-EOF
		  {\\n  "path":"${file}",\\n  "class":"File"\\n  },\\n
		EOF
		)
		unaligned_json="${unaligned_json}${unaligned_single}"
	done
	unaligned_json=${unaligned_json%,\\n}
fi

cat $base_dir/etc/$workflow.json.template | sed "s#\\[CONSENSUS-RESOURCES\\]#$consensus_resources#g;s#\\[DONOR-DIR\\]#$data_dir#g;s#\\[CONSENSUS-FILTER-VCF\\]#$consensus_filter_vcf#g;s#\\[CONSENSUS-VCF\\]#$consensus_vcf#g;s#\\[DELLY-DIR\\]#$delly_dir#g;s#\\[RESOURCE-DIR\\]#$resource_dir#g;s#\\[OUTPUT-DIR\\]#$output_dir#g;s#\\[DONOR\\]#$donor#g;s#\\[TUMOR-BAM\\]#$tumor_bam#g;s#\\[NORMAL-BAM\\]#$normal_bam#g;s#\\[TYPE\\]#$type#g;s#\\[UNALIGNED\\]#$unaligned_json#g" > $directory/Dockstore.json

cd "$directory"

cwl="$(grep $workflow "$base_dir/etc/workflows" | cut -f 2)"

if grep $workflow "$base_dir/etc/workflows" | cut -f 3 | grep "workflow"; then
	docker_type='workflow'
else
	docker_type='tool'
fi

echo "Running:"
if [ $docker_type == 'tool' ]; then
	echo "cd $directory && dockstore tool launch --script --entry "$cwl"  --json Dockstore.json"
	(cd "$directory" && dockstore tool launch --script --entry $cwl --json Dockstore.json)
else
	echo "cd $directory && dockstore workflow launch --entry "$cwl"  --json Dockstore.json"
	(cd "$directory" && dockstore workflow launch --script --entry $cwl --json Dockstore.json)
fi
