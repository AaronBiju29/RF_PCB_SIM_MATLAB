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

% Import gerber files
pcb_top = gerberRead('IMPORT TOP SIDE GERBER FILES');
%pcb_bottom = gerberRead('IMPORT BOTTOM SIDE GERBER FILES');
pcb_outline = gerberRead('IMPORT BOARD OUTLINE GERBER FILES');

% Define board outline with extra padding
% Get vertices from all shapes in top layer
allVertices = vertcat(pcb_outline.shapes.Vertices);
% Compute bounding box
x_min = min(allVertices(:,1));
x_max = max(allVertices(:,1));
y_min = min(allVertices(:,2));
y_max = max(allVertices(:,2));
% Define padding (e.g., 0.5 mm)
pad = 0.5e-3;
% Define new board size
board_length = (x_max - x_min) + 2*pad;
board_width  = (y_max - y_min) + 2*pad;
% Define new board center
board_center = [(x_max + x_min)/2, (y_max + y_min)/2];
% Create padded board shape
paddedBoard = traceRectangular( ...
    'Length', board_length, ...
    'Width', board_width, ...
    'Center', board_center);

% Select desired area
x_values = pcb_top.shapes.Vertices(:, 1);
y_values = pcb_top.shapes.Vertices(:, 2);
% Apply vectorized condition for the region of interest
in_x_range = (x_values > 10e-3) & (x_values < 40e-3);
in_y_range = (y_values > 10e-3) & (y_values < 50e-3);
% Logical AND across both dimensions
in_roi = in_x_range & in_y_range;
% Extract selected vertices and add z = 0
pcb_intended_area_vertices = [x_values(in_roi), y_values(in_roi), zeros(sum(in_roi),1)];
int_area_lay = antenna.Polygon(Vertices = pcb_intended_area_vertices);

%Define pcbComponent 
pcb = pcbComponent;
pcb.BoardThickness = d.Thickness;
pcb.Conductor = m; 
groundplane = traceRectangular(Length=(x_max - x_min),Width=(y_max - y_min), Center=[(x_max + x_min)/2, (y_max + y_min)/2]);
%pcb.Layers = {pcb_top.shapes, d, pcb_bottom.shapes};
pcb.Layers = {int_area_lay, d, groundplane};
pcb.BoardShape = paddedBoard;
%Find feed locations from the layout after the image get displayed
%pcb.FeedLocations = [7.5e-3, 21.25e-3, 1, 3; 7.5e-3, 20.85e-3, 1, 3; 29.2e-3, 47e-3, 1, 3; 15.05e-3, 47e-3, 1, 3]; 
%pcb.FeedDiameter = w/2;
figure;
show(pcb)
figure;
layout(pcb);

%Define mesh to reduce memory usage
% meshconfig(pcb, "manual"); 
% meshobj = mesh(pcb, 'MaxEdgeLength', 5e-2);
% figure;
% show(meshobj);

%Define S parameter function and plot the S parameters
% spar = sparameters(pcb,linspace(1e9,20e9,30), 100);
% figure;
% rfplot(spar);


%///Hereafter all Scrap Code///%
% totalVertices = 0;
% for i = 1:numel(pcb.Layers)
%     for j = 1:numel(pcb.Layers(i).Polygons)
%         poly = pcb.Layers(i).Polygons(j);
%         totalVertices = totalVertices + numel(poly.Vertices);
%     end
% end
% disp(totalVertices)

%Select specific area(Alternative code)
% x_values = pcb_top.shapes.Vertices(:, 1);
% y_values = pcb_top.shapes.Vertices(:, 2);
% len_x = size(x_values);  %x and y will have same count
% pcb_area = []; 
% for i = 1:len_x(1)
%     for j = 1:len_x(1)
%         if (x_values(i)>10e-3) && (x_values(i)<40e-3)
%             if (y_values(j)>10e-3) && (y_values(j)<50e-3)
%                 new_ver = [x_values(i), y_values(j), 0];
%                 pcb_area = [pcb_area; new_ver];
%             end
%         end
%     end
% end
% plot(pcb_area)