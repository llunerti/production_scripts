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



while :; do
    case $1 in
        -h|-\?|--help)
            show_help    # Display a usage synopsis.
            exit
            ;;
        -i|--input_dir)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                INPUT_DIR=$2
                echo "** HLT step: looking for DIGI step output file into $INPUT_DIR directory"
                shift
            else
                echo "** HLT step: Using $INPUT_DIR as input path"
            fi
            ;;
        -o|--output_dir)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                OUTPUT_DIR=$2
                echo "** HLT step: Using $OUTPUT_DIR as output directory"
                shift
            else
                echo "** HLT step: Using $INPUT_DIR as default output directory"
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
                echo "** HLT step: Using ${PROCESS_LABEL}_${JOB_NUMBER}_DIGI.root as input file"
                shift
            else
                die 'ERROR: "--process_label" requires a non-empty option argument.'
            fi
            ;;
        -n|--nevents)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                EVENTS=$2
                echo "** HLT step: producing $EVENTS (input value)"
                shift
            else
                echo "** HLT step: producing $EVENTS (default value)"
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

INPUT_FILENAME_DIGI=${PROCESS_LABEL}_${JOB_NUMBER}_DIGI.root
OUT_FILENAME_HLT=${PROCESS_LABEL}_${JOB_NUMBER}_HLT.root
CFG_FILENAME_HLT=${PROCESS_LABEL}_HLT_cfg.py

export SCRAM_ARCH=slc7_amd64_gcc700

source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_10_2_16_UL/src ] ; then
  echo release CMSSW_10_2_16_UL already exists
else
  scram p CMSSW CMSSW_10_2_16_UL
fi
cd CMSSW_10_2_16_UL/src
eval `scram runtime -sh`

scram b
cd ../..

# cmsDriver command
cmsDriver.py  --python_filename $CFG_FILENAME_HLT --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --fileout file:${OUTPUT_DIR}/${OUT_FILENAME_HLT} --conditions 102X_upgrade2018_realistic_v15 --customise_commands 'process.source.bypassVersionCheck = cms.untracked.bool(True)' --step HLT:2018v32 --geometry DB:Extended --filein file:$INPUT_DIR/$INPUT_FILENAME_DIGI --era Run2_2018 --no_exec --mc -n $EVENTS || exit $? ;

#define HOME variable
export HOME=${PWD}
#check
echo "!!! HLT STEP, HOME variable: ${HOME} !!!"

# Run the cmsRun
cmsRun $CFG_FILENAME_HLT || exit $? ;
