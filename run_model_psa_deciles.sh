NUM_PATIENTS=10
NUM_ITER=1000
for i in $(eval echo "{1..$NUM_PATIENTS}")
do
	export PATIENT=$i 
	export PATIENT_GROUP=deciles
	for j in $(eval echo "{1..$NUM_ITER}")
	do
		export ITERATION=$j
		qsub run_model_psa.job
	done
done
