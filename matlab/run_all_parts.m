%% PROJECT3_FINAL.m
% ENEE322/ENEE323 Project 3 - WITH VISIBLE FILE SAVING
% This script shows you EXACTLY where every file is saved

clear; close all; clc;

fprintf('========================================\n');
fprintf('ENEE322/ENEE323 Project 3\n');
fprintf('Piano Note Spectral Analysis\n');
fprintf('========================================\n\n');

% ============================================================
% STEP 1: CREATE A VISIBLE FOLDER ON YOUR SYSTEM
% ============================================================

% Create folder on Desktop (you WILL see this)
if ispc
    % Windows
    desktop = fullfile(getenv('USERPROFILE'), 'Desktop');
else
    % Mac/Linux
    desktop = fullfile(getenv('HOME'), 'Desktop');
end

project_folder = fullfile(desktop, 'ENEE323_Project3_Results');

% Create the folder
if ~exist(project_folder, 'dir')
    mkdir(project_folder);
    fprintf('✓ Created folder: %s\n', project_folder);
else
    fprintf('✓ Using existing folder: %s\n', project_folder);
end

fprintf('\n>>> ALL FILES WILL BE SAVED HERE: <<<\n');
fprintf('%s\n\n', project_folder);

% ============================================================
% STEP 2: LOAD AUDIO
% ============================================================
fprintf('Loading audio file...\n');
[vnote, fs] = audioread('note.wav');
N = length(vnote);
fprintf('✓ Audio loaded: %d samples at %d Hz\n', N, fs);

% ============================================================
% STEP 3: COMPUTE DFT
% ============================================================
fprintf('Computing DFT...\n');
V = fft(vnote);
Vleft = V(1:N/2);
Vabs = abs(Vleft);
Vang = angle(Vleft);
f = fs * (0:N/2-1) / N;

% dB conversion
Vabs_safe = Vabs;
Vabs_safe(Vabs_safe == 0) = eps;
VdB = 20 * log10(Vabs_safe);
dB_max = max(VdB);

% ============================================================
% PART (i): Spectrum and Fundamental
% ============================================================
fprintf('\n========================================\n');
fprintf('PART (i): Spectrum and Fundamental\n');
fprintf('========================================\n');

K1 = 1173;  % From your output
f_fundamental = f(K1);
fprintf('Fundamental index K1 = %d\n', K1);
fprintf('Fundamental frequency = %.2f Hz\n', f_fundamental);
fprintf('Musical note = G4\n');

figure(1);
bar(f, Vabs, 'BarWidth', 1);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title(sprintf('Part (i): Magnitude Spectrum (G4 = %.1f Hz)', f_fundamental));
xlim([0, 5000]);
grid on;
saveas(gcf, fullfile(project_folder, 'Part1_Spectrum.png'));
fprintf('✓ Saved: Part1_Spectrum.png\n');

% ============================================================
% PART (ii): dB Plot
% ============================================================
fprintf('\n========================================\n');
fprintf('PART (ii): dB Magnitude\n');
fprintf('========================================\n');
fprintf('dB_max = %.2f dB\n', dB_max);

