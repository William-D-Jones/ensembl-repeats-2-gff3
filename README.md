# Ensembl Repeats Annotation Generator (ensembl-repeats-2-gff3)

The Ensembl Repeats Annotation Generator (ensembl-repeats-2-gff3) information on
genomic repeats from Ensembl and produces annotations in .gff3 format. The
.gff3 annotations produced are designed to be compatible with the HOMER 
software suite (http://homer.ucsd.edu/homer/).

## Prerequisites:

1. The Ensembl Perl API
(https://mart.ensembl.org/info/docs/api/api_installation.html).

2. Ensembl Git Tools (https://github.com/Ensembl/ensembl-git-tools).

## Installation:

```
git clone https://github.com/William-D-Jones/ensembl-repeats-2-gff3.git
```

## Usage:

1. Before use, determine which Ensembl version you wish to use. The appropriate
version must be setup with `get checkout` in Ensembl Git Tools. For example,
if you wish to use Ensembl version 108, use the following command, which
assumes that Ensembl Git Tools has been added to `PATH`.

```
git ensembl --checkout --branch release/108 api
```

2. Extract repeats for the desired species of interest. For example, to
extract repeats from the zebrafish genome, use the following command. Note
that .gff3 records are sent to stdout by default and should be redirected to
a file if desired.

```
perl ensembl_repeats_2_gff3.pl -species danio_rerio > repeats.gff
```

3. If the repeats are to be used to generate a custom genome with the HOMER
software, supply the repeats.gff file to HOMER's program loadGenome.pl with the
flag -ensemblRepeats.

```
loadGenome.pl -ensemblRepeats repeats.gff ...
```

## Command-Line Options:

Usage:
    =====================================================================
    HOMER-style Ensembl .gff3 repeat generator.

    This program generates a HOMER-style .gff3 file of genome repeats
    extracted from Ensembl. The Ensembl database version is controlled by
    the git repository for the Ensembl Perl API. To switch to a different
    Ensembl version, use git checkout before invoking this program.
    =====================================================================

    Ens2HOMER_Extract_Repeats.pl -species <species_name> [-help]

      arguments:
        species:   Species name, for example danio_rerio.
        help:      Displays this help message.

