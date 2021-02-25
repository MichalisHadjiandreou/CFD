function [final_velocity,final_exact]=semi_lagr_function_modified(N_grid)
% The following function uses an input value of lambda and outputs the
% velocity slice (v vs x) at the end of time dimension. 
% Designed by Michalis Hadjiandreou on 22 Nov 2019

%% Set the standard variables and the grid properties
t_min=0;            % Minimum value of time domain
t_max=1;            % Maximum value of time domain
x_min=0;            % Minimum value of spatial domain
x_max=1;            % Maximum value of spatial domain

%% Apply discretisation to our domain
Deltax=x_max/(N_grid-1);        % Find the spatial step based on the equation on the report
Deltat=0.1;                     % Time step: given in the equation
x=x_min:Deltax:x_max;           % Create the spatial domain
t=t_min:Deltat:t_max;           % Create the time domain

%% Initialize the velocity matrix to reduce execution time. Note that columns represent time and rows represent space
u=zeros(N_grid,length(t));

%% Apply and assign boundary conditions as specified by the question
u_initial=double(x>0.5);        % All x values greateer than 0.5 should have 1 and the rest 0
u_initial(end)=u_initial(1);    % Apply the periodic condition
u(:,1)=u_initial;               % Assign the initial velocity vector to our solution

%% Start the implementation of Semi-Lagrangian scheme
k=zeros(1,2);                   % Initialise the values of k to be substituted with each iteration

% Apply nested for loop to evaluate the velocity mesh from the space-time
% mesh
for n=1:length(t)-1                                        % Keep the convention of subscripts with handout
    for i=1:(N_grid-1)                                     % Keep the convention of subscripts with handout
        k(1)=i-ceil(10*(cos(t(n))-cos(t(n+1)))/Deltax);    % Capture the left side of the departure point. NB lambda changes therefore Delta(at) changes with time
        x_departure=x(i)-(10*(cos(t(n))-cos(t(n+1))));     % Evaluate the position of the departure point. NB varies with time
        k(2)=k(1)+1;                                       % This is the right side of the departure point and therefore the immediately next subscript of k(1)
        
        % We then need to apply the periodic condition and the wrapping
        % around of the departure point and the subscripts in case they get
        % out of the domain
        
        % Shift the subscript
        if k(1)<1
            k(1)=k(1)+(N_grid-1);   % Shift it back via adding the grid length
            k(2)=k(1)+1;            % Need to shift the second coefficient as well, to be consistent
        end
        
        %Shift the departure point
        if x_departure<x_min
            x_departure=x_departure+x_max;
        end
        
        %Find the amplification factor/the fractional part of the linear
        %interpolation
        frac=(x_departure-x(k(1)))/(x(k(2))-x(k(1)));
        
        %Apply the scheme mentioned on the handout
        u(i,n+1) = u(k(1),n) + frac*(u(k(2),n)-u(k(1),n)); %Evaluation of the next time step 
    end                             %This finishes the spatial slice at each time step
    u(N_grid,n+1)=u(1,n+1);         %Apply periodic conditions on the solutions
end                                 %This completes the mesh


%% Extract the final time slice to be used for comparison with rest of lambdas
final_velocity=u(:,end); 

%% Find the exact solution
[time,space]=meshgrid(t,x);                 %Create a mesh
dep = space-(10*cos(t(1))-10*cos(time));    %Changes due to non-linearity
while any(any(dep<0))
    dep(dep<0) = dep(dep<0)+1;
end
while any(any(dep>1))
    dep(dep>1) = dep(dep>1)-1;
end
exact=double(dep>0.5);
exact(end,:)=exact(1,:);                    %Periodic
final_exact=exact(:,end);                   %Export this result
    end


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    