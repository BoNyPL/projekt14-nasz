params;
out = sim('os4');
%Oś Azymutu
az_zad = out.logsout.get('az_zad').Values;   % Zadany azymut
azth = out.logsout.get('az_theta').Values;   % kąt

%Oś Elewacji
el_zad = out.logsout.get('el_zad').Values;   % Zadana elewacja
e_az = mod(rad2deg(az_zad.Data - azth.Data) + 180, 360) - 180; %Uchyb azymutu


%Wykresy
figure; tiledlayout(2,1);
nexttile; hold on;
plot(az_zad.Time, mod(rad2deg(az_zad.Data), 360)); ylabel('azymut Zadany [deg]'); xlabel('t [s]');
plot(azth.Time, mod(rad2deg(azth.Data), 360)); ylabel('azymut Lufy [deg]'); xlabel('t [s]');
legend('azymutZadany','azymutLufy');
hold off;
nexttile; plot(az_zad.Time, e_az); ylabel('Uchyb Azymutu [deg]'); xlabel('t [s]');
legend('UchybAzymutu');
exportgraphics(gcf, fullfile(currentProject().RootFolder, 'results', 'etap4.png'));

params;
cel_baza = cel;  az_baza = az;  el_baza = el;

scenariusze = {
    'przelot_bokiem', [-3000 1500 800],  [150 0 0],    40
    'nurkowanie',     [-2500 -2000 1500], [100 100 -30], 40
    'nad_dzialkiem',  [-3000 0 600],     [150 0 0],    40
    };
    wyniki = table();
    t_start = 5; 

    for i = 1:size(scenariusze, 1)
    [nazwa, p0, v, T] = scenariusze{i, :};
    for ff = [0 1]
        cel = cel_baza;  cel.p0 = p0;  cel.v = v;  cel.Tsim = T;
        az = az_baza;  az.ff = ff;
        el = el_baza;  el.ff = ff;

        out  = sim('os4');
        t    = out.logsout.get('az_zad').Values.Time;
        azC  = out.logsout.get('az_zad').Values.Data; % kierunek do celu
        elC  = out.logsout.get('el_zad').Values.Data;
        azL  = out.logsout.get('az_theta').Values.Data; % kierunek lufy
        elL  = out.logsout.get('el_theta').Values.Data;

        uC = [cos(elC).*sin(azC), cos(elC).*cos(azC), sin(elC)];
        uL = [cos(elL).*sin(azL), cos(elL).*cos(azL), sin(elL)];
        c   = sum(uC .* uL, 2);                % iloczyn skalarny wiersz po wierszu
        err = acosd(min(max(c, -1), 1));       % błąd wycelowania [deg]

        m = t >= t_start;
        wyniki = [wyniki; table(string(nazwa), ff, ...
            sqrt(mean(err(m).^2)), max(err(m)), 100*mean(err(m) > 1), ...
            'VariableNames', {'Scenariusz','FF','RMS_deg','Max_deg','Pow_1deg_proc'})];
    end
    figure('Name', nazwa); tiledlayout(3,1);
    nexttile; plot(t, mod(rad2deg(azL),360), t, mod(rad2deg(azC),360), '--');
    ylabel('azymut [deg]'); legend('lufa','cel'); title(strrep(nazwa,'_',' '));
    nexttile; plot(t, rad2deg(elL), t, rad2deg(elC), '--'); yline(85, ':', '85°');
    ylabel('elewacja [deg]');
    nexttile; semilogy(t, max(err, 1e-3)); yline(1, ':', '1°');
    ylabel('błąd wycelowania [deg]'); xlabel('t [s]');
    exportgraphics(gcf, fullfile(currentProject().RootFolder, 'results', ['etap4_' nazwa '.png']));
    end

    cel = cel_baza;  az = az_baza;  el = el_baza;
    disp(wyniki)