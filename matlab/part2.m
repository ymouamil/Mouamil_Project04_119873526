%% part2.m
% ENEE322/ENEE323 Project - Part (ii)
% Plot magnitude in dB, find dB_max

clear; close all; clc;

% Load the audio file
[vnote, fs] = audioread('note.wav');
N = length(vnote);

% Compute DFT
V = fft(vnote);
Vleft = V(1:N/2);

% Convert to dB (relative to 1)
% Using 20*log10 for magnitude (not power)
Vabs = abs(Vleft);
Vabs(Vabs == 0) = eps;  % Avoid log(0)
VdB = 20 * log10(Vabs);

% Find maximum dB value
dB_max = max(VdB);
fprintf('\n=== Part (ii) ===\n');
fprintf('Maximum dB value (dB_max) = %.2f dB\n', dB_max);
fprintf('(This occurs at the fundamental harmonic)\n');

% Plot dB magnitude
f = fs * (0:N/2-1) / N;
figure(2);
plot(f, VdB);
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Magnitude Spectrum in dB');
xlim([0, 5000]);
grid on;

% Mark dB_max
hold on;
[max_idx, max_pos] = max(VdB);
plot(f(max_pos), max_idx, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
legend('Spectrum', sprintf('dB_{max} = %.2f dB', dB_max));
