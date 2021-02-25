function F=F(U,gamma,sign)
%This function is used for the evaluation of the numerical flux based on
%the derived formula given by Steger and Warming.
%The preprocessing involves manipulation of conservative variables to
%calculate rho,p,H,lambda and c. Sign=1 denotes F+,lambda+ etc.
%Designed by Michalis Hadjiandreou on 20 Jan 2020
%% Calculate the relating variables needed for F
rho=U(1,:);                                         %First conservative variable
u=U(2,:)./U(1,:);                                   %Velocity at each x location
p=(gamma-1).*(U(3,:)-0.5.*(U(2,:).^2)./U(1,:));     %pressure rearranged based on conservative variables
c=sqrt(gamma.*p./rho);                              %local speed of sound
H=U(3,:)./U(1,:)+p./rho;                            %Calculate H
%% Calculate the local eigenvalues
lambda_1=u-c;
lambda_2=u;
lambda_3=u+c;

%% Apply eigenvalue splitting based on desired sign
if sign==1
    lambda=0.5*( [lambda_1;lambda_2;lambda_3;] + abs([lambda_1;lambda_2;lambda_3;]) );
else
    lambda=0.5*( [lambda_1;lambda_2;lambda_3;] - abs([lambda_1;lambda_2;lambda_3;]) );
end

%% Compose the numeric flux based on equation 10
F=zeros(3,length(U));                                                                                           %initialize for speeding up
F(1,:) = rho./(2*gamma) .*(lambda(1,:) + 2*(gamma - 1)*lambda(2,:) + lambda(3,:));                              %substitute the first row of values
F(2,:) = rho./(2*gamma) .*((u - c).*lambda(1,:) + 2*(gamma - 1)*u.*lambda(2,:) + (u + c).*lambda(3,:));         %substitute the second row of values
F(3,:) = rho./(2*gamma) .*((H - u.*c).*lambda(1,:) + (gamma - 1)*u.^2.*lambda(2,:) + (H + u.*c).*lambda(3,:));  %substitute the third row of values
