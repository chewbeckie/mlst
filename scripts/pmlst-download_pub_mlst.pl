#!/usr/bin/env perl

use strict;
use HTTP::Tiny;
use JSON;
use Data::Dumper;
use constant BASE_URI => 'http://rest.pubmlst.org';

my $http = HTTP::Tiny->new();
my $schemes_uri = BASE_URI . '/db/pubmlst_plasmid_isolates/schemes';

sub get_json {
    my ($http, $uri) = @_;
    my $response = $http->get($uri);
    my $response_content_json = decode_json $response->{content};
    return $response_content_json;
}

my @schemes = @{ get_json($http, $schemes_uri)->{schemes} };
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
    my @loci = @{ get_json($http, $seqdef_uri)->{loci} };
    return @loci;
}

foreach my $scheme (@schemes) {
    my $scheme_uri = $scheme->{scheme};
    my $scheme_name = $scheme->{description};
    my $processed_scheme_name = process_mlst_scheme_name($scheme_name);
    print STDERR ("Scheme ",  $scheme_name, " (", $processed_scheme_name, ") ", $scheme_uri, "\n");
    
    my @loci = download_pmlst_scheme_alleles($scheme_name, $scheme_uri, ".");

    foreach my $locus (@loci) {
	print $locus . "\n";
    }

}

