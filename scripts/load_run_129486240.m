run129486240_data=cell(1);
try
x=load('C:\Users\tsatter\Documents\GitHub\AAE560/rundata/run129486240/job1/run129486240_job1.mat');
run129486240_data{1}=x.output;
catch e
x=1;
 run129486240_data{1}=x;
end

run129486240_input.v1=2;
save('-v7','C:\Users\tsatter\Documents\GitHub\AAE560/rundata/run129486240.mat','run129486240_data','run129486240_input');
