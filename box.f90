! *****************************************************************!
! File : squareblock . f90 !
! Synopsis : Explicit MacCormack method !
! Solution of viscid laminar flow around a square block !
! MEEN 6310 Project 1 !
! Author : Paul Gessler <paul.gessler@mu.edu> !
! Date : 19 December 2013 !
! *****************************************************************!

PROGRAM SquareBlock
INTEGER istep,n,nn,ii,jj,itermax,nskip,ishow,jshow
!PARAMETER(nn=2,jj=60,ii=int(jj*35.d0/3.d0),itermax=250000,nskip=10)
PARAMETER(nn=2,jj=60,ii=int(jj*35.d0/3.d0),itermax=10000,nskip=10)
DOUBLE PRECISION x(0:ii), y(0:jj)
DOUBLE PRECISION u(nn,0:ii,0:jj), v(nn,0:ii,0:jj)
DOUBLE PRECISION us(1,0:ii,0:jj), vs( 1,0:ii,0:jj)
DOUBLE PRECISION rho(nn,0:ii,0:jj), rhos(nn,0:ii,0:jj)
DOUBLE PRECISION rhou(nn,0:ii,0:jj), rhov(nn,0:ii,0:jj)
DOUBLE PRECISION rhous(1,0:ii,0:jj), rhovs(1,0:ii,0:jj)
DOUBLE PRECISION cdcl(3,0:int(itermax/nskip)), t(0:itermax)
DOUBLE PRECISION UU,rho0,VV,Mach,Masq,Re,dx,dy,dt,D,resid,Cd,Cl
DOUBLE PRECISION a1,a2,a3,a4,a5,a6,a7,a8,a9,a10, a11

Mach = 0.05d0
Masq = Mach**2
UU = 1.00d0
VV = 0.00d0
Re = 20.0d0
D = 1.00d0
rho0 = 1.00d0
dx = 35.0d0*D/dfloat(ii)
dy = 3.00d0*D/dfloat(jj)
dt = 0.90d0*Mach*dx/dsqrt(2.d0)

ishow = -1
jshow = -1

print *,'Reynolds number : ',Re
print *,'Time step, dt:    ',dt

do i=0, ii
x(i) = dx*dfloat(i)
enddo
do j=0, jj
y(j) = dy*dfloat(j)
enddo
open(unit=31,file='x.dat',form='formatted',status='unknown')
open(unit=32,file='y.dat',form='formatted',status='unknown')
write(31,'(E12.4)') (x(i),i=0,ii)
write(32,'(E12.4)') (y(j),j=0,jj)
close(31)
close(32)

a1 = dt/dx
a2 = dt/dy
a3 = dt/(dx*Masq)
a4 = dt/(dy*Masq)
a5 = 4.d0*dt/(3.d0*Re*dx**2)
a6 = dt/(Re*dy**2)
a7 = dt/(Re*dx**2)
a8 = 4.d0*dt/(3.d0*Re*dy**2)
a9 = dt/(12.d0*Re*dx*dy)
a10 = 2.d0*(a5+a6)
a11 = 2.d0*(a7+a8)

! initialize
do i=0, ii
do j=0, jj
n = 1
if ( x(i) .ge. 15.d0*D .and. x(i) .le. 16.d0*D .and. &
    y(j) .ge. 1.d0*D .and. y(j) .le. 2.d0*D ) then
    u(n,i,j) = 0.0d0
    v(n,i,j) = 0.0d0
else
    u(n,i,j) = UU
    v(n,i,j) = VV
endif
rho(n,i,j) = rho0
rhos(n,i,j) = rho0
rhou(n,i,j) = rho(n,i,j)*u(n,i,j)
rhov(n,i,j) = rho(n,i,j)*v(n,i,j)
rhous(n,i,j) = rhou(n,i,j)
rhovs(n,i,j) = rhov(n,i,j)
enddo
enddo

do istep=0,itermax
n = 1
t(istep) = istep *dt

! step 1 done below ( update solution )

