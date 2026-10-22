%% analiza_etap1.m - porównanie modelu os1 ze wzorem analitycznym
params;                                % nowe parametry
out = sim('os1');                      % uruchomienie modelu

w = out.logsout.get('omega').Values;   % zapisany sygnał omega
t = w.Time;                            % chwile czasu z solvera
w_m = w.Data;                          % prędkość z modelu

% rozwiązanie analityczne z kroku 2 (przed skokiem prędkość = 0)
w_a = az.K*U_skok*(1 - exp(-(t - t_skok)/az.T)) .* (t >= t_skok);

figure;
plot(t, w_m, 'LineWidth', 1.5); hold on;
plot(t, w_a, '--', 'LineWidth', 1.5);
grid on; xlabel('t [s]'); ylabel('\omega [rad/s]');
legend('model Simulink', 'wzór analityczny', 'Location', 'southeast');
title('Odpowiedź skokowa osi azymutu');

fprintf('Największa różnica model - wzór: %.2e rad/s\n', max(abs(w_m - w_a)));
exportgraphics(gcf, fullfile(currentProject().RootFolder, 'results', 'etap1_omega.png'));