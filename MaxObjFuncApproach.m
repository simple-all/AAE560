function [route_choice] = MaxObjFuncApproach(AvgS1,AvgS2,AvgS3,TotalCars1,TotalCars2,TotalCars3)
%UNTITLED Summary of this function goes here
% AvgS - is the average travel speed in each of the three other routes
% TotalCars = amount of vehicles on the road
% index = location of max value in speed array
%route choice is the index of the max solution
Speed = [AvgS1,AvgS2,AvgS3];
Cars = [TotalCars1,TotalCars2,TotalCars3];
choice - rand(1);
for i=1:1:3
    Obj
[val,ind] = max(Speed);
route_choice=ind;
end

