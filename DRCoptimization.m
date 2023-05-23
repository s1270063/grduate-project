function DRCoptimization()
% Use this as your main function to run the genetic algorithm (GA)

% Make sure that the sampling rate is 16000, if the sampling rate of a file
% is not 16000 you need to resample it.

% There are two noises, optimize the parameters of the compressor
% independently for these two noises

% there are 6 parameters to control in a compressor. These are the ranges
% you should consider:
% 
%     'AttackTime',     [0.0 .050]
%     'ReleaseTime',    [0.0 .050]
%     'Threshold',      [-60 0]
%     'Ratio',          [1 10]
%     'KneeWidth',      [0 6]
%     'MakeUpGain',     [0 6]

% USE THIS LINE FOR REPRODUCIBILITY
rng default % For reproducibility

numberOfVariables = 6;

% Consider using these options for your GA
gaoptions = optimoptions(@ga,...
    'UseParallel',true, ... % If you can run in parallel it would be faster
    'Display', 'iter', ...% To see the evolution in the Command Window
    'PlotFcn','gaplotbestf' ... % Save these plots for your report
    );

% This is the way to invoke the GA

lowBoundariesOfThe6Parameters = [0.0,0.0,-60,1,0,0];
upperBoundariesOfThe6Parameters = [.050,.050,0,10,6,6];

% Study what is this, the parameters, everything, This is your core.
[x,~]=ga(@(x) eSIILoss(x(1), x(2),x(3),x(4),x(5),x(6)), ... % make sure that eSIILoss has the same parameters
    numberOfVariables,[],[],[],[],lowBoundariesOfThe6Parameters,...
    upperBoundariesOfThe6Parameters,[],...
    gaoptions);

% Display the final results for reporting
disp(x)

end

function e = eSIILoss(AttackTime,ReleaseTime,Threshold,Ratio,KneeWidth,MakeUpGain)
% use this for computing the loss/fitness function for the GA

targetsnr = -9;

% read the speech file(s)
[y, Fs] = audioread('/FW03/fto/word/fami1/list_a/fto_1a01.wav');

% our target is 16,000 but if the audio is already 16,000 then we do not
% have to do anything.

if Fs ~= 16000
    y = resample(y,Fs,16000);
end

% set the compressor with the values given by the GA

comp = compressor('SampleRate',16000,'AttackTime',AttackTime,'ReleaseTime',ReleaseTime,'Threshold',Threshold,'Ratio',Ratio,'KneeWidth',KneeWidth,'MakeUpGain',MakeUpGain);

% process the speech file with the compressor and save it in y

y = comp(y);

% Mix the result with the noise at the given SNR

% Read the noise and resample the noise

[y_noise, Fs2] =audioread('Noises/CCITTRec227_16kHz.wav');

if Fs2 ~= 16000
    y_noise =resample(y_noise,Fs2,16000);
end

% Study what is SNR and how to applied to a signal.

[~,xm,~] = mixsignal(y,bgNoise,targetsnr);

% compute the eSII, if the noise is cafeteria use 'FN' otherwise use 'SN'
[~, ~, esii, ~] = extSII(xm, bgNoise, sr, 'FN'); %'SN'

%return the loss as
e = log(1-esii);
end
