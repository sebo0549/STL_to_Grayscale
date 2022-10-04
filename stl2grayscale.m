function I=stl2grayscale(varargin)
%stl2grayscale: Function to transform a 3D geometry represented by a STL file into a grayscale image
%   
%   INPUT: 
%       filename_input:  String specifing the name of the STL file used as
%       input. The plane of interest is assumed to lie in the x-y-plane!
%
%       filename_output: String specifing the name of the saved image file.
%       If not specified the output file gets the same name as the input
%       file and is saved as a .bmp image
%       
%       N_pixel: number of pixels in the final image. If the input geometry
%       is not square the larger side is devided into N_pixel segments
%
%   OUTPUT:
%       I: Matrix with the image data
% -----------------------------------------------
% Author: Sebastian Bohm (sebastian.bohm@tu-ilmenau.de)
% Date: 21-09-2022

%% process input parameters
if(length(varargin)<1)
    return
elseif(length(varargin)==1)
    filename_input=varargin{1};
    s=strsplit(varargin{1},'.stl');
    filename_output=sprintf('%s%s',s{1},'.bmp');
    N_pixel=1024;
elseif(length(varargin)==2)
    filename_input=varargin{1};
    filename_output=varargin{2};
    N_pixel=1024;
elseif(length(varargin)>2)
    filename_input=varargin{1};
    filename_output=varargin{2};
    N_pixel=varargin{3};
end                                

%% read STL file
TR=stlread(filename_input);
P=TR.Points;                % extract coordinates
Con=TR.ConnectivityList;    % extract connectivity matrix
P(:,3)=P(:,3)-min(P(:,3));  % shift z-coordinate 

%% generate grid for the image
Lx=max(P(:,1))-min(P(:,1));
Ly=max(P(:,2))-min(P(:,2));

if(Lx>Ly)
    Nx_pixel=N_pixel;
    Ny_pixel=round(Ly/Lx*N_pixel);
else
    Ny_pixel=N_pixel;
    Nx_pixel=round(Lx/Ly*N_pixel);
end

x=linspace(min(P(:,1)),max(P(:,1)),Nx_pixel);
y=linspace(min(P(:,2)),max(P(:,2)),Ny_pixel);

[X,Y]=meshgrid(x,y);

Xvec=X(:);
Yvec=Y(:);

%% determine gray scale values
Zmin=min(P(:,3));
Zneu=Zmin*ones(Nx_pixel*Ny_pixel,1);
for n=1:length(Con(:,1))
    if(any(P(Con(n,:),3)>Zmin)) 
        % only points which lie inside of a rectangle around each triangle
        % can contribute

        xmin=min(P(Con(n,:),1));
        xmax=max(P(Con(n,:),1));
        ymin=min(P(Con(n,:),2));
        ymax=max(P(Con(n,:),2));
        
        indx=find(x>=xmin & x<=xmax);
        indy=find(y>=ymin & y<=ymax);
        
        [Ix,Iy]=meshgrid(indy,indx);
        inds = sub2ind([Ny_pixel,Nx_pixel],Ix,Iy);
        inds=inds(:);
        
        % find all points that lie inside of the rectangle but also lie inside of the triangle
        in = Check_Point_Inside_Triangle([P(Con(n,:),1),P(Con(n,:),2)],[Xvec(inds),Yvec(inds)]);
        
        N_in=length(inds(in));
        if(N_in>0)
            % detect intersection point for each point inside of the actual
            % triangle
            P1=P(Con(n,1),:)';
            P2=P(Con(n,2),:)';
            P3=P(Con(n,3),:)';
            
            xnew=Xvec(inds(in));
            ynew=Yvec(inds(in));
            
            % z-coordinate on the actual triangle
            z=P1(3)+(ynew-P1(2))*((P2(1)-P1(1))*(P3(3)-P1(3))-(P3(1)-P1(1))*(P2(3)-P1(3)))/((P2(1)-P1(1))*(P3(2)-P1(2))-(P3(1)-P1(1))*(P2(2)-P1(2)))-...
                (xnew-P1(1))*((P2(2)-P1(2))*(P3(3)-P1(3))-(P3(2)-P1(2))*(P2(3)-P1(3)))/((P2(1)-P1(1))*(P3(2)-P1(2))-(P3(1)-P1(1))*(P2(2)-P1(2)));
            
            % only take the "highest" point into account
            ind2=inds(in);
            ind3=Zneu(ind2)<z;
            Zneu(ind2(ind3))=z(ind3);
        end
    end
end


%% Generate gray-scale image
Zneu=reshape(Zneu,Ny_pixel,Nx_pixel); % reshape vector into a matrix 
I=flipud(mat2gray(Zneu,[min(Zneu(:)),max(Zneu(:))]));
imwrite(I,filename_output) % store file

%% plot results
figure(1)
set(figure(1),'units','normalized','outerposition',[0 0 1 1])   % maximize figure
subplot(1,2,1)
trisurf(Con,P(:,1),P(:,2),P(:,3),'FaceAlpha',0.5,'FaceColor',[0.5,0.5,0.5])
xlabel('x')
ylabel('y')
zlabel('z')
axis equal
view(60,45)

subplot(1,2,2)
imshow(I)
axis equal
end

function P_in_or_out = Check_Point_Inside_Triangle(P,P_check)
% P_in_or_out: function detects if Points P_check are inside of the 
% triangle given by P by solving: 
% r = r0 + (r1 - r0) * a + (r2 - r0) * b 
% P_check are inside if a>0 & b>0 & 1-a-b>0 is true
%   INPUT:  
%        P (3x2): Matrix specifing the coordinates of the vertices of the
%                    triangle
%        P_check (Nx2): Coordinates of the Points we want to check
% -----------------------------------------------
% Author: Sebastian Bohm (sebastian.bohm@tu-ilmenau.de)
% Date: 21-09-2022

r0x = P(1,1); r0y = P(1,2);
r1x = P(2,1); r1y = P(2,2); 
r2x = P(3,1); r2y = P(3,2);

r0x_t = P_check(:,1);
r0y_t = P_check(:,2);

Area = 0.5 *(-r1y.*r2x + r0y.*(-r1x + r2x) + r0x.*(r1y - r2y) + r1x.*r2y);
a = 1./(2*Area).*(r0y.*r2x - r0x.*r2y + (r2y - r0y).*r0x_t + (r0x - r2x).*r0y_t);
b = 1./(2*Area).*(r0x.*r1y - r0y.*r1x + (r0y - r1y).*r0x_t + (r1x - r0x).*r0y_t);

P_in_or_out=logical(a>0 & b>0 & 1-a-b>0);
end