! step 2
do i=1,ii-1
do j=1,jj-1
rhos(n,i,j) = rho(n,i,j) - a1 *( rhou (n,i+1, j) - rhou (n,i,j)) &
    - a2 *( rhov (n, i,j +1) - rhov (n,i,j))
if (x(i) .ge. 15.d0*D .and. x(i) .le. 16.d0*D .and. &
    y(j) .ge. 1.d0*D .and. y(j) .le. 2.d0*D) then
    rhous(n,i,j) = 0.0d0
    rhovs(n,i,j) = 0.0d0
else
    rhous(n,i,j) = rhou(n,i,j) - a3 *(rho(n,i+1,j) - rho(n,i,j)) &
        - a1 *(rho(n,i+1,j)*u(n,i+1,j )**2 - rho(n,i,j)*u(n,i,j )**2) &
        - a2 *(rho(n,i,j +1)* u(n,i,j +1)* v(n,i,j +1) &
        - rho(n,i, j)*u(n,i, j)*v(n,i, j)) &
        - a10 *u(n,i,j) + a5 *(u(n,i+1, j) + u(n,i -1, j)) &
        + a6 *(u(n, i,j +1) + u(n, i,j -1)) &
        + a9 *(v(n,i+1,j +1) + v(n,i -1,j -1) - v(n,i+1,j -1) - v(n,i -1,j +1))
    rhovs(n,i,j) = rhov(n,i,j) - a4 *(rho(n,i,j+1) - rho(n,i,j)) &
        - a2 *( rho(n,i,j +1)* v(n,i,j +1)**2 - rho(n,i,j)*v(n,i,j )**2) &
        - a1 *( rho(n,i+1,j)*u(n,i+1,j)*v(n,i+1,j) &
        - rho(n,i, j)*u(n,i, j)*v(n,i, j)) &
        - a11 *v(n,i,j) + a7 *(v(n,i+1, j) + v(n,i -1, j)) &
        + a8 *(v(n, i,j +1) + v(n, i,j -1)) &
        + a9 *(u(n,i+1,j +1) + u(n,i -1,j -1) - u(n,i+1,j -1) - u(n,i -1,j +1))
endif
enddo
enddo

! step 3 - impose boundary conditions
do i=1, ii ! since rho (n ,i -1 ,j) is not defined at i=0
j = 0 ! bottom
rhos(n,i,j) = rho(n,i,j) &
    - dt *(4.d0* rhov(n,i,j +1) - rhov(n,i,j +2) &
    - 3.d0* rhov(n,i, j ))/(2.d0*dy)
rhous(n,i,j) = rhos(n,i,j)* UU
rhovs(n,i,j) = 0.d0
j = jj ! top
rhos(n,i,j) = rho(n,i,j) &
    + dt *(4.d0* rhov(n,i,j-1) - rhov(n,i,j-2) &
    - 3.d0* rhov(n,i, j))/(2.d0*dy)
rhous(n,i,j) = rhos(n,i,j)* UU
rhovs(n,i,j) = 0.d0
if (x(i) .ge. 15.d0*D .and. x(i) .le. 16.d0*D) then
    j = int (2.d0*D/dy)
    rhos(n,i,j) = (4.d0* rho (n,i,j+1) - rho(n,i,j +2))/3.d0 &
        - 8.d0* Masq *( -5.d0*v(n,i,j +1) + 4.d0*v(n,i,j +2) - v(n,i,j +3)) &
        /(9.d0*dy*Re) &
        - Masq *( -(u(n,i+1,j +2) - u(n,i -1,j +2)) + 4.d0 *(u(n,i+1,j+1) &
        - u(n,i -1,j +1)) - 3.d0 *(u(n,i+1,j) - u(n,i -1,j )))/(18.d0*dx*Re)
    j = int (1.d0*D/dy)
    rhos (n,i,j) = (4.d0* rho (n,i,j -1) - rho(n,i,j -2))/3.d0 &
        + 8.d0* Masq *( -5.d0*v(n,i,j -1) + 4.d0*v(n,i,j -2) - v(n,i,j -3)) &
        /(9.d0*dy*Re) &
        - Masq *( -(u(n,i+1,j -2) - u(n,i -1,j -2)) + 4.d0 *(u(n,i+1,j -1) &
        - u(n,i -1,j -1)) - 3.d0 *(u(n,i+1,j) - u(n,i -1,j )))/(18.d0*dx*Re)
