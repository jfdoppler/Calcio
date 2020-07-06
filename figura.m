%% Con este script hacemos las figuras
% Antes de correrlo hay que correr roi_analysis_v3.m

%% Marcamos las ROIs
figure('pos',[10 50 1800 900]);
% obtengo el color order
colores=get(gca,'ColorOrder');
while(size(colores,1)<size(Fl,2))
    colores=repmat(colores,[2 1]);
end
% Empiezo a plotear
h(1)=subplot(1, 1, 1);
[~, orden] = sort(dist_to_center, 'descend');
I = insertText(video(:,:,215),[0 0],0,'AnchorPoint','LeftBottom');
for k=1:size(roi_list,2)
    index = orden(k);
    x_loc=roi_list(3,index);
    y_loc=roi_list(1,index);
    posicion=[x_loc y_loc];
    if k ==24
        I = insertText(I,posicion,k,'AnchorPoint','LeftTop','FontSize',8,'BoxColor',colores(index,:), 'BoxOpacity',0.1);
    end
end
imshow(I);
% Marcamos el "centro"
radio = 2;
rectangle('Position',[hvc_x_center-radio, hvc_y_center-radio, 2*radio, 2*radio],'Curvature',[1 1],'EdgeColor', 'none', 'FaceColor','red');
% Marcamos cada roi
for k=1:size(roi_list,2)
    index = orden(k);
    x_loc=roi_list(3,index);
    y_loc=roi_list(1,index);
    x_width=roi_list(4,index)-x_loc;
    y_width=roi_list(2,index)-y_loc;
    posicion=[x_loc,y_loc,x_width,y_width];
    rectangle('Position',posicion,'EdgeColor',colores(index,:),'FaceColor','none');
    % Marcamos la linea que lo conecta al centro
    line([hvc_x_center, x_loc],[hvc_y_center, y_loc], 'color', colores(index,:))
end
xlim([80 310]);
ylim([90 270]);

%% Una figura todo junto (rois, canto, deltaF)
figure('pos',[10 50 1800 900]);
% obtengo el colorOrder
colores=get(gca,'ColorOrder');
while(size(colores,1)<size(Fl,2))
    colores=repmat(colores,[2 1]);
end
% Empiezo a plotear
h(1)=subplot(3,5,[1:2,6:7,11:12]);
[sorted, orden] = sort(dist_to_center, 'descend');
I = insertText(video(:,:,215),[0 0],0,'AnchorPoint','LeftBottom');
for k=1:size(roi_list,2)
    index = orden(k);
    x_loc=roi_list(3,index);
    y_loc=roi_list(1,index);
    posicion=[x_loc y_loc];
    I = insertText(I,posicion,k,'AnchorPoint','LeftTop','FontSize',8,'BoxColor',colores(index,:), 'BoxOpacity',0.1);
end
imshow(I);
radio = 2;
rectangle('Position',[hvc_x_center-radio, hvc_y_center-radio, 2*radio, 2*radio],'Curvature',[1 1],'EdgeColor', 'none', 'FaceColor','red');

for k=1:size(roi_list,2)
    index = orden(k);
    x_loc=roi_list(3,index);
    y_loc=roi_list(1,index);
    x_width=roi_list(4,index)-x_loc;
    y_width=roi_list(2,index)-y_loc;
    posicion=[x_loc,y_loc,x_width,y_width];
    rectangle('Position',posicion,'EdgeColor',colores(index,:),'FaceColor','none');
    line([hvc_x_center, x_loc],[hvc_y_center, y_loc], 'color', colores(index,:))
end
xlim([80 310]);
ylim([90 270]);

% ploteo las cosas!
h(2)=subplot(3,5,3:5);
[~,F,T,P]=spectrogram(sound,gausswin((15E-3)*Fs,2),...
    round(0.97*(10E-3)*Fs),2^nextpow2((10E-3)*Fs),...
    Fs,'yaxis');
imagesc(T,F/1000,10*log10(P/20));
ylabel('Frequency (kHz)');
set(gca,'YDir','normal');

