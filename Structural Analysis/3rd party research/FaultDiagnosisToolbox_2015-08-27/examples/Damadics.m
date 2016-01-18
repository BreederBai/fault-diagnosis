%% Structural analysis of the model of the DAMADICS 
%  benchmark valve model from the paper
%    Dustegor, D., Frisk, E., Cocquempot, V., Krysander, M., and 
%    Staroswiecki, M., "Structural analysis of fault isolability in the
%    DAMADICS benchmark", Control Engineering Practice, 14(6), 597-608,
%    2006
clear 
close all

%% Define model
% Unknown variables
model.type = 'VarStruc';
model.x = {'x', 'xh', 'Ps', 'P1', 'P2', 'Pz',...
	'Pv', 'DeltaP', 'DeltaP-a', ...
	'Q', 'Qv', 'Qv3', 'Qc', 'T1', 'Fvc', 'xf10'};

% Faults
model.f = {'f1', 'f4', 'f5', 'f7', 'f8', 'f9', 'f10', 'f11', 'f12', ...
	'f13', 'f16', 'f18'};

% Known variables
model.z = {'Yx', 'YP1', 'YP2', 'CVI', 'Cv', 'x3'};

% Define structure
% Each line represents a model relation and lists all involved variables. 
model.rels = {...
    {'Ps', 'xf10', 'x', 'f4', 'f11', 'Fvc'},... % e1
    {'xh', 'x', 'f8'},... % e2
    {'Qv', 'f5', 'f1', 'xh', 'DeltaP'},... % e3
    {'DeltaP-a', 'xh', 'P1', 'Pv'},... % e4
    {'Pv', 'T1'},... % e5
    {'DeltaP', 'P1', 'P2', 'DeltaP-a'},... % e6
    {'Fvc', 'P1', 'xh', 'P2', 'DeltaP-a','Pv'},... % e7
    {'Qv3', 'x3', 'f18', 'P1', 'P2'},... % e8
    {'Qc', 'Ps', 'xh'},... % e9
    {'Qc', 'f9', 'Ps', 'xf10', 'CVI', 'Pz', 'f16'},... % e10
    {'Q', 'Qv', 'Qv3'},... % e11
    {'Yx', 'xh', 'f13'},... % e12
    {'YP1', 'P1'},... % e14
    {'YP2', 'P2'},... % e15
    {'T1', 'f7'},... % e18
    {'CVI', 'f12', 'Cv', 'Yx'},... % e19
    {'xf10', 'f10'},... % e20 - dummy equation for fault f10
};

sm = DiagnosisModel(model);
sm.name = 'Damadics benchmark';
sm.PossibleSensorLocations(model.x(1:15)); % all variables but dummy-variable xf10 measureable

clear model
%% Plot Model
figure(1)
sm.PlotModel();

%% Perform detectability analysis
[df,ndf] = sm.DetectabilityAnalysis();

%% Perform sensor placement analysis for detectability
sDet = sm.SensorPlacementDetectability();
sm2 = sm.AddSensors( sDet{1} );

figure(2)
sm2.IsolabilityAnalysis('permute', true);

figure(3)
sm2.PlotDM('eqclass', true, 'fault', true);

%% Perform sensor placement analysis for full fault isolability
sIsol = sm.SensorPlacementIsolability();
sm3 = sm.AddSensors( sIsol{1} );

figure(4)
sm3.IsolabilityAnalysis('permute', true);

figure(5)
sm3.PlotDM('eqclass', true, 'fault', true);

%% Get set of MSOs
msos = sm3.MSO();
