#!/usr/bin/perl
use strict;
use warnings;

if (@ARGV != 2) {
    die "Usage: perl sep_alu.pl File1 File2\n";
}

my ($file1, $file2) = @ARGV;

my $output_file_A = "I_Alu.tab";
my $output_file_B = "F_CpG.tab";
my $output_file_C = "F_Global.tab";

open(my $fh1, '<', $file1) or die "Error opening $file1: $!";
open(my $fh2, '<', $file2) or die "Error opening $file2: $!";

open(output_A, '>', $output_file_A) or die "Error creating $output_file_A: $!";
open(output_B, '>', $output_file_B) or die "Error creating $output_file_B: $!";
open(output_C, '>', $output_file_C) or die "Error creating $output_file_C: $!";

my %entries_file2;
while (my $line2 = <$fh2>) {
    chomp($line2);
    my @columns2 = split(/\s+/, $line2);
    my $chr2 = $columns2[0];
    push @{$entries_file2{$chr2}}, \@columns2;
}

close($fh2);

while (my $line1 = <$fh1>) {
    chomp($line1);
    my @columns1 = split(/\s+/, $line1);
    my $IlmnID = $columns1[0];
    my $chr1 = $columns1[1];
    my $Mapinfo = $columns1[2];
    my $Strand1 = $columns1[3];
    my $gene = $columns1[4];
    my $group = $columns1[5];
    my $cpg = $columns1[6];

    if (exists $entries_file2{$chr1}) {
        foreach my $entry2 (@{$entries_file2{$chr1}}) {
            my $chr2 = $entry2->[0];
            my $Start = $entry2->[1];
            my $End = $entry2->[2];
            my $Strand2 = $entry2->[3];
            my $Subfamily = $entry2->[4];
            my $Length = $entry2->[6];

            my $Rel_pos1 = ($Mapinfo - $Start) / $Length * 100;
            my $Rel_pos2 = ($End - $Mapinfo) / $Length * 100;

            my $Flan_1 = $Start - 500;
            my $Flan_2 = $End + 500;

            my $Fla_pos1 = $Start - $Mapinfo;
            my $Fla_pos2 = $End - $Mapinfo;
            my $Fla_pos3 = -($End - $Mapinfo);
            my $Fla_pos4 = -($Start - $Mapinfo);

            if ($Strand2 eq "+" && $Mapinfo >= $Start && $Mapinfo <= $End) {
                print output_A "$IlmnID\t$chr1\t$Start\t$Mapinfo\t$End\t$Rel_pos1\t$Subfamily\t$Strand2\t$gene\t$cpg\t$group\n";
                last;
            }
            elsif($Strand2 eq "-" && $Mapinfo >= $Start && $Mapinfo <= $End){
                print output_A "$IlmnID\t$chr1\t$Start\t$Mapinfo\t$End\t$Rel_pos2\t$Subfamily\t$Strand2\t$gene\t$cpg\t$group\n";
                last;
	    }
            elsif($Strand2 eq "+" && $Mapinfo >= $Flan_1 && $Mapinfo <= $Start && $cpg eq "Island"){
                print output_B "$IlmnID\t$chr1\t$Flan_1\t$Mapinfo\t$Start\t$Fla_pos1\t$Subfamily\t$Strand2\t$gene\t$cpg\t$group\n";
		last;
            }
            elsif($Strand2 eq "+" && $Mapinfo >= $End && $Mapinfo <= $Flan_2 && $cpg eq "Island"){
                print output_B "$IlmnID\t$chr1\t$End\t$Mapinfo\t$Flan_2\t$Fla_pos2\t$Subfamily\t$Strand2\t$gene\t$cpg\t$group\n";
		last;
            }
            elsif($Strand2 eq "-" && $Mapinfo >= $End && $Mapinfo <= $Flan_2 && $cpg eq "Island"){
                print output_B "$IlmnID\t$chr1\t$Flan_2\t$Mapinfo\t$End\t$Fla_pos3\t$Subfamily\t$Strand2\t$gene\t$cpg\t$group\n";
		last;
            }
            elsif($Strand2 eq "-" && $Mapinfo >= $Flan_1 && $Mapinfo <= $Start && $cpg eq "Island"){
                print output_B "$IlmnID\t$chr1\t$Start\t$Mapinfo\t$Flan_1\t$Fla_pos4\t$Subfamily\t$Strand2\t$gene\t$cpg\t$group\n";
		last;
            }
            elsif($Strand2 eq "+" && $Mapinfo >= $Flan_1 && $Mapinfo <= $Start && $cpg ne "Island"){
                print output_C "$IlmnID\t$chr1\t$Flan_1\t$Mapinfo\t$Start\t$Fla_pos1\t$Subfamily\t$Strand2\t$gene\t$cpg\t$group\n";
                last;
            }
            elsif($Strand2 eq "+" && $Mapinfo >= $End && $Mapinfo <= $Flan_2 && $cpg ne "Island"){
                print output_C "$IlmnID\t$chr1\t$End\t$Mapinfo\t$Flan_2\t$Fla_pos2\t$Subfamily\t$Strand2\t$gene\t$cpg\t$group\n";
                last;
            }
            elsif($Strand2 eq "-" && $Mapinfo >= $End && $Mapinfo <= $Flan_2 && $cpg ne "Island"){
                print output_C "$IlmnID\t$chr1\t$Flan_2\t$Mapinfo\t$End\t$Fla_pos3\t$Subfamily\t$Strand2\t$gene\t$cpg\t$group\n";
                last;
            }
            elsif($Strand2 eq "-" && $Mapinfo >= $Flan_1 && $Mapinfo <= $Start && $cpg ne "Island"){
                print output_C "$IlmnID\t$chr1\t$Start\t$Mapinfo\t$Flan_1\t$Fla_pos4\t$Subfamily\t$Strand2\t$gene\t$cpg\t$group\n";
                last;
            } 
        }
    }
}

close($fh1);

print "Processing complete. Output files: $output_file_A, $output_file_B, $output_file_C.\n";
