#!/bin/bash

donor=$1

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
tmp_dir="$base_dir/tmp/workflow_results/$donor"
PCAWG_dir="$base_dir/PCAWG/"

gnos_client="gtdownload -c $base_dir/etc/keyfile.txt -vv"

aliquote=$(grep $donor "${PCAWG_dir}/donor_wgs_samples" | cut -f 2)
gnos_repo=$(grep $aliquote ${PCAWG_dir}/variant_call_entries_with_broad_oxog_filter_applied.txt | cut -f 5)
gnos_id=$(grep $aliquote ${PCAWG_dir}/variant_call_entries_with_broad_oxog_filter_applied.txt | cut -f 6)

echo $gnos_repo
echo $gnos_id

mkdir -p $tmp_dir
echo "$gnos_client $gnos_repo/cghub/data/analysis/download/$gnos_id"
(cd $tmp_dir; $gnos_client $gnos_repo/cghub/data/analysis/download/$gnos_id)
