#!/usr/bin/env perl
  
use warnings;
use strict;
use YAML::PP;
use YAML::PP::Common;
use JSON::Parse 'parse_json';
use Getopt::Long;
use Text::Wrap;
use Data::Dumper;
use utf8;
use open qw( :std :encoding(UTF-8) );
use feature "say";

my $usage = <<EOS;
  Synopsis: get_citations.pl -cit_out gensp.citations.txt FILE[s].yml

  This script uses information in one or more yaml-format traits files to evaluate and 
  fill in missing citation values (pmid from doi or doi from pmid), and to generate 
  a citations file that can be used for additional work.

  Citation elements are filled in, if null, from a citation file (-in_cit) if provided,
  or otherwise from the PubMed idconv citation service if a PMID is available
  or from the crossref service if only the DOI is available.

  Unless "-trust" is indicated, the PMID and DOI values will be updated from the
  indicated services if there are differences in either between the provided yaml file(s)
  and the values from the services.

  Required:
    (on ARGV)  One or more filenames of yaml-format traits files
    -cit_out   Name of file file to hold doi, pmid, and citation

  Options:
    -in_cit    Filename of three-column file with PubMed citation handles: 
                 doi  pmid   citation[author, author et al., year]
               If citations in the traits file(s) are found in this file, the citation handles
               will be drawn from this file; otherwise, from the PubMed idconv citation service.
    -yml_out   Filename of yaml-format traits to write, filling in doi and/or pmid.
    -overwrite To overwrite the yml_out and cit_out files, if they exist already (boolean).
    -trust     Trust the DOI and PMID as given in the input yaml; otherwise, check both
                 against crossref and update if there is a discrepancy -- for example, in
                 the capitalization in the DOI string.
    -verbose   Write some status info to stderr. Call twice for even more info.
    -help      This message (boolean).
EOS

my ($help, $yml_out, $cit_out, $in_cit);
my $apibase = "https://api.ncbi.nlm.nih.gov/lit/ctxp/v1/pubmed";
my ($overwrite, $trust, $verbose) = (0, 0, 0);
my $sleepytime=2; # Wait time
my $width = 80;   # Wrap yaml strings at this number of characters

GetOptions (
  "cit_out=s" =>  \$cit_out, # retuired
  "yml_out:s" =>  \$yml_out,
  "in_cit:s" =>   \$in_cit,
  "overwrite" =>  \$overwrite,
  "trust" =>      \$trust,
  "verbose+" =>   \$verbose,
  "help" =>       \$help,
);

if (scalar(@ARGV)==0){
  print "\n$usage\n";
  die "Please provide one or more TRAIT.yml files as the first argument.\n\n";
}
die "$usage" unless defined($cit_out);
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

# If a table of citations has been provided (via -in_cit), read it into a hash of arrays
my (%seen_doi, %seen_pmid);
my (%cit_elts_HoA); # Key hash on the doi if present, else pmid, to allow later checks on these.
if ( defined($in_cit) && -e $in_cit){ die "File $in_cit exists already.\n" unless ($overwrite) }
my $CIT_IN_FH;
if ($in_cit){
  open ($CIT_IN_FH, "<", $in_cit) or die "can't open in in_cit, $in_cit: $!";
  while (<$CIT_IN_FH>){
    chomp;
    next unless /^(.*?)\t\s*/; 
    my ($doi, $pmid, $cit_str) = split(/\t/, $_);
    my $cit_id;
    if ( $doi ne "null" ){
      $cit_elts_HoA{$pmid} = [$doi, $pmid, $cit_str];
      $cit_id = $doi;
    }
    elsif ( $doi eq "null" && $pmid ne "null" ){
      $cit_elts_HoA{$doi} = [$doi, $pmid, $cit_str];
      $cit_id = $pmid;
    }
    else {
      die "At least one of the DOI or PMID must be provided.\n";
    }
    unless ( $pmid eq "null" ){ $seen_pmid{$pmid}++ }
    unless ( $doi eq "null" ){ $seen_doi{$doi}++ }
    print "$doi, $pmid, $cit_str\n";
  }
}

