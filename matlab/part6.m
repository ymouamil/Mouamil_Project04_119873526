%% part6.m
% ENEE322/ENEE323 Project - Part (vi)
% Replace highest harmonic cluster with single entry

clear; close all; clc;

% Load Vsave1 from part3
if ~exist('Vsave1.mat', 'file')
    error('Run part3.m first to generate Vsave1.mat');
end
load('Vsave1.mat');

% Load original
[vnote, fs] = audioread('note.wav');
N = length(vnote);

fprintf('\n=== Part (vi) ===\n');

% Determine K1 from user (same as part4)
K1 = input('Enter K1 (fundamental frequency index from part1): ');
Khalf = floor(K1/2);

% Find nonzero (nontrivial) harmonics in Vsave1
nonzero_indices = find(abs(Vsave1) > 0);
harmonic_indices = nonzero_indices(mod(nonzero_indices - 1, K1) == 0);
harmonic_indices = harmonic_indices(harmonic_indices <= length(Vsave1));

% Exclude DC (index 1)
harmonic_indices = harmonic_indices(harmonic_indices > 1);

num_harmonics = length(harmonic_indices);
fprintf('Number of nontrivial harmonics in Vsave1: %d\n', num_harmonics);

if num_harmonics > 0
    highest_harmonic_idx = harmonic_indices(end);
    fprintf('Highest harmonic index: %d\n', highest_harmonic_idx);
    
    % Create Vedit as copy of Vsave1
    Vedit = Vsave1;
    
    % Find cluster around highest harmonic
    start_idx = max(1, highest_harmonic_idx - Khalf);
    end_idx = min(length(Vedit), highest_harmonic_idx + Khalf);
    
    % Compute norm of the cluster
    cluster_norm = norm(Vedit(start_idx:end_idx));
    cluster_phase = angle(Vedit(highest_harmonic_idx));
    
    % Replace cluster with single entry
    Vedit(start_idx:end_idx) = 0;
    Vedit(highest_harmonic_idx) = cluster_norm * exp(1i * cluster_phase);
    
    % Reconstruct signal
    Vnew_full = [Vedit; 0; conj(flipud(Vedit(2:end)))];
    Vee3 = ifft(Vnew_full, 'symmetric');
    
    % Apply taper
    taper = [ones(N/2,1); (0.5 + 0.5*cos(linspace(0,1,N/2)*pi)).'];
    Vee3_taper = Vee3 .* taper;
    
    % Playback
    fprintf('Playing Vee1 (original thresholded, att=60dB)...\n');
    if exist('Vee1.mat', 'file')
        load('Vee1.mat');
        soundsc(Vee1, fs);
    else
        fprintf('Vee1.mat not found, run part3 first.\n');
    end
    pause(4);
    
    fprintf('Playing Vee3 (highest harmonic cluster replaced)...\n');
    soundsc(Vee3_taper, fs);
    
    % Plot
    figure(6);
    subplot(2,1,1);
    plot(abs(Vsave1));
    title('Vsave1 Spectrum (att=60dB)');
    xlabel('Frequency index');
    ylabel('Magnitude');
    
    subplot(2,1,2);
    plot(abs(Vedit));
    title('Vee3 Spectrum (highest harmonic replaced)');
    xlabel('Frequency index');
    ylabel('Magnitude');
    
    save('Vee3.mat', 'Vee3');
    fprintf('Saved Vee3.mat\n');
    
    fprintf('\nDifference: Subtle - highest harmonic is less "rich".\n');
    fprintf('May sound slightly thinner but still recognizable.\n');
else
    fprintf('No harmonics found in Vsave1.\n');
end
