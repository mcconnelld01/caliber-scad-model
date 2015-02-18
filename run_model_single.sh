#!/bin/bash

export PATIENT=$2
export ITERATION=$3
export PATIENT_GROUP=$1
export INPUT_FILE="input_data/pegasus_odyssey_patients.csv"
qsub run_model_psa.job
