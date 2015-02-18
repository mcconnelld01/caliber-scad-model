NUM_PATIENTS=2
PSA=1000
for i in $(eval echo "{1..$NUM_PATIENTS}")
do
	export PATIENT=$i
	export PSA_ITER=$PSA
	export PATIENT_GROUP=manual
	qsub summarise_results.job
done
