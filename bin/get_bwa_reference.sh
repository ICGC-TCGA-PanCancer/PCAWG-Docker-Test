#!/bin/bash

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
resource_dir="$base_dir/resources"
tmp_dir="$base_dir/tmp"

mkdir -p $tmp_dir $resource_dir


for file in genome.fa.gz.64.amb genome.fa.gz.64.sa genome.fa.gz.64.pac genome.fa.gz.64.ann genome.fa.gz.64.bwt genome.fa.gz.fai genome.fa.gz ; do
	(cd $resource_dir; wget "https://dcc.icgc.org/api/v1/download?fn=/PCAWG/reference_data/pcawg-bwa-mem/$file" -O "$file")
done

