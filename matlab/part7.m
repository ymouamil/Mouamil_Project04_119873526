%% part7.m
% ENEE322/ENEE323 Project - Part (vii)
% Multiply pure harmonic signal by exponential decay envelope

clear; close all; clc;

% Load Vee2 from part4
if ~exist('Vee2.mat', 'file')
    error('Run part4.m first to generate Vee2.mat');
end
load('Vee2.mat');

% Load original
[vnote, fs] = audioread('note.wav');
N = length(vnote);
t = (0:N-1) / N;  % normalized time

fprintf('\n=== Part (vii) ===\n');
fprintf('Matching envelope to original vnote...\n');

% Plot original for reference
figure(7);
plot(vnote);
hold on;
xlabel('Sample index');
ylabel('Amplitude');
title('Original vnote with envelope overlay');

% Interactive envelope selection
fprintf('\nTry different envelope parameters:\n');
fprintf('vnote envelope roughly decays like A * exp(-c * t)\n');

% Suggest starting parameters
A_guess = max(abs(vnote));
c_guess = 3;  % trial and error

% Allow user to try different values
while true
    A = input(sprintf('Enter A (amplitude, default=%.3f): ', A_guess));
    if isempty(A), A = A_guess; end
    
    c = input(sprintf('Enter c (decay rate, default=%.2f): ', c_guess));
    if isempty(c), c = c_guess; end
    
    envelope = A * exp(-c * t);
    
    % Plot overlay
    clf;
    plot(vnote, 'b');
    hold on;
    plot(envelope, 'r--', 'LineWidth', 2);
    plot(-envelope, 'r--', 'LineWidth', 2);
    xlabel('Sample index');
    ylabel('Amplitude');
    title(sprintf('Original (blue) vs Envelope A=%.3f, c=%.2f (red)', A, c));
    legend('vnote', 'Envelope');
    
    good = input('Does this envelope match? (y/n): ', 's');
    if strcmpi(good, 'y')
        break;
    end
    fprintf('Try different values.\n');
end

% Apply envelope to Vee2
Vee4 = Vee2 .* envelope';

% Playback comparison
fprintf('\nPlaying ORIGINAL vnote...\n');
soundsc(vnote, fs);
pause(4);

fprintf('Playing Vee4 (pure harmonic with exponential envelope)...\n');
soundsc(Vee4, fs);
pause(4);

% Plot magnitude spectrum of Vee4
figure(8);
Vee4_fft = fft(Vee4);
Vee4_mag = abs(Vee4_fft(1:N/2));
f = fs * (0:N/2-1) / N;

bar(f, Vee4_mag, 'BarWidth', 1);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Magnitude Spectrum of Vee4 (Enveloped Pure Harmonic)');
xlim([0, 5000]);
grid on;

% Compare to original spectrum
figure(9);
vnote_fft = fft(vnote);
vnote_mag = abs(vnote_fft(1:N/2));

subplot(2,1,1);
bar(f, vnote_mag, 'BarWidth', 1);
title('Original vnote Spectrum');
xlim([0, 5000]);

subplot(2,1,2);
bar(f, Vee4_mag, 'BarWidth', 1);
title('Vee4 Spectrum');
xlim([0, 5000]);

fprintf('\nSaving Vee4.mat...\n');
save('Vee4.mat', 'Vee4');
fprintf('Done!\n');

fprintf('\n=== FINAL COMPARISON ===\n');
fprintf('Vee4 sounds similar to vnote but:\n');
fprintf('- Harmonic structure is "cleaner" (only exact harmonics)\n');
fprintf('- No inharmonicity or noise present\n');
fprintf('- Decay envelope is exponential (smoother than original)\n');
fprintf('- Original piano note has more complex attack/decay shape\n');
