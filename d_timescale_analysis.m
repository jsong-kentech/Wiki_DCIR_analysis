clear; clc; close all
% 1. Load: pulse OCV
% loop (pulse)
% SOC estimation
% 2. R calculation
% 3. Plot



%LOAD
filename_pstruct = 'struct_hyundai_hppc_pulse.mat';
filename_ocv = 'OCV_example.mat';

load(filename_pstruct); % pstruct
load(filename_ocv) % ocv [SOC%, OCV]

N = length(pstruct);

% LOOP

for i =1:N% N

    % SOC interpolation
    pstruct(i).SOC = interp1(ocv(:,2), ocv(:,1), pstruct(i).OCV);



    % R by time scale
    pstruct(i).R_vec = (pstruct(i).V - pstruct(i).OCV)./pstruct(i).I; 

    % [0.1 sec, 10 sec, 30 sec)]
    % min, lookup, find
    [~,ind_10sec] = min(abs(pstruct(i).t-pstruct(i).t(1)-10));
    [~,ind_30sec] = min(abs(pstruct(i).t-pstruct(i).t(1)-30));

    pstruct(i).R_bytime = pstruct(i).R_vec([1,ind_10sec,ind_30sec]);




end


% Plot
    soc_vec = [pstruct.SOC];
    R_mat = [pstruct.R_bytime];
    figure(1)
    plot(soc_vec,R_mat(1,:)); hold on
    plot(soc_vec,R_mat(2,:));
    plot(soc_vec,R_mat(3,:));
    ylim([0 0.004])
    legend({'0.1sec','10sec','30sec'})