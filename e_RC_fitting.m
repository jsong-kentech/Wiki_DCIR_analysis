close all; clear; clc;

% Data

filename_data = 'struct_hyundai_hppc_pulse.mat';
load(filename_data) % pstruct
pulse_data = [pstruct(1).t-pstruct(1).t(1),pstruct(1).I, pstruct(1).V - pstruct(1).OCV];

figure(1)
plot(pulse_data(:,1),pulse_data(:,3),'o')
hold on
%yyaxis right
%plot(pulse_data(:,1),pulse_data(:,2))

% Model

% para0 = [0.001,0.001,2,0.002,50];
% V_model = func_V(t_vec,para0,I_avg)
% 
% 
% figure(2)
% plot(t_vec,V_model)


% Minimization
para0 = [0.001,0.001,2,0.002,50];
para_lb = para0*0;
para_ub = para0*10;

t_vec = pulse_data(:,1);
I_avg = mean(pulse_data(:,2));
V_data = pulse_data(:,3);

fhandle_cost = @(para)func_cost(t_vec,para,I_avg,V_data);

para_hat = fmincon(fhandle_cost,para0,[],[],[],[],para_lb,para_ub);



% Visualization

% initial guess
V_model0 = func_V(t_vec,para0,I_avg);
figure(1)
%yyaxis left
plot(t_vec,V_model0,'--','linewidth',2)

% hat
V_model_hat = func_V(t_vec,para_hat,I_avg);
plot(t_vec,V_model_hat,'-','linewidth',2)

legend({'data','initial','fit'})




function cost = func_cost(t,para,I_avg,V_data)

V_model = func_V(t,para,I_avg);

cost = sum((V_data - V_model).^2);



end



function V_model = func_V(t,para,I_avg)


R0 = para(1);
R1= para(2);
tau1 = para(3);
R2 = para(4);
tau2 = para(5);

V_model = R0*I_avg + R1*I_avg*(1-exp(-t/tau1)) +R2*I_avg*(1-exp(-t/tau2));


end