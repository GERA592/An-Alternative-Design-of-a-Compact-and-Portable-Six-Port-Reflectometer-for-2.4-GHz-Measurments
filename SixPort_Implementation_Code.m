% Code for the implementation of a Six-Port Reflectometer in MATLAB
% An Alternative Design of a Compact and Portable Six-Port Reflectometer for 2.4 GHz Reflection Coefficient Measurements
% IEEE Latin America Transactions

% Gerardo Hernandez Veliz

% Clean Port
delete(instrfind({'Port'},{'COM6'}));     % ### IT CAN CHANGE ###

% Create series object 
s = serial('COM6','BaudRate',9600,'Terminator','CR/LF');     % ### AGAIN VERIFY THE PORT ###
warning('off','MATLAB:serial:fscanf:unsuccessfulRead');
% Open Port
fopen(s);


tmax = 5; % Capture time in seconds
rate = 11; 

% Prepare the figure
f = figure('Name','Captura');
a = axes('XLim',[0 tmax],'YLim',[0 110]);
l1 = line(nan,nan,'Color','r','LineWidth',1);
l2 = line(nan,nan,'Color','b','LineWidth',1);
l3 = line(nan,nan,'Color','g','LineWidth',1);
l4 = line(nan,nan,'Color','m','LineWidth',1);

xlabel('Time (s)')
ylabel('Voltage (mV)')
title('Voltage capture of 4 channels')
grid on
hold on

% Inicializar valores de voltaje
v1 = zeros(1,tmax*rate);
v2 = zeros(1,tmax*rate);
v3 = zeros(1,tmax*rate);
v4 = zeros(1,tmax*rate);
i = 1;
t = 0;

% Run timed loop
tic
while t<tmax
    t = toc;

    % Read from the serial port
    a = fscanf(s,'%f,%f,%f,%f')';
    v1(i)=a(1);
    v2(i)=a(2);
    v3(i)=a(3);
    v4(i)=a(4);

% THIS VECTOR IS YOUR VOLTAGE POWER VECTOR TO CALIBRATE, 
% THE VOLTAGES (P4, P3, P5, and P6). PLEASE VERIFY THE ORDER IN THE ADC PORTS P4(A0), P3(A1), P5(A2) and P6(A3).

    % Draw on the figure
    x = linspace(0,i/rate,i);
    set(l1,'YData',v1(1:i),'XData',x);
    set(l2,'YData',v2(1:i),'XData',x);
    set(l3,'YData',v3(1:i),'XData',x);
    set(l4,'YData',v4(1:i),'XData',x);
    drawnow

    % Follow
    i = i+1;
end
% Timer result
clc;
figure(1)
fprintf('%g s of capture to %g cap/s \n',t,i/t);

% Define the Bi constants (Calibration constants)
% After the calibration modify!! YOUR Bi constants
B3=1;
B5=1;
B6=1;

d4=a(1);
d3=a(2)*(B3);
d5=a(3)*(B5);
d6=a(4)*(B6);


% Define the radii of the circle
R3=(d3/d4)*4;
R5=(d5/d4)*4;
R6=(d6/d4)*4;

% Define the value of the Q-points (Calibration constants Qi)
% Use the theoretical values for the first time OR the reflection coefficient of the calibration standards, to get the Pi voltages
Q3=[1,−1.732];
Q5=[1,1.732];
Q6=[−2,0];

% Axis of the figure to plot the reflection coefficient
figure(2)
axis([-3 3 -3 3])
grid on
axis square
   ejx=[-3 3];
   ejy=ejx-ejx;
 hold on;
   plot(ejx,ejy,'k');
   plot(ejy,ejx,'k');
hold on
viscircles([0 0], 1,'Color','k','LineStyle','--', 'LineWidth',1.5);

viscircles([0 0], 1,'Color','k','LineStyle','--');

viscircles(Q3, R3, 'Color','r')
hold on 
viscircles(Q5, R5, 'Color','r')
hold on
viscircles(Q6, R6, 'Color','r')
hold on 

% Iterative code for the estimation of the intersection point

% Convergence tolerance
tolerance = 1e-6;

% Initial estimation of the intersection point
intersection_point = [0, 0];

% Maximum number of iterations
max_iterations = 1000;

% Iteration to find the intersection point
for iter = 1:max_iterations
    % Calculate the distances from the intersection point to the centers
    dis1 = norm(intersection_point - Q3);
    dis2 = norm(intersection_point - Q5);
    dis3 = norm(intersection_point - Q6);
    
    % Calculate the differences between the distances and the radii
    diff1 = dis1 - Q3;
    diff2 = dis2 - Q5;
    diff3 = dis3 - Q6;
    
    % Update the intersection point using a weighting
    intersection_point = intersection_point - [(diff1/dis1) * (intersection_point(1) - Q3(1)), (diff1/dis1) * (intersection_point(2) - Q3(2))]...
                      - [(diff2/dis2) * (intersection_point(1) - Q5(1)), (diff2/dis2) * (intersection_point(2) - Q5(2))]...
                      - [(diff3/dis3) * (intersection_point(1) - Q6(1)), (diff3/dis3) * (intersection_point(2) - Q6(2))];
    
    % Verify the convergence
    if max(abs([diff1, diff2, diff3])) < tolerance
        break;
    end
end

c=intersection_point;
viscircles(c, 0.03, 'Color','r') % Print the estimated point of the reflection coefficient of the DUT
hold on 

% Display the estimation of the intersection point
disp('Estimation of the intersection point:');
disp(intersection_point);


fclose(s); % Cerrar el puerto
delete(s);
clear s;



