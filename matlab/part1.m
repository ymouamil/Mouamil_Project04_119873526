%% part1.m
% ENEE322/ENEE323 Project - Part (i)
% Compute DFT, plot magnitude spectrum, find fundamental frequency

clear; close all; clc;

% Load the audio file
[vnote, fs] = audioread('note.wav');
N = length(vnote);

% Play original sound
fprintf('Playing original note...\n');
soundsc(vnote, fs);
pause(3);

% Compute DFT
V = fft(vnote);
Vleft = V(1:N/2);  % First N/2 entries (positive frequencies)

% Frequency axis (actual frequencies)
f = fs * (0:N/2-1) / N;

% Plot magnitude spectrum
figure(1);
bar(f, abs(Vleft), 'BarWidth', 1);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Magnitude Spectrum of Piano Note');
xlim([0, 5000]);  % Zoom in to see harmonics
grid on;

% Manual zoom instructions
fprintf('\n=== Part (i) ===\n');
fprintf('Zoom in on the figure to identify regularly spaced peaks.\n');
fprintf('Look for the fundamental frequency (lowest peak).\n');
pause;

% Find peaks automatically (for guidance)
[pks, locs] = findpeaks(abs(Vleft), 'MinPeakHeight', max(abs(Vleft))/10, ...
                         'MinPeakDistance', 50);
f_peaks = f(locs);
fprintf('\nDetected peaks at frequencies (Hz):\n');
fprintf('%.2f\n', f_peaks);

% User should identify K1 from manual zoom
% K1 = floor(fundamental_freq * N / fs);  % Uncomment with actual value

fprintf('\nMANUAL STEP: Identify the fundamental frequency by zooming.\n');
fprintf('Record the frequency index as K1.\n');
fprintf('Example: If fundamental is 261.63 Hz (C4), then K1 = round(261.63 * N / fs)\n');
