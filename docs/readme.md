# Papers

https://iopscience.iop.org/article/10.1088/0004-6256/144/4/120/meta

http://kurucz.harvard.edu/papers/

Download:

	$ wget --no-host-directories --recursive --no-parent --continue --tries=3 --wait=0 http://kurucz.harvard.edu/papers/

# SYNTHE

Calculate spectrum from scratch








# Important quantities and files

molecules.dat

  Molecular equilibrium constants
  List of molecular lines
  
  Reader code: atlas9mem.for:4723
  
      READ(2,13)C,E1,E2,E3,E4,E5,E6
   13 FORMAT(F18.2,F7.3,5E11.4)
   
  

.bdf - BIN
bsf*.dat - BIN

  Opacity distribution function
  One file per abundance (metallicity, alpha enchanced etc.)
  Come in big and little versions, see atlas9mem:4295
    - big version has 337 entries?
	- lit files are bigger, 1221 entries

.ros / .ross - ASCII
  
  Rosseland mean opacities
  Calculated for a grid of logT and logP at a few microturbulent velocities (0..8 km/s)
  Independent of wavelength / resolution
  These are computed from the ODFs
  
  Reader code: atlas9mem.for:4017
  Hard coded for 42 pressures and 57 temperatures
  
      READ(1,1152)(TABKAP(IT,IP,IV),IV=1,5)
 1152 FORMAT(5X,5X,5F7.3)
  
.dat - ASCII, model input parameter files

  Contain model input parameters, no idea how they're generated




  
  
All the models
have the same number of plane parallel layers from log(tau_Ross)=-6.875
to +2.00 in steps of Delta[log(tau_Ross)] = 0.125, computed assuming a pure
mixing-length convection (no oveshooting) with 1/Hp=1.25.
  


# DFSYNTHE

Download the code

	$ wget --no-directories --no-host-directories --recursive --no-parent --continue --tries=3 --wait=0 http://kurucz.harvard.edu/programs/newdf/
	
Download line lists

	$ wget --no-host-directories --recursive --no-parent --continue --tries=3 --wait=0 http://kurucz.harvard.edu/linelists/

Comment out OPEN statements (contain VMS-specific syntax) and compile

	$ gfortran -fno-automatic -w -O3 -o repackdi.exe repackdi.for
	
Follow 0df.readme and the .com files
	
Pre-tabulate opacity distribution functions

	$ ln -s 
	
	
	
# ATLAS'9

- http://kurucz.harvard.edu/programs/atlas9/
- http://wwwuser.oats.inaf.it/castelli/sources/atlas9codes.html
- uses precomputed ODF's, supposed to be fast

	$ wget --no-directories --no-host-directories --recursive --no-parent --continue --tries=3 --wait=1 http://kurucz.harvard.edu/programs/atlas9/
	
Basic usage can be figured out from ap00t10000g40k2odfnew.com on the Castelli web page. 

- input files:
  - Rosseland kappa opacities
  - opacity distribution files
  - molecules list
  
Old Rosseland opacitied from Kurucz web site:

	http://kurucz.harvard.edu/opacities/rosseland/
  
