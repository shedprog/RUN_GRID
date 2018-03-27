#!/bin/sh
#
#
#$ -e REFOUTDIR/bird_info_out/bird_out_mc/err/
#$ -o REFOUTDIR/bird_info_out/bird_out_mc/out/
#
#   Turn on Verbose Mode
set -x

source REFWORKDIR/settings_env.sh

echo $TMPDIR
cd $TMPDIR

cp REFWORKDIR/tmp_xfitter/minuit.in.txt .
cp REFWORKDIR/tmp_xfitter/ewparam.txt .
cp REFWORKDIR/tmp_xfitter/steering.txt .
ln -s $XFITTER/bin/xfitter  .
ln -s REFWORKDIR/datafiles .


INCItype='VV'
INCIvarval=0.0
INCIvarstep=1.0E-06
IREP=1
IREP2=1
INISeedMC=11000111

cp REFOUTDIR/output/derivatives/CIDerivatives_CI_${INCItype}.txt ./CIDerivatives.txt

sed -i "s|CItype = '.*'|CItype = '$INCItype'|g" $TMPDIR/steering.txt
sed -i "s|CIvarval =.*|CIvarval = $INCIvarval|g" $TMPDIR/steering.txt
sed -i "s|CIvarstep = '.*'|CIvarstep = $INCIvarstep|g" $TMPDIR/steering.txt
sed -i "s|CIDoSimpFit =.*|CIDoSimpFit = true|g" $TMPDIR/steering.txt
sed -i "s|CISimpFitStep = .*|CISimpFitStep = 'SimpFit'|g" $TMPDIR/steering.txt
sed -i "s|ISeedMC =.*|ISeedMC = $INISeedMC|g" $TMPDIR/steering.txt
sed -i "s|lRAND = .*|lRAND = True|g" $TMPDIR/steering.txt

./xfitter

#cp $TMPDIR/output/CIout.txt  REFOUTDIR/output/monte_carlo/CIval_in_${INCItype}_${IREP}.txt
cp $TMPDIR/steering.txt REFOUTDIR/output/monte_carlo/steering_${INCItype}_${IREP}.txt

RES=$(awk '{ print $3,$4 }' < output/CIout.txt)
chis=$(grep -i 'After' output/Results.txt | awk '{print $3}')
status=$(grep -ir -E 'STATUS=CONVERGED|STATUS=FAILED' | awk '{print $6}')
echo $INCItype $chis $INCIvarval $RES $status>> REFOUTDIR/output/monte_carlo/RESULTS_${INCItype}_${IREP}.txt

#Warning: Clean!
rm REFOUTDIR/bird_info_out/bird_out_mc/err/*
rm REFOUTDIR/bird_info_out/bird_out_mc/out/*
rm REFOUTDIR/RUN/run_mc/r_${IREP}/batch_${INCItype}_${IREP}_${IREP2}.cmd
