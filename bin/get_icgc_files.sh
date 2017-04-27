#!/bin/bash

donor=$1

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
data_dir="$base_dir/data"
tmp_dir="$data_dir/tmp"
icgc_dir="$base_dir/ICGC"
export_file="$icgc_dir/export.tsv"
donor_dir="$icgc_dir/$donor"

[[ -d $icgc_dir ]] || mkdir -p $icgc_dir
[[ -f $export_file ]] || curl -X GET --header 'Accept: text/tsv' 'https://dcc.icgc.org/api/v1/repository/files/export?filters=%7B%7D' > $export_file

if [ ! -d $donor_dir ]; then
  mkdir -p $donor_dir/ID
  for file in $(grep -w $donor "$export_file"|cut -f 2); do
    json_file="$donor_dir/$file"
    curl -X GET --header 'Accept: application/json' "https://dcc.icgc.org/api/v1/repository/files/$file" > $json_file
    type=$(jq .dataCategorization.dataType $json_file | sed 's/"//g')
    filename=$(jq .fileCopies[0].fileName $json_file | sed 's/"//g')
    specimen=$(jq .donors[0].specimenType[0] $json_file | sed 's/"//g')
    object_id=$(jq .objectId $json_file | sed 's/"//g')
    bundle_id=$(jq .fileCopies[0].repoDataBundleId $json_file | sed 's/"//g')
    id_file="$donor_dir/ID/$type.$specimen.$filename"
    echo $file
    echo $id_file
    echo "${object_id}#${bundle_id}" | tr '#' '\t' > "$id_file"
  done
fi
