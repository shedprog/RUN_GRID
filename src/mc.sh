#!/bin/zsh
function monte_carlo_LH_default {
    echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    echo '~~~~~~~~ Monte carlo-mode was activated ~~~~~~~~'
    echo '~~~~~~~~~~~~~~ Default xfitter ~~~~~~~~~~~~~~~~~'
    echo '~~~~~~~~~~~~~~ LH aproch ~~~~~~~~~~~~~~~~~~~~~~~'
    echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' 

    remove_monte_carlo_DEF_result

    for CItype in "${models[@]}"
    do
        CIvarstep=0.0

        l_upper_lim=$(grep -i $CItype $WORKDIR/settings_limits.txt | awk '{print $3}')
        l_lower_lim=$(grep -i $CItype $WORKDIR/settings_limits.txt | awk '{print $2}')
        r_upper_lim=$(grep -i $CItype $WORKDIR/settings_limits.txt | awk '{print $5}')
        r_lower_lim=$(grep -i $CItype $WORKDIR/settings_limits.txt | awk '{print $4}')

        for (( IREP=1; IREP<=$(($NUMBER_OF_STEPS*2)); IREP=$(($IREP+1)) ))
        do

        mkdir -p $OUTPUTDIR/RUN/run_mc_def/r_${IREP}

        if [ "$IREP" -le "$NUMBER_OF_STEPS" ]; then 
            START=$l_lower_lim
            STEP=$( echo $l_upper_lim $l_lower_lim $NUMBER_OF_STEPS | awk '{print ($1-$2)/$3}')
            CIvarval=$( echo $STEP $IREP $START | awk '{print $1*$2+$3}')
        else
            START=$r_lower_lim
            STEP=$( echo $r_upper_lim $r_lower_lim $NUMBER_OF_STEPS | awk '{print ($1-$2)/$3}')
            CIvarval=$( echo $STEP $IREP $START $NUMBER_OF_STEPS | awk '{print $1*($2-$4)+$3}')
        fi

            for (( IREP2=1; IREP2<=$seednumber; IREP2=$(($IREP2+1)) ))
            do  
                echo $CItype $CIvarval  

                seed=$(echo $seedstart $seedstep $IREP $IREP2 | awk '{print $1+$2*(($3-1)*5000+$4)}')
            
                while  [ $(qstat -s p | wc -l) -gt 20000 ]; do sleep 1;echo '.'; done 
                                    
                sed "s|PDF_is=.*|PDF_is='CI'|g ;\
                s|REFWORKDIR|$WORKDIR|g ; s|REFOUTDIR|$OUTPUTDIR|g ;\
                s|INCItype=.*|INCItype='$CItype'|g ;\
                s|INCIvarval=.*|INCIvarval=$CIvarval|g ; s|INCIvarstep=.*|INCIvarstep=$CIvarstep|g ;\
                s|INISeedMC=.*|INISeedMC=$seed|g ; s|IREP=.*|IREP=$IREP|g ; s|IREP2=.*|IREP2=$IREP2|g ;\
                s|INchange_CIvarval_afterMC=.*|INchange_CIvarval_afterMC=false|g ;\
                s|INISeedMC=.*|INISeedMC=$seed|g \
                " $WORKDIR/tmp_grid/batch_bird_mc_def.cmd > $OUTPUTDIR/RUN/run_mc_def/r_${IREP}/batch_CI_${CItype}_${IREP}_${IREP2}.cmd
                    
                qsub -l distro=sld6 -l h_vmem=5000M -q short.q -cwd $OUTPUTDIR/RUN/run_mc_def/r_${IREP}/batch_CI_${CItype}_${IREP}_${IREP2}.cmd &

                sed "s|PDF_is=.*|PDF_is='SM'|g ;\
                s|REFWORKDIR|$WORKDIR|g ; s|REFOUTDIR|$OUTPUTDIR|g ;\
                s|INCItype=.*|INCItype='$CItype'|g ;\
                s|INCIvarval=.*|INCIvarval=$CIvarval|g ; s|INCIvarstep=.*|INCIvarstep=$CIvarstep|g ;\
                s|INISeedMC=.*|INISeedMC=$seed|g ; s|IREP=.*|IREP=$IREP|g ; s|IREP2=.*|IREP2=$IREP2|g ;\
                s|INchange_CIvarval_afterMC=.*|INchange_CIvarval_afterMC=true|g ;\
                s|INCIvarval_afterMC=.*|INCIvarval_afterMC=0.0|g ;\
                s|INISeedMC=.*|INISeedMC=$seed|g \
                " $WORKDIR/tmp_grid/batch_bird_mc_def.cmd > $OUTPUTDIR/RUN/run_mc_def/r_${IREP}/batch_SM_${CItype}_${IREP}_${IREP2}.cmd
                    
                qsub -l distro=sld6 -l h_vmem=5000M -q short.q -cwd $OUTPUTDIR/RUN/run_mc_def/r_${IREP}/batch_SM_${CItype}_${IREP}_${IREP2}.cmd &
            done

        done

    done
}

