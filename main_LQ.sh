#!/bin/zsh

source settings_var.sh
source src/simpfit.sh
source src/clean.sh
source src/derivative.sh
source src/mc.sh


function replica {
    echo $OUTPUTDIR
    python $WORKDIR/src/analysis_py/replica_new.py right $1 $OUTPUTDIR $models
}


function main_menu
{
    local -a MY_ACTIONS

    # The name of the functions to call
    MY_ACTIONS=("build_deriv"\
        "simpfit"\
        "monte_carlo_freq_LQ settings_limits.txt"\
        "monte_carlo_freq_LQ settings_explimits.txt"\
        "replica measured"\
        "replica expected"\
        "CLEAN_ALL")
        
    # The name of the names of the functions to call
    LABELS=("Build derivatives for SM, CI"\
        "Simplified fit <-- derivatives for SM, CI"\
        "Monte carlo frequency aproch <-- derivatives for SM, CI"\
        "Monte carlo frequency aproch EXPECTED LIMS <-- derivatives for SM, CI"\
        "Analysis - measured"\
        "Analysis - expected"\
        "CLEAN_ALL")

    local -i I=1
    echo "SELECT RUN_GRID OPTION"
    while [ $I -le ${#MY_ACTIONS[@]} ]
    do
        echo "$I) ${LABELS[$I]}"
        (( I += 1 ))
    done

    local SELECTION
    read -s SELECTION

    local ORD_VALUE=$(LC_CTYPE=C printf '%d' "'$SELECTION")
    (( ORD_VALUE -= 48 ))

    if [ $ORD_VALUE -gt 0 -a $ORD_VALUE -le ${#MY_ACTIONS[@]} ]
    then
        eval ${MY_ACTIONS[${ORD_VALUE}]}
        return
    fi

    echo "-> INVALID SELECTION"
    main_menu
}

main_menu 
