#!/bin/bash
#this file will run to check which filterbank files have been run and which have not
while getopts "bfld:" flag
do
    case "${flag}" in
        b) RBATCH=true;;
        f) RFETCH=true;;
        l) LOCAL=true;;
        d) DM=$OPTARG;;
    esac
done
shift $(($OPTIND - 1))
FILFILES=$@
echo $FILFILES
BATCH=false
FETCH=false
for FIL in $FILFILES;
do
    #strip the extension
    PULSAR=$(echo "$FIL" | rev | cut -f2- -d '.' | rev)
    if [ -d $PULSAR ]; then
        SP="${PULSAR}/"*"cands.csv"
        if [ -f $SP ]; then
            #now finally check if results has been run
            #Check FETCH 1 has been run
            FP="${PULSAR}/nsub_0_5/results_a.csv"
            echo $PULSAR
            if [ ! -f $FP ]; then
                #echo $FP
                #echo "$FIL never ran FETCH missing 0"
                #ls -lHd $FIL
                FETCH=true
            fi

            #check FETCH 2 has been run
            FP="${PULSAR}/nsub_1/results_a.csv"
            if [ ! -f $FP ]; then
                #echo $FP
                #echo "$FIL never ran FETCH missing 1"
                #ls -lHd $FIL
                FETCH=true
            fi

            #check FETCH 2 has been run
            FP="${PULSAR}/nsub_short_0_5/results_a.csv"
            if [ ! -f $FP ]; then
                #echo $FP
                #echo "$FIL never ran FETCH missing 1"
                #ls -lHd $FIL
                FETCH=true
            fi

            #check FETCH 2 has been run
            FP="${PULSAR}/nsub_0_1/results_a.csv"
            if [ ! -f $FP ]; then
                #echo $FP
                #echo "$FIL never ran FETCH missing 1"
                #ls -lHd $FIL
                FETCH=true
            fi

            FP="${PULSAR}/nsub_0_1_short/results_a.csv"
            if [ ! -f $FP ]; then
                #echo $FP
                #echo "$FIL never ran FETCH missing 1"
                #ls -lHd $FIL
                FETCH=true
            fi


            if [ "$FETCH" = false ]; then
                echo "$FIL finished everything nothing to see here..." >> completed.csv
            else
                #check if cands is empty
                LINES=$(cat "$PULSAR"/cands.csv | wc -l)
                if [ "$LINES" -gt 1 ]
                then
                    FETCH=true
                    #echo "**** printing cands *****"
                    #cat "${PULSAR}"/*cands*.csv
                    #echo "****end cands*****"
                    echo "$FIL never ran FETCH"
                    ls -lHd $FIL
                else
                    FETCH=false
                    echo "${PULSAR} - cands file empty"
                fi
            fi

        else
            echo "$FIL never finished running single_pulse_search.py"
            ls -hlHd $FIL
            BATCH=true
        fi
    else
        echo "$FIL has no directory"
        BATCH=true
    fi
    #run the a batch for this pulsar, should probably use the base job script... but it's easier to do it this way
    if [ "$RBATCH" = true ]; then
        if [ "$BATCH" = true ]; then
            echo "submitting batch job for $PULSAR"
            #find the directory that the script belongs to
            SCRIPT_DIR="$(dirname $(readlink -f $0))"
            #this will send the batch job and after it's done sent the fetch job
            if [ "$LOCAL" = true ]; then
                $SCRIPT_DIR/process_all_fil.sh -l -d $DM -f $FIL
            else
                $SCRIPT_DIR/process_all_fil.sh -d $DM -f $FIL
            fi
        fi
    fi
    if [ "$RFETCH" = true ]; then
        if [ "$FETCH" = true ]; then
            echo "submitting FETCH job for $PULSAR"
            #find the directory that the script belongs to
            SCRIPT_DIR="$(dirname $(readlink -f $0))"
            AP=$(readlink -f $PULSAR)
            #lets find all directories where we've run prep_fetch
            PROCESSED=$(find $AP -name 'cands.csv' -printf '%h\n' | sort -u)
            cd $PROCESSED
            if [ "$LOCAL" = true ]; then
                $SCRIPT_DIR/automated_filterbank_FETCH_single.sh -l -i $PROCESSED -p $SCRIPT_DIR
            else
                sbatch $SCRIPT_DIR/automated_filterbank_FETCH_single.sh -i $PROCESSED -p $SCRIPT_DIR
            fi
            cd ..
        fi
    fi
    
    BATCH=false
    FETCH=false
done
