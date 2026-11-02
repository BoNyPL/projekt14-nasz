function aplikacja_projekt14

params;   % wartości domyślne (az, el, scen)

h.fig = uifigure('Name', 'Projekt 14 – test dwóch osi (os3)', 'Position', [80 80 1250 740]);
gl    = uigridlayout(h.fig, [1 2], 'ColumnWidth', {320, '1x'});

%% Panel ustawień
p = uipanel(gl, 'Title', 'Scenariusz');
g = uigridlayout(p, [10 2], 'ColumnWidth', {'1x', 90}, ...
    'RowHeight', [repmat({28}, 1, 9), {'1x'}]);

h.az0  = pole(g, 'Azymut startowy [°]',         rad2deg(az.th0));
h.azr  = pole(g, 'Azymut zadany [°]',           rad2deg(scen.az_ref));
h.el0  = pole(g, 'Elewacja startowa [°]',       rad2deg(el.th0));
h.elr1 = pole(g, 'Elewacja zadana 1 [°]',       rad2deg(scen.el_ref1));
h.elr2 = pole(g, 'Elewacja zadana 2 [°]',       rad2deg(scen.el_ref2));
h.elt  = pole(g, 'Chwila zmiany elewacji [s]',  scen.el_t);
h.T    = pole(g, 'Czas symulacji [s]',          scen.Tsim);

bSym = uibutton(g, 'Text', 'Symuluj', 'FontWeight', 'bold');
bDom = uibutton(g, 'Text', 'Domyślne');

