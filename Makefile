FC = gfortran
FCFLAGS = -fno-automatic -w -O3
BINDIR = bin
SRCDIR = src

all: $(BINDIR)/xnfpelsyn \
	 $(BINDIR)/synbeg \
	 $(BINDIR)/rgfalllinesnew \
	 $(BINDIR)/rpredict \
	 $(BINDIR)/rmolecasc \
	 $(BINDIR)/rschwenk \
	 $(BINDIR)/rh2ofast \
     $(BINDIR)/synthe \
	 $(BINDIR)/spectrv \
	 $(BINDIR)/rotate \
	 $(BINDIR)/broaden \
	 $(BINDIR)/converfsynnmtoa \
	 $(BINDIR)/fluxaverage1a_nmtoa
	 
clean:
	rm -r $(BINDIR)/*

$(BINDIR)/atlas7v.o:
	$(FC) $(FCFLAGS) -c $(SRCDIR)/atlas7v.for -o $@
	
$(BINDIR)/xnfpelsyn.o:
	$(FC) $(FCFLAGS) -c $(SRCDIR)/xnfpelsyn.for -o $@
	
$(BINDIR)/xnfpelsyn: $(BINDIR)/atlas7v.o $(BINDIR)/xnfpelsyn.o
	$(FC) $(BINDIR)/xnfpelsyn.o $(BINDIR)/atlas7v.o -o $@

$(BINDIR)/synbeg:
	$(FC) $(FCFLAGS) -o $@ $(SRCDIR)/synbeg.for
	
$(BINDIR)/rgfalllinesnew:
	$(FC) $(FCFLAGS) -o $@ $(SRCDIR)/rgfalllinesnew.for
	
$(BINDIR)/rpredict:
	$(FC) $(FCFLAGS) -o $@ $(SRCDIR)/rpredict.for
	
$(BINDIR)/rmolecasc:    
	$(FC) $(FCFLAGS) -o $@ $(SRCDIR)/rmolecasc.for

$(BINDIR)/rschwenk:
	$(FC) $(FCFLAGS) -o $@ $(SRCDIR)/rschwenk.for

$(BINDIR)/rh2ofast:
	$(FC) $(FCFLAGS) -o $@ $(SRCDIR)/rh2ofast.for

$(BINDIR)/synthe:
	$(FC) $(FCFLAGS) -o $@ $(SRCDIR)/synthe.for
	
$(BINDIR)/spectrv.o:
	$(FC) $(FCFLAGS) -c $(SRCDIR)/spectrv.for -o $@
	
$(BINDIR)/spectrv: $(BINDIR)/atlas7v.o $(BINDIR)/spectrv.o
	$(FC) -o $@ $(BINDIR)/spectrv.o $(BINDIR)/atlas7v.o
	
$(BINDIR)/rotate:
	$(FC) $(FCFLAGS) -o $@ $(SRCDIR)/rotate.for

$(BINDIR)/broaden:
	$(FC) $(FCFLAGS) -o $@ $(SRCDIR)/broaden.for

$(BINDIR)/converfsynnmtoa:
	$(FC) $(FCFLAGS) -o $@ $(SRCDIR)/converfsynnmtoa.for

$(BINDIR)/fluxaverage1a_nmtoa:
	$(FC) $(FCFLAGS) -o $@ $(SRCDIR)/fluxaverage1a_nmtoa.for
