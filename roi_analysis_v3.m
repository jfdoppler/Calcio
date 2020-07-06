clc
clear all
close all
%%
% Primero, carga datos: lista de rois (rois.mat)
% La variable folder debe contener el path del repositorio
folder = 'C:\Users\Juan\Desktop\Calcio\';
cd(folder)
load rois_v3.mat 
%% Carga el video 
v = VideoReader('journal.pbio.1002158.s006.MP4');
% Guardamos los timestamps del video
t_video = zeros(1, 625);
video = zeros(v.height, v.width, 625, 'uint8');
i = 1;
while hasFrame(v)
    t_video(i) = v.CurrentTime;
    video(:, :, i) = rgb2gray(v.readFrame);
    i = i+1;
end
% Separamos el audio
[sound, Fs] = audioread('journal.pbio.1002158.s006.MP4');
% Y lo guardamos en un wav
audiowrite('journal.pbio.1002158.s006.wav', sound, Fs);
t_audio = (1/Fs)*(0:1:size(sound, 1)-1);
% Defino tiempos para determinacion de F0
frame_begin = 14; % Hasta frame 13, el video esta completamente en negro
frame_F0 = 40; % Hasta frame 40, ninguna ROI se prende
% Definimos coordenadas de referencia
hvc_x_center = 199;
hvc_y_center = 207;
%% Comienza el analisis de las ROI
% a partir de la info guardada en roi_list (2 vertices que definen el
% rectangulo), toma para cada frame Fl (senal de fluorescencia)
% roi_list(1,2): define ancho en "x" de la matriz "video"
% roi_list(3,4): define alto en "y" de la matriz "video"
% NOTA: en el inspector de video, x e y estan intercambiados. "x" es altura
% mientras que "y" es ancho
% Hay ROIs superpuestas?

%% Calculo fluorescencia
Fl = zeros(size(video, 3), size(roi_list, 2));
F00 = zeros(size(video, 3), size(roi_list, 2));
dist_to_center = zeros(1, size(roi_list, 2));
% Si queremos hacer un video con las rois marcadas
make_vid = 0;
video_rois = video;
for k = 1:size(roi_list, 2)
    idx_y = roi_list(1, k):roi_list(2, k);
    y_center = mean(idx_y);
    idx_x = roi_list(3, k):roi_list(4, k);
    x_center = mean(idx_x);
    dist_to_center(k) = sqrt((x_center-hvc_x_center)^2 + (y_center-hvc_y_center)^2);
    for i = 1:size(video, 3)
        Fl(i, k) = mean2(video(idx_y, idx_x, i));
        F00(i, k) = mean2(video(idx_y, idx_x, max(i-8,1):min(i+8,size(video,3))));
    end
    if make_vid
       video_rois(idx_y(1), idx_x, :) = 0;
       video_rois(idx_y(end), idx_x, :) = 0;
       video_rois(idx_y, idx_x(1), :) = 0;
       video_rois(idx_y, idx_x(end), :) = 0;
    end
end

deltaF = Fl./F00;
deltaF(1:13, :) = NaN; % saco las primeras 13 frames
% Con esto, ploteo DeltaF/F0
for k = 1:size(Fl, 2)
    plot(deltaF(:, k)+(k-1));
    hold on
end
