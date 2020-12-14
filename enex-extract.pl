#! /usr/bin/perl -w    

# enex-extract.pl
# exztracts attachments from Evernote Export file (.enex)

# This script takes the name(s) of one or more .enex files as its arguments, 
# and extracts all file and image attachments to separate files. If a file 
# already exists, the script will append a number to the filename to make it 
# unique.

# Version 1, Dec 2020

use warnings;
use v5.10; 

use Data::Dumper;
use XML::Twig; 
use Getopt::Std;
use MIME::Base64;

# define handler for resource tag; all other tags in the file will be 
# igored

my $twig=XML::Twig->new(   
  twig_handlers => 
    { resource => \&exportResource
    }); 

# iterate over command line arguments

foreach my $inputFileName (@ARGV) {
  say "Parsing $inputFileName: ";
  $twig->parsefile($inputFileName);
}

# And that's all, folks.
 
# handler for resource tag
sub exportResource { 
  my( $twig, $elt)= @_;

  # get Filename      
  my $encodedFileName = $elt -> first_child ('resource-attributes') -> first_child_text ('file-name');
  my ($baseName, $extension) = ($encodedFileName =~ /^(.+)\.(\w+)$/);
  my $actualFileName = $encodedFileName; 
  my $count = 0; 
  while (-e $actualFileName) {
    $actualFileName = $baseName . (++$count) . "." .$extension; 
  }
  say "  Saving $encodedFileName as $actualFileName."; 

  # decode and write file
  my $base64text = $elt -> first_child_text ('data'); 
  open(OUTFILE, '>:raw', $actualFileName) or die $!;
  print OUTFILE (decode_base64 ($base64text));
  close(OUTFILE);   
}