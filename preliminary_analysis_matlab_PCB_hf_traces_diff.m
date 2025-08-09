clc;
clear all; 

% Constants
mil_to_m = 2.54e-5;

% Parameters (converted to meters)
l = 1961.9 * mil_to_m; %mil %Length of the PCB trace
w = 9.857  * mil_to_m; %mil %Width of the PCB trace
h = 60     * mil_to_m; %mil %Thickness of the PCB
t = 1.4    * mil_to_m; %mil %Thickness of the PCB trace
g = 4.998  * mil_to_m; %mil %Gap between differential traces
gpl = 1000  * mil_to_m; %mil %Assumed
c = 59.6e6; % S/m %Conducticity of copper PCB trace
dk = 3.38; %Dielectric constant of Rogers 4003C
df = 0.0027; %Dissipation factor of Rogers 4003C at 10GHz

% Define material and conductor
d = dielectric('Name', 'Rogers4003C', 'EpsilonR', dk, 'LossTangent', df, 'Thickness', h);
%d = dielectric('TMM3') 
m = metal('Name', 'Cu', 'Conductivity', c, 'Thickness', t);

% Use coupledMicrostripLine 
cml = coupledMicrostripLine('Length', l, 'Width', w, 'Spacing', g, ...
    'Height', h, 'Substrate', d, 'Conductor', m);

% Show coupledMicrostripLine
figure(1)
show(cml)

% Frequency sweep 
f = linspace(1e9, 20e9, 100); % Vectorized sweep
sparam = sparameters(cml, f, 100, 'Behavioral', true); % 100-ohm reference
% s_numeric = sparam.Parameters;       % Extract raw 4×4×N matrix
% sdiff_numeric = s2sdd(s_numeric);    % Convert to 2×2×N diff S-matrix
% sdiff = sparameters(sdiff_numeric, sparam.Frequencies, 100);  % Rewrap into sparameters object

% Plot
figure(2)
rfplot(sparam)
