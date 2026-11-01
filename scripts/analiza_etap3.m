params;
out = sim('os3');
%Oś Azymutu
azth = out.logsout.get('az_theta').Values;   % kąt
azw  = out.logsout.get('az_omega').Values;   % prędkość
azU  = out.logsout.get('az_U').Values;       % napięcie
%Oś Elewacji
elth = out.logsout.get('el_theta').Values;   % kąt
elw  = out.logsout.get('el_omega').Values;   % prędkość
elU  = out.logsout.get('el_U').Values;       % napięcie
obrot_ocz = rad2deg(mod(scen.az_ref - az.th0 + pi, 2*pi) - pi);
obrot     = rad2deg( azth.Data(end) - az.th0); 
el_maks   = rad2deg(max(elth.Data));
el_mini   = rad2deg(min(elth.Data));
w_maks    = rad2deg(max(abs(elw.Data)));


fprintf('Max |U|: %.2f V\n', max(abs(elU.Data)));
fprintf('Max |omega|: %.2f deg/s\n', w_maks);
fprintf('Oczekiwany obrót: %.2f deg\n', obrot_ocz);
fprintf('Obrót azymutu: %.2f deg\n', obrot);
fprintf('Max elewacji %.2f deg\n', el_maks);
fprintf('Min elewacji %.2f deg\n', el_mini);

figure; tiledlayout(2,2);
nexttile; plot(elw.Time, rad2deg(elw.Data)); ylabel('\omega_{el} [deg/s]'); xlabel('t [s]');
nexttile; plot(azU.Time, azU.Data, elU.Time, elU.Data); ylabel('U [V]'); xlabel('t [s]');
legend('azymut','elewacja');
nexttile; plot(azth.Time, rad2deg(azth.Data)); ylabel('azymut [deg]'); xlabel('t [s]');
nexttile; plot(elth.Time, rad2deg(elth.Data)); ylabel('elewacja [deg]'); xlabel('t [s]');

exportgraphics(gcf, fullfile(currentProject().RootFolder, 'results', 'etap3_dwie_osie.png'));



if abs(obrot - obrot_ocz) < 0.5 && el_maks <= rad2deg(el.max) + 0.5 && el_mini >= rad2deg(el.min) - 0.5
    fprintf('WYNIK: OK\n'); 
else
     fprintf('WYNIK: BŁĄD\n');
end