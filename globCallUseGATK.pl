#######################################################################################################################################################
#	File Name: globCallUseGATK.pl
#	> Author: QiangGao
#	> Mail: qgao@genetics.ac.cn 
#	Created Time: Thu 13 Nov 2014 02:01:03 PM CST
#	Modified Time: 20200902 luoyf (luoyf@im.ac.cn) 
#	Major modification: UnifiedGenotyper in GATK-3.4-46 was changed to HaplotypeCaller in gatk4(v4.1.6) 
#	It is noted that NO filter steps is performed in this initial variants calling process and thus minimizes the chance of missing real variants 
#	Please download this file and replace old script (globCallUseGATK.pl)
#   Make sure the gatk4 (or a laterr version) has been installed correctly 
########################################################################################################################################################

#!/usr/bin/perl -w
use strict;
my @file=`find ./tmp_pipe_data -name "*.sorted.bam"|grep -v source`;
my $core=8;
my $input;
my $refdb="zh11.chrs.con.fasta";

foreach(@file){
	chomp $_;
	$input.="-I $_ ";
}
my $i=0;

my $dir="GATK";
open(OUT,">./SNPcallGATK.sh");
print OUT<<"EOF";
date
#java -Xmx35g -Djava.io.tmpdir=$dir/tmp -jar ./Software/GenomeAnalysisTK-3.4-46/GenomeAnalysisTK.jar -nt $core -glm BOTH -T UnifiedGenotyper -R $refdb $input  -o $dir/all_last.vcf -metrics $dir/all.UniGenMetrics -stand_call_conf 50.0 -stand_emit_conf 10.0 -dcov 1000 -A Coverage -A AlleleBalance  # luoyf 20200902
#date  # luoyf deletion 20200902
# java -Xmx35g -Djava.io.tmpdir=$dir/tmp -jar ./Software/GenomeAnalysisTK-3.4-46/GenomeAnalysisTK.jar  -R $refdb -T VariantFiltration -V:VCF $dir/all_last.vcf -o $dir/all_last.filtered.vcf --clusterWindowSize 10 --filterExpression "MQ0 >= 4 && ((MQ0 / (1.0 * DP)) > 0.1)" --filterName "HARD_TO_VALIDATE" --filterExpression "DP < 5 " --filterName "LowCoverage" --filterExpression "QUAL < 30.0 " --filterName "VeryLowQual" --filterExpression "QUAL > 30.0 && QUAL < 50.0 " --filterName "LowQual" --filterExpression "QD < 1.5 " --filterName "LowQD"  # luoyf deletion 20200902
./Software/gatk4-4.1.6.0-0/gatk HaplotypeCaller --java-options "-Xmx35g"  -R $refdb -I $input -O  $dir/all_last.vcf    # luoyf adding 20200902
rm -Rf $dir/tmp
date
EOF
my $cc=`sh SNPcallGATK.sh`;

