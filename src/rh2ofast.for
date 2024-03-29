      PROGRAM RH2OFAST
C     FAST VERSION,  NO ENERGY LEVEL INFORMATION
C     READS PACKED BINARY VERSION OF PARTRIDGE AND SCHWENKE'S H2O LINELIST
      PARAMETER (kw=99)
c      COMMON /LINDAT/WL,E,EP,LABEL(2),LABELP(2),OTHER1(2),OTHER2(2),
      COMMON /LINDAT/WL,E,EP,LABEL,LABELP,OTHER1,OTHER2,
     1        WLVAC,CENTER,CONCEN, NELION,GAMMAR,GAMMAS,GAMMAW,REF,
     2      NBLO,NBUP,ISO1,X1,ISO2,X2,GFLOG,XJ,XJP,CODE,ELO,GF,GS,GR,GW,
     3        DWL,DGFLOG,DGAMMAR,DGAMMAS,DGAMMAW,DWLISO,ISOSHIFT,EXTRA3
C      REAL*8 LINDAT8(14)
C      REAL*4 LINDAT4(28)
C      EQUIVALENCE (LINDAT8(1),WL),(LINDAT4(1),NELION)
      REAL*8 LINDAT8I(3)
      REAL*8 LINDAT8II(3)
      REAL*4 LINDAT4I(4)
      REAL*4 LINDAT4II(23)
      EQUIVALENCE (LINDAT8I(1),WL)
      EQUIVALENCE (LINDAT8II(1),WLVAC)
      EQUIVALENCE (LINDAT4I(1),NELION)
      EQUIVALENCE (LINDAT4II(1),NBLO)
      character*10 LABEL,LABELP,OTHER1,OTHER2
      CHARACTER*4 REF
      CHARACTER*2 LABELISO(4)
      REAL*8 WL,E,EP,WLVAC,CENTER,CONCEN,UNPACKWL,WLVAC1
c      REAL*8 LABEL,LABELP,OTHER1,OTHER2,LABELISO(4)
      CHARACTER*10 COTHER1,COTHER2,CLABEL,CLABELP
      EQUIVALENCE (COTHER1,OTHER1),(COTHER2,OTHER2)
      EQUIVALENCE (CLABEL,LABEL),(CLABELP,LABELP)
      INTEGER TYPE
      EQUIVALENCE (GF,G,CGF),(TYPE,NLAST)
      REAL*8 RESOLU,RATIO,RATIOLG,WLBEG,WLEND,RATIOLOG,WLBEG1,WLEND1
      REAL*8 RATIORATIO,VACAIR
      REAL*4 DECKJ(7,kw),XISO(4),X2ISO(4)
      REAL*4 TABLOG(32768),AIRSHIFT(100000)
      INTEGER*2 IELO,IGFLOG
      EQUIVALENCE (IWL,IWLBYTES(1))
      BYTE IWLBYTES(4),IELOBYTES(2),IGFLOGBYTES(2),ONEBYTE
      EQUIVALENCE (IELOBYTES(1),IELO),(IGFLOGBYTES(1),IGFLOG)
C               1H1H16O 1H1H17O 1H1H18O 1H2H16O
      DATA XISO/  .9976,  .0004,  .0020, .00001/
      DATA X2ISO/-0.001, -3.398, -2.690, -5.000/
      DATA LABELISO/'16','17','18','26'/
C
      data alpha/0./
      DO 1 I=1,32768
    1 TABLOG(I)=10.**((I-16384)*.001)
      IF(IFPRED.NE.1)CALL TABVACAIR(AIRSHIFT)
