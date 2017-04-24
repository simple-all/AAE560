run129486239_data=cell(1);
try
x=load('/home/tsatter/AAE560/rundata/run129486239/job1/run129486239_job1.mat');
run129486239_data{1}=x.output;
catch e
x=1;
 run129486239_data{1}=x;
end

run129486239_input.v1=1;
save('-v7','/home/tsatter/AAE560/rundata/run129486239.mat','run129486239_data','run129486239_input');
