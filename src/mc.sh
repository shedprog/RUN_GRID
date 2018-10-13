#!/bin/zsh
function monte_carlo_freq_updated {
# This code runs all replicas for fixed eta_true in one submit_file
	echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    echo '~~~~~~~~ Monte carlo-mode was activated ~~~~~~~~'
    echo '~~~~~~~~~~~~~~~ Frequency approach ~~~~~~~~~~~~~'
    echo '~~~~~~~~~~~~~~~~~ updated version ~~~~~~~~~~~~~~'
    echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' 

    echo "Do you want to delete MC generated results? (Y/n)"
    echo "Press Y to create the clean folder for data"
    read 
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        # do dangerous stuff
        remove_monte_carlo_result
    fi


	for CItype in "${models[@]}"
    do

		CIvarstep=1.0E-07
	
        l_upper_lim=$(grep -i "^$CItype\b" $WORKDIR/$1 | awk '{print $3}')
        l_lower_lim=$(grep -i "^$CItype\b" $WORKDIR/$1 | awk '{print $2}')
        r_upper_lim=$(grep -i "^$CItype\b" $WORKDIR/$1 | awk '{print $5}')
        r_lower_lim=$(grep -i "^$CItype\b" $WORKDIR/$1 | awk '{print $4}')

		for (( IREP=1; IREP<=$(($NUMBER_OF_STEPS*2)); IREP=$(($IREP+1)) ))
		do
		
        mkdir -p $OUTPUTDIR/RUN/run_mc/r_${IREP}
        
        # Check the number of submited jobs (should not be more than 5k)
        while  [ $(condor_q | awk '/Total for query:/{print $10}') -gt 10000 ]; do sleep 1;echo '.'; done 

		if [ "$IREP" -le "$NUMBER_OF_STEPS" ]; then 
			START=$l_lower_lim
			STEP=$( echo $l_upper_lim $l_lower_lim $NUMBER_OF_STEPS | awk '{print ($1-$2)/($3-1)}')
			CIvarval=$( echo $STEP $IREP $START | awk '{print $1*($2-1)+$3}')
        else
			START=$r_lower_lim
			STEP=$( echo $r_upper_lim $r_lower_lim $NUMBER_OF_STEPS | awk '{print ($1-$2)/($3-1)}')
			CIvarval=$( echo $STEP $IREP $START $NUMBER_OF_STEPS | awk '{print $1*($2-1-$4)+$3}')
		fi

        # This variable was generated to save results for different runs of this soft in different files
        # Because IRAND and SEED and other things will be the same
        RANDOMIZE=$((RANDOM))

        echo $CItype $CIvarval	
                            
        sed "s|REFWORKDIR|$WORKDIR|g ; s|REFOUTDIR|$OUTPUTDIR|g ;\
        s|INCItype=.*|INCItype='$CItype'|g ;\
        s|INCIvarval=.*|INCIvarval=$CIvarval|g ; s|INCIvarstep=.*|INCIvarstep=$CIvarstep|g ;\
        s|INCIDoSimpFit=.*|INCIDoSimpFit='true'|g ; s|INCISimpFitStep=.*|INCISimpFitStep='SimpFit'|g ; \
        s|IREP=.*|IREP=$IREP|g ;\
        s|INchange_CIvarval_afterMC=.*|INchange_CIvarval_afterMC=false|g;\
        s|INCIvarval_afterMC=.*|INCIvarval_afterMC=0.0|g;\
        s|INlRAND=.*|INlRAND=true|g; \
        s|randomize=.*|randomize=$RANDOMIZE|g \
        " $WORKDIR/tmp_grid/condor_submit_mc.sh > $OUTPUTDIR/RUN/run_mc/r_${IREP}/condor_submit_mc_${CItype}_${IREP}.sh

        sed "s|RUN_FILE|$OUTPUTDIR/RUN/run_mc/r_${IREP}/condor_submit_mc_${CItype}_${IREP}.sh|g ;\
        s|REFOUTDIR|$OUTPUTDIR|g ;\
        s|NUMBER_OF_RUN|$seednumber|g \
        " $WORKDIR/tmp_grid/condor_submit > $OUTPUTDIR/RUN/run_mc/r_${IREP}/condor_submit_${CItype}_${IREP}

        chmod +x $OUTPUTDIR/RUN/run_mc/r_${IREP}/condor_submit_mc_${CItype}_${IREP}.sh
            
        condor_submit $OUTPUTDIR/RUN/run_mc/r_${IREP}/condor_submit_${CItype}_${IREP}

	    done
	done	
  

}