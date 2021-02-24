% This script is used alongside the semi_lagr_function.m function so please
% make sure they are in the same folder. The aim of this is to run the
% function for various lambda values and plot the final time slice for all
% the cases for comparison.
% Designed by Michalis Hadjiandreou on 22 Nov 2019

%% Clear everything
clear
clc
close all

%% Assign the values of lambda to run through
lambda=[0.5,1,1.5,5];           %Given in the question

%% Run the function in a loop. Each row represents the velocity vector of the final time slice at EACH lambda
for i=1:length(lambda)
    [x,u_plot(i,:),final_exact(i,:)]=semi_lagr_function(lambda(i));
end

%% Plot the results
figure
one=plot(x,u_plot(1,:),'k-','LineWidth',2)
hold on 
two=plot(x,u_plot(2,:),'r-','LineWidth',3)
three=plot(x,u_plot(3,:),'b--','LineWidth',2)
four=plot(x,u_plot(4,:),'g.','LineWidth',2)
grid minor
xlabel('Space domain')
ylabel('Velocity')

%Plot the exact
ex=plot(x,final_exact(end,:),'c-','LineWidth',1);

legend([one,two,three,four,ex],['\lambda=',num2str(lambda(1))],['\lambda=',num2str(lambda(2))],['\lambda=',num2str(lambda(3))],['\lambda=',num2str(lambda(4))],'Exact');
