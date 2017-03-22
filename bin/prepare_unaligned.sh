#!/bin/bash

donor=$1
type=$2

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
resource_dir="$base_dir/resources/"
data_dir="$base_dir/data/$donor/"
tmp_dir="$base_dir/tmp/$donor"
header_file="$tmp_dir/bam_header.sam"
aligned_bam="$data_dir/$type.bam"
tmp_unaligned="$tmp_dir/$type/unaligned/"

mkdir -p $tmp_unaligned

if [ $type = "normal" ]
then
	specimen_type="Normal"
elif [ $type = "tumor" ]
then
	specimen_type="Primary tumour - solid tissue"
else
	echo "Please define type of bam: normal/tumor"
	exit -1
fi

java -Xmx8G -jar $base_dir/lib/picard/picard.jar RevertSam \
		I=$aligned_bam \
		O=$tmp_unaligned \
		OUTPUT_BY_READGROUP=true \
		OUTPUT_BY_READGROUP_FILE_FORMAT=bam \
		ATTRIBUTE_TO_CLEAR=XS \
		SORT_ORDER=unsorted \
		RESTORE_ORIGINAL_QUALITIES=true \
		REMOVE_DUPLICATE_INFORMATION=true \
		REMOVE_ALIGNMENT_INFORMATION=true \
		TMP_DIR=$tmp_dir

counter=1
for file in $(find ${tmp_unaligned} -name *.bam)
do

	RG=$(java -Xmx8G -jar $base_dir/lib/picard/picard.jar ViewSam INPUT=$file HEADER_ONLY=true | grep "^@RG")

	cat > $header_file <<-EOF
	@HD	VN:1.4
	${RG}
	@CO	dcc_project_code:DOCKER-TEST
	@CO	submitter_donor_id:${donor}
	@CO	submitter_specimen_id:${donor}.specimen
	@CO	submitter_sample_id:${donor}.sample
	@CO	dcc_specimen_type:${specimen_type}
	@CO	use_cntl:85098796-a2c1-11e3-a743-6c6c38d06053
	EOF

	java -Xmx8G -jar $base_dir/lib/picard/picard.jar ReplaceSamHeader \
		I=$file \
		HEADER=$header_file \
		O=${data_dir}${type}.unaligned.${counter}.bam

	rm $file
	((counter++))
done
