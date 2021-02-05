#!/opt/local/bin/perl5.30 -w
#use strict;

use Data::Dumper;
use File::Basename;
use LWP::UserAgent;
use HTTP::Request;
use JSON;

my $ua = new LWP::UserAgent;
$ua->agent("Perl API Client/1.0");
$ua->timeout(30);

my @valid_extensions = qw/\.mkv \.mp4 \.avi/;

my @dir;

opendir DIR,".";
@dir = readdir(DIR);
@dir = sort {$a cmp $b} @dir;
close DIR;

my @file_list;
my @nuked_list;

foreach(@dir){
  next if ( ($_ =~ /\.sfv$/) || ($_ =~ /^\./ )) ;

  print "$_ ";

  my ($name,$dir,$ext) = fileparse($_, @valid_extensions);
  if(length($ext) == 0) {
    print $_ . " has no valid extension\n";
    exit;
  }

  $crc32 = `crc32 "$_"`;
  $crc32 =~ s/\r?\n\z//;

  print " [$crc32] ";

  my $srrdb_crc = "https://www.srrdb.com/api/search/archive-crc:$crc32";

  while(1) {
    my $request = HTTP::Request->new("GET" => $srrdb_crc);
    $response = $ua->request($request);

    if( $response->content =~ /results/ ) {
      last;
    }

    print "\n\tRetrying srrdb";
    sleep 5;
  }

  my $json_obj = JSON->new->utf8->decode($response->content);

  if( !defined( $json_obj->{'results'}[0]{'release'} ) ) {
    print " crc32 not found \n";
    next;
  }

  if( $_ ne $json_obj->{'results'}[0]{'release'} . ${ext} ) {
    system("mv ${_} $json_obj->{'results'}[0]{'release'}${ext}");
  } 

  $srrdb_name = $json_obj->{'results'}[0]{'release'};
  my $url = "https://predb.ovh/api/v1/?q=" . $srrdb_name;

  while(1) {
    my $request = HTTP::Request->new("GET" => $url);
    $response = $ua->request($request);

    if( !($response->content =~ /<!DOCTYPE html>/ ) ) {
      last;
    }

    print "\n\tRetrying predb";
    sleep 5;
  }

  $json_obj = JSON->new->utf8->decode($response->content);

  if ( $json_obj->{data}{rowCount} == 0 ) {
    print "\n\tnot found on predb";
  }

  for ( my $ii=0; $ii < $json_obj->{data}{rowCount}; $ii++ ) {
    if ( $json_obj->{data}{rows}[$ii]{name} eq $srrdb_name ) {
      if ( defined($json_obj->{data}{rows}[$ii]{nuke}{typeId}) && $json_obj->{data}{rows}[$ii]{nuke}{typeId} == 1 ) {
        print "\n\tnuked: " . $json_obj->{data}{rows}[$ii]{nuke}{reason} . "\n";
      }
    }
  }

  print "\n";

}


