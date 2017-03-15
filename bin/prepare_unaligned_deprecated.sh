#!/bin/bash

donor=$1

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
resource_dir="$base_dir/resources/"
tumor_bam="$base_dir/data/$donor/tumor.bam"
normal_bam="$base_dir/data/$donor/normal.bam"
tumor_bam_unaligned="$base_dir/data/$donor/tumor.unaligned.bam"
normal_bam_unaligned="$base_dir/data/$donor/normal.unaligned.bam"

normal_header_file="$base_dir/tmp/normal_bam_header.sam"
tumor_header_file="$base_dir/tmp/tumor_bam_header.sam"

cat > $normal_header_file <<-EOF
@HD	VN:1.4
@RG	ID:DOCKER:${1}.normal	CN:DOCKER	PL:ILLUMINA	PM:Illumina HiSeq 2000	LB:WGS:DOCKER:28085	PI:453	SM:00000000-0000-0000-0000-000000000000	PU:DOCKER:1_1	DT:2013-03-18T00:00:00+00:00
@CO	dcc_project_code:DOCKER-TEST
@CO	submitter_donor_id:$1
@CO	submitter_specimen_id:${1}.specimen
@CO	submitter_sample_id:${1}.sample
@CO	dcc_specimen_type:Normal
@CO	use_cntl:85098796-a2c1-11e3-a743-6c6c38d06053
EOF

cat > $tumor_header_file <<-EOF
@HD	VN:1.4
@RG	ID:DOCKER:${1}.tumor	CN:DOCKER	PL:ILLUMINA	PM:Illumina HiSeq 2000	LB:WGS:DOCKER:28085	PI:453	SM:00000000-0000-0000-0000-000000000001	PU:DOCKER:2_2	DT:2013-03-18T00:00:00+00:00
@CO	dcc_project_code:DOCKER-TEST
@CO	submitter_donor_id:$1
@CO	submitter_specimen_id:${1}.specimen
@CO	submitter_sample_id:${1}.sample
@CO	dcc_specimen_type:Primary tumour - solid tissue
@CO	use_cntl:85098796-a2c1-11e3-a743-6c6c38d06053
EOF

cat "$tumor_bam" | $base_dir/lib/biobambam/bin/bamreset resetheadertext=$tumor_header_file exclude=QCFAIL,SECONDARY,SUPPLEMENTARY > "$tumor_bam_unaligned"
#rm "$tumor_bam"
cat "$normal_bam" | $base_dir/lib/biobambam/bin/bamreset  resetheadertext=$normal_header_file exclude=QCFAIL,SECONDARY,SUPPLEMENTARY > "$normal_bam_unaligned"
#rm "$normal_bam"
