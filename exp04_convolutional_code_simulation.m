%% Experiment 4: Convolutional Encoding and Viterbi Decoding
% Standalone hard-decision simulation; core MATLAB only.
% Rate 1/2, constraint length K=3, generator polynomials [111] and [101].
% Save as convolutional_code_simulation.m and press Run.

clear; close all; clc;
rng(21);

%% Parameters and input data
dataBits = [1 0 1 1 0 0 1 0 1 1 0 1];
K = 3;
memory = K-1;
numStates = 2^memory;

% Append tail zeros so the encoder returns to state 00.
terminatedInput = [dataBits zeros(1,memory)];

%% Convolutional encoding
% State is [previous input bit, second previous input bit].
state = [0 0];
codedBits = zeros(1,2*numel(terminatedInput));
stateTrace = zeros(numel(terminatedInput)+1,2);
stateTrace(1,:) = state;

for k = 1:numel(terminatedInput)
    u = terminatedInput(k);
    v1 = mod(u + state(1) + state(2),2); % generator 111
    v2 = mod(u + state(2),2);            % generator 101
    codedBits(2*k-1:2*k) = [v1 v2];

    state = [u state(1)];
    stateTrace(k+1,:) = state;
end

%% Simulate a binary symmetric channel by flipping bits
flipProbability = 0.05;
errorMask = rand(size(codedBits)) < flipProbability;
receivedBits = mod(codedBits + errorMask,2);

%% Viterbi decoder (hard decision, Hamming-distance metric)
% State number: 2*previous_bit + second_previous_bit, in range 0..3.
% Store path metric, predecessor state, and input decision.
numSteps = numel(terminatedInput);
largeMetric = 1e9;
pathMetric = largeMetric*ones(numStates,numSteps+1);
predecessor = zeros(numStates,numSteps);
inputDecision = zeros(numStates,numSteps);
pathMetric(1,1) = 0;  % known initial state 00

% Trellis transition tables
nextState = zeros(numStates,2);
branchOutput = zeros(numStates,2,2);
for s = 0:numStates-1
    prev1 = bitget(s,2);
    prev2 = bitget(s,1);
    for u = 0:1
        out1 = mod(u+prev1+prev2,2);
        out2 = mod(u+prev2,2);
        newPrev1 = u;
        newPrev2 = prev1;
        ns = 2*newPrev1 + newPrev2;
        nextState(s+1,u+1) = ns;
        branchOutput(s+1,u+1,:) = [out1 out2];
    end
end

for tStep = 1:numSteps
    r = receivedBits(2*tStep-1:2*tStep);
    for s = 0:numStates-1
        if pathMetric(s+1,tStep) >= largeMetric
            continue;
        end
        for u = 0:1
            ns = nextState(s+1,u+1);
            out = squeeze(branchOutput(s+1,u+1,:)).';
            branchMetric = sum(out ~= r);
            candidate = pathMetric(s+1,tStep) + branchMetric;
            if candidate < pathMetric(ns+1,tStep+1)
                pathMetric(ns+1,tStep+1) = candidate;
                predecessor(ns+1,tStep) = s;
                inputDecision(ns+1,tStep) = u;
            end
        end
    end
end

% Because tail zeros were appended, choose final state 00.
currentState = 0;
decodedTerminated = zeros(1,numSteps);
for tStep = numSteps:-1:1
    decodedTerminated(tStep) = inputDecision(currentState+1,tStep);
    currentState = predecessor(currentState+1,tStep);
end
decodedBits = decodedTerminated(1:numel(dataBits));

%% Results
rawErrors = sum(receivedBits ~= codedBits);
decodedErrors = sum(decodedBits ~= dataBits);

fprintf('CONVOLUTIONAL CODING SUMMARY\n');
fprintf('Constraint length K   : %d\n',K);
fprintf('Memory elements       : %d\n',memory);
fprintf('Number of states      : %d\n',numStates);
fprintf('Code rate             : 1/2\n');
fprintf('Input bits            : '); fprintf('%d',dataBits); fprintf('\n');
fprintf('Encoded bits          : '); fprintf('%d',codedBits); fprintf('\n');
fprintf('Received coded bits   : '); fprintf('%d',receivedBits); fprintf('\n');
fprintf('Decoded data bits     : '); fprintf('%d',decodedBits); fprintf('\n');
fprintf('Coded-bit channel flips: %d\n',rawErrors);
fprintf('Errors after decoding : %d out of %d information bits\n',decodedErrors,numel(dataBits));

%% Visualization
figure('Name','Convolutional Coding and Viterbi Decoding','Color','w');

subplot(4,1,1);
stairs(0:numel(dataBits)-1,dataBits,'LineWidth',1.5);
grid on; ylim([-0.2 1.2]); xlim([0 numel(dataBits)-1]);
title('1. Original information bits');
xlabel('Bit index'); ylabel('Bit');

subplot(4,1,2);
stairs(0:numel(codedBits)-1,codedBits,'LineWidth',1.3);
grid on; ylim([-0.2 1.2]); xlim([0 numel(codedBits)-1]);
title('2. Encoded bitstream (rate 1/2, including tail bits)');
xlabel('Coded-bit index'); ylabel('Bit');

subplot(4,1,3);
stairs(0:numel(receivedBits)-1,receivedBits,'LineWidth',1.3);
grid on; ylim([-0.2 1.2]); xlim([0 numel(receivedBits)-1]);
title(sprintf('3. Received coded bits (flip probability %.2f)',flipProbability));
xlabel('Coded-bit index'); ylabel('Bit');

subplot(4,1,4);
stairs(0:numel(dataBits)-1,dataBits,'b','LineWidth',2); hold on;
stairs(0:numel(decodedBits)-1,decodedBits,'r--','LineWidth',1.5);
grid on; ylim([-0.2 1.2]); xlim([0 numel(dataBits)-1]);
title('4. Original and Viterbi-decoded information bits');
xlabel('Information-bit index'); ylabel('Bit');
legend('Original','Decoded','Location','best');

figure('Name','Convolutional Encoder State Evolution','Color','w');
stairs(0:numel(terminatedInput),stateTrace(:,1),'LineWidth',1.5); hold on;
stairs(0:numel(terminatedInput),stateTrace(:,2),'LineWidth',1.5);
grid on; ylim([-0.2 1.2]);
title('Encoder memory bits over time');
xlabel('Input step'); ylabel('Stored bit');
legend('Previous input bit','Second previous input bit','Location','best');

%% Notes
% XOR is modulo-2 addition.
% For K=3, there are 2^(K-1)=4 states.
% Viterbi decoding retains the minimum-Hamming-distance path per state.
% Results depend on random channel flips; a short codeword may occasionally
% decode incorrectly. Increase the input length to study average performance.
