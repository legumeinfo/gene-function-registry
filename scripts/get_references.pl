#!/usr/bin/env perl
  
use warnings;
use strict;
use Getopt::Long;
use feature "say";
use utf8;
use open qw( :std :encoding(UTF-8) );

my $usage = <<EOS;
  Synopsis: cat PMID_LIST | get_references.pl [options]
    OR
            get_references.pl [options] FILE.tsv

  This script takes in tabular data containing a field of pubmed IDs 
  (the table provided either as a file or via STDIN)
  and retrieves article summaries in MEDLINE format.

  Required:
    one or more PubMedIDs on stdin, e.g. \"echo 15471541 | get_references.pl\"
    OR a tabular citation file with PubMedIDs in a specified field (default column 2)..
       doi  pmid   pmcid  citation[author, author et al., year]

  Options:
    -out       Output filename
    -pmidcol   Column with pubmed IDs (zero indexed; default 1, for the second column)
    -verbose   Write some status info to stderr.
    -help      This message (boolean).
EOS

my $pmidcol=1;
my ($outfile, $verbose, $help);

GetOptions (
  "out:s" =>     \$outfile,
  "pmidcol:i" => \$pmidcol,
  "verbose" =>   \$verbose,
  "help" =>      \$help,
);

die "$usage" if ($help);
die "$usage" if (@ARGV == 0 && -t STDIN);

my $OUT_FH;
if ($outfile){
  open $OUT_FH, ">", $outfile or die "Can't open out $outfile: $!";
}

while (<>){
  chomp;
  my @line = split("\t", $_);
  my $pmid = $line[$pmidcol];
  &printstr("##### PUB RECORD #####");
  my $header = "## " . join ("  ", @line) . " ##";
  if ($OUT_FH){say "== Processing $header"}
  &printstr($header);
  if ($pmid eq "null"){
    &printstr("## Skipping retrieval of this record because there is no pubmed ID ##\n");
  }
  else {
    #my $medline_rec = `efetch -db pubmed -id $pmid -format medline`;
    # See https://dataguide.nlm.nih.gov/eutilities/utilities.html#efetch
    my $pubmed_request = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=$pmid&retmode=text&rettype=medline";
    my $medline_rec = qx{curl --silent "$pubmed_request"};
    &printstr("$medline_rec\n");
  }
  sleep(3);
}   

#####################
sub printstr {
  my $str_to_print = shift;
  if ($OUT_FH) {

    say $OUT_FH $str_to_print;
  }
  else {
    say $str_to_print;
  }
}

__END__

S. Cannon
2023-05-02 Initial version
2024-09-15 Specify input and output as utf-8
