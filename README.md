## Tet2Hex for Nek5000/NekRS

This code generates the Hexahedral mesh in Nek5000/NekRS `.re2` format based on tet-to-hex approach.    
This is a subset of my other code, SphereMesh, for the pebble-bed mesh generation. All right reserved. 

### Usage 

- Main driver: `driver1.m`

- Specify the input points into variable `P (#pts,3)`.   
  This can be arbitrary 3D points. For examples: 

  - Template 1: single tet
  ```
     P=[0,0,0; 1,0,0; 0,1,0; 0,0,1];
  ```
  
  - Template 2: uniform lattice
  ```
     L = 3; W = 2; H = 1; % length, width and height of box 
   
     xx=linspace(0,L,11);
     yy=linspace(0,L,7);
     zz=linspace(0,L,3);
   
     [X,Y,Z] = meshgrid(xx,yy,zz);
     P=[X(:),Y(:),Z(:)];
  ```

  - Template 3: random ponts in a 3D box
  ```
     L = 3; W = 2; H = 1; % length, width and height of box
     npts = 201;  % # pts

     P = zeros(npts,3); rng(23); % for reproducible
     P(:,1) = L*rand(1,npts); %x-coordinate of a point
     P(:,2) = W*rand(1,npts); %y-coordinate of a point
     P(:,3) = H*rand(1,npts); %z-coordinate of a point
  ```

  - Template 4: uniform points in an unit sphere
  ```
     npts=1000;
     x=normrnd(0,1,npts,1);
     y=normrnd(0,1,npts,1);
     z=normrnd(0,1,npts,1);
     R=rand(npts,1).^(1/3);
     R=R./sqrt(x.^2+y.^2+z.^2);
     P = [x.*R, y.*R, z.*R];
  ```

- The code will generate the following fies under the `output/` directory
  - `mesh.re2`: Nek re2
  - `mesh.co2`: Nek co2
  - `logfile`: re-direct the printed info from terminal to the logfile.    
     The previous logfile will be backup to `logfile.1`
  - `Hexes_Hini.vtk`: the vtk file for the mesh (`ifdump=1`). This can be open via ParaView
 

### Notes
- Currently, Octave is not supported 
- All boundaries are set to walls `W  ' since there is no other info 
- The function `dump_nek_re2` is not the fastest version. Potential slow-down for E > 1M
- The `tet2hex` is a first edition, this can be sped up further.


