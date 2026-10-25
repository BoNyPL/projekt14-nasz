%% params.m - parametry modelu (projekt 14)
% Jednostki SI, kąty w radianach.

%% oś azymutu: napęd 1. rzędu G(s) = K/(T*s + 1), napięcie -> predkość osi
az.K    = 0.5;  % wzmocnienie [rad/s/V]
az.T    = 0.2;  % stała czasowa [s]
az.Umax = 24;   % nasycenie napięcia [V]

%% Symulacja
U_skok = 12;  % wartość skoku napięcia [V]
t_skok = 1;   % chwila skoku [s]
Tsim   = 5;   % czas symulacji [s]

%%Nastawy azymutu
az.Tw = 0.05;
az.Kp_w = az.T/(az.K*az.Tw);
az.Ki_w = az.Kp_w/az.T; 
az.Kp_th = 1/(2*az.Tw);  
az.wmax = 1.0;
theta_zad = deg2rad(90);

%% oś elewacji:
el.K = 0.4;
el.T = 0.25;
el.Umax = 24;
el.Tw = 0.05;
el.wmax = 1;
el.Kp_w = el.T/(el.K*el.Tw);
el.Ki_w = el.Kp_w/el.T; 
el.Kp_th = 1/(2*el.Tw);
el.min = deg2rad(5);
el.max = deg2rad(85);
el.stop_min = 0;
el.stop_max = deg2rad(90);
el.amax = 4;
az.th0 = deg2rad(350);
el.th0 = deg2rad(30);
el.theta_zad = deg2rad(89);