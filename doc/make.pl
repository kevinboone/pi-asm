#!/usr/bin/perl -w
use strict;

my $MAIN_TITLE="ARM assembly-language programming for the Raspberry Pi";
my $TARGET_PREFIX="pi-asm";
my $TOC="target/$TARGET_PREFIX-toc.html";

my @files=`ls src/`;
my @titles = ();

foreach my $file (@files)
  {
  chomp $file;
  push (@titles, `head -1 src/$file`);
  }

foreach my $title (@titles)
  {
  chomp $title;
  }

my $index = 0;
my $count = scalar (@files);

foreach my $file (@files)
  {
  chomp $file;
  my $outfile = "target/$TARGET_PREFIX-$file";
  my $prev_file;
  my $next_file;
  my $prev_title;
  my $next_title;
  if ($index > 0) { $prev_file = $files[$index - 1]; }
  if ($index > 0) { $prev_title = $titles[$index - 1]; }
  if ($index < $count) { $next_file = $files[$index + 1]; }
  if ($index < $count) { $next_title = $titles[$index + 1]; }
  my $p = $index;
  my $t = $index + 1;
  my $n = $index + 2;
 
  open (OUT, ">$outfile") or die;

  print (OUT "<section>\n");
  print (OUT "<h1>$MAIN_TITLE</h1>\n");
  print (OUT "<h2>$t. $titles[$index]</h2>\n");

  open (IN, "<src/$file") or die; 
  my $line = 0;
  while (<IN>)
    {
    if ($line != 0) { print (OUT $_)};
    $line++;
    }
  close (IN);
  print (OUT "<hr/>\n");

  print (OUT "<ul>\n");
  if ($prev_file)
    {
    print (OUT "<li>\n");
    print (OUT "<a href=\"$TARGET_PREFIX-$prev_file\">Previous: $p. $prev_title</a>\n");
    print (OUT "</li>\n");
    }
  print (OUT "<li>\n");
  print (OUT "<a href=\"$TARGET_PREFIX-toc.html\">Table of contents</a>\n");
  print (OUT "</li>\n");
  if ($next_file)
    {
    print (OUT "<li>\n");
    print (OUT "<a href=\"$TARGET_PREFIX-$next_file\">Next: $n. $next_title</a>\n");
    print (OUT "</li>\n");
    }
  print (OUT "</ul>\n");

  print (OUT "<last-modified/>\n");
  print (OUT "</section>\n");
  close OUT; 

  $index++;
  }

open (OUT, ">$TOC") or die;

print (OUT "<section>\n");
print (OUT "<h1>$MAIN_TITLE</h1>\n");
print (OUT "<h2>Table of contents</h2>\n");
print (OUT "<p>\n");

for (my $i = 0; $i < $count; $i++)
  {
  my $n = $i + 1;
  print (OUT "<a href=\"$TARGET_PREFIX-$files[$i]\">$n. $titles[$i]</a><br/>\n");
  }

print (OUT "</p>\n");
print (OUT "<last-modified/>\n");
print (OUT "</section>\n");
close (OUT);