c      OPEN(UNIT=11,STATUS='OLD',READONLY,SHARED,FORM='UNFORMATTED',
c     1RECORDTYPE='FIXED',RECORDSIZE=2,ACCESS='DIRECT')
      OPEN(UNIT=11,STATUS='OLD',ACTION='READ',FORM='UNFORMATTED',
     1    RECL=8, ACCESS='DIRECT')
      OPEN(UNIT=12,STATUS='OLD',FORM='UNFORMATTED',ACCESS='APPEND')
      OPEN(UNIT=14,STATUS='OLD',FORM='UNFORMATTED',ACCESS='APPEND')
      READ(93)NLINES,LENGTH,IFVAC,IFNLTE,N19,TURBV,DECKJ,IFPRED,
     1WLBEG,WLEND,RESOLU,RATIO,RATIOLG,CUTOFF,LINOUT
      RATIOLOG=LOG(1.D0+1.D0/2000000.D0)
      RATIORATIO=RATIOLOG/RATIOLG
      IXWLBEG=DLOG(WLBEG)/RATIOLG
      IF(DEXP(IXWLBEG*RATIOLG).LT.WLBEG)IXWLBEG=IXWLBEG+1
C
      WLBEG1=WLBEG-1.
      WLEND1=WLEND+1.
      N=0
      READ(11,REC=1)IWL
c     on some computers need byte rotation
c     onebyte=iwlbytes(1)
c     iwlbytes(1)=iwlbytes(4)
c     iwlbytes(4)=onebyte
c     onebyte=iwlbytes(2)
c     iwlbytes(2)=iwlbytes(3)
c     iwlbytes(3)=onebyte
      WLVAC=EXP(IWL*RATIOLOG)
      IF(IFVAC.NE.1)THEN
      KWL=WLVAC*10.+.5
      WLVAC=WLVAC+AIRSHIFT(KWL)
      ENDIF
      PRINT 3334,WLVAC
 3334 FORMAT(' FIRST LINE IS        1','   WL',F12.4)
      IF(WLVAC.GT.WLEND1)GO TO 21
      LENGTHFILE=65912356
      READ(11,REC=LENGTHFILE)IWL
c     on some computers need byte rotation
c     onebyte=iwlbytes(1)
c     iwlbytes(1)=iwlbytes(4)
c     iwlbytes(4)=onebyte
c     onebyte=iwlbytes(2)
c     iwlbytes(2)=iwlbytes(3)
c     iwlbytes(3)=onebyte
      WLVAC=EXP(IWL*RATIOLOG)
      IF(IFVAC.NE.1)WLVAC=VACAIR(WLVAC)
      PRINT 3335,LENGTHFILE,WLVAC
 3335 FORMAT(' LAST LINE IS ',I9,'   WL',F12.4)
      IF(WLBEG1.GT.WLVAC)GO TO 21
C     FIND THE FIRST LINE AFTER ISTART
      LIMITBLUE=1
      LIMITRED=LENGTHFILE
   12 NEWLIMIT=(LIMITRED+LIMITBLUE)/2
      PRINT 3333,LIMITBLUE,NEWLIMIT,LIMITRED
 3333 FORMAT(3I10)
      READ(11,REC=NEWLIMIT)IWL
c     on some computers need byte rotation
c     onebyte=iwlbytes(1)
c     iwlbytes(1)=iwlbytes(4)
c     iwlbytes(4)=onebyte
c     onebyte=iwlbytes(2)
c     iwlbytes(2)=iwlbytes(3)
c     iwlbytes(3)=onebyte
      WLVAC=EXP(IWL*RATIOLOG)
      IF(IFVAC.NE.1)WLVAC=VACAIR(WLVAC)
      IF(WLVAC.LT.WLBEG1)GO TO 13
      LIMITRED=NEWLIMIT
      IF(LIMITRED-LIMITBLUE.LE.1)GO TO 14
      GO TO 12
   13 LIMITBLUE=NEWLIMIT
      IF(LIMITRED-LIMITBLUE.LE.1)GO TO 14
      GO TO 12
   14 ISTART=NEWLIMIT
      PRINT 3333,LIMITBLUE,LIMITRED,NEWLIMIT
      WRITE(6,6)ISTART
    6 FORMAT(I10,14H IS FIRST LINE)
C
      DO 20 ILINE=ISTART,LENGTHFILE
      READ(11,REC=ILINE)IWL,IELO,IGFLOG
