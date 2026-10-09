%% Experiment 2: Direct Sequence Spread Spectrum (DSSS)
% Standalone BPSK DSSS demonstration; core MATLAB only.
% Save as dsss_simulation.m and press Run.

clear; close all; clc;
rng(7);                         % Reproducible noise

%% Parameters
dataBits = [1 0 1 1 0 0 1 0];  % Information bits
pnBits = [1 1 0 1 0 0 1 0];     % Example spreading sequence
chipsPerBit = numel(pnBits);
chipRate = 8000;                % chips/s (illustrative)
samplesPerChip = 20;
fs = chipRate*samplesPerChip;
chipDuration = 1/chipRate;

% Map binary values to bipolar symbols: 1 -> +1, 0 -> -1
dataSymbols = 2*dataBits - 1;
pnSymbols = 2*pnBits - 1;

%% Spread each information symbol with the PN code
spreadChips = zeros(1,numel(dataBits)*chipsPerBit);
for k = 1:numel(dataBits)
    chipIdx = (k-1)*chipsPerBit + (1:chipsPerBit);
    spreadChips(chipIdx) = dataSymbols(k)*pnSymbols;
end

%% Build a rectangular-chip waveform
tx = repelem(spreadChips, samplesPerChip);
t = (0:numel(tx)-1)/fs;

%% Add AWGN and a narrowband interferer (optional demonstration)
snrDb = 3;
signalPower = mean(tx.^2);
noisePower = signalPower / (10^(snrDb/10));
awgn = sqrt(noisePower)*randn(size(tx));

interferenceAmplitude = 0.45;
interferenceFrequency = 350;  % lower than chip rate
interference = interferenceAmplitude*sin(2*pi*interferenceFrequency*t);
rx = tx + awgn + interference;

%% Despread using the synchronized PN sequence
% Integrate/average over samples in each chip, then correlate per bit.
rxChipEstimates = mean(reshape(rx,samplesPerChip,[]),1);
rxBitMetric = zeros(1,numel(dataBits));
rxBits = zeros(1,numel(dataBits));

for k = 1:numel(dataBits)
    chipIdx = (k-1)*chipsPerBit + (1:chipsPerBit);
    rxBitMetric(k) = sum(rxChipEstimates(chipIdx).*pnSymbols);
    rxBits(k) = rxBitMetric(k) >= 0;
end

bitErrors = sum(rxBits ~= dataBits);
processingGain = chipsPerBit;
processingGainDb = 10*log10(processingGain);

fprintf('DSSS SIMULATION SUMMARY\n');
fprintf('Information bits         : '); fprintf('%d ',dataBits); fprintf('\n');
fprintf('PN code                  : '); fprintf('%d ',pnBits); fprintf('\n');
fprintf('Chips per information bit: %d\n',chipsPerBit);
fprintf('Theoretical processing gain: %.2f (%.2f dB)\n',processingGain,processingGainDb);
fprintf('Recovered bits           : '); fprintf('%d ',rxBits); fprintf('\n');
fprintf('Bit errors in this run   : %d out of %d\n',bitErrors,numel(dataBits));

%% Visualization
figure('Name','DSSS Spreading and Despreading','Color','w');

subplot(5,1,1);
stairs(0:numel(dataBits),[dataBits dataBits(end)],'LineWidth',1.4);
grid on; ylim([-0.2 1.2]);
title('1. Original information bits (display only)');
xlabel('Bit interval'); ylabel('Bit');

subplot(5,1,2);
stairs(0:numel(pnBits),[pnBits pnBits(end)],'LineWidth',1.4);
grid on; ylim([-0.2 1.2]);
title('2. Example PN spreading code');
xlabel('Chip interval'); ylabel('PN bit');

subplot(5,1,3);
chipTime = (0:numel(spreadChips))*chipDuration;
stairs(chipTime,[spreadChips spreadChips(end)],'LineWidth',1.1);
grid on; ylim([-1.4 1.4]);
title('3. DSSS spread signal (bipolar chip values)');
xlabel('Time (s)'); ylabel('Amplitude');

subplot(5,1,4);
plot(t,rx,'Color',[0.25 0.45 0.8]); grid on;
title('4. Received spread signal with AWGN and narrowband interference');
xlabel('Time (s)'); ylabel('Amplitude');

subplot(5,1,5);
stem(1:numel(rxBitMetric),rxBitMetric,'filled','LineWidth',1.2); hold on;
yline(0,'k--');
grid on;
title('5. Despreader correlation metrics (sign gives detected bit)');
xlabel('Information-bit index'); ylabel('Correlation');

figure('Name','DSSS Original vs Recovered Bits','Color','w');
stairs(0:numel(dataBits)-1,dataBits,'b','LineWidth',2); hold on;
stairs(0:numel(rxBits)-1,rxBits,'r--','LineWidth',1.6);
grid on; ylim([-0.2 1.2]); xlim([0 numel(dataBits)-1]);
xlabel('Bit index'); ylabel('Bit');
title('DSSS: Original and detected data');
legend('Original bits','Detected bits','Location','best');

%% Notes
% This is a baseband, bipolar DSSS model. A practical RF DSSS system also
% modulates the spread waveform onto a carrier and requires code timing sync.
% Processing gain for N chips/bit is approximately N, or 10*log10(N) dB.
