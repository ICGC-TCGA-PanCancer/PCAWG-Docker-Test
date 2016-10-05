#!/bin/bash

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
resource_dir="$base_dir/resources"
tmp_dir="$base_dir/tmp"

mkdir -p $tmp_dir $resource_dir

gnos_client="gtdownload -c $base_dir/etc/keyfile.txt"

(cd $tmp_dir; $gnos_client -vv https://gtrepo-dkfz.annailabs.com/cghub/data/analysis/download/32749c9f-d8aa-4ff5-b32c-296976aec706)
mv $tmp_dir/*/*.tar.gz $resource_dir
