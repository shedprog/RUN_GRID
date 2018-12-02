#!/bin/zsh
function monte_carlo_freq_updated {
# This code runs all replicas for fixed eta_true in one submit_file
	echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    echo '~~~~~~~~ Monte carlo-mode was activated ~~~~~~~~'
    echo '~~~~~~~~~~~~~~~ Frequency approach ~~~~~~~~~~~~~'
    echo '~~~~~~~~~~~~~~~~~ updated version ~~~~~~~~~~~~~~'
    echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' 

    # echo "Do you want to delete MC generated results? (Y/n)"
    # echo "Press Y to create the clean folder for data"
    # read 
    # if [[ $REPLY =~ ^[Yy]$ ]]
    # then
    #     # do dangerous stuff
    #     remove_monte_carlo_result
    # fi

    ci_mode=$1
    ci_side=$2

    echo $ci_mode $ci_side


	for CItype in "${models[@]}"
    do

        CIvarstep=1.0E-07

        if [ "$ci_mode" = "measured" ]; then
            ci_mode='settings_limits_sys.txt'
        elif [ "$ci_mode" = "expected" ]; then
            ci_mode='settings_explimits.txt'
        fi

        if [ "$ci_side" = "right" ]; then
            upper_lim=$(grep -i "^$CItype\b" $WORKDIR/$ci_mode | awk '{print $5}')
            lower_lim=$(grep -i "^$CItype\b" $WORKDIR/$ci_mode | awk '{print $4}')
        elif [ "$ci_side" = "left" ]; then
            upper_lim=$(grep -i "^$CItype\b" $WORKDIR/$ci_mode | awk '{print $3}')
            lower_lim=$(grep -i "^$CItype\b" $WORKDIR/$ci_mode | awk '{print $2}')   
        fi

        START=$lower_lim
        STEP=$( echo $upper_lim $lower_lim $NUMBER_OF_STEPS | awk '{print ($1-$2)/($3-1)}')
        echo $upper_lim $lower_lim $NUMBER_OF_STEPS


		for (( IREP=1; IREP<=$NUMBER_OF_STEPS; IREP=$(($IREP+1)) ))
		do
            
            # mkdir -p $OUTPUTDIR/RUN/run_mc/r_${IREP}
            
            # # Check the number of submited jobs (should not be more than 5k)
            while  [ $(condor_q | awk '/Total for query:/{print $10}') -gt 10000 ]; do sleep 1;echo '.'; done 


            CIvarval=$( echo $STEP $IREP $START | awk '{print $1*($2-1)+$3}')

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
            s|INlRAND=.*|INlRAND = true|g; \
            s|randomize=.*|randomize=$RANDOMIZE|g \
            " $WORKDIR/tmp_grid/condor_submit_mc.sh > $OUTPUTDIR/RUN/run_mc/condor_submit_mc_${CItype}_${IREP}_${RANDOMIZE}.sh

            sed "s|RUN_FILE|$OUTPUTDIR/RUN/run_mc/condor_submit_mc_${CItype}_${IREP}_${RANDOMIZE}.sh|g ;\
            s|REFOUTDIR|$OUTPUTDIR|g ;\
            s|NUMBER_OF_RUN|$seednumber|g \
            " $WORKDIR/tmp_grid/condor_submit > $OUTPUTDIR/RUN/run_mc/condor_submit_${CItype}_${IREP}_${RANDOMIZE}

            chmod +x $OUTPUTDIR/RUN/run_mc/condor_submit_mc_${CItype}_${IREP}_${RANDOMIZE}.sh
                
            condor_submit $OUTPUTDIR/RUN/run_mc/condor_submit_${CItype}_${IREP}_${RANDOMIZE}

	    done
	done	
  

}