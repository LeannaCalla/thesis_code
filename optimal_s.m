function [ s_star, s_full, c_star, u_star, B_star, t_char, f_star, T_bar] = optimal_s(set, start_day, end_day)
% optimal s : given a set of data will return the optimal s for entire
% dataset and the t_char

 %% Pig data
if set == 1
    % sept mouth
    data_pig = xlsread('../../Sept_pig2.xlsx');
    pig = [data_pig(1:end-18, 6)];
    placement_time = 10;
elseif set == 2
    % sept mouth
    data_pig = xlsread('../ADS_Sept_Logger_6_Pig_1_probe.xlsx');
    pig = [data_pig(3:end-18, 4)];
   placement_time = 10;
elseif set == 3
    % jul mouth
    data_pig = xlsread('../../Aug_pig2.xlsx');
    pig = [data_pig(1:end-12, 7)];
    placement_time = 11;
elseif set == 4
    % sept - pig 2 rectum
    data_pig = xlsread('../../Sept_pig2.xlsx');
    pig = [data_pig(1:end-18, 7)];
    placement_time = 10;
elseif set == 5
    % Austrila
    data_pig = xlsread('../../Austraila/australianpigdata/Australia_Pig1_Ambient_and_Probe_Data.xlsx');
    pig = [data_pig(1:end-19, 4)];
end

%% EC data/spline
if set == 1 || set == 2 || set == 4
    data_ec = xlsread('../../Sept_EC-g3in.xlsx');
    EC = [data_ec(3: end-17, 6)];
elseif set == 3
    data_ec = xlsread('../../Aug_EC-g3in.xlsx');
    EC = [data_ec(1:end-13, 6)];
elseif set == 5
    data_ec = xlsread('../../Austraila/australianpigdata/Weather_Station_Data_AUS_2017.xlsx');
    EC = [data_ec(587:(587+length(pig)), 4)];
end
[EC_struct] = smooth_spline(0, length(EC) -1, EC);

total_time = (end_day-start_day +1)*24;
start_time = (start_day*24)-23;
end_time = end_day*24;

%% find the best c

[t_char, N] = char_times(set, start_time, end_time, total_time);
% create indexes to give important transition times
%sunrise_idx = sunrise - 9;
%sunset_idx = sunset- 9;
num_sec = length(N);
%t_char = round(t_char);
% Golden ratio on c0

c_up = 0.8;
c_low = 0.00001;
thres = 1e-5;
gr = (1 + sqrt(5))/2 -1;

while abs(c_up - c_low) > thres
    c1 = gr*c_low + (1-gr)*c_up;
    c2 = gr*c_up + (1-gr)*c_low;
    % set up z
    [z_up, u_up] = compute_z(pig, c2, EC_struct, start_time, end_time);
    [z_low, u_low] = compute_z(pig, c1, EC_struct, start_time, end_time);
    
    % build B
    B_up = compute_Bmat(c2, t_char, placement_time, end_time + placement_time -1);
    B_low = compute_Bmat(c1, t_char, placement_time, end_time + placement_time -1);
    
    % compute s
    s_up = -B_up\z_up;
    s_low = -B_low\z_low;
    
    % compute error
    f_up = transpose(z_up + B_up*s_up)*z_up; 
    f_low = transpose(z_low + B_low*s_low)*z_low;
    
    
    if f_low > f_up
        c_low = c1;
    end
    if f_low < f_up
        c_up = c2;
    end
end
% best c found

if f_low < f_up
    c_star = c_low;
    f_star = f_low;
    s_star = s_low;
    B_star = B_low;
    u_star = u_low;
else
    c_star = c_up;
    f_star = f_up;
    s_star = s_up;
    B_star = B_up;
    u_star = u_up;
end

s_full = [];
t_char = round(t_char);
for i = 1:length(t_char) - 1
    time_sec = t_char(i+1) - t_char(i);
      if i == length(t_char)-1
        % last interval is not a complete day/night
        s_full = [s_full; s_star(i)*ones(time_sec, 1)]; 
        break
      end
    s_full = [s_full; s_star(i)*ones(time_sec, 1)];
end
    
T_bar = u_star + B_star*s_star;



end