endif
enddo
do j=0, jj
i = 0
rhos(n,i,j) = rho0
rhous(n,i,j) = rhos(n,i,j)* UU
rhovs(n,i,j) = rhos(n,i,j)* VV
i = ii
rhos(n,i,j) = rho(n,i,j) &
    + dt *(4.d0* rhou(n,i -1,j) - rhou(n,i -2,j) &
    - 3.d0* rhou (n, i,j ))/(2.d0*dx)
rhous(n,i,j) = (4.d0* rhous(n,i -1,j) - rhous(n,i -2,j ))/3.d0
rhovs(n,i,j) = (4.d0* rhovs(n,i -1,j) - rhovs(n,i -2,j ))/3.d0
if (y(j) .ge. 1.d0*D .and. y(j) .le. 2.d0*D) then
    i = int (15.d0*D/dx)
    rhos (n,i,j) = (4.d0* rho (n,i -1,j) - rho(n,i -2,j ))/3.d0 &
        + 8.d0* Masq *( -5.d0*u(n,i -1,j) + 4.d0*u(n,i -2,j) - u(n,i -3,j)) &
        /(9.d0*dx*Re) - Masq *(4.d0 *(v(n,i -1,j +1) - v(n,i -1,j -1)) &
        - (v(n,i -2,j +1) - v(n,i -2,j -1)) - 3.d0 *(v(n,i,j+1) - v(n,i,j -1))) &
        /(18.d0*dy*Re)
    if (j .eq. int (1.d0*D/dy )) then
        rhos (n,i,j) = ( rhos (n,i,j) + (4.d0*rho(n,i,j -1) - rho(n,i,j -2))/3.d0 &
            + 8.d0* Masq *( -5.d0*v(n,i,j -1) + 4.d0*v(n,i,j -2) - v(n,i,j -3)) &
            /(9.d0*dy*Re) &
            - Masq *( -(u(n,i+1,j -2) - u(n,i -1,j -2)) + 4.d0 *(u(n,i+1,j -1) &
            - u(n,i -1,j -1)) - 3.d0 *(u(n,i+1,j) - u(n,i -1,j )))/(18.d0*dx*Re ))/2.d0
    elseif (j .eq. int (2.d0*D/dy )) then
        rhos (n,i,j) = ( rhos (n,i,j) + (4.d0*rho(n,i,j+1) - rho(n,i,j +2))/3.d0 &
            - 8.d0* Masq *( -5.d0*v(n,i,j +1) + 4.d0*v(n,i,j +2) - v(n,i,j +3)) &
            /(9.d0*dy*Re) &
            - Masq *( -(u(n,i+1,j +2) - u(n,i -1,j +2)) + 4.d0 *(u(n,i+1,j+1) &
            - u(n,i -1,j +1)) - 3.d0 *(u(n,i+1,j) - u(n,i -1,j )))/(18.d0*dx*Re ))/2.d0
    endif
    i = int (16.d0*D/dx)
    rhos (n,i,j) = (4.d0* rho (n,i+1,j) - rho(n,i+2,j ))/3.d0 &
        - 8.d0* Masq *( -5.d0*u(n,i+1,j) + 4.d0*u(n,i+2,j) - u(n,i+3,j)) &
        /(9.d0*dx*Re) - Masq *(4.d0 *(v(n,i+1,j +1) - v(n,i+1,j -1)) &
        - (v(n,i+2,j +1) - v(n,i+2,j -1)) - 3.d0 *(v(n,i,j+1) - v(n,i,j -1))) &
        /(18.d0*dy*Re)
endif
enddo

! step 4
do i=0, ii
do j=0, jj
us(n,i,j) = rhous (n,i,j)/ rhos (n,i,j)
vs(n,i,j) = rhovs (n,i,j)/ rhos (n,i,j)
enddo
enddo

