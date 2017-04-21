#!/bin/bash
#PBS -o 'C:\Users\tsatter\Documents\GitHub\AAE560/rundata/run129486239/job1/qsub.out'
#PBS -e 'C:\Users\tsatter\Documents\GitHub\AAE560/rundata/run129486239/job1/qsub.err'
cd C:\Users\tsatter\Documents\GitHub\AAE560
mkdir -p C:\Users\tsatter\Documents\GitHub\AAE560/rundata/run129486239/job1
mkdir -p /tmp/log_run129486239_job1/
matlab -nodisplay -nosplash -nodesktop > /tmp/console_run129486239_job1.out 2>&1 << EOF
util.QsubModel.exec_run('C:\Users\tsatter\Documents\GitHub\AAE560/rundata/run129486239/job1/run129486239_job1.mat','models.base.base_1000(''/tmp/log_run129486239_job1/'',1)');
dbstack
exit
EOF
gzip /tmp/console_run129486239_job1.out
 mv /tmp/console_run129486239_job1.out.gz C:\Users\tsatter\Documents\GitHub\AAE560/rundata/run129486239/job1
