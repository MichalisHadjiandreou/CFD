%The following script is used to investigate the effect of timesteps on
%maximum eigen values and the RHS of the CFL inequality
%Designed by Michalis Hadjiandreou on 20 Jan 2020
clear
clc
close all

%% Plot options
set(0,'defaulttextInterpreter','latex') %latex axis labels
set(0,'defaultlegendInterpreter','latex') %latex axis labels

%% Timestep effect
t=0.0005:0.0005:0.0070;  %Set a range of timesteps to be investigated

for i=t
   j=j+1;                %counter
   [u_final(j,:),maxi_lambda(j),hyp_vel(j)] =myfunction(i); %Store the values of LHS and RHS of CFL inequality
end

%% Plot
%Plot the variation of LHS and RHS of inequality for the specific case of
%N=300 as the timesteps vary
plot(t,hyp_vel)
hold on
plot(t,1./maxi_lambda)
legend('$\frac{\Delta t}{\Delta x}$','$\frac{1}{max(\lambda_{i})}$')
xlabel('$\Delta t$')
ylabel('Properties in legend')
grid minor