h(3)=subplot(3,5,[8:10,13:15]);
for k=1:size(roi_list,2)
    index = orden(k);
    plot(t_video,deltaF(:,index)+k,'color',colores(index,:))
    hold on
end
ylabel('$\Delta$ F / F0 (mas cercanos arriba)','Interpreter','Latex');
xlabel('time (s)');

% propiedades al final
linkaxes(h(2:3),'x');
colormap(h(2),jet);
set(h(2),'YLim',[0 8]);
set(h(2:3),'XLim',[3 24]);
set(h(3),'YLim',[20 35]);
%% Interpolo deltaF
rate = 1/30;
t_video_samp = 0:rate:max(t_video);
deltaF_samp = zeros(size(t_video_samp, 2), size(roi_list, 2));
for index=1:size(roi_list, 2)
    x = t_video;
    y = deltaF(:,index);
    deltaF_samp(:, index) = interp1(x, y, t_video_samp,'linear');
end
%% SEGMENTO el canto
% 8.999877	motivs	A	9.487377
% 9.487377	motivs	B	10.309472
% 11.029284	motivs	A	11.518437
% 11.518437	motivs	B	12.203516
% 12.203516	motivs	B	12.945014
% 13.761069	motivs	A	14.282935
% 14.282935	motivs	B	14.951895
% 16.099488	motivs	A	16.638238
% 16.638238	motivs	B	17.291078
% 18.617748	motivs	A	19.234855
time_start = [8.999877, 11.029284, 13.761069, 16.099488, 18.617748];
time_end = [10.309472, 12.945014, 14.951895, 17.291078, 19.234855];
dt = max(time_end-time_start);
figure('pos',[10 50 800 800]);

for n_mot=1:size(time_start, 2)
    [~, n_start] = min(abs(t_audio-(time_start(n_mot)-0.15)));
    [~, n_end] = min(abs(t_audio-(time_end(n_mot)+0.05)));
    signal = sound(n_start:n_end);
    t_signal = t_audio(n_start:n_end);
    [~,F_s,T_s,P_s]=spectrogram(signal,gausswin((10E-3)*Fs,2),...
        round(0.97*(10E-3)*Fs),2^nextpow2((10E-3)*Fs),...
        Fs,'yaxis');
    h(n_mot)=subplot(size(time_start, 2), 1, n_mot);
    imagesc(T_s,F_s/1000,10*log10(P_s/20));
    set(gca,'YDir','normal');
    set(h(n_mot),'YLim',[0 8]);
    colormap(h(n_mot), jet);
end
linkaxes(h,'x');
set(h(1),'XLim',[0 dt+0.2]);

%% Grafico 1 motivo y el calcio para cada ROI en cada repeticion
% close all
% 8.999877	motivs	A	9.487377
% 9.487377	motivs	B	10.309472
% 11.029284	motivs	A	11.518437
% 11.518437	motivs	B	12.203516
% 12.203516	motivs	B	12.945014
% 13.761069	motivs	A	14.282935
% 14.282935	motivs	B	14.951895
% 16.099488	motivs	A	16.638238
% 16.638238	motivs	B	17.291078
% 18.617748	motivs	A	19.234855
time_start = [8.999877, 11.029284, 13.761069, 16.099488, 18.617748];
time_end = [10.309472, 12.945014, 14.951895, 17.291078, 19.234855];
n_mot = 4;
[~,F_s,T_s,P_s]=spectrogram(sound,gausswin((10E-3)*Fs,2),...
    round(0.97*(10E-3)*Fs),2^nextpow2((10E-3)*Fs),...
    Fs,'yaxis');
figure('pos',[10 50 300 1000]);
h(1)=subplot(5, 1, 1);
imagesc(T_s,F_s/1000,10*log10(P_s/20));
set(gca,'YDir','normal');
set(h(1),'YLim',[0 8]);
colormap(h(1), jet);
h(2)=subplot(5, 1, 2:5);
n_fig = 2;
for n_ca=(n_fig-1)*15+1:min(n_fig*15, size(roi_list,2))
    for n_m=1:4
        [~, n_start] = min(abs(t_video-(time_start(n_m)-0.15)));
        [~, n_end] = min(abs(t_video-(time_end(n_m)+0.05)));
        signal = deltaF(n_start:n_end, orden(n_ca));
        t_signal = t_video(n_start:n_end)-time_start(n_m)+time_start(n_mot);
        index = orden(n_ca);
        plot(t_signal,signal+n_ca,'-','color',colores(index,:),'MarkerFaceColor',colores(index,:), 'MarkerSize', 2)
        hold on
    end
