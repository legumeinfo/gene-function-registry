#!/usr/bin/env perl
  
use warnings;
use strict;
use YAML::PP;
use YAML::PP::Common qw/ :PRESERVE /;
use JSON::Parse 'parse_json';
use Getopt::Long;
use Text::Wrap;
#use Data::Dumper;
use utf8;
use open qw( :std :encoding(UTF-8) );
use feature "say";

my $usage = <<EOS;
  Synopsis: get_citations.pl -traits gensp.traits.yml -cit_out gensp.citations.txt

  This script uses information in a yaml-format traits file to evaluate and fill in 
  missing citation values (pmid from doi or doi from pmid), and to generate 
  a citations file that can be used for additional work.
  Citation elements are filled in, if null, from a citation file (-in_cit) if provided,
  or otherwise from the PubMed idconv citation service.

  Required:
    -traits    Filename of yaml-format traits file (required).
    -cit_out   Name of file file to hold doi, pmid, and citation (required).

  Options:
    -in_cit    Filename of three-column file with PubMed citation handles: 
                 doi  pmid   citation[author, author et al., year]
               If citations in the traits file are found in this file, the citation handles
               will be drawn from this file; otherwise, from the PubMed idconv citation service.
    -yml_out   Filename of yaml-format traits to write, filling in doi and/or pmid.
    -overwrite To overwrite the yml_out and cit_out files, if they exist already (boolean).
    -verbose   Write some status info to stderr.
    -help      This message (boolean).
EOS

my ($traits, $help, $verbose, $yml_out, $cit_out, $in_cit);
my $doc_count = 1;
my $apibase = "https://api.ncbi.nlm.nih.gov/lit/ctxp/v1/pubmed";
my $overwrite=0;
my $sleepytime=2;
my $width = 100;  # Wrap at this number of characters

GetOptions (
  "traits=s" =>   \$traits,  # required
  "cit_out=s" =>  \$cit_out, # retuired
  "yml_out:s" =>  \$yml_out,
  "in_cit:s" =>   \$in_cit,
  "doc_count:i" => \$doc_count,
  "overwrite" =>  \$overwrite,
  "verbose" =>    \$verbose,
  "help" =>       \$help,
);

die "$usage" unless (defined($traits) && defined($cit_out));
die "$usage" if ($help);

if ( defined($yml_out) && -e $yml_out){ die "File $yml_out exists already.\n" unless ($overwrite) }
my $YML_FH;
if ($yml_out){
  open ($YML_FH, ">", $yml_out) or die "can't open out yml_out, $yml_out: $!";
}

if ( defined($yml_out) && -e $cit_out){ die "File $cit_out exists already.\n" unless ($overwrite) }
my $CIT_OUT_FH;
if ($cit_out){
  open ($CIT_OUT_FH, ">", $cit_out) or die "can't open out cit_out, $cit_out: $!";
}

my (%seen_doi, %seen_pmid);
my (%cit_doi_HoA, %cit_pmid_HoA); # Key one hash on the doi and one on the pmid, to allow later checks on these.
if ( defined($in_cit) && -e $in_cit){ die "File $in_cit exists already.\n" unless ($overwrite) }
my $CIT_IN_FH;
if ($in_cit){
  open ($CIT_IN_FH, "<", $in_cit) or die "can't open in in_cit, $in_cit: $!";
  while (<$CIT_IN_FH>){
    chomp;
    next unless /^(.*?)\t\s*/; 
    my ($doi, $pmid, $cit_str) = split(/\t/, $_);
    unless ( $doi eq "null" ){ $seen_doi{$doi}++ }
    unless ( $pmid eq "null" ){ $seen_pmid{$pmid}++ }
    $cit_doi_HoA{$doi} = [$doi, $pmid, $cit_str];
    $cit_pmid_HoA{$pmid} = [$doi, $pmid, $cit_str];
    #print "$doi, $pmid, $cit_str\n";
  }
}

my $yp = YAML::PP->new( preserve => YAML::PP::Common->PRESERVE_ORDER );
my @yaml = $yp->load_file( $traits );

