#!/usr/bin/perl 
use strict;
use warnings;
use List::Util qw(max); 
#Stephen Johnson
#sej917 // 11065472
#Assignment 1 for CMPT898


sub logsumexp{
	#my $id_max = 0;
	my $max = max(@_);
	#print "MAX: $max\n";
	my $exp = 0;
	foreach my $var(@_){
		$exp += exp($var - $max);
	}
	my $trick = $max + log($exp);
	return $trick;
}

sub argmax{
	my $id_max = 0;
	my $max = max(@_);
	for (my $i = 0; $i <= $#_; $i++){
		if ($_[$i] == $max){
			$id_max = $i;
		}
	}
	return $id_max;
}

#File I/O
open(MYFILE2, ">nbc_summary.txt");
my $file = $ARGV[0];
my $num_tests = `wc -l < $file`;
for (my $n = 0; $n < $num_tests; $n++){
	open(MYFILE, $file);
	my %array;
	my $row = 0; #number of examples
	my $col = 0;
	my $num_feat = 0;
	my @test; 
	my $test_class;
	while(<MYFILE>){
		chomp($_);
		if ($row == 0){
			$num_feat++ while ($_ =~ /\t/g);
		}
		if($row != $n){
			for (my $j = 0; $j < $num_feat; $j++){
				$array{$row}{$j} = (split)[$j];
			}
			
		}else{
			for (my $j = 0; $j < $num_feat; $j++){
				$test[$j] = (split)[$j];
			}
		
		}
		$row++;
	}
	close(MYFILE);
	$test_class = $test[0];
	my @N_c; # number of examples in class c
	my %N_jc; # number of examples of feature j in class c

	my $possible_values = 5; #number of possible values for a feature

	for (my $i = 0; $i < $row; $i++){
		for (my $j = 1; $j < $num_feat; $j++){
			for( my $k = 0; $k < $possible_values; $k++){
				$N_jc{$i}{$j}{$k} = 0;
			}
		}
	}

	my @pi_c;
	my %theta_jc;

	for(my $i= 0; $i < $row; $i++){
		if($i != $n){
			my $c = $array{$i}{0}; # Class label of ith example; 
			$N_c[$c] += 1 ;
			for(my $j = 1; $j < $num_feat; $j++){
				$N_jc{$c}{$j}{$array{$i}{$j}} += 1;
			}
		}
	}
	my @a_c;
	my $a_o;
	for (my $i = 0; $i <= $#N_c; $i++){
		$a_c[$i] = 1;#$N_c[$i]/$row;
		$a_o += $a_c[$i];
	}
	
	my $b_0 = 1;
	my $b_1 = 1;

	#this works! for MLE estimates
	for(my $i = 0; $i <= $#N_c; $i++){
		$pi_c[$i] = ($N_c[$i] + $a_c[$i]) / ($row + $a_o); #pi_c = Nc / N
	}

	for (my $c = 0; $c <= $#N_c; $c++){
		for (my $j = 1; $j < $num_feat; $j++){
			for (my $k = 0; $k < $possible_values; $k++){
				$theta_jc{$c}{$j}{$k} = ($N_jc{$c}{$j}{$k} + $b_0)/ ($N_c[$c] + $b_0 + $b_1); #theta_jc = Njc / Nc
			}
		}
	}

	#MAP estimates
	#my $pi_c = ($N_c + $a_c[$c]) / ($N + $a_o);
	#my $theta_jc = ($N_jc + $b_1 ) / ($N_c + $b_0 + $b_1 );



	#PREDICTION STEP
	my @L_ic;

	for (my $c = 0; $c <= $#N_c; $c++){
		$L_ic[$c] = 0;
	}

	my @p_ic;
	for (my $c = 0; $c <= $#N_c; $c++){
		$L_ic[$c] = log($pi_c[$c]);
		for (my $j = 1; $j < $num_feat; $j++){
			if ($theta_jc{$c}{$j}{$test[$j]} == 0){
				$L_ic[$c] += log(1);
			}else{
				$L_ic[$c] += log($theta_jc{$c}{$j}{$test[$j]}); 
			}
		}	
	}
	for (my $c = 0; $c <= $#N_c; $c++){
		$p_ic[$c] = exp($L_ic[$c] - &logsumexp(@L_ic));
	}
	my $y_i = &argmax(@p_ic);

	if ($y_i != $test_class){
		print "ERROR: Test $n failed, Predicted class: $y_i Actual class: $test_class\n";
	}
	print MYFILE2 "$y_i\n";
}

