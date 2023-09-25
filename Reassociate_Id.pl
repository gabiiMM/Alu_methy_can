#!/usr/bin/perl
use strict;
use warnings;

if (@ARGV != 3) {
    die "Usage: perl script.pl Beta_value_file Dict_file Alu Output_file\n";
}

my %dictionary;

my $untrans = 0;

my $File_1 = $ARGV[0];
my $File_2 = $ARGV[1];
my $outfile = $ARGV[2];

my $base_file_1 = (split /\./, (split /\//, $File_1)[-1])[0];
my $base_file_2 = (split /\./, (split /\//, $File_2)[-1])[0];

open my $infile, '<', $File_1 or die "Could not open $File_1: $!";
open my $dictfile, '<', $File_2 or die "Could not open $File_2: $!";
open my $out, '>', $outfile or die "Could not open $outfile: $!";

while (my $line1 = <$dictfile>) {
    chomp $line1;
    my @col1 = split("\t", $line1);
    $dictionary{$col1[0]} = join("\t", @col1[1..$#col1]);
}

while (my $line2 = <$infile>) {
    chomp $line2;
    my @col2 = split("\t", $line2);
    if (exists $dictionary{$col2[0]}) {
        print $out "$col2[0]\t$dictionary{$col2[0]}\t", join("\t", @col2[1..$#col2]), "\n";
    } else {
        $untrans++;
    }
}

print "$base_file_1 not associated with $base_file_2: $untrans\n";

close $infile;
close $dictfile;
close $out;