h.wynik = uilabel(g, 'Text', 'Ustaw scenariusz i kliknij Symuluj', ...
    'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
h.wynik.Layout.Row = 9;  h.wynik.Layout.Column = [1 2];

h.opis = uitextarea(g, 'Editable', 'off', 'FontName', 'Consolas');
h.opis.Layout.Row = 10;  h.opis.Layout.Column = [1 2];

%% Wykresy
ga = uigridlayout(gl, [2 2]);
for k = 1:4
    h.ax(k) = uiaxes(ga);
    grid(h.ax(k), 'on');
    xlabel(h.ax(k), 't [s]');
end
title(h.ax(1), 'Azymut');                ylabel(h.ax(1), '[°]');
title(h.ax(2), 'Elewacja');              ylabel(h.ax(2), '[°]');
title(h.ax(3), 'Prędkość elewacji');     ylabel(h.ax(3), '\omega [rad/s]');
title(h.ax(4), 'Napięcia sterujące');    ylabel(h.ax(4), 'U [V]');

bSym.ButtonPushedFcn = @(~, ~) symuluj(h);
bDom.ButtonPushedFcn = @(~, ~) domyslne(h);
end


%% ---------------------------------------------------------------------------
function f = pole(g, tekst, wartosc)
% Etykieta i pole liczbowe w jednym wierszu siatki.
uilabel(g, 'Text', tekst);
f = uieditfield(g, 'numeric', 'Value', wartosc);
end


function domyslne(h)
% Przywraca wartości ze scenariusza w params.m.
params;
h.az0.Value  = rad2deg(az.th0);
h.azr.Value  = rad2deg(scen.az_ref);
h.el0.Value  = rad2deg(el.th0);
h.elr1.Value = rad2deg(scen.el_ref1);
h.elr2.Value = rad2deg(scen.el_ref2);
h.elt.Value  = scen.el_t;
h.T.Value    = scen.Tsim;
end


function symuluj(h)
% Uruchamia os3
params; % parametry osi
az.th0       = deg2rad(h.az0.Value);
el.th0       = deg2rad(h.el0.Value);
scen.az_ref  = deg2rad(h.azr.Value);
scen.el_ref1 = deg2rad(h.elr1.Value);
scen.el_ref2 = deg2rad(h.elr2.Value);
scen.el_t    = h.elt.Value;
scen.Tsim    = h.T.Value;

h.wynik.Text = 'Symulacja...';
h.wynik.FontColor = [0 0 0];
drawnow;

in = Simulink.SimulationInput('os3');
in = in.setVariable('az', az);
in = in.setVariable('el', el);
in = in.setVariable('scen', scen);
try
    out = sim(in);
    if ~isempty(out.ErrorMessage)
        error('%s', out.ErrorMessage);
    end
catch err
    h.wynik.Text = 'BŁĄD SYMULACJI';
    h.wynik.FontColor = [0.8 0 0];
    uialert(h.fig, err.message, 'Błąd symulacji');
    return
end

azth = out.logsout.get('az_theta').Values;
azU  = out.logsout.get('az_U').Values;
elth = out.logsout.get('el_theta').Values;
elw  = out.logsout.get('el_omega').Values;
elU  = out.logsout.get('el_U').Values;

obrot_ocz = rad2deg(mod(scen.az_ref - az.th0 + pi, 2*pi) - pi);
obrot     = rad2deg(azth.Data(end) - az.th0);
el_maks   = rad2deg(max(elth.Data));
el_mini   = rad2deg(min(elth.Data));
el_kon    = rad2deg(elth.Data(end));
if scen.el_t < scen.Tsim, el_zad = scen.el_ref2; else, el_zad = scen.el_ref1; end
el_cel    = rad2deg(min(max(el_zad, el.min), el.max));
tol       = 0.5;                                          % tolerancja [°]

ok = abs(obrot - obrot_ocz) < tol ...
    && el_maks <= rad2deg(el.max) + tol ...
    && el_mini >= rad2deg(el.min) - tol ...
    && abs(el_kon - el_cel) < tol;

if ok
    h.wynik.Text = 'WYNIK: OK';
    h.wynik.FontColor = [0 0.55 0];
else
    h.wynik.Text = 'WYNIK: BŁĄD';
    h.wynik.FontColor = [0.8 0 0];
end
h.opis.Value = {
    sprintf('Azymut:   obrót %+.2f° (oczekiwany %+.2f°)', obrot, obrot_ocz)
    sprintf('Elewacja: max %.2f°, min %.2f°', el_maks, el_mini)
    sprintf('          końcowa %.2f° (cel %.2f°)', el_kon, el_cel)
    sprintf('Max |U|:  azymut %.2f V, elewacja %.2f V', max(abs(azU.Data)), max(abs(elU.Data)))
    sprintf('Max |ω| elewacji: %.3f rad/s', max(abs(elw.Data)))
    sprintf('Kryteria: ±%.1f°, zakres %g–%g°', tol, rad2deg(el.min), rad2deg(el.max))
    };

% wykresy 
ax = h.ax;
plot(ax(1), azth.Time, rad2deg(azth.Data), 'LineWidth', 1.2);
yline(ax(1), rad2deg(az.th0) + obrot_ocz, '--', 'cel');
opisz(ax(1), 'Azymut', '[°]');

plot(ax(2), elth.Time, rad2deg(elth.Data), 'LineWidth', 1.2);
yline(ax(2), rad2deg([el.min el.max]), '--', {'5°', '85°'});
yline(ax(2), rad2deg([el.stop_min el.stop_max]), 'r:', {'ogranicznik', 'ogranicznik'});
ylim(ax(2), [-5 95]);
opisz(ax(2), 'Elewacja', '[°]');

plot(ax(3), elw.Time, elw.Data, 'LineWidth', 1.2);
opisz(ax(3), 'Prędkość elewacji', '\omega [rad/s]');

plot(ax(4), azU.Time, azU.Data, elU.Time, elU.Data, 'LineWidth', 1.2);
legend(ax(4), 'azymut', 'elewacja');
opisz(ax(4), 'Napięcia sterujące', 'U [V]');
end


function opisz(ax, tytul, os_y)
title(ax, tytul);  ylabel(ax, os_y);  xlabel(ax, 't [s]');  grid(ax, 'on');
end
