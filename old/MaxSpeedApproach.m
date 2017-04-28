function [speed,route_choice] = MaxSpeedApproach(AvgS1,AvgS2,AvgS3)
%UNTITLED Summary of this function goes here
% AvgS - is the average travel speed in each of the three other routes
% val = max value of average speed
% index = location of max value in speed array
%route choice is the index of the max solution
Speed = [AvgS1,AvgS2,AvgS3];
[val,ind] = max(Speed);
route_choice=ind;
speed = val;
end

