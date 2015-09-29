% ---------------------------------------------------------------------
%                       EARTHWORKS CALCULATOR
% ---------------------------------------------------------------------
% NAME:           Aniket Verma      20521830      a28verma@uwaterloo.ca
% DEPARTMENT:     Civil and Environmental Engineering
% ---------------------------------------------------------------------
clc, clear, format long, format compact
% -------------------------------------------------------- Start of Script

% Initialize variables
station = [];               % Chainage of cross section point (m)
elev = [];                  % Existing elevation of cross section point (m)
grade = [];                 % Elevation of propsed grade (m)
hc = [];                    % Cut Height (m)
hf = [];                    % Fill Height (m)
Ac = [];                    % Cut Area (m^2) 
Af = [];                    % Fill Area (m^2)
Vc = [];                    % Cut Volume (m^3)
Vf = [];                    % Fill Volume (m^3)
road = 10;                  % Width of proposed road (m)
slope = 3;                  % Slope of trapezoidal prism (-)
soil_factor = 1.15;         % Soil balance facotr (-)
g_point = [];               % Array of Boolean Values
g_location = [];            % Location of grade points
valid = 'Fail';             % Used to display validity of grade points
error = 0.0000000001;       % Used to confirm validity of grade points

% Read data from a text file
fid = fopen('cross_section_data.txt');
data = textscan(fid, '%f%f%f');
fclose(fid);

% ----- Store data in their respective arrays 
station = data{:, 1};
elev = data{:, 2};
grade = data{:, 3};

% Calculate Fill Heigt and Cut Height
hc = elev - grade;
hf = grade - elev;

% Assign zeros to all non-positive values
hc(hc < 0) = 0;
hf(hf < 0) = 0;

% Calculate Cut and Fill Areas
Ac = (road + (slope*hc)).*hc;
Af = (road + (slope*hf)).*hf;

% Calculate Cut Volume
for i = 2:length(Ac)
    hm = (hc(i-1) + hc(i))/2;           % Calculate middle height (m)
    Am = (road + (slope*hm))*hm;        % Calculate middle area (m^2)
    Vc(i) = (1/6)*(Ac(i-1) + 4*Am+ Ac(i))*(station(i)- station(i-1));
end

% Calculate Fill Volume
for i = 2:length(Af)
    hm = (hf(i-1) + hf(i))/2;           % Calculate middle height (m)
    Am = (road + (slope*hm))*hm;        % Calculate middle area (m^2)
    Vf(i) = (1/6)*(Af(i-1) + 4*Am+ Af(i))*(station(i)- station(i-1));
end

% Find Grade Points
where = [];
for i = 1:length(elev)
    if elev(i) == grade(i);
        where = [where; i];
    end
end


% Verify Grade Points
for i = 1:length(where)
    g_point(i) = 0;
    if where(i)~=1 | where(i)==length(station)  
    % Skips if the first and/or last point is a grade point
        num1 = where(i)-1;
        num2 = where(i)+1;
        g_station = ((grade(num1)-((grade(num1)-grade(num2))...
            /(station(num1)-station(num2)))*station(num1))-(elev(num1)-...
            ((elev(num1)-elev(num2))/(station(num1)-station(num2)))...
            *station(num1)))/(((elev(num1)-elev(num2))/(station(num1)-...
            station(num2)))-((grade(num1)-grade(num2))/(station(num1)-...
            station(num2)))); 
        g_elev = ((elev(num1)-elev(num2))/(station(num1)-station(num2)))...
            *g_station +(elev(num1)-((elev(num1)-elev(num2))/...
            (station(num1)-station(num2)))*station(num1));
        g_grade = g_elev;
        station_error = 100*abs(station(where(i))-g_station)/g_station;
        elev_error = 100*abs(elev(where(i))-g_elev)/g_elev;
        grade_error = 100*abs(grade(where(i))-g_grade)/g_grade;
        if (station_error<error) & (elev_error<error) &...
                (grade_error<error)
            g_point(i) = 1;
            g_location = [g_location; where(i)];
        end
    end
end

% Display Results to User
fprintf('\nEarthworks Calculator Results\n')
fprintf('-----------------------------\n\n')

fprintf(['%-10s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s'...
         '%-15s\n'], 'Point', 'Road', 'Existing', 'Proposed', 'Cut',...
         'Fill', 'Cut', 'Fill', 'Cut', 'Fill', 'Fill Volume')
fprintf(['%-10s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s'...
         '%-15s\n'], 'Number', 'Station', 'Elevation', 'Profile',...
         'Height (m)', 'Height (m)', 'Area (m^2)', 'Area (m^2)',...
         'Volume (m^3)', 'Volume (m^3)', '15% (m^3)')
     
for i=1:length(station)
   fprintf(['%-10d %-15.1f %-15.3f %-15.3f %-15.3f %-15.3f %-15.3f '...
            '%-15.3f %-15.3f %-15.3f %-15.3f\n'], i, station(i),...
            elev(i), grade(i), hc(i), hf(i), Ac(i), Af(i), Vc(i),...
            Vf(i), soil_factor*Vc(i));
end

fprintf(['\n%-10s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15.3f '...
         '%-15.3f %-15.3f\n'], ' ', ' ', ' ', ' ', ' ', ' ', ' ',... 
         'Total Volume', sum(Vc), sum(Vf), soil_factor*sum(Vf))

fprintf('\nSummary of Grade Point Results\n')
fprintf('  ------------------------------\n\n')

if sum(g_point) >= 2
    valid = 'Pass';
end

fprintf('Valididty of Grade Points: %s\n\n', valid)
fprintf('Locations of Grade Points: ')
for i = 1:length(g_location)
    if i == length(g_location)
        fprintf('Point %d \n\n', g_location(i))
        break;
    end
   fprintf('Point %d, ', g_location(i)) 
end
