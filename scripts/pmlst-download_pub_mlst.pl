#!/usr/bin/env perl

use strict;
use HTTP::Tiny;
use JSON;
use Data::Dumper;
use constant BASE_URI => 'http://rest.pubmlst.org';

my $HTTP = HTTP::Tiny->new();
my $schemes_uri = BASE_URI . '/db/pubmlst_plasmid_isolates/schemes';

sub get_json {
    my ($uri) = @_;
    my $response = $HTTP->get($uri);
    my $response_content_json = decode_json $response->{content};
    return $response_content_json;
}

my @schemes = @{ get_json($schemes_uri)->{schemes} };
my $num_schemes = @schemes;

print STDERR "There are $num_schemes pMLST schemes.\n";


sub process_mlst_scheme_name {
    my ($scheme_name) = @_;
    $scheme_name =~ s/\s+/__/;
    $scheme_name =~ s/\//_/;
    return $scheme_name;
}

sub download_pmlst_scheme_alleles {
    my ($scheme_name, $scheme_uri, $scheme_dir) = @_;
    (my $seqdef_uri = $scheme_uri) =~ s/isolates/seqdef/; 
    my @loci = @{ get_json($seqdef_uri)->{loci} };
    system "mkdir $scheme_dir";
    foreach my $locus (@loci) {
	print $locus . "\n";
	my $locus_info = get_json($locus);
	my $locus_id = $locus_info->{id};
	my $locus_fasta_uri = $locus_info->{alleles_fasta};
	my $locus_filename = $locus_id . ".tfa";
	system "cd $scheme_dir && wget -q -O $locus_filename $locus_fasta_uri";
    }
}

foreach my $scheme (@schemes) {
    my $scheme_uri = $scheme->{scheme};
    my $scheme_name = $scheme->{description};
    my $processed_scheme_name = process_mlst_scheme_name($scheme_name);
    print STDERR ("Scheme ",  $scheme_name, " (", $processed_scheme_name, ") ", $scheme_uri, "\n");
    
    download_pmlst_scheme_alleles($scheme_name, $scheme_uri, $processed_scheme_name);

}

