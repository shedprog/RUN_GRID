#!/bin/zsh

source settings_var.sh
source src/simpfit.sh
source src/clean.sh
source src/derivative.sh
source src/mc.sh

function LH_method {
    python $WORKDIR/src/analysis_py/Q_method.py left $OUTPUTDIR
    python $WORKDIR/src/analysis_py/Q_method.py right $OUTPUTDIR
}

function replica {
    python $WORKDIR/src/analysis_py/build_.py left $OUTPUTDIR
    python $WORKDIR/src/analysis_py/Q_method.py right $OUTPUTDIR
}


function main_menu
{
    local -a MY_ACTIONS
    MY_ACTIONS=("build_deriv"\
        "simpfit"\
        "monte_carlo_LH_default"\
        "monte_carlo_freq settings_limits.txt"\
        "monte_carlo_freq settings_explimits.txt"\
        "monte_carlo_LH"\
        "LH_method"\
        "replica"\
        "CLEAN_ALL")

    LABELS=("Build derivatives for SM, CI"\
        "Simplified fit <-- derivatives for SM, CI"\
        "Monte carlo LH (deault xFitter!) - long work"
        "Monte carlo frequency aproch <-- derivatives for SM, CI"\
        "Monte carlo frequency aproch EXPECTED LIMS <-- derivatives for SM, CI"\
        "Monte carlo LH_method <-- derivatives for SM, CI"\
        "Analysis (Python) - LH_method"\
        "Analysis (Python) - replica"
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
