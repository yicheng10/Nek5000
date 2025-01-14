c-----------------------------------------------------------------------
      subroutine exact(uu,vv,xx,yy,n,time,visc,u0,v0)
c
c     This routine creates initial conditions for an exact solution
c     to the Navier-Stokes equations based on the paper of Walsh [1],
c     with an additional translational velocity (u0,v0).
c     
c     The computational domain is [0,2pi]^2 with doubly-periodic 
c     boundary conditions.
c     
c     Walsh's solution consists of an array of vortices determined 
c     as a linear combinations of eigenfunctions of having form:
c     
c         cos(pi m x)cos(pi n y), cos(pi m x)sin(pi n y)
c         sin(pi m x)cos(pi n y), sin(pi m x)sin(pi n y)
c     
c     and
c
c         cos(pi k x)cos(pi l y), cos(pi k x)sin(pi l y)
c         sin(pi k x)cos(pi l y), sin(pi k x)sin(pi l y)
c     
c     While there are constraints on admissible (m,n),(k,l)
c     pairings, Walsh shows that there is a large class of
c     possible pairings that give rise to very complex vortex
c     patterns.
c     
c     Walsh's solution applies either to unsteady Stokes or 
c     unsteady Navier-Stokes.  The solution is a non-translating
c     decaying array of vortices that decays at the rate 
c
c          exp ( -4 pi^2 (m^2+n^2) visc time ),
c
c     with (m^2+n^2) = (k^2+l^2). A nearly stationary state may
c     be obtained by taking the viscosity to be extremely small,
c     so the effective decay is negligible.   This limit, however,
c     leads to an unstable state, thus diminsishing the value of 
c     Walsh's solution as a high-Reynolds number test case.
c
c     It is possible to extend Walsh's solution to a stable convectively-
c     dominated case by simulating an array of vortices that translate
c     at arbitrary speed by adding a constant to the initial velocity field.  
c     This approach provides a good test for convection-diffusion dynamics.
c     
c     The approach can also be extended to incompressible MHD with unit
c     magnetic Prandtl number Pm.
c     
c [1] Owen Walsh, "Eddy Solutions of the Navier-Stokes Equations,"
c     in The Navier-Stokes Equations II - Theory and Numerical Methods,
c     Proceedings, Oberwolfach 1991, J.G. Heywood, K. Masuda,
c     R. Rautmann,  S.A. Solonnikov, Eds., Springer-Verlag, pp. 306--309
c     (1992).
c
c     2/23/02; 6/2/09;  pff
c
c
      include 'SIZE'
      include 'INPUT'
c
      real uu(n),vv(n),xx(n),yy(n)
c
      real cpsi(2,5), a(2,5)
      save cpsi     , a

c     data a / .4,.45 , .4,.2 , -.2,-.1 , .2,.05, -.09,-.1 / ! See eddy.m
c     data cpsi / 0,65 , 16,63 , 25,60 , 33,56 , 39,52 /     ! See squares.f
c     data cpsi / 0,85 , 13,84 , 36,77 , 40,75 , 51,68 /


c     This data from Walsh's Figure 1 [1]:

      data a / -.2,-.2, .25,0.,   0,0  ,  0,0  ,  0,0  /
      data cpsi / 0, 5 ,  3, 4 ,  0,0  ,  0,0  ,  0,0  /

      one   = 1.
      pi    = 4.*atan(one)

      aa    = cpsi(2,1)**2
      arg   = -visc*time*aa  ! domain is [0:2pi]
      e     = exp(arg)
