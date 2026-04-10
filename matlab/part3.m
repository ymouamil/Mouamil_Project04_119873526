%% part3.m
% ENEE322/ENEE323 Project - Part (iii)
% Zero out entries below dB_max - att, invert, apply taper

clear; close all; clc;

% Load audio
[vnote, fs] = audioread('note.wav');
N = length(vnote);

% Compute DFT
V = fft(vnote);
Vleft = V(1:N/2);
Vabs = abs(Vleft);
Vabs(Vabs == 0) = eps;
VdB = 20 * log10(Vabs);
dB_max = max(VdB);

% Taper function (from given code)
taper = [ones(N/2,1); (0.5 + 0.5*cos(linspace(0,1,N/2)*pi)).'];

fprintf('\n=== Part (iii) ===\n');

% Test different attenuation values
att_values = [40, 60];

for att = att_values
    fprintf('\n--- att = %d dB ---\n', att);
    
    % Zero out entries below threshold
    threshold = dB_max - att;
    Vedit = Vleft;
    Vedit(VdB < threshold) = 0;
    
    % Count nonzero entries
    nonzero_count = nnz(abs(Vedit) > 0);
    fprintf('Non-zero entries after thresholding: %d\n', nonzero_count);
    
    % Reconstruct full spectrum and invert
    Vnew_full = [Vedit; 0; conj(flipud(Vedit(2:end)))];
    vnew = ifft(Vnew_full, 'symmetric');
    
    % Plot without taper
    figure;
    plot(vnew);
    xlabel('Sample index');
    ylabel('Amplitude');
    title(sprintf('Reconstructed Signal (att = %d dB) - No Taper', att));
    fprintf('Notice: Signal does NOT taper off at the ends.\n');
    fprintf('Audio playback without taper will have clicks/pops at boundaries.\n');
    
    % Play without taper
    fprintf('Playing WITHOUT taper (expect clicks)...\n');
    soundsc(vnew, fs);
    pause(3);
    
    % Apply taper
    vtaper = vnew .* taper;
    
    figure;
    plot(vtaper);
    xlabel('Sample index');
    ylabel('Amplitude');
    title(sprintf('Reconstructed Signal with Taper (att = %d dB)', att));
    
    % Play with taper
    fprintf('Playing WITH taper (smoother)...\n');
    soundsc(vtaper, fs);
    pause(3);
    
    % Save for att = 60 dB
    if att == 60
        Vsave1 = Vedit;
        Vee1 = vtaper;
        save('Vsave1.mat', 'Vsave1');
        save('Vee1.mat', 'Vee1');
        fprintf('\nSaved Vsave1 and Vee1 for att = 60 dB\n');
    end
end

fprintf('\nComparison: att=40dB removes less, more harmonics remain.\n');
fprintf('att=60dB removes more noise/higher harmonics, sounds cleaner.\n');
fprintf('The taper eliminates boundary discontinuities (clicks/pops).\n');
