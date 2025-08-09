clc;
clear all;

%Define all parameters
l = 1961.9; %mil %Length of the PCB trace
w = 9.857; %mil %Width of the PCB trace
h = 60; %mil %Thickness of the PCB
t = 1.4; %mil %Thickness of the PCB trace
dk = 3.38; %Dielectric constant of Rogers 4003C
df = 0.0027; %Dissipation factor of Rogers 4003C at 10GHz

%Convert all the units to meters
l = l*2.54e-5; 
w = w*2.54e-5;
h = h*2.54e-5;
t = t*2.54e-5; 

%Define the microstripline
mstl = txlineMicrostrip('LineLength', l, 'Width', w, 'Height', h, 'Thickness', t, 'EpsilonR', dk, 'LossTangent', df); 

%Calculate the s parameters from range 1 to 20 GHz and 50 ohm reference impedance
%f = (1:20)*1e9; 
f = linspace(1, 20, 1000)*1e9; 
sparam = sparameters(mstl, f, 100); 

%Plot S parameters 
rfplot(sparam)

