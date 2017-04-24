run10021_data=cell(1);
try
x=load('/home/tsatter/AAE560/rundata/run10021/job1/run10021_job1.mat');
run10021_data{1,1}=x.output;
catch e
x=1;
 run10021_data{1,1}=x;
end

run10021_input.v1=500;
run10021_input.v2=1;
save('-v7','/home/tsatter/AAE560/rundata/run10021.mat','run10021_data','run10021_input');