for my $doc_ref ( @yaml ){
  &printstr_yml( "---" );
  while (my ($key, $value) = each (%{$doc_ref})){
    if ($key =~ /references/){
      &printstr_yml( "references:" );
      foreach my $cit ( @{ $value } ){

        # Put the four elements of the citation into an ordered array
        my @pubmed_components;
        my @cit_elts = qw(null null null);
        my @updated_cit = qw(null null null); 
        while (my ($k, $v) = each (%{$cit})){
          if ( $k =~ /citation/ ){ if ( defined $v && $v !~ /null|~/ ){ $cit_elts[0] = $v } }
          elsif ( $k =~ /doi/ ){ if ( defined $v && $v !~ /null|~/ ){ $cit_elts[1] = $v } }
          elsif ( $k =~ /pmid/ ){ if ( defined $v && $v !~ /null|~/ ){ $cit_elts[2] = $v } }
          else { warn "Unrecognized citation key: $k\n"; }
        }

        ## citation ##
        my $citation = $cit_elts[0];
        
        say "  == AA: ", join(", ", @cit_elts);

        ## other components: doi & pmid ##
        my ($doi, $pmid) = ( $cit_elts[1], $cit_elts[2] );
        if ( $pmid !~ /null|~/ ){ # get doi (PubMed IDs) from pmid
          # say "CHECK: get_ids for pmid $pmid";
          @pubmed_components = &get_ids("pmid", $pmid);
        }
        elsif ( $doi !~ /null|~/ ){ # get pmid (and all PubMed IDs) from doi
          # say "CHECK: get_ids for doi $doi";
          @pubmed_components = &get_ids("doi", $doi);
        }

        # say "  == BB: ", join(", ", @pubmed_components);
        say "";
        $doi = $pubmed_components[0];
        $pmid = $pubmed_components[1];
        &printstr_yml( "  - citation: $citation" );
        &printstr_yml( "    doi: $doi" );
        &printstr_yml( "    pmid: $pmid" );

        if ( $seen_doi{$doi} ){
          #say "  == CC: ", join(", ", @pubmed_components, $citation);
          next;
        }
        else {
          #say "  == DD: ", join(", ", @pubmed_components, $citation);
          $cit_doi_HoA{$doi} = [@pubmed_components, $citation];
          $seen_doi{$doi}++; 
        }
      }
    }
    elsif ($key =~ /traits/){
      &printstr_yml( "traits:" );
      foreach my $trait (@{ $value }){
        while (my ($k, $v) = each (%{$trait})){
          if ($k =~ /name/) { # e.g. entity_name, relation_name, quality_name
            &printstr_yml( "  - $k: $v" );
          }
          else {  # e.g. entity, relation, quality
            &printstr_yml( "    $k: $v" );
          }
        }
      }
    }
    elsif ($key =~ /gene_symbols|curators|comments/){
      &printstr_yml( "$key:" );
      foreach my $val (@{ $value }){
        &printstr_yml( "  - $val" );
      }
    }
    else {
      if ( defined $value && $value !~ /null|~/ ){ &printstr_yml( "$key: $value" ) }
      else { &printstr_yml( "$key: null" ) }
    }
  }
  $doc_count++;
  &printstr_yml("");
}

if ($verbose){ warn "\nPrinting table of identifiers and citations\n"}
# Print table of citations
for my $doi (keys %cit_doi_HoA){
  my $pmid = @{$cit_doi_HoA{$doi}}[1];
  my $nlm_cite;
  if ($pmid =~ /null/){
    $nlm_cite = "Reference not retrieved, as the pubmed ID is null."
  }
  else {
    #say "  == JJ: PMID is $pmid";
    if ($verbose){ warn "  == Retrieving and printing citation for $pmid\n"; }
    my $pubmed_request = "https://api.ncbi.nlm.nih.gov/lit/ctxp/v1/pubmed/?format=citation&contenttype=json&id=$pmid";
    my $result_json = qx{curl --silent "$pubmed_request"};
    sleep($sleepytime);

    # Parse the json result by converting it to a perl hash of hashes; then pull out the "nlm" "format" element.
    my $result_perl = parse_json ($result_json);
    #say "\n", Dumper($result_perl), "\n";
    while ( my ($k, $v) = each %{$result_perl} ){
      #say "\nCHECK: for $k: $v";
      if ($k =~ /nlm/){
        while ( my ($k2, $v2) = each %{$v} ){
          if ($k2 =~ /format/) { $nlm_cite = $v2 }
        }
      }
    }
    
    say $CIT_OUT_FH join("\t", @{$cit_doi_HoA{$doi}}), "\t\"", $nlm_cite, "\"";
  }
}

