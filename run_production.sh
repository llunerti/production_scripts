#!/bin/bash
# POSIX

show_help() {
    echo "Usage: ${0##*/} [-i INPUT_DIR] [-o OUTPUT_DIR] [-l PROCESS_LABEL] [-n NEVENTS] [--proxy_path PROXY_PATH] [--job_number JOB_NUMBER]..."
    exit 1
}

die() {
    printf '%s\n' "$1" >&2
    exit 0
}

ABS_PATH=/afs/cern.ch/work/l/llunerti/private/BsToDsMuNu_generation/GEN/production_scripts
#export HOME=/home/CMS-T3/lunerti
EVENTS=10
PROCESS_LABEL=
PROXY_PATH=
INPUT_DIR=
OUTPUT_DIR=
JOB_NUMBER=0
EOS_MGM_URL=root://eosuser.cern.ch

while :; do
    case $1 in
        -h|-\?|--help)
            show_help  
            exit
            ;;
        -i|--input_dir)  
            if [ "$2" ]; then
                INPUT_DIR=$2
                shift
            else
                die '!!! ERROR: "--input_dir" requires a non-empty option argument !!!'
            fi
            ;;
        -o|--output_dir)  
            if [ "$2" ]; then
                OUTPUT_DIR=$2
                shift
            else
                die '!!! ERROR: "--output_dir" requires a non-empty option argument !!!'
            fi
            ;;
        -l|--process_label) 
            if [ "$2" ]; then
                PROCESS_LABEL=$2
                shift
            else
                die '!!! ERROR: "--process_label" requires a non-empty option argument !!!'
            fi
            ;;
        -n|--nevents) 
            if [ "$2" ]; then
                EVENTS=$2
                shift
            fi
            ;;
        --proxy_path) 
            if [ "$2" ]; then
                PROXY_PATH=$2
                shift
            else
                die '!!! ERROR: "--proxy_path" requires a non-empty option argument !!!'
            fi
            ;;
        --job_number) 
            if [ "$2" ]; then
                JOB_NUMBER=$2
                shift
            fi
            ;;
        --)              # End of all options.
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)               # Default case: No more options, so break out of the loop.
            break
    esac

    shift
done

${ABS_PATH}/run_GEN_step.sh     -i $INPUT_DIR -o $OUTPUT_DIR -n $EVENTS --job_number ${JOB_NUMBER} --process_label ${PROCESS_LABEL} &&\

${ABS_PATH}/run_SIM_step.sh     -i $INPUT_DIR -o $OUTPUT_DIR -n $EVENTS --job_number ${JOB_NUMBER} --process_label ${PROCESS_LABEL} &&\

${ABS_PATH}/run_DIGI_step.sh    -i $INPUT_DIR -o $OUTPUT_DIR -n $EVENTS --job_number ${JOB_NUMBER} --process_label ${PROCESS_LABEL} --proxy_path $PROXY_PATH &&\

${ABS_PATH}/run_HLT_step.sh     -i $INPUT_DIR -o $OUTPUT_DIR -n $EVENTS --job_number ${JOB_NUMBER} --process_label ${PROCESS_LABEL} &&\

${ABS_PATH}/run_RECO_step.sh    -i $INPUT_DIR -o $OUTPUT_DIR -n $EVENTS --job_number ${JOB_NUMBER} --process_label ${PROCESS_LABEL} &&\

${ABS_PATH}/run_miniAOD_step.sh -i $INPUT_DIR -o $OUTPUT_DIR -n $EVENTS --job_number ${JOB_NUMBER} --process_label ${PROCESS_LABEL} &&\

#staging out miniAOD output
eos cp ${LABEL}_MINIAOD.root /eos/user/l/llunerti/gen_samples/
