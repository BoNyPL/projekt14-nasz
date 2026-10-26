params;
out = sim('os3');
%Oś Azymutu
azth = out.logsout.get('az.theta').Values;   % kąt
azw  = out.logsout.get('az.omega').Values;   % prędkość
azU  = out.logsout.get('az.U').Values;       % napięcie
%Oś Elewacji
elth = out.logsout.get('theta').Values;   % kąt
elw  = out.logsout.get('omega').Values;   % prędkość
elU  = out.logsout.get('U').Values;       % napięcie


info = stepinfo(th.Data, th.Time, theta_zad);   % dane kąta, czas, wartość końcowa
fprintf('Przeregulowanie: %.2f %%\n', info.Overshoot);
fprintf('Czas ustalania: %.3f s\n', info.SettlingTime);
fprintf('Uchyb ustalony: %.2e rad\n', theta_zad - th.Data(end));
fprintf('Max |U|: %.2f V\n', max(abs(U.Data)));
fprintf('Max |omega|: %.3f rad/s\n', max(abs(w.Data)));
fprintf('Oczekiwany obrót: %.2e rad\n', scen.az_ref - az.th0);

figure; tiledlayout(3,1);
nexttile; plot(th.Time, th.Data); hold on; yline(theta_zad, '--'); ylabel('\theta [rad]');
nexttile; plot(w.Time, w.Data); ylabel('\omega [rad/s]');
nexttile; plot(U.Time, U.Data); ylabel('U [V]'); xlabel('t [s]');
exportgraphics(gcf, fullfile(currentProject().RootFolder, 'results', 'etap3_dwie_osie.png'));