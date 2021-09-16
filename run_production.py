#!/usr/bin/env python3

import os
import socket
import json
import sys
import subprocess

envOverride = {}

if 'HOME' not in os.environ:
    if socket.getfqdn().endswith("infn.it"):
        envOverride['HOME'] = '/home/CMS-T3/lunerti'

os.environ.update(envOverride)

script, inputFileName, job_number = sys.argv

gen_step_command     = str()
sim_step_command     = str()
digi_step_command    = str()
hlt_step_command     = str()
reco_step_command    = str()
miniaod_step_command = str()

abs_path           = str()
gen_input_dir      = str()
gen_output_dir     = str()
sim_input_dir      = str()
sim_output_dir     = str()
digi_input_dir     = str()
digi_output_dir    = str()
hlt_input_dir      = str()
hlt_output_dir     = str()
reco_input_dir     = str()
reco_output_dir    = str()
miniaod_input_dir  = str()
miniaod_output_dir = str()
events             = str()
process_label      = str()
proxy_path         = str()

with open(inputFileName) as cfg_json:
    config = json.load(cfg_json)

    abs_path           = str(config["PROD"]["ABS_PATH"])
    gen_input_dir      = str(config["GEN"]["INPUT_DIR"])
    gen_output_dir     = str(config["GEN"]["OUTPUT_DIR"])
    sim_input_dir      = str(config["SIM"]["INPUT_DIR"])
    sim_output_dir     = str(config["SIM"]["OUTPUT_DIR"])
    digi_input_dir     = str(config["DIGI"]["INPUT_DIR"])
    digi_output_dir    = str(config["DIGI"]["OUTPUT_DIR"])
    hlt_input_dir      = str(config["HLT"]["INPUT_DIR"])
    hlt_output_dir     = str(config["HLT"]["OUTPUT_DIR"])
    reco_input_dir     = str(config["RECO"]["INPUT_DIR"])
    reco_output_dir    = str(config["RECO"]["OUTPUT_DIR"])
    miniaod_input_dir  = str(config["MINIAOD"]["INPUT_DIR"])
    miniaod_output_dir = str(config["MINIAOD"]["OUTPUT_DIR"])
    events             = str(config["PROD"]["EVENTS"])
    process_label      = str(config["PROD"]["PROCESS_LABEL"])
    proxy_path         = str(config["DIGI"]["PROXY_PATH"])

    gen_step_command     = "{}/run_GEN_step.sh -i {} -o {} -n {} --job_number {} --process_label {}".format(abs_path, gen_input_dir, gen_output_dir, events, job_number, process_label)
    sim_step_command     = "{}/run_SIM_step.sh -i {} -o {} -n {} --job_number {} --process_label {}".format(abs_path, sim_input_dir, sim_output_dir, events, job_number, process_label)
    digi_step_command    = "{}/run_DIGI_step.sh -i {} -o {} -n {} --job_number {} --process_label {} --proxy_path {}".format(abs_path, digi_input_dir, digi_output_dir, events, job_number, process_label, proxy_path)
    hlt_step_command     = "{}/run_HLT_step.sh -i {} -o {} -n {} --job_number {} --process_label {}".format(abs_path, hlt_input_dir, hlt_output_dir, events, job_number, process_label)
    reco_step_command    = "{}/run_RECO_step.sh -i {} -o {} -n {} --job_number {} --process_label {}".format(abs_path, reco_input_dir, reco_output_dir, events, job_number, process_label)
    miniaod_step_command = "{}/run_miniAOD_step.sh -i {} -o {} -n {} --job_number {} --process_label {}".format(abs_path, miniaod_input_dir, miniaod_output_dir, events, job_number, process_label)


try:
    print("RUNNING {}".format(gen_step_command))
    subprocess.call(gen_step_command,shell=True)
    
    print("RUNNING {}".format(sim_step_command))
    subprocess.call(sim_step_command,shell=True)
    
    print("RUNNING {}".format(digi_step_command))
    subprocess.call(digi_step_command,shell=True)
    
    print("RUNNING {}".format(hlt_step_command))
    subprocess.call(hlt_step_command,shell=True)
    
    print("RUNNING {}".format(reco_step_command))
    subprocess.call(reco_step_command,shell=True)
    
    print("RUNNING {}".format(miniaod_step_command))
    subprocess.call(miniaod_step_command,shell=True)

except subprocess.CalledProcessError:
    exit(0)
    
