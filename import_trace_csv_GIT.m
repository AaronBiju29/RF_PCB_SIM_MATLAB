clc;
clear all;

% Constants
inch_to_m = 2.54e-2;
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

%Intended nets
diffN = 'SPECIFY INTENDED DIFFERENTIAL TRACE';
diffP = 'SPECIFY INTENDED DIFFERENTIAL TRACE';

%Import trace data
trace_data = readtable('SPECIFY CSV FILE CONTAINING TRACE INFORMATION'); %Import CSV trace file from Altium  

%Find the intended NET
rows = strcmp(trace_data.CADNet, diffN);
len = length(rows); 
count = 1;
for i = 1:len
    if rows(i) == 1
        x_start = trace_data.X1_in_(i) * inch_to_m;
        y_start = trace_data.Y1_in_(i) * inch_to_m;
        x_end = trace_data.X2_in_(i) * inch_to_m; 
        y_end = trace_data.Y2_in_(i) * inch_to_m; 
        w = trace_data.Width_in_(i) * inch_to_m; 
        p1 = [x_start, y_start];
        p2 = [x_end,  y_end]; 
        dir = p2 - p1; 
        dir = dir / norm(dir);
        per = [-dir(2), dir(1)];
        hw = w/2; 
        r1 = p1 + hw*per; 
        r2 = p1 - hw*per;
        r3 = p2 - hw*per; 
        r4 = p2 + hw*per; 
        temp_loc = [r1; r2; r3; r4]; 
        temp_shape = antenna.Polygon(Vertices = temp_loc);
        temp_edge_point1 = antenna.Circle(Center = p1, radius = hw);
        temp_edge_point2 = antenna.Circle(Center = p2, radius = hw); 
        if count == 1
            total_shape_N = temp_shape + temp_edge_point1 + temp_edge_point2; 
        else
            total_shape_N = total_shape_N + temp_shape + temp_edge_point1 + temp_edge_point2; 
        end
        count = count + 1; 
    end
end

rows = strcmp(trace_data.CADNet, diffP);
len = length(rows); 
count = 1;
for i = 1:len
    if rows(i) == 1
        x_start = trace_data.X1_in_(i) * inch_to_m;
        y_start = trace_data.Y1_in_(i) * inch_to_m;
        x_end = trace_data.X2_in_(i) * inch_to_m; 
        y_end = trace_data.Y2_in_(i) * inch_to_m; 
        w = trace_data.Width_in_(i) * inch_to_m; 
        p1 = [x_start, y_start];
        p2 = [x_end,  y_end]; 
        dir = p2 - p1; 
        dir = dir / norm(dir);
        per = [-dir(2), dir(1)];
        hw = w/2; 
        r1 = p1 + hw*per; 
        r2 = p1 - hw*per;
        r3 = p2 - hw*per; 
        r4 = p2 + hw*per; 
        temp_loc = [r1; r2; r3; r4]; 
        temp_shape = antenna.Polygon(Vertices = temp_loc);
        temp_edge_point1 = antenna.Circle(Center = p1, radius = hw);
        temp_edge_point2 = antenna.Circle(Center = p2, radius = hw);  
        if count == 1
            total_shape_P = temp_shape + temp_edge_point1 + temp_edge_point2; 
        else
            total_shape_P = total_shape_P + temp_shape + temp_edge_point1 + temp_edge_point2; 
        end
        count = count + 1; 
    end
end

% Merge both differential pair into a single shape 
des_diff = total_shape_N + total_shape_P; 

%Find the center of differential traces
pad_m_x = 6*1e-3; %Padding buffer to cover the entire area of diff pairs X direction
pad_m_y = 10*1e-3; %Padding buffer to cover the entire area of diff pairs Y direction 
ps_des_diff = polyshape(des_diff.Vertices(:, 1:2));
[cxp, cyp] = centroid(ps_des_diff); 
vert_des_diff = ps_des_diff.Vertices;
maxx = max(vert_des_diff(:, 1)); 
minx = min(vert_des_diff(:, 1)); 
maxy = max(vert_des_diff(:, 2));
miny = min(vert_des_diff(:, 2)); 
len_x = maxx - minx + pad_m_x; 
width_y = maxy - miny + pad_m_y; 

%Define board outline 
board_outline = antenna.Polygon(Vertices = [0 , 0; len_x, 0; len_x, width_y; 0, width_y]); 

%Find the center of the board outline
bo_ps = polyshape(board_outline.Vertices(:, 1:2)); 
[cxbo, cybo] = centroid(bo_ps); 

%Bring the polygon to center of the board
c_dist = [cxp, cyp] - [cxbo, cybo];  %Coordinates to bring to center
vert_des_diff_cent = vert_des_diff - [c_dist(1), c_dist(2)];
ps_des_diff_cent_ant = antenna.Polygon(Vertices = vert_des_diff_cent);

%Feed locations (Feed locations will vary according to trace locations)
%Need to automate
vert_feed = ps_des_diff_cent_ant.Vertices; 
x_idx_min = find(vert_feed(:, 1) == min(vert_feed(:, 1)));
next_idx_x = 2;
if length(x_idx_min) > 2
    next_idx_x = 3; 