! step 5
do i=1,ii -1
do j=1,jj -1
rho (n+1,i,j) = (( rho(n,i,j) + rhos (n,i,j)) &
    - a1 *( rhous (n,i,j) - rhous (n,i -1, j)) &
    - a2 *( rhovs (n,i,j) - rhovs (n, i,j -1)))/2.d0
if ( x(i) .ge. 15.d0*D .and. x(i) .le. 16.d0*D .and. &
    y(j) .ge. 1.d0*D .and. y(j) .le. 2.d0*D ) then
    rhou (n+1,i,j) = 0
    rhov (n+1,i,j) = 0
else
    rhou(n+1,i,j) = ( rhou (n,i,j) + rhous (n,i,j) &
        - a3 *( rhos (n,i,j) - rhos (n,i -1,j)) &
        - a1 *( rhos (n, i,j)* us(n, i,j )**2 &
        - rhos (n,i -1,j)* us(n,i -1,j )**2) &
        - a2 *( rhos (n,i, j)* us(n,i, j)* vs(n,i, j) &
        - rhos (n,i,j -1)* us(n,i,j -1)* vs(n,i,j -1)) &
        - a10 *us(n,i,j) + a5 *( us(n,i+1, j) + us(n,i -1, j)) &
        + a6 *( us(n, i,j +1) + us(n, i,j -1)) &
        + a9 *( vs(n,i+1,j+1) + vs(n,i -1,j -1) &
        - vs(n,i+1,j -1) - vs(n,i -1,j +1)))/2.d0
    rhov(n+1,i,j) = ( rhov (n,i,j) + rhovs (n,i,j) &
        - a4 *( rhos (n,i,j) - rhos (n,i,j -1)) &
        - a1 *( rhos (n, i,j)* us(n, i,j)* vs(n, i,j) &
        - rhos (n,i -1,j)* us(n,i -1,j)* vs(n,i -1,j)) &
        - a2 *( rhos (n,i, j)* vs(n,i, j )**2 &
        - rhos (n,i,j -1)* vs(n,i,j -1)**2) &
        - a11 *vs(n,i,j) + a7 *( vs(n,i+1, j) + vs(n,i -1, j)) &
        + a8 *( vs(n, i,j +1) + vs(n, i,j -1)) &
        + a9 *( us(n,i+1,j+1) + us(n,i -1,j -1) &
        - us(n,i+1,j -1) - us(n,i -1,j +1)))/2.d0
endif
enddo
enddo

! step 6 - impose boundary conditions
do j = 0,jj
i = 0
rho (n+1,i,j) = ( rho (n,i,j) + rhos (n,i,j) &
    - dt *(4.d0* rhous (n,i+1,j) - rhous (n,i+2,j) &
    - 3.d0* rhous (n, i,j ))/(2.d0*dx ))/2.d0
rhou (n+1,i,j) = rho (n+1,i,j)* UU
rhov (n+1,i,j) = rho (n+1,i,j)* VV
i = ii ! right
rho (n+1,i,j) = ( rho (n,i,j) + rhos (n,i,j) &
    + dt *(4.d0* rhous (n,i -1,j) - rhous (n,i -2,j) &
    - 3.d0* rhous (n,i,j ))/(2.d0*dx ))/2.d0
