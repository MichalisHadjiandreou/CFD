function max_lambda=max_lambda(U,gamma)
%The following code is used to determine the maximum eigenvalue of all
%spatial locations for a certrain input of vector U
%Designed by Michalis Hadjiandreou on 20 Jan 2020
%% Calculate the necessary variables for the determination of lambdas
rho=U(1,:);                                         %First conservative variable
u=U(2,:)./U(1,:);                                   %Velocity at each x location
p=(gamma-1).*(U(3,:)-0.5.*(U(2,:).^2)./U(1,:));     %pressure rearranged based on conservative variables
c=sqrt(gamma.*p./rho);                              %local speed of sound
H=U(3,:)./U(1,:)+p./rho;                            %Calculate H
%% Calculate the local eigenvalues
lambda_1=u-c;
lambda_2=u;
lambda_3=u+c;

%% Find the global maximum of the 2D matrix of lambdas
max_lambda=max(max(abs([lambda_1,lambda_2,lambda_3])));
end
