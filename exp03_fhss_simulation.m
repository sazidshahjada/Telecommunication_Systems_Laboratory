%% Experiment 3: Frequency Hopping Spread Spectrum (FHSS)
% Standalone real passband simulation with coherent per-hop BPSK detection.
% Core MATLAB only; no Communications or Signal Processing Toolbox required.
% Save as fhss_simulation.m and press Run.

clear; close all; clc;
rng(12);

%% Parameters
dataBits = [1 0 1 1 0 1 0 0];
dataSymbols = 2*dataBits - 1;       % 1 -> +1, 0 -> -1

fs = 20000;                         % sampling rate (Hz)
bitDuration = 0.02;                 % one bit per hop in this example
samplesPerBit = round(fs*bitDuration);
bitDuration = samplesPerBit/fs;
tBit = (0:samplesPerBit-1)/fs;

hopFrequencies = [500 1000 1500 2000]; % Hz, illustrative baseband carriers
hopPattern = [2 4 1 3 2 1 4 3];       % shared known hop indices
if numel(hopPattern) < numel(dataBits)
    error('Hopping pattern must contain at least as many entries as data bits.');
end
hopPattern = hopPattern(1:numel(dataBits));
selectedFrequencies = hopFrequencies(hopPattern);

%% Generate hopping BPSK signal: each bit uses a different carrier
tx = zeros(1,numel(dataBits)*samplesPerBit);
for k = 1:numel(dataBits)
    idx = (k-1)*samplesPerBit + (1:samplesPerBit);
    tx(idx) = dataSymbols(k)*cos(2*pi*selectedFrequencies(k)*tBit);
end
t = (0:numel(tx)-1)/fs;

%% Add white Gaussian noise
snrDb = 8;
noisePower = mean(tx.^2)/(10^(snrDb/10));
rx = tx + sqrt(noisePower)*randn(size(tx));

%% Synchronized receiver: correlate with the expected frequency on each hop
detectedBits = zeros(size(dataBits));
decisionMetric = zeros(size(dataBits));
for k = 1:numel(dataBits)
    idx = (k-1)*samplesPerBit + (1:samplesPerBit);
    localCarrier = cos(2*pi*selectedFrequencies(k)*tBit);
    decisionMetric(k) = sum(rx(idx).*localCarrier);
    detectedBits(k) = decisionMetric(k) >= 0;
end
numErrors = sum(detectedBits ~= dataBits);

fprintf('FHSS SIMULATION SUMMARY\n');
fprintf('Data bits             : '); fprintf('%d ',dataBits); fprintf('\n');
fprintf('Hop indices           : '); fprintf('%d ',hopPattern); fprintf('\n');
fprintf('Selected frequencies  : '); fprintf('%.0f ',selectedFrequencies); fprintf('Hz\n');
fprintf('Hopping interval      : %.3f ms\n',1000*bitDuration);
fprintf('Detected bits         : '); fprintf('%d ',detectedBits); fprintf('\n');
fprintf('Bit errors            : %d out of %d\n',numErrors,numel(dataBits));

%% Visualization
figure('Name','FHSS Frequency Hopping Simulation','Color','w');

subplot(4,1,1);
stairs(0:numel(dataBits)-1,dataBits,'LineWidth',1.5);
grid on; ylim([-0.2 1.2]); xlim([0 numel(dataBits)-1]);
title('1. Input data bits');
xlabel('Bit / hop index'); ylabel('Bit');

subplot(4,1,2);
stairs(0:numel(dataBits)-1,selectedFrequencies,'LineWidth',1.8);
grid on; xlim([0 numel(dataBits)-1]);
title('2. Carrier frequency selected by the hopping pattern');
xlabel('Bit / hop index'); ylabel('Frequency (Hz)');

subplot(4,1,3);
plot(t,tx,'b'); grid on;
title('3. Transmitted FHSS waveform (BPSK on hopping carriers)');
xlabel('Time (s)'); ylabel('Amplitude');

subplot(4,1,4);
plot(t,rx,'Color',[0.25 0.45 0.8]); grid on;
title('4. Received FHSS waveform with AWGN');
xlabel('Time (s)'); ylabel('Amplitude');

figure('Name','FHSS Original vs Detected Data','Color','w');
stairs(0:numel(dataBits)-1,dataBits,'b','LineWidth',2); hold on;
stairs(0:numel(detectedBits)-1,detectedBits,'r--','LineWidth',1.6);
grid on; ylim([-0.2 1.2]); xlim([0 numel(dataBits)-1]);
xlabel('Bit / hop index'); ylabel('Bit');
title('FHSS: Original and detected bits');
legend('Original bits','Detected bits','Location','best');

%% Notes
% This is a teaching model with one data bit per hop and a known hop pattern.
% Real FHSS systems need hop synchronization, RF frequency synthesis and
% may use several symbols per hop (slow hopping) or several hops per symbol
% (fast hopping). The selected carriers are illustrative, not a radio plan.