c     on some computers need byte rotation
c     onebyte=iwlbytes(1)
c     iwlbytes(1)=iwlbytes(4)
c     iwlbytes(4)=onebyte
c     onebyte=iwlbytes(2)
c     iwlbytes(2)=iwlbytes(3)
c     iwlbytes(3)=onebyte
c     onebyte=ielobytes(1)
c     ielobytes(1)=ielobytes(2)
c     ielobytes(2)=onebyte
c     onebyte=igflogbytes(1)
c     igflogbytes(1)=igflogbytes(2)
c     igflogbytes(2)=onebyte
c
      WLVAC=EXP(IWL*RATIOLOG)
      FREQ=2.99792458E17/WLVAC
      IF(IFVAC.NE.1)THEN
      KWL=WLVAC*10.+.5
      WLVAC=WLVAC+AIRSHIFT(KWL)
      ENDIF
      IF(WLVAC.GT.WLEND1)GO TO 21
      IXWL=DLOG(WLVAC)/RATIOLG+.5D0
      ISO=1
      IF(IELO.GT.0.AND.IGFLOG.GT.0)GO TO 19
      ISO=2
      IF(IELO.GT.0)GO TO 19
      ISO=3
      IF(IGFLOG.GT.0)GO TO 19
      ISO=4
   19 NELION=534
      ELO=ABS(IELO)
      IGFLOG=ABS(IGFLOG)
      NBUFF=IXWL-IXWLBEG+1
      CONGF=.01502*TABLOG(IGFLOG)/FREQ*XISO(ISO)
      FRQ4PI=FREQ*12.5664
C     GAMMAS=0
C     LOG GAMMAW=-7
C     IGR=
      IGS=1
      IGW=9384
      GAMMAR=2.223E13/WLVAC**2*.001
      GAMRF=GAMMAR/FRQ4PI
C     GAMRF=TABLOG(IGR)/FRQ4PI
      GAMSF=TABLOG(IGS)/FRQ4PI
      GAMWF=TABLOG(IGW)/FRQ4PI
      WRITE(12)NBUFF,CONGF,NELION,ELO,GAMRF,GAMSF,GAMWF,alpha
      NLINES=NLINES+1
      IF(N.EQ.0)WRITE(6,1919)WLVAC
 1919 FORMAT(F12.4)
      N=N+1
   20 CONTINUE
   21 LINOUT=-ABS(LINOUT)
      WRITE(6,22)N
   22 FORMAT(I10,13H IS LAST LINE)
      WRITE(6,1919)WLVAC
   25 WRITE(6,26)NLINES
   26 FORMAT(I10,25H LINES WRITTEN ON TAPE 12)
      REWIND 93
      WRITE(93)NLINES,LENGTH,IFVAC,IFNLTE,N19,TURBV,DECKJ,IFPRED,
     1WLBEG,WLEND,RESOLU,RATIO,RATIOLG,CUTOFF,LINOUT
      CALL EXIT
      END
      SUBROUTINE TABVACAIR(AIRSHIFT)
      REAL*4 AIRSHIFT(100000)
      REAL*8 WLVAC,VACAIR
      DO 1 IWL=1,1999
    1 AIRSHIFT(IWL)=0.
      DO 2 IWL=2000,100000
      WLVAC=IWL*.1
    2 AIRSHIFT(IWL)=VACAIR(WLVAC)-WLVAC
      RETURN
      END
      FUNCTION VACAIR(W)
      IMPLICIT REAL*8 (A-H,O-Z)
C     W IS VACUUM WAVELENGTH IN NM
      WAVEN=1.D7/W
      VACAIR=W/(1.0000834213D0+
     1 2406030.D0/(1.30D10-WAVEN**2)+15997.D0/(3.89D9-WAVEN**2))
C    1(1.000064328+2949810./(1.46E10-WAVEN**2)+25540./(4.1E9-WAVEN**2))
      RETURN
      END