c
c     ux = psi_y,  uy = -psi_x
c
      do i=1,n
         x = xx(i) - u0*time
         y = yy(i) - v0*time

         sx = sin(cpsi(2,1)*x)
         cx = cos(cpsi(2,1)*x)
         sy = sin(cpsi(2,1)*y)
         cy = cos(cpsi(2,1)*y)
         u  =  a(1,1)*cpsi(2,1)*cy 
         v  =  a(2,1)*cpsi(2,1)*sx

         do k=2,5
            s1x = sin(cpsi(1,k)*x)
            c1x = cos(cpsi(1,k)*x)
            s2x = sin(cpsi(2,k)*x)
            c2x = cos(cpsi(2,k)*x)

            s1y = sin(cpsi(1,k)*y)
            c1y = cos(cpsi(1,k)*y)
            s2y = sin(cpsi(2,k)*y)
            c2y = cos(cpsi(2,k)*y)
            
            c1  = cpsi(1,k)
            c2  = cpsi(2,k)

            if (k.eq.2) u = u + a(1,k)*s1x*c2y*c2
            if (k.eq.2) v = v - a(1,k)*c1x*s2y*c1
            if (k.eq.2) u = u - a(2,k)*s2x*c1y*c1
            if (k.eq.2) v = v + a(2,k)*c2x*s1y*c2

            if (k.eq.3) u = u - a(1,k)*s1x*c2y*c2
            if (k.eq.3) v = v + a(1,k)*c1x*s2y*c1
            if (k.eq.3) u = u - a(2,k)*c2x*c1y*c1
            if (k.eq.3) v = v - a(2,k)*s2x*s1y*c2

            if (k.eq.4) u = u + a(1,k)*c1x*c2y*c2
            if (k.eq.4) v = v + a(1,k)*s1x*s2y*c1
            if (k.eq.4) u = u + a(2,k)*c2x*c1y*c1
            if (k.eq.4) v = v + a(2,k)*s2x*s1y*c2

            if (k.eq.5) u = u - a(1,k)*s1x*c2y*c2
            if (k.eq.5) v = v + a(1,k)*c1x*s2y*c1
            if (k.eq.5) u = u - a(2,k)*s2x*c1y*c1
            if (k.eq.5) v = v + a(2,k)*c2x*s1y*c2
         enddo
         uu(i) = u*e + u0
         vv(i) = v*e + v0
      enddo

      return
      end
c-----------------------------------------------------------------------
      subroutine uservp (ix,iy,iz,ieg)
      include 'SIZE'
      include 'TOTAL'
      include 'NEKUSE'
C
      udiff =0.
      utrans=0.
      return
      end
c-----------------------------------------------------------------------
      subroutine userf  (ix,iy,iz,ieg)
      include 'SIZE'
      include 'TOTAL'
      include 'NEKUSE'
C
      ffx = 0.0
      ffy = 0.0
      ffz = 0.0
      return
      end
c-----------------------------------------------------------------------
      subroutine userq  (ix,iy,iz,ieg)
      include 'SIZE'
      include 'TOTAL'
      include 'NEKUSE'
C
      qvol   = 0.0
      source = 0.0
      return
      end
c-----------------------------------------------------------------------
      subroutine userchk
      include 'SIZE'  
      include 'TOTAL' 
      include 'NEKNEK'
c
      common /exacu/ ue(lx1,ly1,lz1,lelt),ve(lx1,ly1,lz1,lelt)
      common /exacd/ ud(lx1,ly1,lz1,lelt),vd(lx1,ly1,lz1,lelt)


      ifield = 1  ! for outpost

      n    = nx1*ny1*nz1*nelv
      visc = param(2)
      u0   = param(96)
      v0   = param(97)
      call exact  (ue,ve,xm1,ym1,n,time,visc,u0,v0)
      if (istep.eq.0     ) call outpost(ue,ve,vx,pr,t,'   ')

      call sub3   (ud,ue,vx,n)
      call sub3   (vd,ve,vy,n)
      if (istep.eq.nsteps) call outpost(ud,vd,vx,pr,t,'   ')

      umx = glamax(vx,n)
      vmx = glamax(vy,n)
      uex = glamax(ue,n)
      vex = glamax(ve,n)
      udx = glamax(ud,n)
      vdx = glamax(vd,n)

c    Global error calculation
      if (IFNEKNEK) then 
      umx_gl = uglamax(vx,n)
      vmx_gl = uglamax(vy,n)
      uex_gl = uglamax(ue,n)
      vex_gl = uglamax(ve,n)
      udx_gl = uglamax(ud,n)
      vdx_gl = uglamax(vd,n)
      end if  


      if (nid.eq.0) then
          write(6,11) istep,time,udx,umx,uex,u0,'  X err', session
          write(6,11) istep,time,vdx,vmx,vex,v0,'  Y err', session
      end if
      call nekgsync
      if (nid_global.eq.0) then	  
          write(6,11) istep,time,udx_gl,umx_gl,uex_gl,u0,'  X err',
     & 'global'
          write(6,11) istep,time,vdx_gl,vmx_gl,vex_gl,v0,'  Y err',
     & 'global'
   11     format(i5,1p5e14.6,a7,2x,a7)
      endif


      if (istep.le.5) then        !  Reset velocity to eliminate 
         call copy (vx,ue,n)      !  start-up contributions to
         call copy (vy,ve,n)      !  temporal-accuracy behavior.
      endif

      return
      end
