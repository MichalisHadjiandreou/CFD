%THE FOLLOWING SCRIPT IS DESIGNED TO USE THE METHOD OF NON LINEAR LIFTING
%LINE IN ORDER TO STUDY THE AERODYNAMIC PERFORMANE OF 3D WINGS TAKING INTO
%CONSIDERATION THE EFFECTS OF DOWNWASH BY DISCRETISIZING WING INTO N
%PANELS. OUTPUTS SHOULD INCLUDE THE LIFT PER UNIT SPAN AT EACH PANEL AS
%WELL AS CALCULATIONS OF CL AND CD FOR THE WHOLE WING AT SPECIFIC AS WELL
%AS A RANGE OF VALUES OF FREESTREAM ANGLES OF ATTACK.
%DESIGNED BY MICHALIS HADJIANDREOU ON 9TH APRIL 2017


%BEGIN BY CLEARING THE SCREEN AND WORKSPACE
%------------------------------------------
clear
clc


%INPUT THE NECESSARY INFORMATION
%-------------------------------
S=input('Please input the wing area (projected) in SI units: '); %WING AREA
lambda=input('Please input the taper ratio: '); %TAPER RATIO
asp_ratio=input('Please input the aspect ratio of the wing: '); %ASPECT RATIO
eps_tip=input(['Please input the twist angle at the tip of the wing in ',char(176),' : ']); %TWIST AT TIP
frstreamv=input('Please input the freestream velocity desired in SI units: '); %FREE STREAM VELOCITY
frsalpha=input(['Please input the freestream angle of attack in ',char(176),' : ']); %ANGLE OF ATTACK
choice=menu('Choose the type of aerofoil from database or enter a new one','N65-2-415','Enter a new one'); %AVOID ERRORS IN INPUTING THE .dat FILE AND POTENTIAL USE FOR BIGGER COLLECTION OF .dat FILES
if choice==1
    fname='N65-2-415.dat';
else
fname=input('Please input the filename of the section data including the extension (.dat): ','s'); %FILENAME TO BE INPUT IN CASE NOT IN DATABASE
end
h=input('Please input the value of the height you wish as a condition in the calculations: '); %HEIGHT OF FLIGHT
N=input('Please input the number of panels you wish the wing to be discretisized: '); %NUMBER OF PANELS
warning('The damping factor has to be chosen carefully. The number of panels, the angle of attack and the convergence factor all affect. The higher the damping factor the more accurate the solution however in most cases the convergence is very slow. As a rough idea for a quick output in the case of 100 panels any angle above -10 degrees and with convergence factor equal to 0.00001 a damping factor 0.05-0.1 will make the convergence fast')
D=input('Please input the damping factor wished: '); %DAMPING FACTOR


%CONVERT THE ANGLE FIRST OF ALL
%------------------------------
frsalpha=frsalpha*pi/180;


%READ THE ASCII FILE AND EXTRACT THE NECESSARY DATA
%--------------------------------------------------
R=fopen(fname,'r');
k=fscanf(R,'%5s',[1 5]); %SKIP THE CHARACTERS 
data=fscanf(R,'%f %f %f',[3 Inf]); %EXTRACT THE DATA
data=data'; %TRANSPOSE BEFORE GETTING SUBMATRICES
fclose(R); %CLOSE THE FILE
alpha=data(:,1).*pi./180; %ANGLES OF ATTACK CONVERTED INTO RADIANS
Cl=data(:,2); %SECTIONAL LIFT COEFFICIENTS
Cd=data(:,3); %SECTIONAL DRAG COEFFICIENTS


%INITIAL CALCULATIONS USING WING GEOMETRY PROPERTIES
%---------------------------------------------------
span=sqrt(asp_ratio*S); %CALCULATION OF THE SPAN OF THE WING
c_root=(2*S)/(span*(1+lambda)); %CALCULATION OF THE CHORD OF THE SECTION AT THE ROOT


