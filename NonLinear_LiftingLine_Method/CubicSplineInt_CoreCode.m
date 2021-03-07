% The following script is used for performing cubic spline interpolation and evaluate
% the interpolated value for a given data set, at a specific value of x
% Designed by Michalis Hadjiandreou on 4th April 2017

% Begin by clearing the screen and workspace
%------------------------------------------
clear
clc

% Input the necessary information
%-------------------------------
warning('Your vectors must be equal in length otherwise the script will not run!')
disp('Please input square brackets at the start and end of the vectors to be inputted below: ')
XIN=input('Please input the vector of the independent variable datapoints: '); % THE VALUES OF x OF THE DATAPOINTS
YIN=input('Please input the vector of the dependent variable datapoints: '); % THE VALUES OF f(x) OF THE CORRESPONDING x DATAPOINTS
XEVAL=input('Please input as a vector the value or values of the independent variable datapoints you wish to obtain the interpolated values for: '); %THE VALUES OF x YOU WISH TO OBTAIN THE INTERPOLATED VALUES OF y

%PERFORM A CHECK THAT THE ORDER OF THE INPUT XIN IS IN ASCENDING ORDER
%------------------------------------------------------------------
TEST=issorted(XIN); %RETURNS 1 IF SORTED AND 0 IF NOT
while TEST==0
    warning('The values of independent variables are not in ascending order. Please re-input the sorted vector and make sure any necessary swapping in the corresponding y-values to be done')
    XIN=input('Please input the vector of the independent variable datapoints: '); % THE VALUES OF x OF THE DATAPOINTS
    YIN=input('Please input the vector of the dependent variable datapoints: '); % THE VALUES OF f(x) OF THE CORRESPONDING x DATAPOINTS
    TEST=issorted(XIN); %RE CHECK IF SORTED
end

%CALL THE FUNCTION cubic_spline_interpolation TO OBTAIN THE COEFFICIENTS THAT ARE GOING TO BE USED FOR cubicEval FUNCTION
%------------------------------------------------------------------------------------------------------------------------
COEFFICIENTS=cubic_spline_interpolation(XIN,YIN); %THE ARRAY OF COEFFICIENTS IS ARRANGED WITHIN THE FUNCTION IN THE FORM REQUIRED BY cubicEval

%USE THE FUNCTION cubicEval TO EVALUATE THE INTEROPLATED VALUES
%--------------------------------------------------------------
YEVAL=zeros(1,length(XEVAL)); %INITIALIZE THE VECTOR OF INTERPOLATED VALUES THAT ARE GOING TO BE SUBSTITUTED LATER
for i=1:length(XEVAL) %REPEAT CALLING THE FUNCTION FOR OBTAINING EACH INTERPOLATED VALUE
    YEVAL(i)=cubicEval(XIN,COEFFICIENTS,XEVAL(i)); %SUBSTITUTE 0 WITH THE TRUE VALUE FOR OPTIMIZING SPEED
end

%PLOTTING OF THE POINTS FOR VERIFICATION OF VALID INTERPOLATION IN A FASTER
%WAY THAN CALLING THE FUNCTION cubicEval EACH TIME
%--------------------------------------------------------------------------
%REVERT THE FORM OF COEFFICIENTS IN A WAY TO BE USED FOR PLOTTING
COEFFICIENTS=flip(COEFFICIENTS,2);
COEFFICIENTS=COEFFICIENTS';

%CREATE THE VECTORS TO BE PLOTTED USING MATRICES FOR EACH INTERVAL
INTERVALS=length(XIN)-1; %NUMBER OF INTERVALS NEEDED FOR PLOTTING

for i=1:INTERVALS
    XPLOT=linspace(XIN(i),XIN(i+1)); %CREATES EQUIDISTANT 100 POINTS BETWEEN THE INPUTTED x DATAPOINTS AT EACH INTEVAL
    YPLOT=[ones(100,1) (XPLOT'-XIN(i)) (XPLOT'-XIN(i)).^2 (XPLOT'-XIN(i)).^3]*COEFFICIENTS(:,i); %MATRIX MULTIPLICATION OF THE FORM OF AN ARRAY 100X4 (includes terms of x^0 (x-xi) (x-xi)^2 (x-xi)^3 FOR EACH POINT IN THE linspace OF THAT INTERVAL TIMES THE
    %COEFFICIENT'S COLUMN THAT CONTAINS THE SPECIFIC COEFFICENTS OF THAT INTERVAL. THIS WILL RESULT IN A 100X1 VECTOR YPLOT THAT CONTAINS THE INTERPOLATED y-values WITHIN THAT INTERVAL
    plot(XPLOT,YPLOT,'-k') %PLOT THE VALUES OF THE SPECIFIC INTERVAL
    hold on %KEEP UPDATING THE PLOT FOR EACH INTERVAL
end

plot(XIN,YIN,'or')%PLOT THE POINTS THAT WERE INPUTTED
axis([XIN(1)-1 max(XIN)+1 min(YIN)-5 max(YIN)+5]) %ARRANGE THE AXES SO THAT THE WHOLE PLOT IS VISIBLE

%OUTPUT THE RESULTS OF INTERPOLATED VALUES
%-----------------------------------------

for i=1:length(XEVAL) %IN THE CASE OF MORE THAN ONE VALUES TO BE INTERPOLATED
    disp(['The interoplated value of ',num2str(XEVAL(i)),' is: ',num2str(YEVAL(i))])
end