Get .ros Rossland opacities from Castelli web page (and use file names from Kurucz web page or from http://wwwuser.oats.inaf.it/castelli/kaprossnew.html):

	$ wget http://wwwuser.oats.inaf.it/castelli/kaprossnew/kapp00.ros

To interpolate Rosseland opacities for metallicity use kaprossinterp.for and kaprossinterp.com

The interpolation formula for x0< x_int < x1  is:

f(x_int)=[(x1-x_int)/(x1-x0)]f(x0)+ [(x_int-x0)/(x1-x0)]f(x1)
f(x_int)=          w1        f(x0)+           w2        f(x1)

Get ODFs from Kurucz web site http://kurucz.harvard.edu/opacities.html 

	$ wget --no-directories --no-host-directories --recursive --no-parent --continue --tries=3 --wait=1 http://kurucz.harvard.edu/opacities.html
	
molecules.dat can be downloaded from http://wwwuser.oats.inaf.it/castelli/sources/atlas9/molecules.dat

## Compiling

The two source files provided by Castelli are essentially the same except for a few read/write routines, try diff them!

* `atlas9mem.for`: compute model atmospheres

	$ gfortran -fno-automatic -w -O3 -o atlas9mem.exe atlas9mem.for >& err.out

* `atlas9v.for`: compute fluxes from model athmospheres

	$ gfortran -fno-automatic -w -O3 -o atlas9v.exe atlas9v.for >& err.out
	
## Running

Fortran program inputs can be figured out from the TAPEn lines at the beginning of the source

* `atlas9mem`

```
C     TAPE1 ROSSELAND OPACITY TABLES TO BE READ IF ABUNDANCE NOT 1X SOLAR
C     TAPE2 MOLECULAR EQUILIBRIUM CONSTANTS
CCCCC TAPE3	OUTPUT FILE ????
C     TAPE5 INPUT
C     TAPE6 OUTPUT
C     TAPE7 MODEL AND OR FLUX OUTPUT
C     TAPE9 LINE DISTRIBUTION FUNCTION INPUT
```

	$ ln -s ../data/rossnew/kapp00.ros fort.1			# Rosseland opacity file (grid for Teff and P values)
	$ ln -s ../data/odfnew/p00lit2.bdf fort.9			# Opacity distribution (for given abundance, resolution and turbulent velocity)
	$ ln -s ../data/molecules.dat fort.2				# Molecules file
	$ ln -s /export/.../ap00k0odfnew.dat fort.3			# Model file, the example shows and input file for a specific temperature only but the ones I have contain all temps
	$ ./atlas9mem.exe <fort.card >test.out				# runs in about 10 sec and will produce a model output of about 1.5 MB

* `atlas9v`

```
C     TAPE1 ROSSELAND OPACITY TABLES TO BE READ IF ABUNDANCE NOT 1X SOLAR
C     TAPE2 MOLECULAR EQUILIBRIUM CONSTANTS
C     TAPE5 INPUT
C     TAPE6 OUTPUT
C     TAPE7 MODEL AND OR FLUX OUTPUT
C     TAPE9 LINE DISTRIBUTION FUNCTION INPUT
```

To generate fluxes

	$ ln -s ../data/odfnew/p00lit2.bdf fort.9
	$ ln -s ../data/molecules.dat fort.2
	$ ln -s /export/.../ap00k0odfnew.dat fort.3
	$ ./atlas9v.exe <fort.card >test.out
	
To generate intensities

	$ ln -s ../data/odfnew/p00lit2.bdf fort.9
	$ ln -s ../data/molecules.dat fort.2
	$ ln -s /export/.../ap00k0odfnew.dat fort.3
	$ ./atlas9v.exe <fort.card >test.out

	
## atlas9mem Parameters are read from stdin (CARD)

"parser" code starts at atlas9mem.for:3742

```
READ KAPPA																			** read Rosseland opacity file from TAPE1
READ PUNCH																			** read from stdin
MOLECULES ON																		** turn on molecular lines
READ MOLECULES																		** read molecules list
FREQUENCIES 337 1 337 BIG															** NUM:number of frequencies NULO:start fq idx NUHI:stop fq idx, see label 2200
VTURB 2.0E+5																		** turbulent velocity but it should match ODF, see label:2900
CONVECTION OVER 1.25 0 36															** ON/OFF/OVER 1/H_p:mixing length OVERWT:overshoot NCONV, see atlas9mem.for:4215
TITLE  [0.0] VTURB=2  L/H=1.25 NOVER NEW ODF										** Title of output model, free text?
SCALE 72 -6.875 0.125 10000. 4.0													** KRHOX:No. of layers TAU1LG STEPLG TEFF1 GNEW:logg, see label 2700
ABUNDANCE SCALE   1.0000 ABUNDANCE CHANGE 1 0.9204 2 0.07834						** see label 800 at atlas9mem.for:3893, XSCALE:scaling factor for metal abundances
 ABUNDANCE CHANGE  3 -10.94  4 -10.64  5  -9.49  6  -3.52  7  -4.12  8  -3.21       ** see label 820 at atlas9mem.for:3904, IZ: ABUND(IZ):normally assumed abundances
 ABUNDANCE CHANGE  9  -7.48 10  -3.96 11  -5.71 12  -4.46 13  -5.57 14  -4.49		** These numbers are written into the model outputs and seem to be the same with a few exceptions
 ABUNDANCE CHANGE 15  -6.59 16  -4.71 17  -6.54 18  -5.64 19  -6.92 20  -5.68		** See Castelli's ATLAS12 paper on the meaning of these
 ABUNDANCE CHANGE 21  -8.87 22  -7.02 23  -8.04 24  -6.37 25  -6.65 26  -4.54
 ABUNDANCE CHANGE 27  -7.12 28  -5.79 29  -7.83 30  -7.44 31  -9.16 32  -8.63
 ABUNDANCE CHANGE 33  -9.67 34  -8.63 35  -9.41 36  -8.73 37  -9.44 38  -9.07
 ABUNDANCE CHANGE 39  -9.80 40  -9.44 41 -10.62 42 -10.12 43 -20.00 44 -10.20
 ABUNDANCE CHANGE 45 -10.92 46 -10.35 47 -11.10 48 -10.27 49 -10.38 50 -10.04
 ABUNDANCE CHANGE 51 -11.04 52  -9.80 53 -10.53 54  -9.87 55 -10.91 56  -9.91
 ABUNDANCE CHANGE 57 -10.87 58 -10.46 59 -11.33 60 -10.54 61 -20.00 62 -11.03
 ABUNDANCE CHANGE 63 -11.53 64 -10.92 65 -11.69 66 -10.90 67 -11.78 68 -11.11
 ABUNDANCE CHANGE 69 -12.04 70 -10.96 71 -11.98 72 -11.16 73 -12.17 74 -10.93
 ABUNDANCE CHANGE 75 -11.76 76 -10.59 77 -10.69 78 -10.24 79 -11.03 80 -10.91
 ABUNDANCE CHANGE 81 -11.14 82 -10.09 83 -11.33 84 -20.00 85 -20.00 86 -20.00
 ABUNDANCE CHANGE 87 -20.00 88 -20.00 89 -20.00 90 -11.95 91 -20.00 92 -12.54
 ABUNDANCE CHANGE 93 -20.00 94 -20.00 95 -20.00 96 -20.00 97 -20.00 98 -20.00
 ABUNDANCE CHANGE 99 -20.00
ITERATIONS 15 PRINT 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
PUNCH 0 1 0 0 0 0 0 0 0 0 0 0 0 0 1
BEGIN                    ITERATION  10 COMPLETED
SCALE 72 -6.875 0.125 10000. 4.0
ITERATIONS 15 PRINT 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
PUNCH 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
BEGIN                    ITERATION  10 COMPLETED
END
```

## atlas9v parameters to generate fluxes are read from stdin (CARD)	
	
```
MOLECULES ON
READ MOLECULES
SURFACE FLUX
FREQUENCIES 1221 1 1221 LITTLE
ITERATIONS 1 PRINT 2 PUNCH 2
READ PUNCH
VTURB 2.0E+5
BEGIN                    ITERATION  10 COMPLETED
END
```
	
## atlas9v parameters to generate intensities are read from stdin (CARD)	
	
```
MOLECULES ON
READ MOLECULES
SURFACE INTENSITY  1 1.
SURFACE INTENSI 17 1.,.9,.8,.7,.6,.5,.4,.3,.25,.2,.15,.125,.1,.075,.05,.025,.01
FREQUENCIES 1221 1 1221 LITTLE
ITERATIONS 1 PRINT 2 PUNCH 2
READ PUNCH
VTURB 2.0E+5
BEGIN                    ITERATION  10 COMPLETED
END
```
	
	
	
	
	
	
	



# ATLAS'12

http://wwwuser.oats.inaf.it/castelli/sources/atlas12.html
http://articles.adsabs.harvard.edu/pdf/2005MSAIS...8...25C

- http://kurucz.harvard.edu/programs/atlas12/
- can generate spectrum without additional input (i.e. ODFs)

    $ wget --no-directories --no-host-directories --recursive --no-parent --continue --tries=3 --wait=1 http://kurucz.harvard.edu/programs/atlas12/
	
	
	
	
	
# SYNTHE

http://wwwuser.oats.inaf.it/castelli/sources/synthe.html
http://wwwuser.oats.inaf.it/castelli/sources/synthe/gcodes.html
http://wwwuser.oats.inaf.it/castelli/sources/synthe/examples/synthenop.html

- calculate surface flux for a converged athmosphere model

## Input files

* continua.dat: continuum absorption, available at http://wwwuser.oats.inaf.it/castelli/sources/syntheg/continua.dat
* molecules.dat: important molecular lines, available at http://kurucz.harvard.edu/programs/synthe/
* ap04t4970g46k1at12.mod: input model, already converged (where to get these???)

Model files should look something like:

```
SURFACE INTENSI 17 1.,.9,.8,.7,.6,.5,.4,.3,.25,.2,.15,.125,.1,.075,.05,.025,.01			# These are needed for rotation-broadened spectra
ITERATIONS 1 PRINT 2 PUNCH 2
CORRECTION OFF
PRESSURE OFF
MOLECULES ON
READ MOLECULES
TEFF   3500.  GRAVITY 0.00000 LTE
TITLE  [-1.5a] N(He)/Ntot=0.0784 VTURB=2.0  L/H=1.25 ODFNEW
 OPACITY IFOP 1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0
 CONVECTION ON   1.25 TURBULENCE OFF  0.00  0.00  0.00  0.00
ABUNDANCE SCALE   0.03162 ABUNDANCE CHANGE
...
READ DECK6 ... # followed by the solution for the atmosphere
...
PRADK 1.9987E-01
BEGIN                    ITERATION  15 COMPLETED
```


## Running

XNFPELSYN pretabulates tables of continuum opacities, number densities/
partition functions, and doppler widths.  

	$ ln -s molecules.dat fort.2								** molecular lines
	$ ln -s continua.dat fort.17								** continuum absorption file
	$ ./xnfpelsyn.exe <ap04t4970g46k1at12.mod >xnfpelsyn.out
	$ cp fort.10 xnft4950g46k1at12.dat							** binary output of 
	$ rm fort.*
	
SYNBEG IS THE FIRST PROGRAM IN THE SYNTHE SERIES.
C     IT READS THE INPUT PARAMETERS AND INITIALIZES TAPES 12 AND 13.
C     SUBSEQUENT PROGRAMS READ THE ATOMIC AND MOLECULAR LINE DATA
C     AND WRITE DATA ON TAPES 12 AND 13 FOR LINES FALLING IN
C     THE WAVELENGTH INTERVAL.  SYNTHE READS TAPES 12 AND 13.
C     PARAMETERS ARE PASSED FROM PROGRAM TO PROGRAM VIA TAPE 93.
C     LINES ARE INCLUDED OR LEFT OUT BY INCLUDING OR LEAVING OUT THE
C     PROGRAM THAT READS THEM.  THE NAMES OF ALL THE READING PROGRAMS
C     BEGIN WITH R.  A SUFFIX P MEANS THAT THE PROGRAM READS BOTH
C     PREDICTED AND REAL WAVELENGTHS.  THE P PROGRAMS SHOULD NOT BE USED
C     FOR MAKING DETAILED LINE BY LINE COMPARISONS WITH OBSERVATIONS.
C     THE ORDER OF THESE READING PROGRAMS DOES NOT MATTER
CCC     EXCEPT FOR RNLTE, RLINE, RKP, AND RKPP, WHICH MUST
C     EXCEPT FOR RNLTE, RLINE, AND RGFIRON WHICH MUST
C     COME FIRST AND IN RELATIVE ORDER IF THEY ARE USED.
		
	$ ./synbeg.exe <<"EOF" >synbeg.out
AIR       700.0     721.0     500000.   0.     0          10 .001         0   00
AIRorVAC  WLBEG     WLEND     RESOLU    TURBV  IFNLTE LINOUT CUTOFF        NREAD
EOF

This will initialize the files with the passed parameters and produce a bunch of output files:

* fort.12 (empty)
* fort.14 (empty)
* fort.19 (empty)
* fort.20 (empty)
* fort.93 (some binary stuff)
	
Now we have to prepare the line lists. Line lists are provided in files grouped by 10 or 100 nm
There are versions with hyperfine splitting. Probably have to load all files relevant to the
wavelength range.

With version `rgfalllinesnew` from Castelli's web page, one has to use line lists from `linelists/gfnew` or `linelists_castelli`
Make sure to use rgfalllinesnew for lines and rgmolecasc for molecules!

Output will be a line list filtered to interesting lines only (about 100k vs. 164k)
These calls also write into the files created by synbeg, so don't remove those!

	$ ln ../data/linelists_castelli/gf0800.100 fort.11
	$ ./rgfalllinesnew.exe >gf0800.out
	$ rm fort.11
	$ ln ../data/linelists_castelli/gf1200.100 fort.11
	$ ./rgfalllinesnew.exe >gf1200.out
	$ rm fort.11
	
	$ ln -s ../data/molecules/molecules/ch/chmasseron.asc fort.11
	$ ./rmolecasc.exe >chmasseron.out
	$ rm fort.11
	
	... repeat above for all line lists / molecules
	
	$ ln -s ../data/linelists_castelli/tioschwenke.bin fort.11
	$ ln -s ../data/linelists_castelli/eschwenke.bin fort.48
	$ ./rschwenk.exe >rschwenk.out							** becomes slow when wide spectral range is used (~20s)
	$ rm fort.11
	
	$ ln -s ../data/molecules/molecules/h2o/h2ofastfix.bin fort.11
	$ ./rh2ofast.exe >h2ofastfix.out
	
Now is the time to run synte!!!
It takes the output from xnfpelsyn, see above

	$ ln -s xnft4950g46k1at12.dat fort.10					** output from xnfpelsyn
	$ ln -s ../data/linelists_castelli/he1tables.dat fort.18
	$ ./synthe.exe >synthe.out								** takes about 15 sec but becomes slow when wl range is broad (8 min)
	
SPECTRV reads the opacity on TAPE9 and the model and computes the 
spectrum which it writes on TAPE7.  In these examples intensities are 
computed at 17 angles.

What is fort.25 for???
RHOXJ IS THE DEPTH ABOVE WHICH THE LINE SOURCE FUNCTION IS J

	$ ln -s ../data/molecules.dat fort.2
	$ cat <<"EOF" >fort.25
0.0       0.        1.        0.        0.        0.        0.        0.
0.
RHOXJ     R1        R101      PH1       PC1       PSI1      PRDDOP    PRDPOW
EOF

	$ ./spectrv.exe <ap04t4970g46k1at12.mod >spectrv.out	** fast
	$ cp fort.7 i7000-7210.dat								** this is a binary file
	
Rotate and broaden

ROTATE rotationally broadens the spectrum by integrating the intensities
over the disk and writes to ROTi for each velocity requested.

	$ ln -s i7000-7210.dat fort.1
	$ ./rotate.exe <<"EOF" >rotate.out
    1														** number of velocities?
2.															** velocity? what's the unit? km/s at limb?
EOF
	$ mv ROT1 f7000-7210vr2.dat								** for some reason it writes to a file not a tape!
	$ rm fort.1
	
The rotated spectrum is then broadened twice by BROADEN.  First by macro-
turbulence and then by a Gaussian instrumental profile.

Sample cards:
```
GAUSSIAN  3.5       KM        COMMENT FIELD
GAUSSIAN  100000.   RESOLUTIONCOMMENT FIELD
GAUSSIAN  7.        PM        COMMENT FIELD
SINX/X    3.5       KM        COMMENT FIELD
SINX/X    100000.   RESOLUTIONCOMMENT FIELD
SINX/X    7.        PM        COMMENT FIELD
RECT      7.        PM        COMMENT FIELD
RECT      3.5       KM        COMMENT FIELD
RECT      100000.   RESOLUTIONCOMMENT FIELD
MACRO     2.0       KM        COMMENT FIELD
PROFILE   5.        POINTS    COMMENT FIELD
RED       .3        .1        .1        .1        .05
BLUE      .3        .1        .1        .1        .05
```
	
	$ ln -s f7000-7210vr2.dat fort.21
	$ ./broaden.exe <<"EOF" >broaden.out
GAUSSIAN  48000.    RESOLUTION
EOF
	$ cp fort.22 f7000-7210vr2br48000ap04t4970g46k1at12.bin
	
Convert results to ASCII

	$ ln -s f7000-7210vr2br48000ap04t4970g46k1at12.dat fort.1
	$ ./converfsynnmtoa.exe
	$ cp fort.2 f7000-7210vr2br48000ap04t4970g46k1at12.asc
	
	$ rm fort.*