function monte_carlo_freq() {
	echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    echo '~~~~~~~~ Monte carlo-mode was activated ~~~~~~~~'
    echo '~~~~~~~~~~~~~~~ Frequency approach ~~~~~~~~~~~~~'
    echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' 
  
    remove_monte_carlo_result

	for CItype in "${models[@]}"

        do

		CIvarstep=1.0E-07
	
        l_upper_lim=$(grep -i $CItype $WORKDIR/$1 | awk '{print $3}')
        l_lower_lim=$(grep -i $CItype $WORKDIR/$1 | awk '{print $2}')
        r_upper_lim=$(grep -i $CItype $WORKDIR/$1 | awk '{print $5}')
        r_lower_lim=$(grep -i $CItype $WORKDIR/$1 | awk '{print $4}')

		for (( IREP=1; IREP<=$(($NUMBER_OF_STEPS*2)); IREP=$(($IREP+1)) ))
		do
		
        mkdir -p $OUTPUTDIR/RUN/run_mc/r_${IREP}

		if [ "$IREP" -le "$NUMBER_OF_STEPS" ]; then 
			START=$l_lower_lim
			STEP=$( echo $l_upper_lim $l_lower_lim $NUMBER_OF_STEPS | awk '{print ($1-$2)/($3-1)}')
			CIvarval=$( echo $STEP $IREP $START | awk '{print $1*($2-1)+$3}')
        else
			START=$r_lower_lim
			STEP=$( echo $r_upper_lim $r_lower_lim $NUMBER_OF_STEPS | awk '{print ($1-$2)/($3-1)}')
			CIvarval=$( echo $STEP $IREP $START $NUMBER_OF_STEPS | awk '{print $1*($2-1-$4)+$3}')
		fi

			for (( IREP2=1; IREP2<=$seednumber; IREP2=$(($IREP2+1)) ))
			do	
				echo $CItype $CIvarval	

				seed=$(echo $seedstart $seedstep $IREP $IREP2 | awk '{print $1+$2*(($3-1)*5000+$4)}')
			
		       	while  [ $(qstat -s p | wc -l) -gt 20000 ]; do sleep 1;echo '.'; done 
									
				sed "s|REFWORKDIR|$WORKDIR|g ; s|REFOUTDIR|$OUTPUTDIR|g ;\
				s|INCItype=.*|INCItype='$CItype'|g ;\
				s|INCIvarval=.*|INCIvarval=$CIvarval|g ; s|INCIvarstep=.*|INCIvarstep=$CIvarstep|g ;\
				s|INCIDoSimpFit=.*|INCIDoSimpFit='true'|g ; s|INCISimpFitStep=.*|INCISimpFitStep='SimpFit'|g ; \
				s|INISeedMC=.*|INISeedMC=$seed|g ; s|IREP=.*|IREP=$IREP|g ; s|IREP2=.*|IREP2=$IREP2|g;\
                s|INchange_CIvarval_afterMC=.*|INchange_CIvarval_afterMC=false|g;\
                s|INCIvarval_afterMC=.*|INCIvarval_afterMC=0.0|g;\
                s|INlRAND=.*|INlRAND=true|g \
				" $WORKDIR/tmp_grid/batch_bird_mc.cmd > $OUTPUTDIR/RUN/run_mc/r_${IREP}/batch_${CItype}_${IREP}_${IREP2}.cmd
				 	
				qsub -l distro=sld6 -l h_vmem=5000M -q short.q -cwd $OUTPUTDIR/RUN/run_mc/r_${IREP}/batch_${CItype}_${IREP}_${IREP2}.cmd &
			done
		done
	done	
} 

