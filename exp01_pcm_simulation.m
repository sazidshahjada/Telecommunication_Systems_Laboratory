%% Experiment 1: Pulse Code Modulation (PCM) and Demodulation
% Standalone simulation; uses core MATLAB functions only.
% Save as pcm_simulation.m and press Run.

clear; close all; clc;

%% Parameters
A = 1;                  % Analog signal peak amplitude
fm = 2;                 % Analog signal frequency (Hz)
fs = 32;                % Sampling frequency (Hz), must exceed 2*fm
nBits = 3;              % Bits per PCM sample
T = 1;                  % Simulation duration (s)
t = 0:1/2000:T;         % Fine time grid for the analog signal

if fs <= 2*fm
    warning('Sampling theorem: choose fs > 2*fm for this demonstration.');
end

x = A*sin(2*pi*fm*t);

%% Sampling
Ts = 1/fs;
ts = 0:Ts:T;
xs = A*sin(2*pi*fm*ts);

%% Uniform quantization
L = 2^nBits;
vmin = -A;
vmax = A;
delta = (vmax-vmin)/L;

% Quantizer index 0...(L-1), then quantization reconstruction levels
idx = floor((xs-vmin)/delta);
idx = min(max(idx,0),L-1);
xq = vmin + (idx + 0.5)*delta;

%% Binary encoding: most-significant bit first
bitMatrix = zeros(numel(idx), nBits);
for k = 1:numel(idx)
    bitMatrix(k,:) = bitget(uint32(idx(k)), nBits:-1:1);
end
bitStream = reshape(bitMatrix.', 1, []);

%% Simple PCM decoding and reconstruction
% Decoding maps each codeword back to its quantization level.
decodedSamples = xq;
tReconstruction = 0:1/2000:T;
xReconstructed = interp1(ts, decodedSamples, tReconstruction, 'linear', 'extrap');

%% Display numerical summary
fprintf('PCM SIMULATION SUMMARY\n');
fprintf('Sampling frequency       : %.2f Hz\n', fs);
fprintf('Input frequency          : %.2f Hz\n', fm);
fprintf('Bits per sample          : %d\n', nBits);
fprintf('Quantization levels      : %d\n', L);
fprintf('Quantization step size   : %.4f V\n', delta);
fprintf('PCM bit rate             : %.2f bits/s\n', nBits*fs);
fprintf('Bit stream               : ');
fprintf('%d', bitStream);
fprintf('\n');

%% Visualization
figure('Name','PCM: Sampling, Quantization, Encoding and Reconstruction', ...
       'Color','w');

subplot(4,1,1);
plot(t,x,'b','LineWidth',1.4); hold on;
stem(ts,xs,'r','filled','MarkerSize',3);
grid on; xlim([0 T]);
title('1. Analog input and sampled values');
xlabel('Time (s)'); ylabel('Amplitude');
legend('Analog input','Samples','Location','best');

subplot(4,1,2);
plot(t,x,'Color',[0.65 0.65 0.65],'LineWidth',1); hold on;
stairs(ts,xq,'r','LineWidth',1.4);
stem(ts,xq,'r','filled','MarkerSize',3);
grid on; xlim([0 T]);
title(sprintf('2. Uniform quantization (%d bits, %d levels)',nBits,L));
xlabel('Time (s)'); ylabel('Amplitude');
legend('Original','Quantized staircase','Quantized samples','Location','best');

subplot(4,1,3);
numShow = min(numel(bitStream), 64);
stairs(0:numShow-1, bitStream(1:numShow),'k','LineWidth',1.4);
grid on; ylim([-0.2 1.2]); xlim([0 max(1,numShow-1)]);
title('3. Serialized PCM bitstream (first bits)');
xlabel('Bit index'); ylabel('Bit value');

subplot(4,1,4);
plot(t,x,'b','LineWidth',1.3); hold on;
plot(tReconstruction,xReconstructed,'r--','LineWidth',1.3);
stem(ts,decodedSamples,'k','MarkerSize',2);
grid on; xlim([0 T]);
title('4. Decoded samples and reconstructed waveform');
xlabel('Time (s)'); ylabel('Amplitude');
legend('Original','Linear reconstruction','Decoded samples','Location','best');

