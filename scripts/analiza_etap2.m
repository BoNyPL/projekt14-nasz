params;
out = sim('os2');
th = out.logsout.get('theta').Values;   % kąt
w  = out.logsout.get('omega').Values;   % prędkość
U  = out.logsout.get('U').Values;       % napięcie


info = stepinfo(th.Data, th.Time, theta_zad);   % dane kąta, czas, wartość końcowa
fprintf('Przeregulowanie: %.2f %%\n', info.Overshoot);
fprintf('Czas ustalania: %.3f s\n', info.SettlingTime);
fprintf('Uchyb ustalony: %.2e rad\n', theta_zad - th.Data(end));
fprintf('Max |U|: %.2f V\n', max(abs(U.Data)));
fprintf('Max |omega|: %.3f rad/s\n', max(abs(w.Data)));

figure; tiledlayout(3,1);
nexttile; plot(th.Time, th.Data); hold on; yline(theta_zad, '--'); ylabel('\theta [rad]');
nexttile; plot(w.Time, w.Data); ylabel('\omega [rad/s]');
nexttile; plot(U.Time, U.Data); ylabel('U [V]'); xlabel('t [s]');
exportgraphics(gcf, fullfile(currentProject().RootFolder, 'results', 'etap2_skok90.png'));