rhou (n+1,i,j) = (4.d0* rhou (n+1,i -1,j) - rhou (n+1,i -2,j ))/3.d0
rhov (n+1,i,j) = (4.d0* rhov (n+1,i -1,j) - rhov (n+1,i -2,j ))/3.d0
if (y(j) .ge. 1.d0*D .and. y(j) .le. 2.d0*D) then
    i = int (15.d0*D/dx) ! front
    rho (n+1,i,j) = ( rhos (n,i,j) &
        + (4.d0* rhos (n,i -1,j) - rhos (n,i -2,j ))/3.d0 &
        + 8.d0* Masq *( -5.d0*us(n,i -1,j) + 4.d0*us(n,i -2,j) &
        - us(n,i -3,j ))/(9.d0*dx*Re) &
        - Masq *(4.d0 *( vs(n,i -1,j+1) - vs(n,i -1,j -1)) &
        - (vs(n,i -2,j +1) - vs(n,i -2,j -1)) &
        - 3.d0 *( vs(n, i,j +1) - vs(n, i,j -1)))/(18.d0*dy*Re ))/2.d0
    i = int (16.d0*D/dx) ! back
    rho (n+1,i,j) = ( rhos (n,i,j) &
        + (4.d0* rhos (n,i+1,j) - rhos (n,i+2,j ))/3.d0 &
        - 8.d0* Masq *( -5.d0*us(n,i+1,j) + 4.d0*us(n,i+2,j) &
        - us(n,i+3,j ))/(9.d0*dx*Re) &
        - Masq *(4.d0 *( vs(n,i+1,j+1) - vs(n,i+1,j -1)) &
        - (vs(n,i+2,j +1) - vs(n,i+2,j -1)) &
        - 3.d0 *( vs(n, i,j +1) - vs(n, i,j -1)))/(18.d0*dy*Re ))/2.d0
endif
enddo
do i = 1,ii -1
j = 0 ! bottom
rho (n+1,i,j) = ( rho (n,i,j) + rhos (n,i,j) &
    - dt *(4.d0* rhovs (n,i,j +1) - rhovs (n,i,j +2) &
    - 3.d0* rhovs (n,i, j ))/(2.d0*dy ))/2.d0
rhou (n+1,i,j) = rho (n+1,i,j)* UU
rhov (n+1,i,j) = rho (n+1,i,j )*0.d0
j = jj ! top
rho (n+1,i,j) = ( rho (n,i,j) + rhos (n,i,j) &
    + dt *(4.d0* rhovs (n,i,j -1) - rhovs (n,i,j -2) &
    - 3.d0* rhovs (n,i, j ))/(2.d0*dy ))/2.d0
rhou (n+1,i,j) = rho (n+1,i,j)* UU
rhov (n+1,i,j) = rho (n+1,i,j )*0.d0
if (x(i) .ge. 15.d0*D .and. x(i) .le. 16.d0*D) then
    j = int (2.d0*D/dy) ! top of block
    rho (n+1,i,j) = ( rhos (n,i,j) &
        + (4.d0* rhos (n,i,j +1) - rhos (n,i,j +2))/3.d0 &
        - 8.d0* Masq *( -5.d0*vs(n,i,j +1) + 4.d0*vs(n,i,j +2) &
        - vs(n,i,j +3))/(9.d0*dy*Re) &
        - Masq *( -( us(n,i+1,j+2) - us(n,i -1,j +2)) &
        + 4.d0 *( us(n,i+1,j +1) - us(n,i -1,j +1)) &
        - 3.d0 *( us(n,i+1, j) - us(n,i -1, j )))/(18.d0*dx*Re ))/2.d0
    j = int (1.d0*D/dy) ! bottom of block
    rho (n+1,i,j) = ( rhos (n,i,j) &
        + (4.d0* rhos (n,i,j -1) - rhos (n,i,j -2))/3.d0 &
        + 8.d0* Masq *( -5.d0*vs(n,i,j -1) + 4.d0*vs(n,i,j -2) &
        - vs(n,i,j -3))/(9.d0*dy*Re) &
        - Masq *( -( us(n,i+1,j -2) - us(n,i -1,j -2)) &
        + 4.d0 *( us(n,i+1,j -1) - us(n,i -1,j -1)) &
        - 3.d0 *( us(n,i+1, j) - us(n,i -1, j )))/(18.d0*dx*Re ))/2.d0
endif
enddo

! update solution
resid = 0.d0
Cd = 0.d0
Cl = 0.d0
do i = 0,ii
do j = 0,jj
! debug output
if (j .eq. jshow ) then
    print '("(n,i,j): (", I9 .9 ," ," , I4 .4 ," ," , I4 .4 ,") &
        &rho: ", F12 .8 ," u: ", F12 .8 ," v: ",F12 .8) ', &
        istep ,i,j, rho (n,i,j),u(n,i,j),v(n,i,j)