c-----------------------------------------------------------------------
      subroutine userbc (ix,iy,iz,iside,ieg)
c     NOTE ::: This subroutine MAY NOT be called by every process
      include 'SIZE'
      include 'TOTAL'
      include 'NEKUSE'
      include 'NEKNEK'

      ie = gllel(ieg)

      if (imask(ix,iy,iz,ie).eq.0) then
      ux=0.0
      uy=0.0
      uz=0.0
      temp=0.0
      else      

      if (igeom.le.2) then
         ux = ubc(ix,iy,iz,ie,1)
         uy = ubc(ix,iy,iz,ie,2)
         uz = ubc(ix,iy,iz,ie,3)
         if (nfld_neknek.gt.3) temp = ubc(ix,iy,iz,ie,ldim+2)
      else
         ux = valint(ix,iy,iz,ie,1)
         uy = valint(ix,iy,iz,ie,2)
         uz = valint(ix,iy,iz,ie,3)
         if (nfld_neknek.gt.3) temp = valint(ix,iy,iz,ie,ldim+2)
      endif

      end if
      return
      end
c-----------------------------------------------------------------------
      subroutine useric (ix,iy,iz,ieg)
      include 'SIZE'
      include 'TOTAL'
      include 'NEKUSE'

      common /exacu/ ue(lx1,ly1,lz1,lelt),ve(lx1,ly1,lz1,lelt)
      common /exacd/ ud(lx1,ly1,lz1,lelt),vd(lx1,ly1,lz1,lelt)

      integer icalld
      save    icalld
      data    icalld  /0/

      n = nx1*ny1*nz1*nelv
      if (icalld.eq.0) then
         icalld = icalld + 1
         time = 0.
         u0   = param(96)
         v0   = param(97)
         call exact (ue,ve,xm1,ym1,n,time,visc,u0,v0)
      endif

      ie = gllel(ieg)
      ux=ue(ix,iy,iz,ie)
      uy=ve(ix,iy,iz,ie)
      uz=0.0
      temp=0

      return
      end
c-----------------------------------------------------------------------
      subroutine usrdat
      include 'SIZE'
      include 'TOTAL'
      include 'NEKNEK'
    
c     ngeom - parameter controlling the number of iterations,
c     set to ngeom=2 by default (no iterations) 
c     One could change the number of iterations as
      ngeom = 6

c     ninter - parameter controlling the order of interface extrapolation 
c     for neknek,
c     set to ninter=1 by default
c     One could change it as
      ninter = 3
c     Caution: if ninter greater than 1 is chosen, ngeom greater than 2 
c     should be used for stability

      if (nid.eq.0) write(6,*) ngeom-1,ninter,'k10-qmax-IEXTm'

c     Set number of fields to interpolate
c     nfld_neknek = ndim+1 (just velocity+pressure)
c     nfld_neknek = ndim+2 (velocity + pressure + temperature)

c     nfld_neknek = 3 - u,v,pr in 2D
c     nfld_neknek = 4 - u,v,pr,t in 2D

c     nfld_neknek = 4 - u,v,w,pr in 3D 
c     nfld_neknek = 5 - u,v,w,pr,t in 3D 

      nfld_neknek=3 !just velocity+pressure 

      return
      end
c-----------------------------------------------------------------------
      subroutine usrdat2
      include 'SIZE'
      include 'TOTAL'

      one   = 1.
      twopi = 8.*atan(one)

      n = nx1*ny1*nz1*nelt    !  Rescale mesh to [0,2pi]^2

      call cmult(xm1,twopi,n)
      call cmult(ym1,twopi,n)

c     This routine initializes the mulitdomain coupling          
      
      call multimesh_create

      return
      end
c----------------------------------------------------------------------
      subroutine usrdat3
      return
      end
c----------------------------------------------------------------------

c automatically added by makenek
      subroutine usrsetvert(glo_num,nel,nx,ny,nz) ! to modify glo_num
      integer*8 glo_num(1)

      return
      end

c automatically added by makenek
      subroutine userqtl

      call userqtl_scig

      return
      end