end
linkaxes(h,'x');
set(h(1),'XLim',[time_start(n_mot)-0.15 time_end(n_mot)+0.05]);
%% Grafico 1 motivo y el calcio PROMEDIO para cada ROI en cada repeticion
% Ojo con los motivos con distinta cantidad de repeticiones
% close all
% 8.999877	motivs	A	9.487377
% 9.487377	motivs	B	10.309472
% 11.029284	motivs	A	11.518437
% 11.518437	motivs	B	12.203516
% 12.203516	motivs	B	12.945014
% 13.761069	motivs	A	14.282935
% 14.282935	motivs	B	14.951895
% 16.099488	motivs	A	16.638238
% 16.638238	motivs	B	17.291078
% 18.617748	motivs	A	19.234855
time_start = [8.999877, 11.029284, 13.761069, 16.099488, 18.617748];
time_end = [10.309472, 12.945014, 14.951895, 17.291078, 19.234855];
n_mot = 4;
[~,F_s,T_s,P_s]=spectrogram(sound,gausswin((10E-3)*Fs,2),...
    round(0.97*(10E-3)*Fs),2^nextpow2((10E-3)*Fs),...
    Fs,'yaxis');
figure('pos',[10 50 300 1000]);
h(1)=subplot(5, 1, 1);
imagesc(T_s,F_s/1000,10*log10(P_s/20));
set(gca,'YDir','normal');
set(h(1),'YLim',[0 8]);
colormap(h(1), jet);
dt = max(time_end-time_start);
h(2)=subplot(5, 1, 2:5);
n_fig = 2;
for n_ca=(n_fig-1)*15+1:min(n_fig*15, size(roi_list,2))
    neurona = zeros(ceil(max(time_end-time_start)/rate), 5);
    [~, n_start] = min(abs(t_video_samp-(time_start(n_mot)-0.15)));
    [~, n_end] = min(abs(t_video_samp-(time_end(n_mot)+0.05)));
    t_signal = t_video_samp(n_start:n_end);
    for n_m=1:5
        [~, n_start] = min(abs(t_video_samp-(time_start(n_m)-0.15)));
        [~, n_end] = min(abs(t_video_samp-(time_end(n_m)+0.05)));
        neurona(1:n_end-n_start+1, n_m) = deltaF_samp(n_start:n_end, orden(n_ca));
    end
    promedio = sum(neurona,2) ./ sum(neurona~=0,2);
    neurona(neurona==0)=NaN;
    index = orden(n_ca);
    x = t_signal';
    y = promedio(1:length(x))+n_ca;
    plot(x,y,'color',colores(index,:),'MarkerFaceColor',colores(index,:), 'MarkerSize', 2)
%     s = nanstd(neurona,[],2);
%     ff = fill([x;flipud(x)],[y-s;flipud(y+s)],[.9 .9 .9],'linestyle','none');
%     set(ff,'facealpha',.9)
    hold on
end
linkaxes(h,'x');
set(h(1),'XLim',[time_start(n_mot)-0.15 time_end(n_mot)+0.05]);
%% Heatmap deltaF
norm = deltaF;
n_trazas = size(Fl, 2);
max_index = zeros(n_trazas, 1);
% Elijo un motivo
n_mot = 4;
[~, n_start] = min(abs(t_video-(time_start(n_mot)-0.15)));
[~, n_end] = min(abs(t_video-(time_end(n_mot)+0.05)));
for k=1:n_trazas
    index = k;
    % Para normalizar seria con estas dos lineas:
    %norm(:,index) = deltaF(:,index)-min(deltaF(n_start:n_end,index));
    %norm(:,index) = norm(:,index)/max(norm(n_start:n_end,index));
    % Sin normalizar:
    norm(:,index) = deltaF(:,index);
    [~, max_index(k)] = max(norm(n_start:n_end, index));
