#!/bin/sh

source REFWORKDIR/settings_env.sh

echo $TMP
cd $TMP
export TMPDIR=$TMP

cp REFOUTDIR/RUN/minuit.in.txt .
cp REFOUTDIR/RUN/ewparam.txt .
cp REFOUTDIR/RUN/steering.txt .
ln -s $XFITTER/bin/xfitter  .
ln -s REFWORKDIR/datafiles .


PDF_is='CI'
INdoCI=true
INCItype='VV'
INCIvarval=0.0
INCIvarstep=1.0E-06
INCIDoSimpFit='true'
INCISimpFitStep='CalcDerivatives'
INchange_CIvarval_afterMC=false
INCIvarval_afterMC=0.0

CI_FIT_TYPE=${INCItype//div//}

sed -i "s|doCI = .*|doCI = $INdoCI|g" $TMPDIR/steering.txt
sed -i "s|CItype = .*|CItype = '$CI_FIT_TYPE'|g" $TMPDIR/steering.txt
sed -i "s|CIvarval = .*|CIvarval = $INCIvarval|g" $TMPDIR/steering.txt
sed -i "s|CIvarstep = .*|CIvarstep = $INCIvarstep|g" $TMPDIR/steering.txt
sed -i "s|CIDoSimpFit =.*|CIDoSimpFit = $INCIDoSimpFit|g" $TMPDIR/steering.txt
sed -i "s|CISimpFitStep = '.*|CISimpFitStep = '$INCISimpFitStep'|g" $TMPDIR/steering.txt
sed -i "s| change_CIvarval_afterMC = .*| change_CIvarval_afterMC = $INchange_CIvarval_afterMC|g" $TMPDIR/steering.txt
sed -i "s| CIvarval_afterMC = .*| CIvarval_afterMC = $INCIvarval_afterMC|g" $TMPDIR/steering.txt

./xfitter

cp $TMPDIR/steering.txt REFOUTDIR/output/derivatives/steering_${PDF_is}_${INCItype}.txt
cp $TMPDIR/CIDerivatives.txt REFOUTDIR/output/derivatives/CIDerivatives_${PDF_is}_${INCItype}.txt


