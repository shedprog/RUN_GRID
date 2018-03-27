#!/bin/sh
#
#
#$ -e REFOUTDIR/bird_info_out/bird_out_mc_def/err/
#$ -o REFOUTDIR/bird_info_out/bird_out_mc_def/out/
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

PDF_is=CI
INCItype='VV'
INCIvarval=0.0
INCIvarstep=1.0E-06
IREP=1
IREP2=1
INISeedMC=11000111
INchange_CIvarval_afterMC=true
INCIvarval_afterMC=0.0

sed -i "s|CItype = '.*'|CItype = '$INCItype'|g" $TMPDIR/steering.txt
sed -i "s|CIvarval =.*|CIvarval = $INCIvarval|g" $TMPDIR/steering.txt
sed -i "s|CIvarstep = .*|CIvarstep = 0.0|g" $TMPDIR/steering.txt
sed -i "s|CIDoSimpFit =.*|CIDoSimpFit = false|g" $TMPDIR/steering.txt
sed -i "s|ISeedMC =.*|ISeedMC = $INISeedMC|g" $TMPDIR/steering.txt
sed -i "s|lRAND = .*|lRAND = True|g" $TMPDIR/steering.txt
sed -i "s| change_CIvarval_afterMC = .*| change_CIvarval_afterMC = $INchange_CIvarval_afterMC|g" $TMPDIR/steering.txt
sed -i "s| CIvarval_afterMC = .*| CIvarval_afterMC = $INCIvarval_afterMC|g" $TMPDIR/steering.txt

./xfitter

#cp $TMPDIR/output/CIout.txt  REFOUTDIR/output/monte_carlo_def/CIval_in_${INCItype}_${IREP}.txt
#cp $TMPDIR/steering.txt REFOUTDIR/output/monte_carlo_def/steering_${INCItype}_${IREP}.txt

#RES=$(awk '{ print $3,$4 }' < output/CIout.txt)
#chis=$(grep -i 'After' output/Results.txt | awk '{print $3}')
#status=$(grep -ir -E 'STATUS=CONVERGED|STATUS=FAILED' | awk '{print $6}')
#echo $INCItype $chis $INCIvarval $RES $status>> REFOUTDIR/output/monte_carlo_def/RESULTS_${INCItype}_${IREP}.txt

if [ "$PDF_is" = 'CI' ];then

cp $TMPDIR/steering.txt REFOUTDIR/output/monte_carlo_def/steering_CI_${INCItype}_${IREP}.txt

RES=$(awk '{ print $3,$4 }' < output/CIout.txt)
chis=$(grep -i 'After' output/Results.txt | awk '{print $3}')
status=$(grep -ir -E 'STATUS=CONVERGED|STATUS=FAILED' | awk '{print $6}')
echo $INCItype $chis $INCIvarval $RES $status $IREP2 >> REFOUTDIR/output/monte_carlo_def/RESULTS_CI_${INCItype}_${IREP}.txt

rm REFOUTDIR/RUN/run_mc_def/r_${IREP}/batch_CI_${CItype}_${IREP}_${IREP2}.cmd

else

cp $TMPDIR/steering.txt REFOUTDIR/output/monte_carlo_def/steering_SM_${INCItype}_${IREP}.txt

chis=$(grep -i 'After' output/Results.txt | awk '{print $3}')
status=$(grep -ir -E 'STATUS=CONVERGED|STATUS=FAILED' | awk '{print $6}')
echo $INCItype $chis $INCIvarval $status $IREP2>> REFOUTDIR/output/monte_carlo_def/RESULTS_SM_${INCItype}_${IREP}.txt

rm REFOUTDIR/RUN/run_mc_def/r_${IREP}/batch_SM_${CItype}_${IREP}_${IREP2}.cmd

fi

#Warning: Clean!
rm REFOUTDIR/bird_info_out_def/bird_out_mc/err/*
rm REFOUTDIR/bird_info_out_def/bird_out_mc/out/*
#rm REFOUTDIR/RUN/run_mc_def/r_${IREP}/batch_${INCItype}_${IREP}_${IREP2}.cmd
