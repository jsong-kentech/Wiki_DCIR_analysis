clear; clc ;

% load

filename = 'struct_hyundai_hppc_parse.mat'; % pased data
filename_out = 'struct_hyundai_hppc_pulse.mat';
Crate_pulse = -1;
%dt_pulse = 180; % there are short pulses as short as 30s
dt_rest = 3600;
type_pulse = 'D';

tol = 0.1;

load(filename)



% assign step condition variable

step_vec = [pdata.step]';
for i = 1:length(step_vec)
    pdata(i).Crate_avg = mean(pdata(i).Crate);
    pdata(i).dt = pdata(i).t(end) -pdata(i).t(1);
end


% SCREENING METHOD 1

j = 0;
% screen out
for i = 2:length(step_vec)
    
    if abs(pdata(i).Crate_avg) < (1+tol)*abs(Crate_pulse)...
            && abs(pdata(i).Crate_avg) > (1-tol)*abs(Crate_pulse)...
            && pdata(i).type == type_pulse ...
            && pdata(i-1).dt > (1-tol)*dt_rest
            % && pdata(i).dt < (1+tol)*dt_pulse...
            % && pdata(i).dt > (1-tol)*dt_pulse...
    
            j=j+1;

            pdata(i).dt_rest = 0;
            pdata(i).OCV = 0;
            
            pstruct(j) = pdata(i);
            pstruct(j).dt_rest = pdata(i-1).dt;
            % add the last OCV in the previous rest 
            pstruct(j).OCV = pdata(i-1).V(end);

    end

end

% SCREENING METHOD 2
% 
% pulse_detect = abs([pdata(2:end).Crate_avg])< (1+tol)*abs(Crate_pulse)...
%             & abs([pdata(2:end).Crate_avg]) > (1-tol)*abs(Crate_pulse)...
%             & [pdata(2:end).type] == type_pulse ...
%             & [pdata(1:end-1).dt] > (1-tol)*dt_rest;
% 
% pstruct = pdata(find([0 pulse_detect]'));


% VISUALIZATION


figure(1); hold on
for j = 1:length(pstruct)
    yyaxis left
    plot(pstruct(j).t,pstruct(j).V,'o-m','linewidth',2); hold on
    yyaxis right
    plot(pstruct(j).t,pstruct(j).Crate,'o-c','linewidth',2)



end

figure(2)
for j = 1:length(pstruct)
    yyaxis left
    plot([0; pstruct(j).t-pstruct(j).t(1)],[pstruct(j).OCV; pstruct(j).V],'-m','linewidth',2); hold on
    yyaxis right
    plot(pstruct(j).t-pstruct(j).t(1),pstruct(j).Crate,'-c','linewidth',2)
    ylim([-3 0])



end





% struct save
save(filename_out,'pstruct')