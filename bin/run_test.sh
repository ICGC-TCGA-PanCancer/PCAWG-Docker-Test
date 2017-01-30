#!/bin/bash

workflow=$1
donor=$2

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
resource_dir="$base_dir/resources/"
directory="$base_dir/tests/$workflow/$donor/"
delly_dir="$base_dir/tests/Delly/$donor/output/"
output_dir="$directory/output/"
tumor_bam="$base_dir/data/$donor/tumor.bam"
normal_bam="$base_dir/data/$donor/normal.bam"
tumor_bam_unaligned="$base_dir/data/$donor/tumor.unaligned.bam"
normal_bam_unaligned="$base_dir/data/$donor/normal.unaligned.bam"

mkdir -p "$directory"
mkdir -p "$output_dir"
cat $base_dir/etc/$workflow.json.template | sed "s#\\[DELLY-DIR\\]#$delly_dir#g;s#\\[RESOURCE-DIR\\]#$resource_dir#g;s#\\[OUTPUT-DIR\\]#$output_dir#g;s#\\[DONOR\\]#$donor#g;s#\\[TUMOR-BAM\\]#$tumor_bam#g;s#\\[NORMAL-BAM\\]#$normal_bam#g;s#\\[TUMOR-BAM-UNALIGNED\\]#$tumor_bam_unaligned#g;s#\\[NORMAL-BAM-UNALIGNED\\]#$normal_bam_unaligned#g" > $directory/Dockstore.json

cd "$directory"

cwl="$(grep $workflow "$base_dir/etc/workflows" | cut -f 2)"

(cd $directory && dockstore tool launch --script --entry "$cwl"  --json Dockstore.json)
