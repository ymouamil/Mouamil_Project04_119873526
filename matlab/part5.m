%% part5.m
% ENEE322/ENEE323 Project - Part (v)
% Play Vee2 with Hamming window, compare to original

clear; close all; clc;

% Load Vee2 from part4
if ~exist('Vee2.mat', 'file')
    error('Run part4.m first to generate Vee2.mat');
end
load('Vee2.mat');

% Load original for comparison
[vnote, fs] = audioread('note.wav');

fprintf('\n=== Part (v) ===\n');

% Apply Hamming window
N = length(Vee2);
hamming_win = hamming(N);
Vee2_hamming = Vee2 .* hamming_win;

% Play original
fprintf('Playing ORIGINAL note...\n');
soundsc(vnote, fs);
pause(4);

% Play pure harmonic WITHOUT window
fprintf('Playing PURE HARMONIC (no window)...\n');
fprintf('Notice: Abrupt start/end causes clicks\n');
soundsc(Vee2, fs);
pause(4);

% Play pure harmonic WITH Hamming window
fprintf('Playing PURE HARMONIC with HAMMING window...\n');
fprintf('Notice: Smoother attack/decay, but still no natural envelope\n');
soundsc(Vee2_hamming, fs);
pause(4);

% Plot comparison
figure(5);
subplot(3,1,1);
plot(vnote);
title('Original vnote');
xlim([0 N]);

subplot(3,1,2);
plot(Vee2);
title('Vee2 (pure harmonic, no window)');
xlim([0 N]);

subplot(3,1,3);
plot(Vee2_hamming);
title('Vee2 with Hamming window');
xlim([0 N]);

fprintf('\nDifference: Hamming window smooths the boundaries.\n');
fprintf('Loudness profile aside, the harmonic content sounds similar,\n');
fprintf('but original has natural decay while pure harmonic sustains.\n');
