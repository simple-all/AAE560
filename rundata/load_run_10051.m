run10051_data=cell(1);
try
x=load('/home/tsatter/AAE560/rundata/run10051/job1/run10051_job1.mat');
run10051_data{1,1}=x.output;
catch e
x=1;
 run10051_data{1,1}=x;
end

run10051_input.v1=500;
run10051_input.v2=1;
save('-v7','/home/tsatter/AAE560/rundata/run10051.mat','run10051_data','run10051_input');
