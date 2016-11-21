#!/bin/bash

donor=$1

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
resource_dir="$base_dir/resources/"
tumor_bam="$base_dir/data/$donor/tumor.bam"
normal_bam="$base_dir/data/$donor/normal.bam"
tumor_bam_unaligned="$base_dir/data/$donor/tumor.unaligned.bam"
normal_bam_unaligned="$base_dir/data/$donor/normal.unaligned.bam"

cat "$tumor_bam" | $base_dir/lib/biobambam/bin/bamreset > "$tumor_bam_unaligned"
cat "$normal_bam" | $base_dir/lib/biobambam/bin/bamreset > "$normal_bam_unaligned"
