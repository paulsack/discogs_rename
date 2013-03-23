#!/usr/bin/perl -w

use Getopt::Std;
use WWW::Discogs;
use MP3::Tag;

getopts('n:');

die "Usage: pipe sorted filelist | discogs_rename.pl -n [discogs album id]\n" unless ($opt_n);

my $client = WWW::Discogs->new;
my $release = $client->release(id => $opt_n);
my $artist = ($release->artists)[0]->{name};

print $release->title, ' BY ', $artist, ' RELEASED ', $release->year, "\n";

my $tracknum = 1;
for my $track ($release->tracklist) {
  my $file = <STDIN>;
  chomp($file);
  print "$file: ", $track->{title}, "\n";
  my $mp3 = MP3::Tag->new($file);
  my $id3v2 = $mp3->new_tag("ID3v2");
  $id3v2->title($track->{title});
  $id3v2->artist($artist);
  $id3v2->album($release->title);
  $id3v2->year($release->year);
  $id3v2->track($tracknum);
  $id3v2->write_tag();
  $tracknum++;
}
