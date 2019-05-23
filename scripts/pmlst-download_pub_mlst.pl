#!/usr/bin/env perl

use strict;
use HTTP::Tiny;
use JSON;
use Data::Dumper;
use constant BASE_URI => 'http://rest.pubmlst.org';


my $http = HTTP::Tiny->new();
my $schemes_uri = BASE_URI . '/db/pubmlst_plasmid_isolates/schemes';
my $response = $http->get($schemes_uri);
my $response_content_json = decode_json $response->{content};
my @schemes = @{ $response_content_json->{schemes} };
my $num_schemes = @schemes;

print STDERR "There are $num_schemes pMLST schemes.\n";

sub process_mlst_scheme_name {
    my ($scheme_name) = @_;
    $scheme_name =~ s/\s+/__/;
    $scheme_name =~ s/\//_/;
    return $scheme_name;
}

sub download_pmlst_scheme_alleles {
    my ($scheme_name, $scheme_url, $scheme_dir) = @_;
    (my $seqdef_url = $scheme_url) =~ s/isolates/seqdef/; 
    my $response = $http->get($seqdef_url);
    my $response_content_json = decode_json $response->{content};
    my @loci = @{ $response_content_json->{loci} };
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