%CALCULATION OF VECTORS AND ARRAYS CONTAINING THE Y-POSITIONS OF MIDSPANS OF
%EACH PANEL AS WELL AS THE BOUNDS OF EACH PANEL IN A COORDINATE XYZ SYSTEM
%THAT HAS ITS ORIGIN AT THE CENTRE OF THE WING
Y=zeros(1,N); %INITIALIZE THE ARRAY OF MIDSPAN LOCATIONS FOR OPTIMIZING SPEED

for i=1:N %CALCULATION OF MIDSPAN LOCATION AT THE CENTRE OF EACH PANEL..
    Y(i)=((-span)/2)+((span*(2*i-1))/(2*N)); %..USING A MATHEMATICAL RELATION
end

Yend=Y; %THE BOUNDS WILL BE PROCESSED USING THE CALCULATED Y VECTOR
Yend(N+1)=Yend(N)+(span/(N)); %ADD ANOTHER ELEMENT OF AS IF YOU ADD ANOTHER EXTRA PANEL FOR THE SUBTRACTION THAT FOLLOWS TO TAKE PLACE
Yend=Yend-(span/(2*N)); %SHIFT THOSE VALUES BY HALF THE LENGTH OF THE SPAN TO BRING THEM TO LOCATIONS OF BEGINNING AND ENDING OF EACH PANEL
Yendpoints=zeros(N,2); %INITIALIZE THE ARRAY OF VORTEX ENDPOINTS

for i=1:N %CREATING THE NX2 ARRAY INCLUDING ENDPOINTS OF THE FOLLOWING CALCULATED GAMMAS
    Yendpoints(i,1)=Yend(i);
    Yendpoints(i,2)=Yend(i+1);
end


%CALCULATION OF ARRAYS OF CHORDS AND TWIST ANGLES AT EACH PANEL ASSUMING
%LINEAR AND SYMMETRIC VARIATION ALONG THE SPAN
%------------------------------------------------------------------------
c=((2*c_root*(lambda-1))/span).*abs(Y)+c_root; %MATHEMATICAL RELATION OF FINDING THE CHORD AT EACH Y
eps_tip=eps_tip*pi/180; %CONVERT THE GIVEN ANGLE OF TWIST AT TIP INTO RADIANS
EPS=((2*eps_tip)/span).*abs(Y); %MATHEMATICAL RELATION OF FINDING THE TWIST ANGLE AT EACH Y


%INTERPOLATE THE GIVEN DATA
%--------------------------
COEFFICIENTS=cubic_spline_interpolation(alpha,Cl); %CUBIC SPLINE INTERPOLATION FOR SECTIONAL COEFFICIENT OF LIFT
COEFFICIENTS_2=cubic_spline_interpolation(alpha,Cd); %CUBIC SPLINE INTERPOLATION FOR SECTIONAL COEFFICIENT OF DRAG


