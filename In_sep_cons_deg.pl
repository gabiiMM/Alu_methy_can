#!/usr/bin/perl
use strict;
use warnings;

if (@ARGV != 6) {
    die "Usage: perl Script.pl Output_reassociate_file Conserved_file Degenerate_file beta_column pos_rel_column subfamily_column\n";
}

my ($input_file, $conservado_file, $degenerado_file, $beta_column, $p_rel_column, $repname_column) = @ARGV;

open(my $entrada, '<', $input_file) or die "Error: Could not open '$input_file': $!\n";
open(my $salida_conservado, '>', $conservado_file) or die "Error: Could not open '$conservado_file': $!\n";
open(my $salida_degenerado, '>', $degenerado_file) or die "Error: Could not open '$degenerado_file': $!\n";

my %sumas_conservado;
my %contadores_conservado;
my %sumas_degenerado;
my %contadores_degenerado;

while (<$entrada>) {
    chomp;
    my @array = split;
    my ($P_rel, $b_val, $repname) = @array[$p_rel_column - 1, $beta_column - 1, $repname_column - 1];

    my $rango = int($P_rel / 5) * 5;

    if ($repname =~ /^(AluSx1|AluSq2|AluSx|AluSq|AluSz|AluSx4|AluSg|AluSg4|AluSx3|AluSq4)$/) {
        $sumas_conservado{$rango} += $b_val;
        $contadores_conservado{$rango}++;
    } else {
        $sumas_degenerado{$rango} += $b_val;
        $contadores_degenerado{$rango}++;
    }
}

close($entrada);

for my $rango (sort { $a <=> $b } keys %sumas_conservado) {
    my $promedio = $sumas_conservado{$rango} / $contadores_conservado{$rango};
    my $rango_final = $rango + 4;
    my $contador = $contadores_conservado{$rango};
    print $salida_conservado "$rango-$rango_final\t$promedio\t$contador\n";
}

for my $rango (sort { $a <=> $b } keys %sumas_degenerado) {
    my $promedio = $sumas_degenerado{$rango} / $contadores_degenerado{$rango};
    my $rango_final = $rango + 4;
    my $contador = $contadores_degenerado{$rango};
    print $salida_degenerado "$rango-$rango_final\t$promedio\t$contador\n";
}

close($salida_conservado);
close($salida_degenerado);

print "Processing completed.\n";
