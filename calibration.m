close all
% clear
clc
% VER FORMATO DEL FILE .TF Y IMPORTAR DIRECTAMENTE ESO EN VEZ DE EXCEL
% VER MEJOR TRANSFORMACION DE COUNTS A VOLTS PARA GRAFICO FINAL
%
%% Import filters as array
% crear filtros y almacenar en vector de coeff nums
load myFilters;
% Excitation frequencies for TF extrapolation
F = [5 6 8 10 12.5 16 20 25 32 40 50 64 80 100 128 160 175 200 230]; % kHz
% freq_filt_array = [F' myFilters];
% Load Transfer Function 
[page,~,~]=xlsread('C:/Users/Camila/Desktop/Alex/Untref/Bioacústica/Matlab programas/función de transferencia.xls',1); % Hidrófono Cethus
freq = page(:,5); %kHz
freq = freq(1:128);
sens = page(:,6); %dB re uPa(rms)^2/counts^2
sens = sens(1:128);
TF = interp1(freq,sens,F,'linear','extrap'); %interpolar linealmente y despues pasar a dB?????
%% Separar chunks %%%%%%%%%%%%%%%%%%
%
path = {'hidro 1/', ...
        'hidro 2/', ...
        'hidro 3/'};
sprintf('Hidrophone 1: Cethus (reference)\nHidrophone 2: Naty\nHidrophone 3: Nico')
for h = 3 %1: length(path);
    files = dir([path{h} '*.wav']);
    fprintf('Hidrófono %d\n', h);
    for index = 1 : length(files);
        fprintf('File %d/%d\n Importing %s\n', index, length(files), files(index).name);
        freq_in = input('Enter Frequency in kHz: '); % kHz
        % Error check
        while ~any(F==freq_in);
            freq_in = input('Wrong frequency, try again\nEnter Frequency in kHz: '); % kHz
        end
        % Remove faulty detections noted during recording 
        if h==1;
            if freq_in==8;
                sprintf('Primera detección incorrecta, eliminar')
            elseif freq_in==128;
                sprintf('Golpe en la mesa, chequear cual detección eliminar')
            end
        elseif (h==2 && freq_in==2) || (h==3 && freq_in==160);
                sprintf('Ojota!!!\n')              
        end
        files(index).frequency = freq_in*10^3; % Hz
        to = 1; 
        s_row = [];
        e_row = [];
        chunk_start = 0;
        chunk_end = 0;
        files(index).detections = [];
        det_index = [0 0];
        Ai = audioinfo([path{h} files(index).name]);
        Fs = Ai.SampleRate;
        % Fragmento de 10 segundos de archivo WAV
        [th_def,~]= audioread([path{h} files(index).name],[1 10*Fs],'native'); 
        th_def = double(th_def);
        th_def_filt = filter(myFilters(F==freq_in),th_def);
        th_def_filt = th_def_filt - mean(th_def_filt); % Remove DC
        th_def_env = abs(hilbert(th_def_filt)); % smooth?
        f_1 = figure(1);
        clf
        set(f_1,'WindowStyle','docked')
        plot (th_def_env)
        sprintf('Enter 0 to skip file')
        th = input('Define Threshold (counts) porfis:  '); % 0 to skip file
        if th == 0;
            continue
        end
        hold on;
        plot([1 length(th_def_filt)],[th th], '--r', 'linewidth', 2)
        % Confirm choice from plot
        confirm = input('Confirm Threshold (Y/N): ','s');
        if confirm == 'N';
            th = input('Define Threshold (counts) porfis:  ');
            hold on;
            plot([1 length(th_def_filt)],[th th], '--g', 'linewidth', 2)
        end
        clear th_def th_def_env th_def_filt
        % Open 1 second segments  
        while to <= Ai.TotalSamples;
           if to <= Ai.TotalSamples-Fs;
               % Read 1 second at a time from WAV file
               [xx,Fs]= audioread([path{h} files(index).name],[to to+Fs-1],'native');  
           else
               % Read until end of file
               [xx,Fs]= audioread([path{h} files(index).name],[to Ai.TotalSamples],'native');
           end
           % Start Detection
           xx = double(xx);
           xx = xx - mean(xx); % Remove DC
           xx_filt = filter(myFilters(F==freq_in),xx);
           xx_env = abs(hilbert(xx_filt)); % smooth?
           tt = (to:to+length(xx)-1)'/Fs; % Vector temporal
%            % Plot check
%            f_2 = figure(2); % coment estooooo
%            set(f_2,'WindowStyle','docked');
%            plot(xx_filt, 'k')
%            hold on;
%            plot(xx_env, 'b') % plot(tt, xx, 'k', tt, xx_env, 'b')
%            hold on;
           % Find Peaks (s: start ; e: end)
           s_row = find(xx_env(1000:end-1000) > th, 1); % skip first 100 samples with artifacts of smooth
           if isempty(s_row)
               to = to + length(xx_filt)+1;
               continue
           end
           chunk_start = s_row + 999; % index correction for smooth
           if chunk_start <= 2000;
                    chunk_end = Fs - 1; 
                    if chunk_end >= length(xx_filt)
                      chunk_end = length(xx_filt)-1;  
                    end
                    det_index(end,2) = to + chunk_end;
%                     plot(chunk_end, xx_filt(chunk_end), '*g', 'markersize', 10) % coment este y eel de abajo!!!
%                     hold off;
                    to = to + chunk_end + 1;
                    continue
%                end
           else 
%                plot(chunk_start, xx_filt(chunk_start), '*r', 'markersize', 10) % coment este y eel de abajo!!!
%                hold off;
               to = to + chunk_start; % Redefine window
               det_index(end+1,1) = to;
           end   
        end
        files(index).detections = det_index(2:end,:);
        % Gráficos
        [check,~]= audioread([path{h} files(index).name]);
        check = filter(myFilters(F==freq_in),check);
        figure(3)
        clf
        hp = plot(check);
        hold on;
        for i = 1:length(files(index).detections);
            plot(files(index).detections(i,1),max(check),'*r', 'markersize', 10);
            plot(files(index).detections(i,2),max(check),'*g', 'markersize', 10);
        end
        set(hp,'linewidth',1)
        set(gca,'fontsize',12)
        xlabel('Time [samples]')
        ylabel('Amplitude')
        title(['Frequency: ' num2str(files(index).frequency)]);
        axis tight
        clear check
    end
%     clearvars -except files h path myFilters;
    %% Take around 10 cycles
%     NFFT = 512;
    i=0;
    j=0;
    for i = 14:length(files)
        for j = 1 : length(files(i).detections)
            [file, fs] = audioread([path{h} files(i).name],[files(i).detections(j,1) files(i).detections(j,2)],'native');
            xx = double(file);
            xx = xx - mean(xx); % Remove DC
            xx_filt = filter(myFilters(F==files(i).frequency*1e-3),xx);
            xx_env = abs(hilbert(xx_filt));
            [~ , pos] = max(xx_env(500:2500)); % empirical limit (1:2500)
            chunk_end = pos+499 + (2e-3)*fs; % 2 ms theoretical free-echo time
            if i == 1;
               chunk_start = chunk_end - (7*1/files(i).frequency)*fs; % Count 7 cicles backwards (for 5 kHz 10 cylces is still in transient) 
            else
               chunk_start = chunk_end - (10*1/files(i).frequency)*fs; % Count 10 cicles backwards
            end
            chunk = xx_filt(chunk_start:chunk_end); 
            tt = (0:length(xx_filt)-1)'/fs; % Vector temporal
            figure
            plot(tt(1:chunk_end*2), xx_filt(1:chunk_end*2), 'k')
            hold on;
            plot(tt(chunk_start:chunk_end), chunk, 'r', 'linewidth', 2)
            plot(tt(pos), xx_filt(pos), '*r', 'markersize', 5)
            plot(tt(chunk_end), xx_filt(chunk_end), '*g', 'markersize', 5);
            title(['frequency: ' num2str(files(i).frequency) ' chunk n° ' num2str(j)])
            pause;
            close
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% VER !! probando sin FFT primero
%             if h == 1;
% %                 TODO: VER SI IMPORTAR DIRECTO ARCHIVO '.TF' !!!!!!!!!!!!!!!!!!!!!!!!!!
%                 % Load Transfer Function 
%                 [FT,~,~]=xlsread('función de transferencia.xls',2); % Hidrófono Cethus
%                 FT = FT(:,6); %dB re uPa(rms)^2/counts^2
%                 window = hanning(length(chunk));
%             %       Using Fft to avoid (/Hz) and allow reconstruction 
%             %         [Pxx,F] = pwelch(signal,window,[],512,fs); %counts(rms)^2/Hz
%             %         Pxx = 10*log10(Pxx);
%             %         chunk_cal = Pxx + FT; %[dB re uPa^2/Hz]
%                 chunk_freq = 2*abs(fft(chunk.*window,NFFT)./NFFT);
%                 chunk_freq = chunk_freq(1:NFFT/2);
%                 chunk_freqdB = 10*log10(chunk_freq) + FT; % counts(rms)^2
%                 chunk_frec_cal = 10.^(chunk_fre_db/10); 
%                 chunk_cal = ifft(chunk_freq_cal);
%             end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            chunks_rms(j) = rms(chunk);
        end
        % Calculte single RMS for each frequency [counts]
        if h == 1;
            Vref(i) = mean(chunks_rms); 
        elseif h == 2;
            Vnaty(F==files(i).frequency*1e-3) = mean(chunks_rms); % Not all files are in order according to excitation frequency
        else
            Vnico(F==files(i).frequency*1e-3) = mean(chunks_rms); % Not all files are in order according to excitation frequency
        end
        %chunks_rms = [];
    end
%     clear files % Necesitamos: Vref, Vnico, Vnaty
end
%% Gain %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Gain_ref = 27.2; %dB in A/D step (Avisoft USG-611)
Gain_naty = [27.2 27.2 27.2 27.2 27.2 27.2 14.8 14.8 14.8 14.8 27.2 27.2 27.2 27.2 27.2 27.2 27.2 27.2 27.2];
Gain_nico = [27.2 27.2 27.2 27.2 27.2 27.2 27.2 27.2 27.2 14.8 27.2 27.2 27.2 27.2 27.2 14.8 14.8 27.2 27.2];
%% SPL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SPL_ref = 20*log10(Vref) - Gain_ref + TF; % [dB re µPa]
%% Sensitivity Unknown Hydrophone %%%%%%
Sens_naty = 20*log10(Vnaty) - Gain_naty - SPL_ref; % [dB re counts/µPa]
Sens_nico = 20*log10(Vnico) - Gain_nico - SPL_ref; % [dB re counts/µPa]
%% Counts ---> Volts
Sens_naty_volts = Sens_naty + 20*log10(1/33580); % [db re V/µPa]
Sens_nico_volts = Sens_nico + 20*log10(1/33580); % [db re V/µPa]
%% Save file in TF format for Triton
dlmwrite('Cadic_transfer_function.tf', Sens_naty, ' ');
dlmwrite('NICO_Cethus_transfer_function.tf', Sens_nico, ' ');
%% Plot Frequency vs Sensitivity
f_axis = F*1e3;
figure()
loglog(f_axis, Sens_naty, 'LineWidth', 2);
figure()
loglog(f_axis, Sens_nico, 'LineWidth', 2)
xlabel('Frequency [Hz]')
ylabel('Sensitivity [dB re counts/µPa]')
title('Hydrophone Sensitivity');
legend('Hidrófono Naty', 'Hidrófono Nico')
grid on;
ax=gca;
ax.XTick=F*1e3;
ax.XTickLabel = {F};
ax.XLim = [F(1)*1e3 F(end)*1e3];
ax.YLim = [-130 -38];
