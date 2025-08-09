clc;
clear all; 

% Constants
mil_to_m = 2.54e-5;

% Parameters (converted to meters)
w = 9.857  * mil_to_m; %mil %Width of the PCB trace
h = 60     * mil_to_m; %mil %Thickness of the PCB
t = 1.4    * mil_to_m; %mil %Thickness of the PCB trace
g = 4.998  * mil_to_m; %mil %Gap between differential traces
c = 59.6e6; % S/m %Conducticity of copper PCB trace
dk = 3.38; %Dielectric constant of Rogers 4003C
df = 0.0027; %Dissipation factor of Rogers 4003C at 10GHz
cc_g = 9.857  * mil_to_m + g; 

% Define material and conductor
d = dielectric('Name', 'Rogers4003C', 'EpsilonR', dk, 'LossTangent', df, 'Thickness', h);
m = metal('Name', 'Cu', 'Conductivity', c, 'Thickness', t);

%Define traces
trace1 = traceLine;
trace1.Length = [450.362 414.708 365.237 46.442 85.856 217.615 177.335]*mil_to_m ;
trace1.Angle  = [0 45 90 45 0 45 90];
trace1.Width  = w;
trace1.Corner = "Miter";
trace2 = copy(trace1);
trace2.Length = [442.078 402.401 360.219 47.949 130.993 152.275 221.337]*mil_to_m;
trace2.Angle  = [0 45 90 135 180 135 90];
trace2 = translate(trace2, [0, cc_g, 0]);
trace = trace2 + trace1;
% figure
% show(trace);

%Define pcbComponent
pcb = pcbComponent;
pcb.Conductor = m;
pcb.BoardThickness = d.Thickness; 
groundplane = traceRectangular(Length=4000*mil_to_m,Width=2200*mil_to_m, Center=[0,0]);
pcb.Layers = {trace, d, groundplane};
pcb.FeedLocations = [0, 0, 1, 3; 0, cc_g, 1, 3; 454.046*mil_to_m, 1007.676*mil_to_m, 1, 3; 1014.046*mil_to_m, 1007.676*mil_to_m, 1, 3];
pcb.BoardShape = groundplane;
pcb.FeedDiameter = trace1.Width/2;
figure
show(pcb);
figure
layout(pcb);

% %Define S parameter function and plot the S parameters
% spar = sparameters(pcb,linspace(1e9,20e9,50), 100);
% figure
% % % %rfplot(spar,2:4,1)
% rfplot(spar)