#####################
sub printstr_yml {
  my $str_to_print = shift;
  my $wrapped;
  $Text::Wrap::columns=$width;
  if ($str_to_print =~ /^(\s+- )(\S+.+)/){
    my $initial = $1;          # leading space-indent and dash
    my $string_first_line= $2; # portion of string that is on the line of the key
    my $subsequent = " "x(length($initial)+2); # spaces for indented lines
    $wrapped = fill(" ", $subsequent, "$initial$string_first_line");
    $str_to_print = $wrapped;
  }
  elsif ($str_to_print =~ /^(\S+): (\S+.+)/){
    my $key = $1; 
    my $val = $2; 
    my $initial = "";      # No indent for first-level key 
    my $subsequent = "  "; # two-space indent for wrapped text of first-level keys
    $wrapped = fill("", $subsequent, "$key: $val");
    $str_to_print = $wrapped;
  }
  if ($YML_FH) {
    say $YML_FH $str_to_print;
  }
  else {
    say $str_to_print;
  }
}

sub get_ids {
  my $cit_type = shift;
  my $cit_id = shift;
  my ($doi_str, $pmid_str, $citation) = qw(null null null null);
  if ($cit_doi_HoA{$cit_id}){
    ($doi_str, $pmid_str, $citation) = @{$cit_doi_HoA{$cit_id}};
    if ($verbose){ warn "  == Filling in from cit_doi_HoA: $doi_str, $pmid_str, $citation\n"; }
  }
  elsif ($cit_pmid_HoA{$cit_id}){
    ($doi_str, $pmid_str, $citation) = @{$cit_pmid_HoA{$cit_id}};
    if ($verbose){ warn "  == Filling in from cit_pmid_HoA: $cit_id, $pmid_str, $citation\n"; }
  }
  else { # get citation components from the service
    if ($verbose){ warn "  == Retrieving PubMed ID components for type $cit_type, ID $cit_id\n" }
    my ($crossref_base, $ncbi_base, $curl_string);
    if ($cit_type =~ /doi/){
      $crossref_base = "https://api.crossref.org/works";
      $curl_string = "curl --silent \"$crossref_base/works/$cit_id\"";
      say "  == EE: Lookup doi $cit_id: $curl_string";
    }
    elsif ($cit_type =~ /pmid/){
      $ncbi_base = "https://api.ncbi.nlm.nih.gov/lit/ctxp/v1/pubmed";
      $curl_string = "curl --silent \"$ncbi_base/?format=citation&id=$cit_id\""; 
      say "  == FF: Lookup pmid $cit_id: $curl_string";
    }
    else {
      die "Unexpected ID type: [$cit_id].\n";
    }
    my $json_response = `$curl_string`;
    # say "=====\n$json_response=====";
     
    if ($json_response =~ /\"DOI\":\"([^"]+)\"/i || $json_response =~ /doi:([^"]+)\"/i){ $doi_str = $1; }
    # say "  == GG: DOI: $doi_str";
    
    if ($json_response =~ /pmid:(\d+)/i || $json_response =~ /PMID: (\d+)/i){ $pmid_str = $1; }
    # say "  == HH: PMID: $pmid_str";
    
    sleep($sleepytime);
  }
  my @components = ($doi_str, $pmid_str);
  return (@components);
}

__END__

S. Cannon
2023-04-30 Initial version, using the PubMed/NLM idconv citation service
2023-05-01 Switch to fatcat biblio lookup service
2023-05-03 Change grouping of ontology terms, adding e.g. entity_name to go with entity
2023-06-22 Handle key-value pairs for which the value is an array: comments, curators, gene_symbols
2023-06-23 Add doc_count as parameter
2024-09-15 Specify input and output as utf-8
2025-05-07 Change from api.fatcat.wiki to api.ncbi.nlm.nih.gov. Wrap long lines in yml

