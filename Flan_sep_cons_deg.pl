#!/usr/bin/perl
use strict;
use warnings;

if (@ARGV != 6) {
    die "Usage: Output_reassociate_file Conserved_file Degenerate_file beta_column pos_rel_column subfamily_column\n";
}

my ($input_file, $conservado_file, $degenerado_file, $beta_column, $pos_column, $repname_column) = @ARGV;

open(my $entrada, '<', $input_file) or die "Error: Could not open '$input_file': $!\n";
open(my $salida_conservado, '>', $conservado_file) or die "Error: Could not open '$conservado_file': $!\n";
open(my $salida_degenerado, '>', $degenerado_file) or die "Error: Could not open '$degenerado_file': $!\n";

my (%sumas_conservado, %contadores_conservado, %sumas_degenerado, %contadores_degenerado);

while (<$entrada>) {
    chomp;
    my @array = split;
    my ($pos, $b_val, $repname) = @array[$pos_column - 1, $beta_column - 1, $repname_column - 1];

    my $rango;

    if ($pos >= -500 && $pos <= 500) {
        if ($pos >= 0) {
            $rango = int($pos / 10) * 10;
        } else {
            $rango = int(($pos) / 10) * 10;
        }
    } else {
        die "Error: Position is outside the allowed range (-500 a 500): $pos\n";
    }

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
    my $contador = $contadores_conservado{$rango};
    print $salida_conservado "$rango\t$promedio\t$contador\n";
}

for my $rango (sort { $a <=> $b } keys %sumas_degenerado) {
    my $promedio = $sumas_degenerado{$rango} / $contadores_degenerado{$rango};
    my $contador = $contadores_degenerado{$rango};
    print $salida_degenerado "$rango\t$promedio\t$contador\n";
}

close($salida_conservado);
close($salida_degenerado);

print "Processing completed.\n";