endif
if (i .eq. ishow ) then
    print '("(n,i,j): (", I9 .9 ," ," , I4 .4 ," ," , I4 .4 ,") &
        &rho: ", F12 .8 ," u: ", F12 .8 ," v: ",F12 .8) ', &
        istep ,i,j, rho (n,i,j),u(n,i,j),v(n,i,j)
endif

! move to next timestep
resid = resid + dabs ( rho (n,i,j) - rho(n+1,i,j))
rho (n,i,j) = rho (n+1,i,j)
rhou (n,i,j) = rhou (n+1,i,j)
rhov (n,i,j) = rhov (n+1,i,j)
u(n,i,j) = rhou (n+1,i,j)/ rho (n+1,i,j)
v(n,i,j) = rhov (n+1,i,j)/ rho (n+1,i,j)

! compute drag and lift coefficients
if (i .eq. int (15.d0*D/dx) .and. &
    y(j) .ge. 1.d0*D .and. y(j) < 2.d0*D) then
    Cd = Cd + (( rho (n,i,j) + rho (n,i,j +1))* dy/ Masq /2.d0 )/( rho0 *UU **2* D)
    Cl = Cl - (dy /(2.d0*dx*Re*UU ))* &
        (-v(n,i,j) + v(n,i -1,j) - v(n,i,j +1) + v(n,i -1,j +1))
endif
if (i .eq. int (16.d0*D/dx) .and. &
    y(j) .ge. 1.d0*D .and. y(j) < 2.d0*D) then
    Cd = Cd - (( rho (n,i,j) + rho (n,i,j +1))* dy/ Masq /2.d0 )/( rho0 *UU **2* D)
    Cl = Cl + (dy /(2.d0*dx*Re*UU ))* &
        (-v(n,i,j) + v(n,i+1,j) - v(n,i,j +1) + v(n,i+1,j +1))
endif
if (j .eq. int (1.d0*D/dy) .and. &
    x(i) .ge. 15.d0*D .and. x(i) < 16.d0*D) then
    Cl = Cl + (( rho (n,i,j) + rho (n,i+1,j))* dy/ Masq /2.d0 )/( rho0 *UU **2* D)
    Cd = Cd - (dx /(2.d0*dy*Re*UU ))* &
        (-u(n,i,j) + u(n,i,j -1) - u(n,i+1,j) + u(n,i+1,j -1))
endif
if (j .eq. int (2.d0*D/dy) .and. &
    x(i) .ge. 15.d0*D .and. x(i) < 16.d0*D) then
    Cl = Cl - (( rho (n,i,j) + rho (n,i+1,j))* dy/ Masq /2.d0 )/( rho0 *UU **2* D)
    Cd = Cd + (dx /(2.d0*dy*Re*UU ))* &
        (-u(n,i,j) + u(n,i,j+1) - u(n,i+1,j) + u(n,i+1,j +1))
endif
enddo
enddo


! output solution
if ( MOD (istep , nskip ) .eq. 0) then
    print '("  Iter : ",I9 .9 ,"   Time : ", F12 .8, &
        & "   Res : ", E16 .9E3 ,"  Cd: ", F12 .8 ,"  Cl: ", F11 .8) ', &
        istep ,t( istep ),resid ,Cd ,Cl
    cdcl (1, int ( istep / nskip )) = t( istep )
    cdcl (2, int ( istep / nskip )) = Cd
    cdcl (3, int ( istep / nskip )) = Cl
endif
enddo ! istep loop

! output
open(unit=34,file='u.dat',form='formatted',status='unknown')
open(unit=35,file='v.dat',form='formatted',status='unknown')
open(unit=36,file='rho.dat',form='formatted',status='unknown')
open(unit=37,file='cdcl.dat',form='formatted',status='unknown')
do j=0, jj
write (34,1) (u(n,i,j),i=0,ii)
write (35,1) (v(n,i,j),i=0,ii)
write (36,1) (rho (n,i,j),i=0,ii)
enddo
do istep=0, int(itermax/nskip)
write (37 ,1) (cdcl(n,istep),n=1,3)
enddo
close (34)
close (35)
close (36)
close (37)

1 Format (2400001E18.8E3)
END

