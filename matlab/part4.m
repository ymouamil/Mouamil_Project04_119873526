%% part4.m
% ENEE322/ENEE323 Project - Part (iv)
% Generate signal consisting purely of harmonics

clear; close all; clc;

% Load audio
[vnote, fs] = audioread('note.wav');
N = length(vnote);

% Compute DFT
V = fft(vnote);
Vleft = V(1:N/2);
Vabs = abs(Vleft);
Vang = angle(Vleft);

% --- YOU MUST SET THESE VALUES BASED ON YOUR SPECTRUM ---
% These are EXAMPLE values - replace with your actual K1 and Khalf
% K1 = fundamental frequency index (e.g., round(261.63 * N / fs))
% Khalf = floor(K1/2)  (half the fundamental index)

% Example for C4 (261.63 Hz) at fs=44100, N around 100000:
% K1 = round(261.63 * N / 44100)
% Khalf = floor(K1/2)

fprintf('\n=== Part (iv) ===\n');
fprintf('WARNING: You must set K1 and Khalf manually!\n');
fprintf('Look at the spectrum from part1 to find K1.\n\n');

% PROMPT USER FOR K1
K1 = input('Enter K1 (fundamental frequency index from part1): ');
Khalf = floor(K1/2);
fprintf('Using K1 = %d, Khalf = %d\n', K1, Khalf);

% Number of harmonics possible
Imax = floor(N/(2*K1)) - 1;
fprintf('Maximum possible harmonics: %d\n', Imax);

% Initialize Vedit with zeros
Vedit = zeros(size(Vleft));

% Handle zeroth harmonic (indices 0 to Khalf)
Vedit(1:Khalf+1) = Vleft(1:Khalf+1);

% Process each harmonic i = 1, 2, ...
for i = 1:Imax
    center_idx = i * K1 + 1;  % +1 for MATLAB 1-indexing
    start_idx = center_idx - Khalf;
    end_idx = center_idx + Khalf;
    
    % Check bounds
    if start_idx < 1 || end_idx > length(Vleft)
        break;
    end
    
    % Get subvector around harmonic
    subvec = Vleft(start_idx:end_idx);
    
    % Norm (modulus) of the subvector
    harmonic_mag = norm(subvec);
    
    % Phase from the peak (center) entry
    harmonic_phase = angle(Vleft(center_idx));
    
    % Set the harmonic entry
    Vedit(center_idx) = harmonic_mag * exp(1i * harmonic_phase);
end

% Reconstruct full spectrum and invert
Vnew_full = [Vedit; 0; conj(flipud(Vedit(2:end)))];
Vee2 = ifft(Vnew_full, 'symmetric');

% Verify amplitude is essentially constant
figure(4);
plot(Vee2);
xlabel('Sample index');
ylabel('Amplitude');
title('Pure Harmonic Signal Vee2');
grid on;

fprintf('\nNotice: Amplitude is essentially constant (no decay envelope).\n');
fprintf('This is because we removed the amplitude envelope from original.\n');

% Save
save('Vee2.mat', 'Vee2');
fprintf('Saved Vee2.mat\n');
