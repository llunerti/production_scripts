#!/bin/bash
# POSIX

show_help() {
    echo "Usage: ${0##*/} [-i INPUT_DIR] [-o OUTPUT_DIR] [--process_label PROCESS_LABEL] [-n NEVENTS] [--job_number JOB_NUMBER]..."
    exit 1
}

die() {
    printf '%s\n' "$1" >&2
    exit 0
}

# Initialize all the option variables.
# This ensures we are not contaminated by variables from the environment.
PROCESS_LABEL=
INPUT_DIR=$PWD;
OUTPUT_DIR=$PWD;
EVENTS=100;
JOB_NUMBER=0
CMSSW_RELEASE=CMSSW_10_6_17_patch1

while :; do
    case $1 in
        -h|-\?|--help)
            show_help    # Display a usage synopsis.
            exit
            ;;
        -i|--input_dir)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                INPUT_DIR=$2
                echo "** RECO step: looking for HLT step output file into $INPUT_DIR directory"
                shift
            else
                echo "** RECO step: Using $INPUT_DIR as input path"
            fi
            ;;
        -o|--output_dir)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                OUTPUT_DIR=$2
                echo "** RECO step: Using $OUTPUT_DIR as output directory"
                shift
            else
                echo "** RECO step: Using $INPUT_DIR as default output directory"
            fi
            ;;
        --job_number) 
            if [ "$2" ]; then
                JOB_NUMBER=$2
                shift
            fi
            ;;
        --process_label)       # Takes an option argument; ensure it has been specified.
            if [ "$INPUT_DIR/$2" ]; then
                PROCESS_LABEL=$2
                echo "** RECO step: Using ${PROCESS_LABEL}_${JOB_NUMBER}_HLT.root as input file"
                shift
            else
                die 'ERROR: "--process_label" requires a non-empty option argument.'
            fi
            ;;
        -n|--nevents)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                EVENTS=$2
                echo "** RECO step: producing $EVENTS (input value)"
                shift
            else
                echo "** RECO step: producing $EVENTS (default value)"
            fi
            ;;
        --cmssw_rel)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                CMSSW_RELEASE=$2
                echo "** RECO step: Using CMSSW_${CMSSW_RELEASE}"
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

INPUT_FILENAME_HLT=${PROCESS_LABEL}_${JOB_NUMBER}_HLT.root
OUT_FILENAME_RECO=${PROCESS_LABEL}_${JOB_NUMBER}_RECO.root
CFG_FILENAME_RECO=${PROCESS_LABEL}_RECO_cfg.py

export SCRAM_ARCH=slc7_amd64_gcc700

source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r ${CMSSW_RELEASE}/src ] ; then
  echo release ${CMSSW_RELEASE} already exists
else
  scram p CMSSW ${CMSSW_RELEASE}
fi
cd ${CMSSW_RELEASE}/src
eval `scram runtime -sh`

scram b
cd ../..

# cmsDriver command
cmsDriver.py  --python_filename $CFG_FILENAME_RECO --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --fileout file:${OUTPUT_DIR}/${OUT_FILENAME_RECO} --conditions 106X_upgrade2018_realistic_v11_L1v1 --step RAW2DIGI,L1Reco,RECO,RECOSIM,EI --geometry DB:Extended --filein file:$INPUT_DIR/$INPUT_FILENAME_HLT --era Run2_2018 --runUnscheduled --no_exec --mc -n $EVENTS || exit $? ;

# Run the cmsRun
cmsRun $CFG_FILENAME_RECO || exit $? ;