end
first_feed_loc = [vert_feed(x_idx_min(1), 1) + w, vert_feed(x_idx_min(1), 2)];
second_feed_loc = [vert_feed(x_idx_min(next_idx_x), 1) + w, vert_feed(x_idx_min(next_idx_x), 2)]; 
y_idx_max = find(vert_feed(:, 2) == max(vert_feed(:, 2))); 
next_idx_y = 2; 
if length(y_idx_max) > 2
    next_idx_y = 3; 
end
third_feed_loc = [vert_feed(y_idx_max(1), 1), vert_feed(y_idx_max(1), 2) - w];
forth_feed_loc = [vert_feed(y_idx_max(next_idx_y), 1), vert_feed(y_idx_max(next_idx_y), 2) - w]; 

%Add SMA pads at third and forth feed locations
len_sma_pad = 50 * mil_to_m; 
width_sma_pad = 160 * mil_to_m; %Values from Altium 
left_sma_pad = antenna.Rectangle(Center = third_feed_loc, Length = len_sma_pad, Width=width_sma_pad); 
right_sma_pad = antenna.Rectangle(Center = forth_feed_loc, Length = len_sma_pad, Width = width_sma_pad); 
ps_des_diff_cent_ant_sma = ps_des_diff_cent_ant + left_sma_pad + right_sma_pad; 

% Apply padding to the differential traces
padc_m = 5*mil_to_m; %Clearance
pg = polyshape(ps_des_diff_cent_ant_sma.Vertices(:, 1:2)); 
pad_pg = polybuffer(pg, padc_m);
pad_des_diff = antenna.Polygon(Vertices = pad_pg.Vertices);

%Define ground plane 
ground_plane = subtract(board_outline, pad_des_diff); 

%Merge both ground plane and diff trace
top_layer = ps_des_diff_cent_ant_sma + ground_plane; 

% Define material and conductor
d = dielectric('Name', 'Rogers4003C', 'EpsilonR', dk, 'LossTangent', df, 'Thickness', h);
m = metal('Name', 'Cu', 'Conductivity', c, 'Thickness', t);

%Add vias near to the differential pair
vias_data = readtable('IMPORT CSV FILE CONTAINING VIAS INFORMATION');
pad_vias_mm = 2e-3;
via_x = vias_data{:, 2} * inch_to_m; 
via_y = vias_data{:, 3} * inch_to_m; 
via_d = vias_data{1, 5} * inch_to_m; %All vias diameter are same 
vias_loc_arr = []; 
for  i = 1:length(via_x)
    if via_x(i) > minx && via_x(i) < (maxx + pad_vias_mm)
        if via_y(i) > miny && via_y(i) < (maxy + pad_vias_mm)
            via_x_cen = via_x(i) - c_dist(1); 
            via_y_cen = via_y(i) - c_dist(2); 
            temp_vias_loc_arr = [via_x_cen, via_y_cen, 1, 3]; %Via between first and second layer
            vias_loc_arr = [vias_loc_arr; temp_vias_loc_arr]; 
        end
    end
end

%Define pcbComponent 
pcb = pcbComponent;
pcb.BoardThickness = d.Thickness;
pcb.Conductor = m; 
groundplane = traceRectangular(Length=len_x,Width=width_y, Center=[cxbo, cybo]);
pcb.Layers = {top_layer, d, groundplane};
pcb.BoardShape = board_outline;
pcb.ViaLocations = vias_loc_arr; 
pcb.ViaDiameter = via_d;
%Find feed locations from the layout after the image get displayed
pcb.FeedLocations = [first_feed_loc(1), first_feed_loc(2), 1, 3; second_feed_loc(1), second_feed_loc(2), 1, 3; 
    third_feed_loc(1), third_feed_loc(2), 1, 3; forth_feed_loc(1), forth_feed_loc(2), 1, 3]; 
pcb.FeedDiameter = w/2;
figure;
show(pcb)
figure;
layout(pcb);

%Define mesh to reduce memory usage
meshconfig(pcb, "manual"); 
mesh(pcb, 'MaxEdgeLength', 1e-3)

%Define S parameter function and plot the S parameters
spar = sparameters(pcb,linspace(1e9,20e9,50), 50);
figure;
rfplot(spar);


%//////////////////Scrap Code/////////////////////
% count = 1; 
% for i = 1:length(via_x)
%     if via_x(i) > minx && via_x(i) < (maxx + pad_vias_mm)
%         if via_y(i) > miny && via_y(i) < maxy 
%             temp_cent = [via_x(i), via_y(i)]; 
%             temp_rad = via_d(i)/2; 
%             via_circle = antenna.Circle(Center = temp_cent, radius = temp_rad); 
%             if count == 1 
%                 total_vias = via_circle; 
%             else
%                 total_vias = total_vias + via_circle; 
%             end
%             count = count + 1; 
%         end
%     end
% end

% %Merge Vias to the differential pair
% des_diff_vias = des_diff + total_vias; 
% ps_des_diff_vias = polyshape(des_diff_vias.Vertices(:, 1:2)); 
% vert_des_diff_vias = ps_des_diff_vias.Vertices;

