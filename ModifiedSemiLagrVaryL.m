% This script is used alongside the semi_lagr_function_modified.m function so please
% make sure they are in the same folder. The aim of this is to run the
% function for various gridpoint values and plot the final time slice for all
% the cases for comparison.
% Designed by Michalis Hadjiandreou on 22 Nov 2019

%% Clear everything
clear
clc
close all

%% Assign the values of lambda to run through
N_grid=[11,21,51,101,201,251,501];           %Grid points sweep test

%% Run the function in a loop. Each row represents the velocity vector of the final time slice at EACH lambda
for i=1:length(N_grid)
    [u_plot{i},final_exact{i}]=semi_lagr_function_modified(N_grid(i));
end

%% Plot the results
figure
one=plot([0:1/(N_grid(1)-1):1],double(u_plot{1}),'kx-','LineWidth',2);
hold on 
two=plot([0:1/(N_grid(2)-1):1],double(u_plot{2}),'ro-','LineWidth',3)
three=plot([0:1/(N_grid(3)-1):1],double(u_plot{3}),'b*--','LineWidth',2)
four=plot([0:1/(N_grid(4)-1):1],double(u_plot{4}),'cx-','LineWidth',2)
five=plot([0:1/(N_grid(5)-1):1],double(u_plot{5}),'r:','LineWidth',2)
six=plot([0:1/(N_grid(6)-1):1],double(u_plot{6}),'b.-','LineWidth',2)
seven=plot([0:1/(N_grid(7)-1):1],double(u_plot{7}),'y.-','LineWidth',2.5)

grid minor
xlabel('Space domain')
ylabel('Velocity')

%Plot the exact
ex=plot([0:1/(N_grid(7)-1):1],double(final_exact{7}),'m-','LineWidth',1.5);

legend([one,two,three,four,five,six,seven,ex],['Ngrid=',num2str(N_grid(1))],['Ngrid=',num2str(N_grid(2))],['Ngrid=',num2str(N_grid(3))],['Ngrid=',num2str(N_grid(4))],['Ngrid=',num2str(N_grid(5))],['Ngrid=',num2str(N_grid(6))],['Ngrid=',num2str(N_grid(7))],'Exact')
