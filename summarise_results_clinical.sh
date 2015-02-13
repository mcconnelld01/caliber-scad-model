NUM_PATIENTS=10
PSA=1000
for i in $(eval echo "{1..$NUM_PATIENTS}")
do
	export PATIENT=$i
	export PSA_ITER=$PSA
	export PATIENT_GROUP=clinical
	qsub summarise_results.job
done
