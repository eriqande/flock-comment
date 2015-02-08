

# simple bash script to simulate data to compare Flock to Structure.


# simulate sample of 4000 individuals from K=5 populations in an island
# model parameterized by migration rate M = 4 Ne m
# sample sizes from the different populations will be
SIZES="250 250 400 550 550"
REPS=1
NUMLOC=96
M=25 
S=50  # scaled mutation rate
ms="./mac_progs/ms"
ms2geno="./mac_progs/ms2geno"
gsi_sim="./mac_progs/gsi_sim"


# remove the old data sets first:
rm -f BaseFile_*.txt struct_intput*.txt

echo "SEEDS1" > seedms   # set the seeds for ms
echo "SEEDS2" > ms2geno_seeds # set seeds for ms2geno
$ms $((2 * 2000)) $((REPS * NUMLOC)) -s $S -I 5 $(echo $SIZES | awk '{for(i=1;i<=NF;i++) printf("%d ",2*$i);}')  $M | \
   $ms2geno -l $NUMLOC -b $SIZES -m 0 0 0 0 0 -s 1 10 4 -s 2 10 4 -s 3 10 4 -s 4 10 4 -s 4 10 4 


echo "



Here are pairwise Fsts between the pops:
"
for i in BaseFile_*.txt; do
	echo "For $i"
	$gsi_sim -b $i | awk '/^PAIRWISE_FST/'
	echo; echo
done

# now squash the resulting Basefiles out into structure format
for i in BaseFile_*.txt; do
	j=${i/BaseFile/struct_input}
	awk 'NF<=2 {next} {print}' $i > $j
done


echo "The resulting structure files are in: $(echo struct_input_*)"