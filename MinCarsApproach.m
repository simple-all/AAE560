function [route_choice] = MinCarsApproach(TotalCars1,TotalCars2,TotalCars3)
%UNTITLED Summary of this function goes here
% TotalCars = amount of vehicles on the road
% index = location of max value in speed array
%route choice is the index of the max solution
Cars = [TotalCars1,TotalCars2,TotalCars3];
[val,ind] = min(Cars);
route_choice=ind;
end