print "\n==========\n";
print "Reading all yaml files from \@ARGV and combining into one variable.\n";
my $combined_content;
foreach my $filename (@ARGV) {
  open my $fh, '<', $filename or die "Could not open file '$filename': $!";
  local $/ = undef; # Slurp mode: read the whole file at once
  $combined_content .= <$fh>;
  close $fh;
}

my $yp = YAML::PP->new( preserve => YAML::PP::Common->PRESERVE_ORDER );
my @yaml = $yp->load_string( $combined_content );

say "\n==========";
say "Process combined yaml and retrieve citations. To see details, call with \"-v\" or \"-v -v\"\n";
for my $doc_ref ( @yaml ){
  &printstr_yml( "---" );
  while (my ($key, $value) = each (%{$doc_ref})){
    if ($key =~ /references/){
      &printstr_yml( "references:" );
      foreach my $cit ( @{ $value } ){
        
        # Put the three elements of the citation (auth-auth-year, doi, pmid) into an ordered array
        my @pubmed_components; # will hold $doi, $pmid
        my @cit_elts = qw(null null null);
        my @updated_cit = qw(null null null); 
        while (my ($k, $v) = each (%{$cit})){
          if ( $k =~ /citation/ ){ if ( defined $v && $v !~ /null|~/ ){ $cit_elts[0] = $v } }
          elsif ( $k =~ /doi/ ){ if ( defined $v && $v !~ /null|~/ ){ $cit_elts[1] = $v } }
          elsif ( $k =~ /pmid/ ){ if ( defined $v && $v !~ /null|~/ ){ $cit_elts[2] = $v } }
          else { warn "Unrecognized citation key: $k\n"; }
        }

        ## citation ##
        my $cit_str = $cit_elts[0];
        
        if ($verbose){ say "    >> AA: ", join(", ", @cit_elts) }

        ## other components: doi & pmid ##
        my ($doi, $pmid) = ( $cit_elts[1], $cit_elts[2] );

        # CASE: Both doi and pmid are present; CHECK BOTH AGAINST CROSSREF
        if ( $doi !~ /null|~/ && $pmid !~ /null|~/ ){ 
          if ($verbose>1){ say "     CHECK: both doi and pmid are present; $doi, $pmid"; }
          if (not $trust){ # Default is to recheck the DOI and PMID against crossref
            @pubmed_components = &check_doi_and_pmid($doi, $pmid);
            $cit_elts_HoA{$doi} = [@pubmed_components, $cit_str];
          }
          else { #trust that the DOI and PMID are correct as provided
            @pubmed_components = ($doi, $pmid);
            $cit_elts_HoA{$doi} = [@pubmed_components, $cit_str];
          }
          if ( ! $seen_doi{$doi} ){
            $seen_doi{$doi}++;
          }
          if ( ! $seen_pmid{$pmid} ){
            $seen_pmid{$pmid}++;
          }
        }
        # CASE: doi is present but pmid is not; GET THE PMID, GIVEN THE DOI
        elsif ( $doi !~ /null|~/ && $pmid =~ /null|~/ ){ 
          if ( ! $seen_doi{$doi} ){
            if ($verbose>1){ say "     CHECK: doi is present but pmid is not; GET THE PMID, GIVEN THE DOI"; }
            @pubmed_components = &get_pmid_given_doi($doi);
            $cit_elts_HoA{$doi} = [@pubmed_components, $cit_str];
            $seen_doi{$doi}++;
          }
          else {
            @pubmed_components = ($doi, $pmid);
          }
        }
        # CASE: pmid is present but doi is not; GET THE DOI, GIVEN THE PMID
        elsif ( $doi =~ /null|~/ && $pmid !~ /null|~/ ){ 
          if ( ! $seen_pmid{$pmid} ){
            if ($verbose>1){ say "     CHECK: pmid is present but doi is not; GET THE DOI, GIVEN THE PMID"; }
            @pubmed_components = &get_doi_given_pmid($pmid);
            $cit_elts_HoA{$pmid} = [@pubmed_components, $cit_str];
            $seen_pmid{$pmid}++;
          }
          else {
            @pubmed_components = ($doi, $pmid);
          }
        }

        if ($verbose){ say "    >> BB: ", join(", ", @pubmed_components); }
        $doi = $pubmed_components[0];
        $pmid = $pubmed_components[1];
        &printstr_yml( "  - citation: $cit_str" );
        &printstr_yml( "    doi: $doi" );
        &printstr_yml( "    pmid: $pmid" );
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
      if ($key =~ /gene_symbols/){
        say "  == Processing record for symbols ", join(", ", @{ $value });
      }
    }
    else {
      if ( defined $value && $value !~ /null|~/ ){ &printstr_yml( "$key: $value" ) }
      else { &printstr_yml( "$key: null" ) }
    }
  }
  &printstr_yml("");
}

say "\n==========";
say "Merge citation elements where possible, keying on citation";
my (%cit_elts_by_cit_HoA, %prev_doi, %prev_pmid);
for my $cit_id (sort keys %cit_elts_HoA){
  my $doi = @{$cit_elts_HoA{$cit_id}}[0];
  my $pmid = @{$cit_elts_HoA{$cit_id}}[1];
  my $cite_str = @{$cit_elts_HoA{$cit_id}}[2];

  if ($prev_doi{$cite_str}){$doi = $prev_doi{$cite_str}}
  if ($prev_pmid{$cite_str}){$pmid = $prev_pmid{$cite_str}}
  $cit_elts_by_cit_HoA{$cite_str} = [$doi, $pmid, $cite_str];

  $prev_doi{$cite_str}  = $doi unless $doi  eq "null";
  $prev_pmid{$cite_str} = $pmid unless $pmid eq "null";
}

say "\n==========";
say "Print table of identifiers and citations\n";
for my $cit_id (sort keys %cit_elts_by_cit_HoA){
  my $doi     = @{$cit_elts_by_cit_HoA{$cit_id}}[0];
  my $pmid    = @{$cit_elts_by_cit_HoA{$cit_id}}[1];
  my $cit_str = @{$cit_elts_by_cit_HoA{$cit_id}}[2];

  say "  == $doi, $pmid, $cit_str";
  my ($nlm_cite, $title_str);
  if ($pmid !~ /null|~/){ 
    if ($verbose){ say "    >> First choice: use PMID to retrieve citation"; }
    if ($verbose){ say "    >> KK: PMID is $pmid"; }
    if ($verbose){ print "\n  == Retrieving and printing citation for $pmid\n"; }
    my $pubmed_request = "https://api.ncbi.nlm.nih.gov/lit/ctxp/v1/pubmed/?format=citation&contenttype=json&id=$pmid";
    my $json_response = qx{curl --silent "$pubmed_request"};
    sleep($sleepytime);

    # Parse the json result by converting it to a perl hash of hashes; then pull out the "nlm" "format" element.
    my $result_perl = parse_json ($json_response);
    #say "\n", Dumper($result_perl), "\n";
    while ( my ($k, $v) = each %{$result_perl} ){
      #say "\n     CHECK: for $k: $v";
      if ($k =~ /nlm/){
        while ( my ($k2, $v2) = each %{$v} ){
          if ($k2 =~ /format/) { 
            $nlm_cite = $v2;
            if ($verbose>1){ say "    >> ZZ1: nlm_cite is $nlm_cite"; }
          }
        }
      }
    }
    say $CIT_OUT_FH join("\t", $doi, $pmid, $cit_str, $nlm_cite);
  }
  elsif ($doi !~ /null|~/){ 
    if ($verbose){ say "    >> Second choice: use DOI. Note that the citation won't be reported."; }
    if ($verbose){ say "    >> LL: DOI is $doi"; }
    if ($verbose){ print "\n    >> Retrieving and printing citation for $doi\n"; }

    my ($crossref_base, $ncbi_base, $curl_string);
    $crossref_base = "https://api.crossref.org/works";
    $curl_string = "curl --silent \"$crossref_base/works/$doi\"";
    if ($verbose){ say "    >> EE2: Lookup doi $doi: $curl_string" }

    my $json_response = `$curl_string`;
    # say "=====\nJSON:\n$json_response\n=====";

    sleep($sleepytime);

    # Parse the json result by converting it to a perl hash of hashes; then pull out the "nlm" "format" element.
    my $result_perl = parse_json ($json_response);
    #say "\n", Dumper($result_perl), "\n";
    while ( my ($k, $v) = each %{$result_perl} ){
      #say "\n     CHECK: for $k: $v";
      if ($k eq "message"){
        while ( my ($k2, $v2) = each %{$v} ){
          if ($k2 eq "title") { 
            $title_str = $v2->[0];
            if ($verbose>1){ say "    >> ZZ2: title is: $title_str"; }
          }
        }
      }
    }
    my $warn_str = "WARNING Citation not reported, given DOI only. Title:";
    say $CIT_OUT_FH join("\t", $doi, $pmid, $cit_str, "$warn_str $title_str");
  }
  else {
    die "WARNING: It appears that both doi and pmid are null. Please provide at least one; pmid preferred.\n";
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

#####
sub check_doi_and_pmid {
  my $doi_str = shift;
  my $pmid_str = shift;
  my $cit_str;
  if ($cit_elts_HoA{$doi_str}){ # If citation components were provided via -in_cit, use them (from doi)
    ($doi_str, $pmid_str, $cit_str) = @{$cit_elts_HoA{$doi_str}};
    if ($verbose){ print "    >> Filling in from cit_elts_HoA: $doi_str, $pmid_str, $cit_str\n"; }
  }
  else { # check elements against the service
    if ($verbose){ print "\n  == Retrieving PMID and DOI components, given DOI $doi_str\n" }
    my ($crossref_base, $curl_string);

    $crossref_base = "https://api.crossref.org/works";
    $curl_string = "curl --silent \"$crossref_base/works/$doi_str\"";
    if ($verbose){ say "    >> GG: Lookup $doi_str: $curl_string" }
    sleep($sleepytime);

    my $json_response = `$curl_string`;
    # say "=====\n$json_response\n=====";
     
    # Parse the json result by converting it to a perl hash of hashes; then pull out the DOI element.
    my $result_perl = parse_json ($json_response);
    #say "\n", Dumper($result_perl), "\n";
    while ( my ($k, $v) = each %{$result_perl} ){
      if ($k eq "message"){
        while ( my ($k2, $v2) = each %{$v} ){
          if ($k2 =~ /pmid/i){
            if ($v2 ne $pmid_str){
              if ($verbose){ say "     PMID in curation != PMID in crossref: $pmid_str, $v2"; }
              $pmid_str = $v2;
            }
            if ($verbose){ say "    >> HH1: PMID: $pmid_str"; }
          }
          if ($k2 =~ /DOI/i){
            if ($v2 ne $doi_str){
              if ($verbose){ say "     DOI in curation != DOI in crossref: $doi_str, $v2"; }
              $doi_str = $v2;
            }
            if ($verbose){ say "    >> HH2: DOI: $doi_str"; }
          }
        }
      }
    }
    unless (defined $pmid_str && length $pmid_str) {
      warn "     No PMID was found for DOI $doi_str\n";
      $pmid_str = "null";
    }
  }

  my @components = ($doi_str, $pmid_str);
  return (@components);
}
#####

sub get_pmid_given_doi {
  my $doi_str = shift;
  my ($pmid_str, $cit_str);
  if ($cit_elts_HoA{$doi_str}){ # If citation components were provided via -in_cit, use them (from doi)
    ($doi_str, $pmid_str, $cit_str) = @{$cit_elts_HoA{$doi_str}};
    if ($verbose){ print "    >> Filling in from cit_elts_HoA: $doi_str, $pmid_str, $cit_str\n"; }
  }
  else { # get citation components from the service
    if ($verbose){ print "\n  == Retrieving PubMed ID components, given DOI $doi_str\n" }
    my ($crossref_base, $curl_string);

    $crossref_base = "https://api.crossref.org/works";
    $curl_string = "curl --silent \"$crossref_base/works/$doi_str\"";
    if ($verbose){ say "    >> GG: Lookup $doi_str: $curl_string" }
    sleep($sleepytime);

    my $json_response = `$curl_string`;
    # say "=====\n$json_response\n=====";
     
    # Get the PMID, and handle it if missing
    # Parse the json result by converting it to a perl hash of hashes; then pull out the DOI element.
    my $result_perl = parse_json ($json_response);
    #say "\n", Dumper($result_perl), "\n";
    while ( my ($k, $v) = each %{$result_perl} ){
      if ($k eq "message"){
        while ( my ($k2, $v2) = each %{$v} ){
          if ($k2 =~ /pmid/i){
            $pmid_str = $v2;
            if ($verbose){ say "    >> HH1: PMID: $pmid_str"; }
          }
          if ($k2 =~ /DOI/i){
            if ($v2 ne $doi_str){
              warn "     DOI in curation != DOI in crossref: $doi_str, $v2; swapping";
              $doi_str = $v2;
            }
            if ($verbose){ say "    >> HH2: DOI: $doi_str"; }
          }
        }
      }
    }
    unless (defined $pmid_str && length $pmid_str) {
      warn "     No PMID was found for DOI $doi_str\n";
      $pmid_str = "null";
    }
  }

  my @components = ($doi_str, $pmid_str);
  return (@components);
}

sub get_doi_given_pmid {
  my $pmid_str = shift;
  my ($doi_str, $cit_str, $nlm_cite);
  if ($cit_elts_HoA{$pmid_str}){ # If citation components were provided via -in_cit, use them (from doi)
    ($doi_str, $pmid_str, $cit_str) = @{$cit_elts_HoA{$pmid_str}};
    if ($verbose){ print "    >> Filling in from cit_elts_HoA: $doi_str, $pmid_str, $cit_str\n"; }
  }
  else { # get citation components from the service
    if ($verbose){ print "\n  == Retrieving PubMed ID components, given PMID $pmid_str\n" }
    my ($ncbi_base, $curl_string);

    $ncbi_base = "https://api.ncbi.nlm.nih.gov/lit/ctxp/v1/pubmed";

    $curl_string = "curl --silent \"$ncbi_base/?format=citation&id=$pmid_str\""; 
    if ($verbose){ say "    >> II: Lookup $pmid_str: $curl_string\n" }
    sleep($sleepytime);

    my $json_response = `$curl_string`;
    # say "=====\nJSON:\n$json_response\n=====";

    # Parse the json result by converting it to a perl hash of hashes; then pull out the "nlm" "format" element.
    my $result_perl = parse_json ($json_response);
    #say "\n", Dumper($result_perl), "\n";
    while ( my ($k, $v) = each %{$result_perl} ){
      #say "\nCHECK: for $k: $v";
      if ($k =~ /nlm/){
        while ( my ($k2, $v2) = each %{$v} ){
          #say "YY: $k2, $v2";
          if ($k2 =~ /format/) { $nlm_cite = $v2 }
        }
      }
    }

    if ($nlm_cite =~ /.+ doi: (\S+) .+/i){ $doi_str = $1; }
    $doi_str =~ s/\.$//; # strip trailing period

    my $new_pmid_str;
    if ($nlm_cite =~ /.+ PMID: (\d+)/i){ $new_pmid_str = $1; }
    if ($new_pmid_str ne $pmid_str){
      warn "     PMID in curation != PMID in PubMed: $pmid_str, $new_pmid_str; swapping\n";
      $pmid_str = $new_pmid_str;
    }

    if ($verbose){ say "    >> JJ: DOI: $doi_str"; }
    unless (defined $doi_str && length $doi_str) {
      warn "     No DOI was found for PMID $pmid_str\n";
      $doi_str = "null";
    }
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
2024-09-15 Specify input and output as utf-8
2025-05-07 Change from api.fatcat.wiki to api.ncbi.nlm.nih.gov. Wrap long lines in yml.
2025-05-09 Remember doi and pmid components to avoid looking them up repeatedly
2025-07-01 Print citations sorted by doi
2025-07-28 Script overhaul to better extract DOI and PMID strings from the PubMed and Crossref services, and
            to merge elements relative to unique citations.

get_citations.pl -cit_out test.citations.txt -yml_out test.traits.yml -v -over test_in.yml
