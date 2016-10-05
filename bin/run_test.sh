#!/bin/bash

workflow=$1
donor=$2

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
resource_dir="$base_dir/resources/"
directory="$base_dir/tests/$workflow/$donor/"
output_dir="$directory/output/"
tumor_bam="$base_dir/data/$donor/tumor.bam"
normal_bam="$base_dir/data/$donor/normal.bam"

mkdir -p "$directory"
mkdir -p "$output_dir"
cat $base_dir/etc/$workflow.json.template | sed "s#\\[RESOURCE-DIR\\]#$resource_dir#g;s#\\[OUTPUT-DIR\\]#$output_dir#g;s#\\[DONOR\\]#$donor#g;s#\\[TUMOR-BAM\\]#$tumor_bam#g;s#\\[NORMAL-BAM\\]#$normal_bam#g" > $directory/Dockstore.json

cd "$directory"

cwl="$(grep $workflow "$base_dir/etc/workflows" | cut -f 2)"

(cd $directory && dockstore tool launch --entry "$cwl"  --json Dockstore.json)
