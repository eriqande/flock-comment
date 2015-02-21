# simple bash script to simulate data to compare Flock to Structure.
if [ $# -ne 1 ]; then
  echo "Call this with the scaled Migration rate as the single argument"
  exit 1
fi

MigRate=$1


# simulate sample of 4000 individuals from K=5 populations in an island
# model parameterized by migration rate M = 4 Ne m
# sample sizes from the different populations will be
SIZES="250 250 400 550 550"
REPS=1
NUMLOC=96
M=$MigRate

S=50  # scaled mutation rate
ms="./mac_progs/ms"
ms2geno="./mac_progs/ms2geno"
gsi_sim="./mac_progs/gsi_sim"


# remove the old data sets first:
rm -f BaseFile_*.txt struct_intput*.txt

# eca added some one locus to be simulated in case some didn't achieve ascertainment.
# Note that this will gooch up the seeds, so it will all have to get re-run.  For this
# I will add more than just one locus, I will do 10.  
$ms $((2 * 2000)) $((REPS * NUMLOC + 10)) -s $S -I 5 $(echo $SIZES | awk '{for(i=1;i<=NF;i++) printf("%d ",2*$i);}')  $M | \
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