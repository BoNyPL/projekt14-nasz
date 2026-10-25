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