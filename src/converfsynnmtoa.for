      PROGRAM CONVERFSYNNMTOA
C     PROGRAM ASCIISYN(TAPE1,TAPE2,OUTPUT,TAPE6=OUTPUT)
C     TAPE1=SPECTRUM INPUT
C     TAPE2=SPECTRUM OUTPUT IN ASCII CARD IMAGES
C     TAPE6=OUTPUT
C     FOR FLUX SPECTRA NMU IS 1
c      COMMON/LINDAT/WL,GFLOG,XJ,E,XJP,EP,CODE,LABEL(2),LABELP(2),NELION,
c     1               GAMMAR,GAMMAS,GAMMAW,REF,NBLO,NBUP,ISO1,X1,ISO2,
c     2        X2,OTHER1(2),OTHER2(2),ELO,GF,WLVAC,GS,GR,GW,CENTER,CONCEN
c      COMMON /LINDAT/WL,E,EP,LABEL(2),LABELP(2),OTHER1(2),OTHER2(2),
c     1        WLVAC,CENTER,CONCEN, NELION,GAMMAR,GAMMAS,GAMMAW,REF,
c     2      NBLO,NBUP,ISO1,X1,ISO2,X2,GFLOG,XJ,XJP,CODE,ELO,GF,GS,GR,GW,
c     3        DWL,DGFLOG,DGAMMAR,DGAMMAS,DGAMMAW,EXTRA1,EXTRA2,EXTRA3
      REAL*8 WL,E,EP,WLVAC,CENTER,CONCEN
c      REAL*8 LABEL,LABELP,OTHER1,OTHER2,LINDAT
CCRAY DIMENSION LINDAT(34)
c      DIMENSION LINDAT(24)
c      EQUIVALENCE (LINDAT(1),WL)
      DIMENSION XMU(20),QMU(40),WLEDGE(200),TITLE(74)
      REAL*8 TEFF,GLOG,WBEGIN,RESOLU,XMU,WLEDGE
      REAL*8 QMU
      Character*1 title
      DIMENSION QOUT(10000)
      OPEN(UNIT=1,FORM='UNFORMATTED',ACTION='READ',STATUS='OLD')
      READ(1)TEFF,GLOG,TITLE,WBEGIN,RESOLU,NWL,IFSURF,NMU,XMU,NEDGE,
     1WLEDGE
      WRITE(6,1)TEFF,GLOG,TITLE
    1 FORMAT(5HTEFF ,F7.0,7HGRAVITY,F7.3/7HTITLE  ,74A1)
      WRITE(2,1)TEFF,GLOG,TITLE
      IF(IFSURF.EQ.3)NMU=1
      NMU2=NMU+NMU
C      OPEN(UNIT=2,BLOCKSIZE=4800,RECORDSIZE=80,STATUS='NEW',
C     1RECORDTYPE='FIXED')
C      WRITE(2,2)TEFF,GLOG,TITLE,WBEGIN,RESOLU,NWL,IFSURF,NMU,XMU,NEDGE,
C     1WLEDGE
    2 FORMAT(F10.1,F10.3/6HTITLE ,74A1/F10.3,F10.1,I10,I5,I5/
     1 10F8.4/10F8.4/I10/(5F16.5))
	npti=0
      DO 6 IWL=1,NWL,100
      N100=MIN0(NWL-IWL+1,100)
      J=0
      DO 4 I100=1,N100 
      READ(1)(QMU(I),I=1,NMU2)
      DO 3 I=1,NMU2
      J=J+1
    3 QOUT(J)=QMU(I) 
	NIWL=IWL+I100-1
	WAVE=WBEGIN*(1.+1./RESOLU)**(NIWL-1)
	freq=2.997925e17/wave
	npti=npti+1
c      WRITE(2,5)j,WAVE,freq,QOUT(J-1),QOUT(J)
c    5 FORMAT(4HFLUX,I5,F9.5,1PE20.6,2E13.4)
	wavea=10.*wave
	fluxl=4.*qout(j-1)*2.99792458E18/(wavea*wavea)
	fluxc=4.*qout(j)*2.99792458E18/(wavea*wavea)	
	resid=fluxl/fluxc
c      WRITE(2,5)WAVE,freq,QOUT(J-1),QOUT(J)
      WRITE(2,55)WAVEa,fluxl,fluxc,resid
    5 FORMAT(4HFLUX,5x,F9.4,1PE20.6,2E13.4)
55	format(1x,f11.4,1x,1pE12.4,1x,1pE12.4,1x,0PF8.4)
    4 CONTINUE
    6 CONTINUE                                                                  
C      READ(1)NLINES
C      WRITE(2,7)NLINES
C    7 FORMAT(I10)
C      DO 9 I=1,NLINES
C      READ(1)LINDAT
C      WRITE(2,8)WL,GFLOG,XJ,E,XJP,EP,CODE,LABEL,LABELP,
C     1WL,NELION,GR,GS,GW,REF,NBLO,NBUP,ISO1,X1,ISO2,X2,OTHER1,OTHER2,
C     2WL,GF,WLVAC,GAMMAR,GAMMAS,GAMMAW,CENTER,CONCEN
C     2WL,ELO,GF,WLVAC,GAMMAR,GAMMAS,GAMMAW,CENTER,CONCEN
C     ELO MUST BE RECONSTRUCTED
    8 FORMAT(F10.4,F7.3,F5.1,F12.3,F5.1,F12.3,F9.2,A8,A2,A8,A2/
     1F10.4,I4,3F6.2,A4,2I2,I3,F7.2,I3,F7.2,A8,A2,A8,A2/
     2F10.4,1PE10.3,0PF10.3,1P5E10.3)
    9 CONTINUE
	write(6,*)npti
      CALL EXIT
      END
