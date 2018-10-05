#!/bin/zsh

source settings_var.sh
source src/simpfit.sh
source src/clean.sh
source src/derivative.sh
source src/mc.sh

function replica_ROOT {
    echo $OUTPUTDIRs
    python ./src/analysis_py/replica_error.py left $1 $OUTPUTDIR $models &
    python ./src/analysis_py/replica_error.py right $1 $OUTPUTDIR $models
}

function main_menu
{
    local -a MY_ACTIONS

    MY_ACTIONS=("default_fit"\
        "build_deriv"\
        "simpfit"\
        "monte_carlo_freq_updated  settings_limits.txt"\
        "monte_carlo_freq_updated  settings_explimits.txt"\
        "replica measured"\
        "replica expected"\
        "CLEAN_ALL")
        
    LABELS=("Default fit"\
        "Build derivatives for SM, CI"\
        "Simplified fit <-- derivatives for SM, CI"\
        "MC new - measured"\
        "MC new - expected"\
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
