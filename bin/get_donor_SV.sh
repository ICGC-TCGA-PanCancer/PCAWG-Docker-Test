#!/bin/bash

donor=$1
tumor=$2
normal=$3

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
data_dir="$base_dir/data"
donor_dir="$data_dir/$donor"
tmp_dir="$data_dir/tmp/"
PCAWG_dir="$base_dir/PCAWG/"
SV_dir="$PCAWG_dir/SV/"

aliquote=$(grep $donor "${PCAWG_dir}/donor_wgs_samples" | cut -f 2)

[[ -d $donor_dir ]] || mkdir -p $donor_dir

for w in brass delly dranger snowman consensus; do
        tarfile=$(ls "$SV_dir"/* | grep $w)
        vcf=$(tar tvfz $tarfile|grep $aliquote | grep vcf.gz | tr -s ' ' ' ' | cut -f 6 -d ' '|head -n 1)
	if [ -z "$vcf" ]; then
		echo "No $w SV file for donor $donor" 
		exit -1
	fi
	echo "$w - $vcf"
	tar xfz "$tarfile" "$vcf" -O > "$donor_dir/$w.SV.vcf.gz"
done

