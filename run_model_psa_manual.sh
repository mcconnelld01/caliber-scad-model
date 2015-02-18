NUM_PATIENTS=2
NUM_ITER=1000
for i in $(eval echo "{1..$NUM_PATIENTS}")
do
	export PATIENT=$i 
	export PATIENT_GROUP=manual
	export INPUT_FILE="input_data/pegasus_odyssey_patients.csv"
	for j in $(eval echo "{1..$NUM_ITER}")
	do
		export ITERATION=$j
		qsub run_model_psa.job
	done
done
