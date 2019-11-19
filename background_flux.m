% compute compontents of heat flux
clear all; close all
set = 3;

%% call in all pig data
if set == 1
    % sept mouth
    data_pig = xlsread('../../Sept_pig2.xlsx');
    pig = [data_pig(1:end-18, 6)]; % up to and including Nov 1
    start_day = 1;
    end_day = 54;
    avg_over = 5;
elseif set == 2
    % sept mouth
    data_pig = xlsread('../ADS_Sept_Logger_6_Pig_1_probe.xlsx');
    pig = [data_pig(1:end-18, 4)]; % up to and including Nov 1
    start_day = 1;
    end_day = 54;
    avg_over = 5;
elseif set == 3
    % jul mouth
    data_pig = xlsread('../../Aug_pig2.xlsx');
    pig = [data_pig(1:end-12, 7)]; % up to and including Aug 3
    start_day = 1;
    end_day = 29;
    avg_over = 5;
elseif set == 4
    % sept - pig 2 rectum
    data_pig = xlsread('../../Sept_pig2.xlsx');
    pig = [data_pig(1:end - 18, 7)];
    start_day = 1;
    end_day = 54;
    avg_over = 5;
elseif set == 5
    % Austrila
    data_pig = xlsread('../../Austraila/australianpigdata/Australia_Pig1_Ambient_and_Probe_Data.xlsx');
    pig = [data_pig(1:end-19, 4)];
    start_day = 1;
    end_day = 47;
    avg_over = 3;
end
total_time = (end_day-start_day+1)*24;


%% Call in all T0 data, create spline
if set == 1 || set == 2 || set == 4
    data_ec = xlsread('../../Sept_EC-g3in.xlsx');
    EC = [data_ec(3:end-17, 6)]; % up to and including Nov 1
elseif set == 3
    data_ec = xlsread('../../Aug_EC-g3in.xlsx');
    EC = [data_ec(1:end-13, 6)]; % up to and including Aug 3
elseif set == 5
    data_ec = xlsread('../../Austraila/australianpigdata/Weather_Station_Data_AUS_2017.xlsx');
    EC = [data_ec(587:(587+length(pig)), 4)];
    EC2 = [data_pig(1:end-19, 3)];
end
[EC_struct] = smooth_spline(0, length(EC) -1, EC);
% cast EC struct to a function of t
EC_spline = @(t) ppval(EC_struct, t);

% figure
% plot(pig(1:total_time))
% hold on
% plot(EC(1:total_time))


 %% call in s_star, c_star and predicted temp
 [s_star, s_full, c_star, u_star, B_star, t_char, f, T] = optimal_s(set, start_day, end_day);
 
 err = sqrt(f)/norm(pig(1:end_day*24), 2)
 
 figure
 plot(T)
 grid on
 hold on
 plot(pig(1:24*end_day))
 legend('Prediction', 'Experimental')
 %% obtain sp in the long time lim
 se_night = [];
 se_day = [];
 sp_lim = s_star(end-(avg_over*2 -1):end);
 for i = 1:2*avg_over
     if mod(i, 2) == 0 % even -night
         se_night =[se_night; sp_lim(i)];
     else
         se_day = [se_day; sp_lim(i)];
     end
 end
 se_night_avg = mean(se_night);
 se_day_avg = mean(se_day);
     
 se = []; 
 se_piece =[];
 for i = 1:length(t_char) - 1
     time_sec = t_char(i+1) - t_char(i);
     if mod(i, 2) == 1 % day
         se_piece = [se_piece; se_day_avg*ones(time_sec, 1)];
         se = [se; se_day_avg];
     else
         
         se_piece = [se_piece; se_night_avg*ones(time_sec, 1)];
         se = [se; se_night_avg];
     end
 end
 sp = s_star - se;
 sp_piece = s_full - se_piece;
 figure
 plot(s_full, 'k')
 grid on
 hold on
 plot(sp_piece, 'b')
 plot(se_piece, 'g')
 legend('S star', 'sp', 'se')
 
%% prediction can be divided into two pieces

T_e = u_star + B_star*se;
T_p = B_star*sp;

figure
plot(T_e)
hold on
plot(T_p)
legend('Te', 'Tp')
grid on