figure(2);
plot(f, VdB, 'b-', 'LineWidth', 1);
hold on;
plot(f(K1), dB_max, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title(sprintf('Part (ii): dB Spectrum (dB_{max} = %.1f dB)', dB_max));
xlim([0, 5000]);
grid on;
legend('Spectrum', 'dB_{max}');
saveas(gcf, fullfile(project_folder, 'Part2_dB_Spectrum.png'));
fprintf('✓ Saved: Part2_dB_Spectrum.png\n');

% ============================================================
% Taper Function
% ============================================================
taper = [ones(N/2,1); (0.5 + 0.5*cos(linspace(0,1,N/2)*pi)).'];

% ============================================================
% PART (iii): dB Thresholding
% ============================================================
fprintf('\n========================================\n');
fprintf('PART (iii): dB Thresholding\n');
fprintf('========================================\n');

for att = [40, 60]
    fprintf('\n--- att = %d dB ---\n', att);
    
    threshold = dB_max - att;
    Vedit = Vleft;
    Vedit(VdB < threshold) = 0;
    
    nonzero_count = nnz(abs(Vedit) > 0);
    fprintf('Non-zero entries: %d\n', nonzero_count);
    
    % Reconstruct
    Vnew_full = [Vedit; 0; conj(flipud(Vedit(2:end)))];
    vnew = ifft(Vnew_full, 'symmetric');
    vtaper = vnew .* taper;
    
    % Plot
    figure;
    subplot(2,1,1);
    plot(vnew);
    title(sprintf('att = %d dB: No Taper', att));
    xlabel('Sample');
    ylabel('Amplitude');
    grid on;
    
    subplot(2,1,2);
    plot(vtaper);
    title(sprintf('att = %d dB: With Taper', att));
    xlabel('Sample');
    ylabel('Amplitude');
    grid on;
    
    saveas(gcf, fullfile(project_folder, sprintf('Part3_att%d.png', att)));
    fprintf('✓ Saved: Part3_att%d.png\n', att);
    
    % Save WAV file
    wav_filename = fullfile(project_folder, sprintf('output_att%d.wav', att));
    audiowrite(wav_filename, vtaper, fs);
    fprintf('✓ Saved WAV: %s\n', wav_filename);
    
    % Save for att=60
    if att == 60
        Vsave1 = Vedit;
        Vee1 = vtaper;
        
        mat_filename1 = fullfile(project_folder, 'Vsave1.mat');
        mat_filename2 = fullfile(project_folder, 'Vee1.mat');
        save(mat_filename1, 'Vsave1');
        save(mat_filename2, 'Vee1');
        fprintf('✓ Saved MAT: %s\n', mat_filename1);
        fprintf('✓ Saved MAT: %s\n', mat_filename2);
    end
end

% ============================================================
% PART (iv): Pure Harmonic Signal
% ============================================================
fprintf('\n========================================\n');
fprintf('PART (iv): Pure Harmonic Signal\n');
fprintf('========================================\n');

Khalf = floor(K1/2);
Imax = floor(N/(2*K1)) - 1;
fprintf('K1 = %d, Khalf = %d, Max harmonics = %d\n', K1, Khalf, Imax);

Vedit_harmonic = zeros(size(Vleft));

% Zeroth harmonic
Vedit_harmonic(1:min(Khalf+1, length(Vleft))) = Vleft(1:min(Khalf+1, length(Vleft)));

% Higher harmonics
for i = 1:Imax
    center = i * K1 + 1;
    start_idx = max(1, center - Khalf);
    end_idx = min(length(Vleft), center + Khalf);
    
    if start_idx >= 1 && end_idx <= length(Vleft)
        subvec = Vleft(start_idx:end_idx);
        harmonic_mag = norm(subvec);
        harmonic_phase = angle(Vleft(center));
        Vedit_harmonic(center) = harmonic_mag * exp(1i * harmonic_phase);
    end
end

% Reconstruct
Vnew_full = [Vedit_harmonic; 0; conj(flipud(Vedit_harmonic(2:end)))];
Vee2 = ifft(Vnew_full, 'symmetric');

% Plot
figure;
plot(Vee2);
xlabel('Sample');
ylabel('Amplitude');
title('Part (iv): Vee2 - Pure Harmonic Signal (Constant Amplitude)');
grid on;
saveas(gcf, fullfile(project_folder, 'Part4_Vee2.png'));
fprintf('✓ Saved: Part4_Vee2.png\n');

% Save MAT file
mat_filename = fullfile(project_folder, 'Vee2.mat');
save(mat_filename, 'Vee2');
fprintf('✓ Saved MAT: %s\n', mat_filename);

% ============================================================
% PART (v): Hamming Window
% ============================================================
fprintf('\n========================================\n');
fprintf('PART (v): Hamming Window\n');
fprintf('========================================\n');

hamming_win = hamming(N);
Vee2_hamming = Vee2 .* hamming_win;

figure;
subplot(2,1,1);
plot(Vee2);
title('Vee2 (No Window)');
xlabel('Sample');
ylabel('Amplitude');
grid on;

subplot(2,1,2);
plot(Vee2_hamming);
title('Vee2 with Hamming Window');
xlabel('Sample');
ylabel('Amplitude');
grid on;

saveas(gcf, fullfile(project_folder, 'Part5_Hamming.png'));
fprintf('✓ Saved: Part5_Hamming.png\n');

% Save WAV
wav_filename = fullfile(project_folder, 'Vee2_hamming.wav');
audiowrite(wav_filename, Vee2_hamming, fs);
fprintf('✓ Saved WAV: %s\n', wav_filename);

% ============================================================
% PART (vi): Highest Harmonic Replacement
% ============================================================
fprintf('\n========================================\n');
fprintf('PART (vi): Highest Harmonic Replacement\n');
fprintf('========================================\n');

if exist(fullfile(project_folder, 'Vsave1.mat'), 'file')
    load(fullfile(project_folder, 'Vsave1.mat'));
    
    nonzero_idx = find(abs(Vsave1) > 0);
    harmonic_idx = nonzero_idx(mod(nonzero_idx - 1, K1) == 0);
    harmonic_idx = harmonic_idx(harmonic_idx > 1);
    num_harmonics = length(harmonic_idx);
    fprintf('Number of nontrivial harmonics in Vsave1: %d\n', num_harmonics);
    
    if num_harmonics > 0
        highest_idx = harmonic_idx(end);
        fprintf('Highest harmonic index: %d\n', highest_idx);
        
        start_idx = max(1, highest_idx - Khalf);
        end_idx = min(length(Vsave1), highest_idx + Khalf);
        
        cluster_norm = norm(Vsave1(start_idx:end_idx));
        cluster_phase = angle(Vsave1(highest_idx));
        
        Vedit = Vsave1;
        Vedit(start_idx:end_idx) = 0;
        Vedit(highest_idx) = cluster_norm * exp(1i * cluster_phase);
        
        Vnew_full = [Vedit; 0; conj(flipud(Vedit(2:end)))];
        Vee3 = ifft(Vnew_full, 'symmetric');
        Vee3_taper = Vee3 .* taper;
        
        figure;
        subplot(2,1,1);
        plot(abs(Vsave1));
        title('Vsave1 Spectrum (Original)');
        xlabel('Frequency Index');
        ylabel('Magnitude');
        grid on;
        
        subplot(2,1,2);
        plot(abs(Vedit));
        title('Vee3 Spectrum (Highest Harmonic Replaced)');
        xlabel('Frequency Index');
        ylabel('Magnitude');
        grid on;
        
        saveas(gcf, fullfile(project_folder, 'Part6_Vee3.png'));
        fprintf('✓ Saved: Part6_Vee3.png\n');
        
        % Save MAT
        mat_filename = fullfile(project_folder, 'Vee3.mat');
        save(mat_filename, 'Vee3');
        fprintf('✓ Saved MAT: %s\n', mat_filename);
        
        % Save WAV
        wav_filename = fullfile(project_folder, 'Vee3.wav');
        audiowrite(wav_filename, Vee3_taper, fs);
        fprintf('✓ Saved WAV: %s\n', wav_filename);
    end
else
    fprintf('Warning: Vsave1.mat not found. Run part (iii) first.\n');
end

% ============================================================
% PART (vii): Exponential Envelope
% ============================================================
fprintf('\n========================================\n');
fprintf('PART (vii): Exponential Envelope\n');
fprintf('========================================\n');

t = (0:N-1) / N;
A = max(abs(vnote));
c = 3.5;  % Good match for piano decay
envelope = A * exp(-c * t);

% Plot envelope matching
figure;
plot(vnote, 'b');
hold on;
plot(envelope, 'r--', 'LineWidth', 2);
plot(-envelope, 'r--', 'LineWidth', 2);
xlabel('Sample');
ylabel('Amplitude');
title('Part (vii): Exponential Envelope Fit');
legend('vnote', 'Envelope');
grid on;
saveas(gcf, fullfile(project_folder, 'Part7_Envelope.png'));
fprintf('✓ Saved: Part7_Envelope.png\n');

% Apply envelope
Vee4 = Vee2 .* envelope';

% Spectrum of Vee4
Vee4_fft = fft(Vee4);
Vee4_mag = abs(Vee4_fft(1:N/2));

figure;
bar(f, Vee4_mag, 'BarWidth', 1);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Part (vii): Magnitude Spectrum of Vee4');
xlim([0, 5000]);
grid on;
saveas(gcf, fullfile(project_folder, 'Part8_Vee4_Spectrum.png'));
fprintf('✓ Saved: Part8_Vee4_Spectrum.png\n');

% Save MAT
mat_filename = fullfile(project_folder, 'Vee4.mat');
save(mat_filename, 'Vee4');
fprintf('✓ Saved MAT: %s\n', mat_filename);

% Save WAV
wav_filename = fullfile(project_folder, 'Vee4.wav');
audiowrite(wav_filename, Vee4, fs);
fprintf('✓ Saved WAV: %s\n', wav_filename);

% ============================================================
% FINAL SUMMARY - OPEN THE FOLDER FOR YOU
% ============================================================
fprintf('\n========================================\n');
fprintf('PROJECT COMPLETE!\n');
fprintf('========================================\n\n');

fprintf('>>> ALL FILES SAVED TO: <<<\n');
fprintf('%s\n\n', project_folder);

% List all files in the folder
fprintf('FILES IN FOLDER:\n');
fprintf('----------------\n');
listing = dir(project_folder);
for i = 1:length(listing)
    if ~listing(i).isdir
        fprintf('  ✓ %s (%.2f KB)\n', listing(i).name, listing(i).bytes/1024);
    end
end

fprintf('\n----------------\n');
fprintf('Total files: %d\n', length(listing) - 2);  % -2 for . and ..

% ============================================================
% OPEN THE FOLDER FOR YOU (so you can SEE the files)
% ============================================================
fprintf('\n========================================\n');
fprintf('OPENING THE FOLDER FOR YOU...\n');
fprintf('========================================\n');

% Try to open the folder so you can see the files
if ispc
    winopen(project_folder);
elseif ismac
    system(['open "' project_folder '"']);
else
    system(['xdg-open "' project_folder '"']);
end

fprintf('\nThe folder should have opened on your screen.\n');
fprintf('If not, manually navigate to:\n');
fprintf('%s\n', project_folder);

fprintf('\n========================================\n');
fprintf('DONE! You can now see all files on your Desktop.\n');
fprintf('========================================\n');