close all; clear; clc;

% Data

filename_data = 'struct_hyundai_hppc_pulse.mat';
load(filename_data) % pstruct
pulse_data = [pstruct(1).t-pstruct(1).t(1),pstruct(1).I, pstruct(1).V - pstruct(1).OCV];

figure(1)
plot(pulse_data(:,1),pulse_data(:,3))
hold on
yyaxis right
plot(pulse_data(:,1),pulse_data(:,2))


%% cost surface

t_vec = pulse_data(:,1);
I_avg = mean(pulse_data(:,2));
V_data = pulse_data(:,3);


tau1_vec = 10.^(linspace(-1,1.6,51));
tau2_vec = 10.^(linspace(1,2,31));

cost = zeros(length(tau1_vec),length(tau2_vec));

for i = 1:length(tau1_vec)
    for j = 1:length(tau2_vec)
            i
            j
        para0 = [0.001,0.001,tau1_vec(i),0.002,tau2_vec(j)];
        para_lb = [0,0,tau1_vec(i),0,tau2_vec(j)];
        para_ub = [para0(1)*10,para0(2)*10,tau1_vec(i),para0(4)*10,tau2_vec(j)];

        fhandle_cost = @(para)func_cost(t_vec,para,I_avg,V_data);

        [~,cost(i,j)] = fmincon(fhandle_cost,para0,[],[],[],[],para_lb,para_ub);


    end
end


figure(3)
surf(tau2_vec,tau1_vec,cost)
zscale log

% min point

%[M_value,I] = min(cost,[],'all');
%[M_row,M_col] = ind2sub(size(cost),I);






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