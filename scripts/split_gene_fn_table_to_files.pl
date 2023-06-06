#!/usr/bin/env perl 

# Program: split_gene_fn_table_to_files.pl
# S. Cannon 

use strict;
use warnings;
use Getopt::Long;

my ($input_table, $out_dir, $help);
my $field_num = 1;

GetOptions (
  "input_table=s" => \$input_table,
  "out_dir=s"     => \$out_dir,
  "field_num:i"   => \$field_num,
  "help"          => \$help
);

my $usage = <<EOS;
Usage: $0  -in input_table -out out_dir  -field field_num
  Input is a table to be split into yaml-format files, with the latter 
  named by UNIQUE values in the indicated field of the input table.

  The first row without leading "#" in the first element is taken as row headers. 
  
  Required:
  -input_table  Name of input table to be split
  -out_dir   Name of directory for output

  Optional
  -field_name   Number of field to use for naming output files (one-indexed) Default: 1
                Values in this field should be suitable for file-naming, 
                  and the file should be sorted by this column.
  -help         Displays this info
EOS

die "\n$usage\n" if $help;
die "\n$usage\n" unless ($input_table && $out_dir); 

opendir (DIR, "$out_dir") or mkdir($out_dir); close DIR;

open (my $IN, '<', $input_table) or die "can't open in $input_table:$!";

my %seen;
my @header;

my $record_count = 0;
while (my $line = <$IN>) {
  chomp $line;  
  if ($line =~ m/^#|^$/){
    next
  }
  else {
    $record_count++;
  }

  my @elements = split /\t/, $line;

  if ($record_count == 1){
    @header = @elements;
    next;
  }

  my $file_out = $elements[$field_num-1];

  my $i = 0;
  
  if ($seen{$file_out}) {
    next;
  }
  else {
    $seen{$file_out}++;
    my $out_file = "$out_dir/$file_out.yml";
    open (my $OUT, "> $out_file") or die "can't open out $out_file: $!";
    print "Printing $file_out\n";
    print $OUT "---\n";
    for my $key (@header){
      my $value = $elements[$i];
      if ($key =~ /gene_symbols|comments|traits|curators/){
        if ($value){
          my @parts = split(/\|/, $value);
          print $OUT "$key:\n";
          for my $part (@parts) {
            print $OUT "  - $part\n";
          } 
        }
      }
      elsif ($value){
        if ($value =~ /:/) {
          print $OUT "$key: \"$value\"\n";
        }
        else {
          print $OUT "$key: $value\n";
        }
      }
      else {
        print $OUT "$key: ~\n";
      }
      $i++;
    }
  }
}

# Version
# 2022-06 Started (based on split_table_to_files.pl)
# 2023-06-04 Update to match fields and yaml structure from 2023 gene-function-registry


