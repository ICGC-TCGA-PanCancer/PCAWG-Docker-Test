#!/bin/bash

donor=$1

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
data_dir="$base_dir/data"
donor_dir="$data_dir/$donor"
vcf_dir="$data_dir/$donor/workflow_vcfs"
tmp_dir="$data_dir/tmp/workflow_files/$donor"
donor_fi_dir="$base_dir/ICGC/$donor/ID"

icgc_client="$base_dir/icgc-storage-client-1.0.21/bin/icgc-storage-client"

[[ -d $vcf_dir ]] || mkdir -p $vcf_dir

for f in $donor_fi_dir/*; do
	if [[ $f == *"vcf.gz" ]]; then
		name=`echo $f | cut -f 4,6-10 -d'.'`
		tmp_file_dir="$tmp_dir/$name"
		[[ -d $tmp_file_dir ]] || mkdir -p $tmp_file_dir
		objid=`cat "$f"|cut -f 1`
		$icgc_client --profile aws  download --object-id $objid  --output-dir $tmp_file_dir
		cp $tmp_file_dir/*.vcf.gz/* "$vcf_dir/$name"
	fi
done

