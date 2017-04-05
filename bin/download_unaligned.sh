#!/bin/bash

donor=$1

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
resource_dir="$base_dir/resources/"
data_dir="$base_dir/data/$donor/"
tmp_dir="$base_dir/tmp/$donor"
donor_json="$base_dir/donor_json/$donor.json.gz"

normal_bams="$data_dir/normal_bam_list"
tumor_bams="$data_dir/tumor_bam_list"
normal_dir="$data_dir/normal_unaligned_bams"
tumor_dir="$data_dir/tumor_unaligned_bams"

[ -d $data_dir ] || mkdir -p $data_dir

ruby <<-EOF
require 'json'
require 'pp'
json = JSON.parse(\`zcat '$donor_json' \`)

normal = {}
tumor = {}

json["normal_alignment_status"]["unaligned_bams"].each do |info|
   name = info["bam_file_name"]
   gnos = info["gnos_id"]
   normal[name] = gnos
end

json["tumor_alignment_status"][0]["unaligned_bams"].each do |info|
   name = info["bam_file_name"]
   gnos = info["gnos_id"]
   tumor[name] = gnos
end

File.open('$normal_bams','w'){|f| f.write normal.collect{|n,g| [n,g] * ":"} * "\\n"}
File.open('$tumor_bams','w'){|f| f.write tumor.collect{|n,g| [n,g] * ":"} * "\\n"}
EOF

gnos_client="gtdownload -c $base_dir/etc/keyfile.txt -vv"

[[ -d $normal_dir ]] || mkdir -p $normal_dir

for line in `cat $normal_bams`; do 
	name=$(echo $line | cut -f 1 -d:); 
	gnos=$(echo $line | cut -f 2 -d:); 
	download_dir="$tmp_dir/unaligned_bam_download/$name"
        [[ -d $download_dir ]] || mkdir -p $download_dir

	(cd $download_dir; $gnos_client https://gtrepo-dkfz.annailabs.com/cghub/data/analysis/download/$gnos)
	cp $download_dir/**/*.bam "$normal_dir/$name"
done


[[ -d $tumor_dir ]] || mkdir -p $tumor_dir

for line in `cat $tumor_bams`; do 
	name=$(echo $line | cut -f 1 -d:); 
	gnos=$(echo $line | cut -f 2 -d:); 
	download_dir="$tmp_dir/unaligned_bam_download/$name"
        [[ -d $download_dir ]] || mkdir -p $download_dir

	(cd $download_dir; $gnos_client https://gtrepo-dkfz.annailabs.com/cghub/data/analysis/download/$gnos)
	cp $download_dir/**/*.bam "$tumor_dir/$name"
done


