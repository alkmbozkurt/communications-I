fs = 44100;
time = 0:1/fs:4095/fs;

SNR = [-20 -10 0 10 20 30 40 inf]; % Different SNR values

[message1, fs1] = audioread("LabTh_J_fs_44100Hz_messagenumber_1.wav");
[message2, fs2] = audioread("LabTh_J_fs_44100Hz_messagenumber_2.wav");
[message3, fs3] = audioread("LabTh_J_fs_44100Hz_messagenumber_3.wav");
[message4, fs4] = audioread("LabTh_J_fs_44100Hz_messagenumber_4.wav");
[message5, fs5] = audioread("LabTh_J_fs_44100Hz_messagenumber_5.wav");
[message6, fs6] = audioread("LabTh_J_fs_44100Hz_messagenumber_6.wav");
[message7, fs7] = audioread("LabTh_J_fs_44100Hz_messagenumber_7.wav");
[message8, fs8] = audioread("LabTh_J_fs_44100Hz_messagenumber_8.wav");
[message9, fs9] = audioread("LabTh_J_fs_44100Hz_messagenumber_9.wav");
[message10, fs10] = audioread("LabTh_J_fs_44100Hz_messagenumber_10.wav");
[message11, fs11] = audioread("LabTh_J_fs_44100Hz_messagenumber_11.wav");
[message12, fs12] = audioread("LabTh_J_fs_44100Hz_messagenumber_12.wav");
messages = {message1,message2,message3,message4,message5,message6,message7,message8,message9,message10,message11,message12};

fs_s = [fs1,fs2,fs3,fs4,fs5,fs6,fs7,fs8,fs9,fs10,fs11,fs12];

number_samples = 4096;
data_len = 4096;
data = zeros([number_samples data_len]);

fc = 10e3; %10kHz;
label = ones([number_samples 1]);
label = label*4;

for sample_idx = 1:number_samples
    index = randi([1 12],1);
    % index = 6;
    message = messages{index};
    sample_idx
    fs = fs_s(index);
   
    
    %CFO
    sigma = 0.01;  %variance for CFO
    X = randn(1);
    Y = sigma * X;
 

    delta_f_carrier = Y; %Carrier frequency offs    et ~N(0,sigma)

    fc_cfo_added = fc + delta_f_carrier;

    time = (0:length(message)-1)' / fs;
    carrier = cos(2*pi*(fc_cfo_added)*time); %carrier signal,


    segment_start = randi([1, length(message) - data_len]);  % Start of segment
    segment_end = segment_start + data_len-1;       % Random length between 5k and 50k samples
    segment = message(segment_start:segment_end);
    new_carrier = carrier(segment_start:segment_end);


    delta_f = 1000;

    %label:
    %0: DSB SC
    %1: DSB WC
    %2: SSB SC
    %3: SSB WC
    %4  FM

    signal = dsb_sc_generator(segment,new_carrier);
    % signal = dsb_wc_generator(segment,new_carrier);
    % signal = ssb_sc_generator(segment,fc_cfo_added,fs);
    % signal = ssb_wc_generator(segment,new_carrier,fc_cfo_added,fs);
    %signal = fm_generator(segment,delta_f,fc_cfo_added,fs);
   
    
    snr_index = randi([1,length(SNR)],1);
    noisy_signal = awgn(signal,SNR(snr_index), 'measured');



    % time = time(segment_start:segment_end);
    % %Frequency Domain
    % subplot(2,1,1);
    % L = length(noisy_signal);
    % f=linspace(-fs/2,fs/2,L);
    % Y=fftshift(fft(noisy_signal,L)/L);
    % plot(f, abs(Y));
    % xlim([-15e3 15e3]);
    % title("Frequency Domain")
    % xlabel("Frequency (Hz)")
    % title("Frequency Domain")
    % %Time Domain    
    % subplot(2,1,2)
    % plot(time,noisy_signal)
    % xlim([min(time) max(time)])
    % title("Time Domain")
    % % Save the noisy signal to a .mat file
    % 
end
filename = sprintf('FM_16K_DATA_deneme.mat'); % Create filename
save(filename, 'data' ,'fs',"label");
data(sample_idx,:) = noisy_signal;
Y = fft(data(1,:));
plot(44100/4096*(0:4096-1),abs(Y),"LineWidth",3)
title("Complex Magnitude of fft Spectrum")
xlabel("f (Hz)")
ylabel("|fft(X)|")


function [dsb_sc] = dsb_sc_generator(message,carrier)
        dsb_sc = message.*carrier;
end

function [dsb_wc] = dsb_wc_generator(message,carrier)
        dsb_wc = (1+message).*carrier;
end

function [ssb_sc] = ssb_sc_generator(message,fc,fs)
        
        ssb_sc = ssbmod(message,fc,fs);
end

function [ssb_wc] = ssb_wc_generator(message,carrier,fc,fs)
        c = ssbmod(message,fc,fs);
        ssb_wc = c+carrier;
end

function [fm] = fm_generator(message, delta_f,fc,fs)
        
        fm = fmmod(message,fc,fs,delta_f);
end

function [linear_fm] = linear_fm_generator(kf)
        linear_fm = cos(2*pi*fc*time + pi*kf*time.*time);
end