end
norm_ordered = deltaF;
% Las ordeno segun tiempo del maximo
[~, orden_oc] = sort(max_index);
[X, Y] = meshgrid(t_video', 1:n_trazas);
figure('pos',[10 50 500 800]);
h(1)=subplot(10, 1, 1:2);
[~,F,T,P]=spectrogram(sound,gausswin((15E-3)*Fs,2),...
    round(0.97*(10E-3)*Fs),2^nextpow2((10E-3)*Fs),...
    Fs,'yaxis');
imagesc(T,F/1000,10*log10(P/20));
for k=1:n_trazas
    index = orden_oc(k);
    norm_ordered(:,k) = norm(:,index);
    x = X(1, max_index(k)+n_start);
    %line([x x],get(h(1),'YLim'));
end
ylabel('Frequency (kHz)');
set(gca,'YDir','normal');
colormap(h(1), jet);
h(2)=subplot(10, 1, 3:10);

s = surf(X, Y, norm_ordered');
s.EdgeColor = 'none';
set(gca,'YDir','reverse');
set(h(2),'YLim',[1 n_trazas]);
set(gca,'YTick',1:34)
set(gca,'YTickLabel',orden_oc)
view(2);
colorbar('southoutside')
lim = caxis;
%caxis([0 1]);
linkaxes(h,'x');
colormap(h(2), hot);
set(h(1),'XLim',[time_start(n_mot)-0.15 time_end(n_mot)+0.05]);
suptitle(['Motivo ' num2str(n_mot)]);
%% Heatmap deltaF
norm = deltaF;
n_trazas = size(Fl, 2);
max_index = zeros(n_trazas, 1);
n_mot = 4;
[~, n_start] = min(abs(t_video-(time_start(n_mot)-0.15)));
[~, n_end] = min(abs(t_video-(time_end(n_mot)+0.05)));
for k=1:n_trazas
    index = k;
    norm(:,index) = deltaF(:,index);
    [~, max_index(k)] = max(norm(n_start:n_end, index));
    norm(max_index(k)+n_start,index) = max(max(deltaF));
end
norm_ordered = deltaF;
[~, orden_oc] = sort(max_index);
[X, Y] = meshgrid(t_video', 1:n_trazas);
figure('pos',[10 50 500 800]);
h(1)=subplot(10, 1, 1:2);
[~,F,T,P]=spectrogram(sound,gausswin((15E-3)*Fs,2),...
    round(0.97*(10E-3)*Fs),2^nextpow2((10E-3)*Fs),...
    Fs,'yaxis');
imagesc(T,F/1000,10*log10(P/20));
for k=1:n_trazas
    index = orden_oc(k);
    norm_ordered(:,k) = norm(:,index);
    x1 = X(1, max_index(k)+n_start);
    x2 = X(1, max_index(k)+n_start+1);
    x = x1:0.001:x2;
    y1 = (x-x)/(x2-x1)*10;
    y2 = ((x-x)/(x2-x1)+1)*12;
    % Para graficar una linea en el espectro para cada maximo:
    %line([(x1+x2)/2 (x1+x2)/2],get(h(1),'YLim'));
    % Para sombrear en el espectro para cada maximo (dt):
    p = patch([x fliplr(x)], [y1 fliplr(y2)], 'b');
    set(p, 'facealpha', 0.3);
    set(p, 'edgealpha', 0.);
end
ylabel('Frequency (kHz)');
set(gca,'YDir','normal');
colormap(h(1), jet);
h(2)=subplot(10, 1, 3:10);

s = surf(X, Y, norm_ordered');
s.EdgeColor = 'none';
set(gca,'YDir','reverse');
set(h(2),'YLim',[1 n_trazas]);
set(gca,'YTick',1:34)
set(gca,'YTickLabel',orden_oc)
view(2);
colorbar('southoutside')
lim = caxis;
%caxis([0 1]);
linkaxes(h,'x');
colormap(h(2), hot);
set(h(1),'XLim',[time_start(n_mot)-0.15 time_end(n_mot)+0.05]);
suptitle(['Motivo ' num2str(n_mot)]);