%SET SOME INITIAL CONDITIONS FOR THE CALCULATION OF VORTEX STRENGTH AND
%CONTINUE WITH ITERATION
%------------------------------------------------------------------
conv=0.00001; %DECIDED AFTER SEVERAL TESTS (WITH DAMPING FACTOR EQUAL TO 0.05). FOR ANGLES SMALLER THAN -15 CONVERGENCE TAKES A LOT OF TIME
while 1 %INITIATE AN INFINITE LOOP THAT BREAKS WHEN A CONDITION IS MET
    GAMMA_IN=((4*frstreamv*S*frsalpha)/span).*sqrt(1-(Y./(0.5*span)).^2); %ELLIPTICAL DISTRIBUTION 
    W=zeros(1,N); % INITIALIZE THE ARRAY FOR OPTIMIZING SPEED
    for i=1:N
        W(i)=sum(hshoe(Y(i),Yendpoints,GAMMA_IN')); %CALCULATE THE DOWNWASH FOR ALL PANELS
    end
    eff_alpha=EPS+atan(((frstreamv*sin(frsalpha))-W)./(frstreamv*cos(frsalpha))); %CALCULATE THE EFFECTIVE ANGLE OF ATTACH USING DOWNWASH , FOR EACH PANEL
    Cliftvector=zeros(1,N); %INITIALIZE THE VECTOR FOR OPTIMIZING SPEED
    for i=1:N
        Cliftvector(i)=cubicEval(alpha,COEFFICIENTS,eff_alpha(i)); %INTERPOLATE THE VALUE OF SECTIONAL Cl USING EFFECTIVE ANGLE OF ATTACK
    end
    GAMMA_NEW=(0.5*frstreamv).*c.*Cliftvector; %CALCULATE THE NEW CIRCULATION USING FORMULA
    GAMMA_NEW=GAMMA_IN+D.*(GAMMA_NEW-GAMMA_IN); %DAMP IT DOWN
    diff=abs(GAMMA_NEW-GAMMA_IN); %VECTOR OF DIFFERENCES IN CIRCULATION FOR EACH PANEL
    while any(diff>=conv) %GET INTO THE LOOP IF ANY OF THE PANELS HAD A CIRCULATION DIFFERENCE GREATER OR EQUAL TO THE conv FACTOR. IF THIS OCCURS RECALCULATION OF CIRCULATION OF ALL PANELS SHOULD OCCUR SINCE THEY AFFECT EACH OTHER. IN OTHER WORDS THE VECTOR GAMMA HAS TO CONVERGE WHEN ALL TERMS OF diff ARE BELOW conv
        GAMMA_IN=GAMMA_NEW; %STORE THE NEW VALUE AS OLD FOR ITERATION
        for i=1:N %RECALCULATION OF DOWNWASH
            W(i)=sum(HorseShoe(Y(i),Yendpoints,GAMMA_IN'));
        end
        eff_alpha=EPS+atan(((frstreamv*sin(frsalpha))-W)./(frstreamv*cos(frsalpha))); %RECALCULATION OF EFFECTIVE AOA
        for i=1:N
            Cliftvector(i)=cubicEval(alpha,COEFFICIENTS,eff_alpha(i)); %RE-INTERPOLATION OF SECTIONAL Cl
        end
        GAMMA_NEW=(0.5*frstreamv).*c.*Cliftvector; %RECALCULATION OF NEW CIRCULATION VECTOR
        GAMMA_NEW=GAMMA_IN+D.*(GAMMA_NEW-GAMMA_IN); %DAMP IT DOWN
        diff=abs(GAMMA_NEW-GAMMA_IN); %RECALCULATE DIFFERENCE
    end
    if all(diff<conv) %IN THE CASE WHILE LOOP IS EXITED, MEANS CONVERGENCE OCCURED AND THE IF STATEMENT WILL BE SATISFIED. THEREFORE BREAK THE INFINITE LOOP THAT WAS DESIGNED TO FORCE AT LEAST TWO ITERATIONS IN CASE CONVERGENCE OCCURED WITH THE ELLIPTICAL LIFT DISTRIBUTION WHICH WAS ASSUMED
        break
    end
end


%EVALUATION OF COEFFICIENTS OF SECTIONAL DRAG FOR THE CONVERGED VALUES OF
%EFFECTIVE ANGLES OF ATTACK
%-------------------------------------------------------------------------
Cdragarray=zeros(1,N); %ITIALIZE THE VECTOR

for i=1:N %INTEROPLATE THE VALUES FOR ALL PANELS
    Cdragarray(i)=cubicEval(alpha,COEFFICIENTS_2,eff_alpha(i));
end


%LOCAL SECTIONAL LIFT CALCULATIONS
%---------------------------------
[T, a, P, rho] = atmosisa(h); %EXTRACT THE CONDITIONS USING THE FUNCTION
l=(rho*frstreamv).*GAMMA_NEW; %KUTTA-JOUKOWSKI THEOREM FOR SECTIONAL LIFT
figure
Y=[-0.5*span Y 0.5*span]; %WE ADD THE POINTS OF WING TIPS ON EACH SIDE BECAUSE WE WANT TO FORCE THE SECTIONAL LIFT TO PASS THROUGH ZERO THERE SINCE Cl IS ZERO AT THAT POINT
l=[0 l 0]; %SECTIONAL LIFT IS ZERO AT THOSE POINTS SINCE LOCAL Cl IS ZERO
plot(Y,l) %PLOT THE GRAPH OF WING LIFT DISTRIBUTION
xlabel('Wing Span (Symmetric over line x=0)  [m]')
ylabel('Local Sectional Lift per unit span [N/m]')
legend([num2str(frsalpha*180/pi),char(176),' Angle of attack'],'Location','best'); %ADD A LEGEND OF THE ANGLE OF ATTACK

%CALCULATION OF CL AND CD USING SIMPSON'S RULE FOR INTEGRALS
%-----------------------------------------------------------
delta_alpha=atan(((frstreamv*sin(frsalpha))-W)./(frstreamv*cos(frsalpha)))-frsalpha; %CALCULATE THE CHANGE IN ANGLE CAUSED DUE TO DOWNWASH
Fylift=c.*Cliftvector.*cos(delta_alpha); %THIS IS THE FUNCTION THAT IS INTEGRATED ALONG THE WINGSPAN TO OBTAIN THE COEFFICIENT OF LIFT IN 3D
Fylift=[-Fylift(1) Fylift -Fylift(N)]; %TAKING CARE AND ENSURING THAT SECTIONAL Cl AT WING TIPS IS EQUAL TO ZERO.(THINK OF THE WAY SIMPSON'S RULE IS APPLIED, WHEN YOU ARE ON SECOND TERM YOU WANT TO MAKE THE FIRST TERM AS SHOWN IN EQUATION EQUAL TO ZERO THEREFORE YOU ADD TO IT A TERM EQUAL IN MAGNITUDE AND OPPOSITE SIGN. SAME OCCURS ON OPPOSITE SIDE)
sumlift=0; %SUM OF SPLIT INTEGRALS FOR EACH PANEL INITIALIZED
for i=2:(N+1) %INTEGRATE FOR EACH PANEL AND KEEP ADDING IT TO THE sum VARIABLE. NO NEED TO KEEP TRACK AND HISTORY SINCE ONLY THE TOTAL OF ALL INTEGRALS COUNTS
    sumlift=((span/N)/6)*(0.5*(Fylift(i+1)+Fylift(i))+4*Fylift(i)+0.5*(Fylift(i)+Fylift(i-1)))+sumlift; %SIMPSON'S RULE APPLIED AND SUM IS UPDATED AFTER EACH ITERATION
end
CL=(1/S)*sumlift; %DIVIDE BY WING AREA

%SAME EXACT PROCEDURE FOR CD
Fydrag=c.*(Cdragarray-(Cliftvector.*sin(delta_alpha)));
Fydrag=[-Fydrag(1) Fydrag -Fydrag(N)];
sumdrag=0;
for i=2:(N+1)
    sumdrag=((span/N)/6)*(0.5*(Fydrag(i+1)+Fydrag(i))+4*Fydrag(i)+0.5*(Fydrag(i)+Fydrag(i-1)))+sumdrag;
end
CD=(1/S)*sumdrag;


%OUTPUT THE RESULTS OF 3D CL AND CD
%----------------------------------
disp(['For angle of attack ',num2str(frsalpha*180/pi),char(176),', height of flight ',num2str(h),'m and velocity ',num2str(frstreamv),' metres per second using ',num2str(N),' panels: '])
disp(['The 3D Coefficient of Lift CL is equal to: ',num2str(CL)])
disp(['The 3D Coefficient of Drag CD is equal to: ',num2str(CD)])
















