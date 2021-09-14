#!/bin/bash
# POSIX

show_help() {
    echo "Usage: ${0##*/} [--cfg JSON_CFG_FILE]"
    exit 1
}

die() {
    printf '%s\n' "$1" >&2
    exit 0
}


JSON_CFG_FILE=

while :; do
    case $1 in
        -h|-\?|--help)
            show_help  
            exit
            ;;
        --cfg)  
            if [ "$2" ]; then
                JSON_CFG_FILE=$2
                shift
            else
                die '!!! ERROR: "--cfg" requires a non-empty option argument !!!'
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

#initialize all variables using cfg file
ABS_PATH=$(jq -r '.PROD.ABS_PATH' ${JSON_CFG_FILE})
EVENTS=$(jq -r '.PROD.EVENTS' ${JSON_CFG_FILE})
PROCESS_LABEL=$(jq -r '.PROD.PROCESS_LABEL' ${JSON_CFG_FILE})
PROXY_PATH=$(jq -r '.DIGI.PROXY_PATH' ${JSON_CFG_FILE})
JOB_NUMBER=$(jq -r '.PROD.JOB_NUMBER' ${JSON_CFG_FILE})
EOS_MGM_URL=root://eosuser.cern.ch

${ABS_PATH}/run_GEN_step.sh     -i $(jq -r '.GEN.INPUT_DIR' ${JSON_CFG_FILE})     -o $(jq -r '.GEN.OUTPUT_DIR' ${JSON_CFG_FILE})     -n $EVENTS --job_number ${JOB_NUMBER} --process_label ${PROCESS_LABEL} &&\
                                                                                                                                   
${ABS_PATH}/run_SIM_step.sh     -i $(jq -r '.SIM.INPUT_DIR' ${JSON_CFG_FILE})     -o $(jq -r '.SIM.OUTPUT_DIR' ${JSON_CFG_FILE})     -n $EVENTS --job_number ${JOB_NUMBER} --process_label ${PROCESS_LABEL} &&\
                                                                                                                                   
${ABS_PATH}/run_DIGI_step.sh    -i $(jq -r '.DIGI.INPUT_DIR' ${JSON_CFG_FILE})    -o $(jq -r '.DIGI.OUTPUT_DIR' ${JSON_CFG_FILE})    -n $EVENTS --job_number ${JOB_NUMBER} --process_label ${PROCESS_LABEL} --proxy_path $PROXY_PATH &&\
                                                                                                                                   
${ABS_PATH}/run_HLT_step.sh     -i $(jq -r '.HLT.INPUT_DIR' ${JSON_CFG_FILE})     -o $(jq -r '.HLT.OUTPUT_DIR' ${JSON_CFG_FILE})     -n $EVENTS --job_number ${JOB_NUMBER} --process_label ${PROCESS_LABEL} &&\
                                                                                                                                   
${ABS_PATH}/run_RECO_step.sh    -i $(jq -r '.RECO.INPUT_DIR' ${JSON_CFG_FILE})    -o $(jq -r '.RECO.OUTPUT_DIR' ${JSON_CFG_FILE})    -n $EVENTS --job_number ${JOB_NUMBER} --process_label ${PROCESS_LABEL} &&\
                                                                                                                                   
${ABS_PATH}/run_miniAOD_step.sh -i $(jq -r '.MINIAOD.INPUT_DIR' ${JSON_CFG_FILE}) -o $(jq -r '.MINIAOD.OUTPUT_DIR' ${JSON_CFG_FILE}) -n $EVENTS --job_number ${JOB_NUMBER} --process_label ${PROCESS_LABEL} &&\

#staging out miniAOD output
eos cp $(jq -r '.MINIAOD.OUTPUT_DIR' ${JSON_CFG_FILE})/${PROCESS_LABEL}_MINIAOD.root $(jq -r '.PROD.OUTPUT_DIR' ${JSON_CFG_FILE})
