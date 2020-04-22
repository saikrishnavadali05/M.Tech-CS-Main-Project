function handle_out = imshow3D( I, varargin )
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % USE THIS FUNCTION JUST LIKE IMSHOW:
 %
 % EXAMPLES: I = peaks(); figure, imshow3D(I,'shape','sphere','colmap',hot(256));
 %
 % 1) Specify a shape with x,y,z coordinates: 
 %
 %    % Plot a cone
 %    r = (1:1000)';
 %    I = imresize(peaks(),[1000 1000]);
 %    nres = size(I,2);
 %    x = repmat(r,[1 nres]).*repmat(sin(linspace(0,2*pi,nres)),[numel(r) 1]);
 %    y = repmat(r,[1 nres]).*repmat(cos(linspace(0,2*pi,nres)),[numel(r) 1]);
 %    z = repmat((1:numel(r))',[1 nres]);
 %    figure, imshow3D(I,'shape',{x y z},'colmap',winter(256))
 %
 %    % Plot a parallepiped:
 %    I = imresize(peaks(),[100 100]);
 %    r = ones(size(I,1),1);
 %    nres = size(I,2);
 %    t_aux = repmat(r,[1 nres/4]).*repmat(linspace(-1,1,nres/4),[numel(r) 1]);
 %    x = [repmat(r,[1 nres/4]), t_aux(:,end:-1:1), repmat(-r,[1 nres/4]) t_aux];
 %    y = [t_aux, repmat(r,[1 nres/4]), t_aux(:,end:-1:1), repmat(-r,[1 nres/4])];
 %    z = repmat((1:numel(r))',[1 nres]);
 %    figure, imshow3D(I,'shape',{x y z},'colmap',winter(256))
 %
 %    % Plot a zig-zag shape:
 %    I = imresize(peaks(),[100 100]);
 %    r = ones(size(I,1),1);    
 %    nres = size(I,2);
 %    x = [repmat(r,[1 nres/2]) zeros(numel(r),nres/2)];
 %    y = [repmat(r,[1 nres/4]) zeros(numel(r),nres/4) repmat(r,[1 nres/4]) zeros(numel(r),nres/4)];
 %    z = repmat((1:numel(r))',[1 nres]);
 %    figure, imshow3D(I,'shape',{x y z},'colmap',winter(256))
 %
 %    % Plot a spiral
 %    nres = 100;
 %    I = imresize(peaks(),[nres nres]);
 %    r = repmat(linspace(1,10,nres),[size(I,1) 1]);
 %    x = repmat(sin(linspace(0,2*pi,nres)),[size(r,1) 1]).*r;
 %    y = repmat(cos(linspace(0,2*pi,nres)),[size(r,1) 1]).*r;
 %    z = repmat((1:size(r,1))',[1 nres]);
 %    figure, imshow3D(I,'shape',{x y z},'colmap',hot(256))
 %
 %    % Plot a heart
 %    nres = 100;
 %    I = imresize(peaks(),[nres nres]);
 %    r = repmat([linspace(1,10,nres/2), linspace(10,1,nres/2)],[size(I,1) 1]);
 %    x = repmat(sin(linspace(0,2*pi,nres)),[size(r,1) 1]).*r;
 %    y = repmat(cos(linspace(0,2*pi,nres)),[size(r,1) 1]).*r;
 %    z = repmat((1:size(r,1))',[1 nres]);
 %    figure, imshow3D(I,'shape',{x y z},'colmap',hot(256))
 %
 %    % Plot a flower
 %    npetals = 6; % Number of petals
 %    r = repmat(2 - sin(linspace(0,2*npetals*pi,nres)), [size(I,1) 1]);
 %    x = repmat(sin(linspace(0,2*pi,nres)),[size(r,1) 1]).*r;
 %    y = repmat(cos(linspace(0,2*pi,nres)),[size(r,1) 1]).*r;
 %    z = repmat((1:size(r,1))',[1 nres]);
 %    figure, imshow3D(I,'shape',{x y z},'colmap',winter(256))
 %
 %
 % 2) Specify a shape only with a single line:
 % 
 %   % Plot a cone
 %   r = (1:1000)';
 %   figure, imshow3D(I,'shape',r,'colmap',winter(256))
 %
 %   % Plot a Gaussian with mu=0 and sigma=2 using normpdf
 %   I = imresize(peaks(),[1000 1000]);
 %   r = normpdf(linspace(-10,10,size(I,1)),0,2)'; 
 %   figure, imshow3D(I,'shape',r,'colmap',winter(256))
 %
 %   % Plot a Chi-Square distribution using pdf:
 %   I = imresize(peaks(),[1000 1000]);
 %   r = pdf('Chisquare',linspace(0,20,size(I,1)),4);
 %   figure, imshow3D(I,'shape',r,'colmap',winter(256))
 %
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Author: Manuel Blanco Valentin
 % Industrial Engineer & Project Analyst
 % e-mail: mbvalentin@cbpf.br
 %
 % Centro Brasileiro de Pesquisas (CBPF) - CENPES - PETROBRAS
 % Rio de Janeiro - Brazil - 2015
 %
 % LICENSE: This code is open-source, feel freely to use it under your own
 % responsability. Feel free to share this code, but please, do not delete
 % this comments.
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin > 1
    ExtraOptions = {'colmap', 'shape', 'ZTicks','Axes'};
    ExtraOptionsValues = cell(size(ExtraOptions));

    for i = 1:length(varargin)
        try
            pos = strcmp(varargin{i},ExtraOptions);
            if nnz(pos(:)) > 0
                ExtraOptionsValues{find(pos)} = varargin{i+1};
            end
        end
        
    end
    
    Colmap = ExtraOptionsValues{1}; % Colormap
    Shape = ExtraOptionsValues{2}; % Shape
    ZAxis = ExtraOptionsValues{3}; %Z Ticks
    Axes = ExtraOptionsValues{4};
else
    Colmap = gray;
    Shape = 'cylinder';
    ZAxis = [];
    Axes = gca;
end

if isempty(Shape), Shape = 'cylinder'; end;
if isempty(Colmap), Colmap = gray; end;
if isempty(Axes), Axes = gca; end;

% Let's get the image size
[M,N,K] = size(I);

% Create the figure
% f = figure;
% ax = subplot(1,1,1);

% According to the user's selected shape
if ischar(Shape)
    switch char(Shape)
        case 'cylinder'
            cylinder(Axes);
        case 'sphere'
            sphere(Axes);
        otherwise
            error('Only valid shapes are cylinder and sphere. If you wish you can also input the x,y and z coordinates of your shape.');
    end
else
    if iscell(Shape)
        if numel(Shape) == 3
            x = Shape{1};
            y = Shape{2};
            z = Shape{3};
            surf(Axes,x,y,z);
        else
            error('Please, if you want to wish to use your own shape specify it as a cell containing a 3 row vector (x, y and z) coordinates OR as a single vector representing a line (type "doc imshow3D" in MATLAB command prompt for extra info).');
        end
    else
        if isvector(Shape)
            nres = size(I,2);
            
            % In case Shape and I have different sizes, interpolate Shape
            if numel(Shape) ~= nres
                r = interp1((1:numel(Shape)),Shape,linspace(1,numel(Shape),nres));
            else
                r = Shape;
            end
            
            % Final check, just to make sure that r is a COLUMN vector
            if size(r,1) < size(r,2)
                r = r';
            end
            
            x = repmat(r,[1 nres]).*repmat(sin(linspace(0,2*pi,nres)),[numel(r) 1]);
            y = repmat(r,[1 nres]).*repmat(cos(linspace(0,2*pi,nres)),[numel(r) 1]);
            z = repmat((1:numel(r))',[1 nres]);
            
            surf(Axes,x,y,z);
            
        else
            r = Shape;
            nres = size(r,2);
            x = r.*repmat(sin(linspace(0,2*pi,nres)),[size(r,1) 1]);
            y = r.*repmat(cos(linspace(0,2*pi,nres)),[size(r,1) 1]);
            z = repmat((1:size(r,1))',[1 nres]);
            
            surf(Axes,x,y,z);
            
        end
    end
end

% Now let's put the data in
%handle_out = findobj('Type','surface');
%handle_out = handle_out(1);
handle_out = get(Axes,'Children');
set(handle_out,'CData',I,'FaceColor','texturemap',...
    'EdgeColor','none','LineStyle','none');

% And the colormap
if ischar(Colmap) || iscell(Colmap)
    Colmap = eval(Colmap);
    colormap(gca, Colmap);
else
    colormap(gca, Colmap);
end

% Let's fix the aspect of the figure (only if shape is a cylinder)
if ischar(Shape)
    if strcmp(Shape,'cylinder')
        daspect(10.*[M/min([M N]) M/min([M N]) N/min([M N])]);
    end
end

% And change the ticks and tick labels (totally optional)
set(gca, 'XTick',[-1 1], 'XTickLabel', {'N'; 'S'}) 
set(gca, 'YTick',[-1 1], 'YTickLabel', {'E'; 'W'})
set(gca, 'ZDir','reverse')

% K = max(round(M/(5*N)),1);
% %K = 100;
% set(gca,'XLim',[-K K])
% set(gca,'YLim',[-K K])

if ~isempty(ZAxis)
    %zticklabels = cellstr(num2str(ZAxis(round(linspace(1,M, 10))),'%5.4f'));
    set(Axes, 'ZTick',ZAxis{1}./M,... % ZAxis go actually from 0 to 1, not from 1 to M
        'ZTickLabel',ZAxis{2},'zcolor','k');
else
    set(Axes,'ztick',[],'zticklabel',[],'zcolor','none');
end

set(Axes,'box','off','xcolor','none','ycolor','none','xtick',[],'ytick',[]);
set(Axes,'color','none','Clipping','off'); 
% freezeColors;

% zticklabels = strread(num2str(round(linspace(1,N, 2*round(M/min([M N]))))),'%s');
% set(gca, 'ZTick',linspace(0,1, 2*round(M/min([M N]))),...
%     'ZTickLabel',zticklabels);


end

