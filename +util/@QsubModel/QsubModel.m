classdef QsubModel < handle
    %QSUBMODEL QS
    %   Detailed explanation goes here
    
    properties
        runLogPath='./tmp';
    end
    
    methods(Static)
        
        function [ ] = create_run(run_id,function_name,varargin)
            
            %Example:
            %QsubModel.create_run(1,'QsubModel.collectInputSample',[1:20]);
            
            base_param_num=2;
            
            qsub_args='qsub -l nodes=1:ppn=1,walltime=02:00:00';
            exec_dir=pwd();
            %exec_dir='D:/temp';
            data_dir=strcat(exec_dir,'/rundata');
            script_dir=strcat(exec_dir,'/scripts');
            mkdir(data_dir);
            mkdir(script_dir);
            
            
            lenparam=[];
            for i=base_param_num+1:nargin
                param=varargin{i-base_param_num};
                if isa(param, 'char')
                    paramLength = 1;
                else
                    paramLength = length(param);
                end
                lenparam(end+1)=paramLength; %#ok<AGROW>
            end
            
            %numparam=lenparam(1);
            %for i=2:length(lenparam)
            %	numparam=numparam*lenparam(i);
            %end
            
            x=1:max(max(lenparam));
            n=length(lenparam);
            m = length(x);
            X = cell(1, n);
            [X{:}] = ndgrid(x);
            X = X(end : -1 : 1);
            y = cat(n+1, X{:});
            y = reshape(y, [m^n, n]);
            
            for i=1:length(lenparam)
                testval=lenparam(i);
                testvect=y(:,i);
                y(testvect>testval,:)=[];
            end
            
            num_job_id=size(y, 1);
            
            submit_script=strcat(script_dir,'/run_',num2str(run_id),'.sh');
            fid=fopen(submit_script,'w');
            
            load_script=strcat(script_dir,'/load_run_',num2str(run_id),'.m');
            lfid=fopen(load_script,'w');
            sizestr=sprintf('%.0f,',max(y));
            sizestr(end)='';
            dataname=sprintf('run%d_data',run_id);
            fprintf(lfid,'%s=cell(%s);\n',dataname,sizestr);
            
            base_store_file=strcat(script_dir,'/run',num2str(run_id),'/');
            mkdir(base_store_file);
            
            for i=1:num_job_id
                idx=y(i,:);
                log_temp_dir=sprintf('/tmp/log_run%d_job%d/',run_id,i);
                param_string=[ '''''' log_temp_dir '''''' ','];
                for k=1:length(idx)
                    tmp=varargin{k};
                    if isa(tmp, 'char')
                        param_string = strcat(param_string, '''''', tmp, '''''', ',');
                    else
                        param_string=strcat(param_string,num2str(tmp(idx(k))),',');
                    end
                end
                param_string(end)='';
                exec_str=strcat(function_name,'(',param_string,')');
                store_file=strcat(base_store_file,num2str(i),'.sh');
                job_data_dir=strcat(data_dir,'/run',num2str(run_id),'/job',num2str(i));
                
                util.QsubModel.create_script(store_file,log_temp_dir,exec_str,exec_dir,job_data_dir,run_id,i);
                fprintf(fid,'%s %s\n',qsub_args,store_file);
                idxstr=sprintf('%.0f,',idx);
                idxstr(end)='';
                loaddata_file=strcat(job_data_dir,'/run',num2str(run_id),'_job',num2str(i),'.mat');
                fprintf(lfid,'try\n');
                fprintf(lfid,'x=load(''%s'');\n',loaddata_file);
                fprintf(lfid,'%s{%s}=x.output;\n',dataname,idxstr);
                fprintf(lfid,'catch e\nx=%d;\n ',i);
                fprintf(lfid,'%s{%s}=x;\nend\n\n',dataname,idxstr);
            end
            
            for i=base_param_num+1:nargin
                k=i-base_param_num;
                param=varargin{k};
                fprintf(lfid,'run%d_input.v%d=%s;\n',run_id,k,mat2str(param));
            end
            
            finalfile=strcat(data_dir,'/run',num2str(run_id),'.mat');
            %Octave:
            fprintf(lfid,'save(''-v7'',''%s'',''%s'',''run%d_input'');\n',finalfile,dataname,run_id);
            %MATLAB:
            %fprintf(lfid,'save(''%s'',''%s'',''run%d_input'');\n',finalfile,dataname,run_id);
            
            fclose(fid);
            fclose(lfid);
            
            
        end
        
        function [ ] = create_script(store_file,log_temp_dir,exec_str,exec_dir,data_dir,run_id,job_id)
            
            fid=fopen(store_file,'w');
            
            fprintf(fid,'#!/bin/bash\n');
            fprintf(fid,'#PBS -o ''%s/qsub.out''\n',data_dir);
            fprintf(fid,'#PBS -e ''%s/qsub.err''\n',data_dir);
            fprintf(fid,'cd %s\n',exec_dir);
            fprintf(fid,'mkdir -p %s\n',data_dir);
            save_file=strcat(data_dir,'/run',num2str(run_id),'_job',num2str(job_id),'.mat');
            output_temp=sprintf('/tmp/console_run%d_job%d.out',run_id,job_id);
            fprintf(fid,'mkdir -p %s\n',log_temp_dir);
            fprintf(fid,'matlab -nodisplay -nosplash -nodesktop > %s 2>&1 << EOF\n',output_temp);
            fprintf(fid,'util.QsubModel.exec_run(''%s'',''%s'');\n',save_file,exec_str);
            fprintf(fid,'dbstack\n');
            fprintf(fid,'exit\n');
            fprintf(fid,'EOF\n');
            fprintf(fid,'gzip %s\n mv %s.gz %s\n',output_temp,output_temp,data_dir);
            
            fclose(fid);
            
            
        end
        
        function exec_run(save_file,exec_str)
            disp(exec_str);
            [output]=eval(exec_str); %#ok<NASGU>
            
            save(save_file,'output');
            
        end
    end
    
end

