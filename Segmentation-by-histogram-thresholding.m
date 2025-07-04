clear; clc; close all;

% Paso 1: Cargamos el DICOM
folderPath = 'DU01_knee_06mm/';
dicomFiles = dir(fullfile(folderPath, '*.dcm')); % Buscar todos los archivos .dcm
numSlices = length(dicomFiles); % Obtenemos el numero de cortes

% Creamos un arreglo "3D" para almacenar las imágenes DICOM
volume = zeros(512, 512, numSlices, 'uint16'); % 512 x 512, profundidad 16

% Cargamos cada corte
for i = 1:numSlices
    filePath = fullfile(folderPath, dicomFiles(i).name);
    dicomInfo = dicomread(filePath); % Leer el archivo DICOM
    volume(:, :, i) = dicomInfo; % Almacenamos
end

% Mostramos todo el corte original antes del procesamiento
figure;
for j = 1:numSlices
    imshow(volume(:,:,j), []);
    %Graficamos el volumen, todas las filas, todas las columnas, numero de
    %corte, todos los valores de profundidad
    title('Corte original antes del procesamiento');
end
%%

% Formato estandar (entre 0 y 1) Binarizar
Volume = mat2gray(volume);

threshold = 0.445; % Aplicamos un umbral para aislar los valores correspondientes al hueso
boneMask = Volume > threshold; % Máscara binaria para el tejido óseo

% Mostramos un corte antes y después de aplicar la máscara
figure;
subplot(1, 2, 1);
imshow(volume(:, :, round(numSlices/2)), []);  % Histograma de un corte central
title('Antes de aplicar la máscara');
subplot(1, 2, 2);
imshow(boneMask(:, :, round(numSlices/2)), []);
title('Después de aplicar la máscara');

%%
% Definir transformación afín

%Factores de escala en x,y,z
sx = 1; %No
sy = 1; %No
sz = 2.5;
matriz = [sx 0 0 0; 0 sy 0 0; 0 0 sz 0; 0 0 0 1];
tform = affinetform3d(matriz);

% Definir intensidades, alphas y colores
intensity = [0 20 40 120 220 1024]; % Definimos los valores de intensidad de los píxeles en el volumen
alpha = [0 0 0.15 0.3 0.38 0.5]; % Definimos los valores de opacidad asociada a cada valor de intensidad: 0 transparente, 1 opaco
color = [0 0 0; 43 0 0; 103 37 20; 199 155 97; 216 213 201; 255 255 255]/255; % /255 para que sean 1 o 0

% Hay 256 puntos equidistantes entre el mínimo y máximo de intensity usando linspace
queryPoints = linspace(min(intensity), max(intensity), 256);

% Interpolacion lineas para calcular valores de opacidad y color
alphamap = interp1(intensity, alpha, queryPoints)';
colormap = interp1(intensity, color, queryPoints);

% Mostrar histogramas antes y después del procesamiento
figure;
subplot(1, 2, 1);
imhist(volume(:, :, round(numSlices/2)), 256);
title('Histograma antes del procesamiento');
xlabel('Intensidad de píxeles');
ylabel('Frecuencia');
xlim([-0 7e4]); % Limite para ver bien el inicio y final de las graficas

% Histograma del volumen procesado (después del procesamiento)
subplot(1, 2, 2);
imhist(uint8(boneMask(:, :, round(numSlices/2)) * 255), 256); % Convertir máscara binaria a uint8 para visualización
title('Histograma después del procesamiento');
xlabel('Intensidad de píxeles');
ylabel('Frecuencia');
xlim([0 260]); % Limite para ver bien el inicio y final de las graficas

% Mostramos todo el corte original antes del procesamiento
figure;
for j = 1:numSlices
    imshow(boneMask(:,:,j), []);
    %Graficamos el volumen, todas las filas, todas las columnas, numero de
    %corte, todos los valores de profundidad
    title('Corte con Mascara');
end


%% Utilizamos el comando volshow para visualizar el volumen 3D del tejido óseo.
volshow(boneMask, Colormap=colormap, Alphamap=alphamap, Transformation=tform);
%title('Reconstrucción 3D del tejido óseo');

%% Densidades
% Definir intensidades, alphas y colores
intensity = [0 50 100 200 400 1024];
alpha = [0 0.1 0.3 0.6 0.8 1]; % Ajusta la transparencia

%        Negro      Azul        Cafe          Naranja      C.piel   negro
color = [0 0 0; 0.2 0.2 0.6; 0.6 0.3 0.1; 0.9 0.6 0.2; 0.95 0.9 0.8; 1 1 1];

queryPoints = linspace(min(intensity), max(intensity), 256);
alphamap = interp1(intensity, alpha, queryPoints)';
colormap = interp1(intensity, color, queryPoints);

densidades = boneMask .* Volume;

% Mostramos todo el corte original antes del procesamiento
figure;
for j = 1:numSlices
    imshow(densidades(:,:,j), []);
    %Graficamos el volumen, todas las filas, todas las columnas, numero de
    %corte, todos los valores de profundidad
    title('Corte Dicom x Mascara');
end

% volshow(Volume, Colormap=colormap, Alphamap=alphamap, Transformation=tform);
volshow(densidades, Colormap=colormap, Alphamap=alphamap, Transformation=tform);

%%
volshow(Volume, Colormap=colormap, Alphamap=alphamap, Transformation=tform);