function monte_carlo_LH() {

    echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    echo '~~~~~~~~ Monte carlo-mode was activated ~~~~~~~~'
    echo '~~~~~~~~~~~~~~~ for LH method ~~~~~~~~~~~~~~~~~~'
    echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

    remove_monte_carloLH_result
  
	for CItype in "${models[@]}"
        do

        l_upper_lim=$(grep -i $CItype $WORKDIR/settings_limits.txt | awk '{print $3}')
        l_lower_lim=$(grep -i $CItype $WORKDIR/settings_limits.txt | awk '{print $2}')
        r_upper_lim=$(grep -i $CItype $WORKDIR/settings_limits.txt | awk '{print $5}')
        r_lower_lim=$(grep -i $CItype $WORKDIR/settings_limits.txt | awk '{print $4}')


            
      #  for (( IREP=0; IREP<=$(($NUMBER_OF_STEPS*2)); IREP=$(($IREP+1)) ))
       for (( IREP=1; IREP<=$(($NUMBER_OF_STEPS*2)); IREP=$(($IREP+1)) ))
        do
        
        		if [ "$IREP" = 0 ]; then
                # Generate 5000 replicas for Eta_mc=0
                    CIvarval=0.0
                elif [ "$IREP" -le "$NUMBER_OF_STEPS" ]; then 
                    START=$l_lower_lim
					STEP=$( echo $l_upper_lim $l_lower_lim $NUMBER_OF_STEPS | awk '{print ($1-$2)/$3}')
                    CIvarval=$( echo $STEP $IREP $START | awk '{print $1*$2+$3}')
                else
					START=$r_lower_lim
                    STEP=$( echo $r_upper_lim $r_lower_lim $NUMBER_OF_STEPS | awk '{print ($1-$2)/$3}')
					CIvarval=$( echo $STEP $IREP $START $NUMBER_OF_STEPS | awk '{print $1*($2-$4)+$3}')
                fi

            mkdir -p $OUTPUTDIR/RUN/run_mcLH/r_${IREP}
    
            # Derivatives_2 (CIvarval=0, CIvarstep=10^-7) →  Data → Fit (CIvarval=eta_true, CIvarstep=0) → L_s+b^data 
            sed "\
                s|PDF_is=.*|PDF_is='DATA'|g ;\
                s|REFWORKDIR|$WORKDIR|g ; s|REFOUTDIR|$OUTPUTDIR|g ;\
                s|INdoCI=.*|INdoCI=true|g ; s|INCItype=.*|INCItype='$CItype'|g ;\
                s|INCIvarval=.*|INCIvarval=$CIvarval|g ; s|INCIvarstep=.*|INCIvarstep=0.0|g ;\
                s|INCIDoSimpFit=.*|INCIDoSimpFit='true'|g ; s|INCISimpFitStep=.*|INCISimpFitStep='SimpFit'|g ;\
                s|IREP=.*|IREP=$IREP|g ; s|IREP2=.*|IREP2=$IREP2|g;\
                s|INchange_CIvarval_afterMC=.*|INchange_CIvarval_afterMC=false|g;\
                s|INlRAND=.*|INlRAND=false|g \
                " $WORKDIR/tmp_grid/batch_bird_mcLH.cmd > $OUTPUTDIR/RUN/run_mcLH/r_${IREP}/batch_DATA_${CItype}_${IREP}.cmd
             
            qsub -l distro=sld6 -l h_vmem=5000M -q short.q -cwd $OUTPUTDIR/RUN/run_mcLH/r_${IREP}/batch_DATA_${CItype}_${IREP}.cmd &
            for (( IREP2=1; IREP2<=$seednumber; IREP2=$(($IREP2+1)) ))
            do  
            echo $CItype $CIvarval
             
            seed=$(echo $seedstart $seedstep $IREP $IREP2 | awk '{print $1+$2*(($3-1)*5000+$4)}')
                   while  [ $(qstat -s p | wc -l) -gt 20000 ]; do sleep 1;echo '.'; done 
            
            #Derivatives_2(CIvarval=0, CIvarstep=10^-7)→Replica(Civarval=eta_true)→Fit(CIvarval=eta_true,CIvarstep=0)→L_s+b
            sed "\
                s|PDF_is=.*|PDF_is='CI'|g ;\
                s|REFWORKDIR|$WORKDIR|g ; s|REFOUTDIR|$OUTPUTDIR|g ;\
                s|INdoCI=.*|INdoCI=true|g ; s|INCItype=.*|INCItype='$CItype'|g ;\
                s|INCIvarval=.*|INCIvarval=$CIvarval|g ; s|INCIvarstep=.*|INCIvarstep=0.0|g ;\
                s|INCIDoSimpFit=.*|INCIDoSimpFit='true'|g ; s|INCISimpFitStep=.*|INCISimpFitStep='SimpFit'|g ;\
                s|INISeedMC=.*|INISeedMC=$seed|g ; s|IREP=.*|IREP=$IREP|g ; s|IREP2=.*|IREP2=$IREP2|g;\
                s|INchange_CIvarval_afterMC=.*|INchange_CIvarval_afterMC=false|g;\
                s|INCIvarval_afterMC=.*|INCIvarval_afterMC=0.0|g;\
                s|INlRAND=.*|INlRAND=true|g \
                " $WORKDIR/tmp_grid/batch_bird_mcLH.cmd > $OUTPUTDIR/RUN/run_mcLH/r_${IREP}/batch_CI_${CItype}_${IREP}_${IREP2}.cmd
             
            qsub -l distro=sld6 -l h_vmem=5000M -q short.q -cwd $OUTPUTDIR/RUN/run_mcLH/r_${IREP}/batch_CI_${CItype}_${IREP}_${IREP2}.cmd &
            
            # Derivatives_1(CIvarval=0,CIvarstep=0)→Replica(Civarval=eta_true)→Fit(CIvarval=0,CIvarstep=0)→L_b
            sed "\
                s|PDF_is=.*|PDF_is='SM'|g ;\
                s|REFWORKDIR|$WORKDIR|g ; s|REFOUTDIR|$OUTPUTDIR|g ;\
                s|INdoCI=.*|INdoCI=true|g ; s|INCItype=.*|INCItype='$CItype'|g ;\
                s|INCIvarval=.*|INCIvarval=$CIvarval|g ; s|INCIvarstep=.*|INCIvarstep=0.0|g ;\
                s|INCIDoSimpFit=.*|INCIDoSimpFit='true'|g ; s|INCISimpFitStep=.*|INCISimpFitStep='SimpFit'|g ;\
                s|INISeedMC=.*|INISeedMC=$seed|g ; s|IREP=.*|IREP=$IREP|g ; s|IREP2=.*|IREP2=$IREP2|g;\
                s|INchange_CIvarval_afterMC=.*|INchange_CIvarval_afterMC=true|g;\
                s|INCIvarval_afterMC=.*|INCIvarval_afterMC=0.0|g;\
                s|INlRAND=.*|INlRAND=true|g;\
                " $WORKDIR/tmp_grid/batch_bird_mcLH.cmd > $OUTPUTDIR/RUN/run_mcLH/r_${IREP}/batch_SM_${CItype}_${IREP}_${IREP2}.cmd
             
            qsub -l distro=sld6 -l h_vmem=5000M -q short.q -cwd $OUTPUTDIR/RUN/run_mcLH/r_${IREP}/batch_SM_${CItype}_${IREP}_${IREP2}.cmd &
			done


    	done		
    done 
}
