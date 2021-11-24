clc
clear
close all

%% Prop struct
tables = struct('prop', [], 'str_idx', [], 'mod_idx', [], 'pos_idx', [],...
    'D', []);

%% Propiedades 11
% Tracion
tables(1).prop = 'Longitudinal_Tension.csv';
tables(1).str_idx = 13;
tables(1).mod_idx = 14;
tables(1).pos_idx = 8;
tables(1).D = 1;
% Compresion
idx = length(tables) + 1;
tables(idx).prop = 'Longitudinal_Compression.csv';
tables(idx).mod_idx = 6;
tables(idx).pos_idx = 7;
tables(idx).D = 1;

%% Propiedades 11
% Traccion
idx = length(tables) + 1;
tables(idx).prop = 'Transverse_Tension.csv';
tables(idx).str_idx = 6;
tables(idx).mod_idx = 7;
tables(idx).D = 1;
% Compresion
idx = length(tables) + 1;
tables(idx).prop = 'Transverse_Compression.csv';
tables(idx).str_idx = 6;
tables(idx).mod_idx = 7;
tables(idx).pos_idx = 8;
tables(idx).D = 1;

%% Propiedades cortante
idx = length(tables) + 1;
tables(idx).prop = 'In-Plane_Shear.csv';
tables(idx).str_idx = 6;
tables(idx).mod_idx = 8;
tables(idx).D = 1;


%% STATISTICAL CURVE FITTING
props = struct('property', [], 'density', [], 'str_data', [], 'mod_data', [], 'pois_data', [], 'mod', [],...
    'pois', [], 'D', [], 'PD', []);

for t = 1:length(tables)
    props(t).property = tables(t).prop;
    props(t).density = 1580;
    T = readtable(tables(t).prop);

    props(t).str_data = T{:,tables(t).str_idx};  % ksi
    props(t).mod_data = T{:,tables(t).mod_idx};  % msi
    try
        props(t).pois_data = T{:,tables(t).pos_idx};
    catch
        props(t).pois_data = 0;
    end

    % Propiedades Modulus
    props(t).mod = mean(props(t).mod_data);

    % Propiedades Poisson
    props(t).pois = mean(props(t).pois_data);

    % Propiedades Strength
    n = isempty(props(t).str_data);

    switch n
        case 0
            [D, PD] = allfitdist(props(t).str_data);
            props(t).D = D;
            props(t).PD = PD;
            %fprintf('%10s\t'  , D(1).ParamNames{:}); fprintf('\n');
            %fprintf('%10.2f\t', D(1).Params       ); fprintf('\n');

            x = linspace( 0.90*min(props(t).str_data), ...
                1.10*max(props(t).str_data), 1000);
            y = pdf(PD{tables(t).D}, x);
            y = y/max(y)*4;
            p = cdf(PD{tables(t).D}, x)*100;      % Percentaje probability
            a_basis = x(find( p <= 1, 1, 'last' ));
            disp( ['A-basis for ', props(t).property, '  = ' num2str( a_basis )] )
            b_basis = x(find( p <= 10, 1, 'last' ));
            disp( ['B-basis for ', props(t).property, ' = ' num2str( b_basis )] )
            disp('-')

            figure();
                hold on
                plot(x,y,'LineWidth', 2)
                histogram(props(t).str_data, length(props(t).str_data))
                title([D(tables(t).D).DistName ' distribution'])
                grid on
                box on

            figure();
                hold on
                plot(x, p, 'LineWidth', 2)
                xline( a_basis, '-', {'A-basis'}, 'Interpreter', 'Latex', 'LineWidth', 2 );
                xline( b_basis, '-', {'B-basis'}, 'Interpreter', 'Latex', 'LineWidth', 2 );
                title([D(tables(t).D).DistName ' distribution'])
                grid on
                box on

        otherwise
            disp('No strength property')
            disp('-')
    end


end
