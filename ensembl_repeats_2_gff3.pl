###############################################################################
# 
# This perl script extracts repeats from a specified Ensembl genome.
#
# By William D. Jones
#
###############################################################################

=head1 NAME

Ens2HOMER_Extract_Repeats.pl: A HOMER-style Ensembl .gff3 repeat generator.

=head1 SYNOPSIS

=====================================================================
HOMER-style Ensembl .gff3 repeat generator.

This program generates a HOMER-style .gff3 file of genome repeats extracted
from Ensembl. The Ensembl database version is controlled by the git repository 
for the Ensembl Perl API. To switch to a different Ensembl version, use
git checkout before invoking this program.
=====================================================================

Ens2HOMER_Extract_Repeats.pl -species <species_name> [-help]

  arguments:
    species:   Species name, for example danio_rerio. 
    help:      Displays this help message.

=cut

# libraries
use Getopt::Long;
use Pod::Usage;
use POSIX qw/strftime/;

# print start message
print STDERR strftime "%Y-%m-%d %H:%M:%S\t", localtime time;
print STDERR "Starting HOMER-style Ensembl .gff3 repeat generator...\n\n";

# parse command-line arguments
my %hash_args;
GetOptions( \%hash_args, "species=s", "help" ) or pod2usage(2);
pod2usage(1) if %hash_args{help};
die "Missing required argument: -species" unless $hash_args{species};

# set Ensembl registry
use Bio::EnsEMBL::Registry;
my $ens_reg = 'Bio::EnsEMBL::Registry';
$ens_reg->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous',
    -verbose => '0'
);

# set Ensembl Slice adaptor for selected species
my $ens_ad_sl = $ens_reg->get_adaptor($hash_args{species}, 'Core', 'Slice');

# collect slices for all chromosomes and contigs
my @arr_ens_sl_top = @{$ens_ad_sl->fetch_all('toplevel')};

# write header lines to STDOUT
printf("##gff-version 3\n");
foreach my $ens_sl_top (@arr_ens_sl_top) {
    my $str_gff;
    $str_gff .= "##sequence-region ";
    $str_gff .= $ens_sl_top->seq_region_name." ";
    $str_gff .= $ens_sl_top->start." ";
    $str_gff .= $ens_sl_top->end." ";
    printf($str_gff."\n");
}

# write repeat features to STDOUT
foreach my $ens_sl_top (@arr_ens_sl_top) {
    # generate repeat features for the slice
    my @arr_rep = @{$ens_sl_top->get_all_RepeatFeatures()};
    foreach my $rep (@arr_rep) {
        # generate the GFF3-style record
        # follows an example suggested here:
        # https://useast.ensembl.org/info/website/upload/gff.html
        # and the gffstring method for SeqFeature:
        # public Bio::EnsEMBL::SeqFeature::gffstring()
        my $str_gff;

        # set strand
        my $strand = "+";
        if ((defined $rep->strand) && ($rep->strand == -1)) {
            $strand = "-";
        }

        # add required gff fields to gff string
        $str_gff .= (defined $rep->seq_region_name)     
                        ?   $rep->seq_region_name."\t"      :  "\t";
        $str_gff .= "Ensembl\t";
        $str_gff .= "repeat_region\t";
        $str_gff .= (defined $rep->start)       
                        ?   $rep->start."\t"        :  "\t";
        $str_gff .= (defined $rep->end)         
                        ?   $rep->end."\t"          :  "\t";
        $str_gff .= (defined $rep->score)       
                        ?   $rep->score."\t"        :  "\t";
        $str_gff .= (defined $rep->strand)      
                        ?   $strand."\t"             :  ".\t";
        # phase is undefined for all repeats
        $str_gff .= ".\t";
        # add attributes, in the style for repeats in the example above
        $str_gff .= "description=".$rep->repeat_consensus->name;
        $str_gff .= ";hstart=".$rep->hstart;
        $str_gff .= ";hend=".$rep->hend;

        # print gff3 line
        printf($str_gff."\n");

    }
}

# print completion message
print STDERR strftime "%Y-%m-%d %H:%M:%S\t", localtime time;
print STDERR "Finished writing .gff3\n";

