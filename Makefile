###########################################################
#                                                         #
#   This is the Makefile for OMOCLO, OMBrO, and OMHCHO,   #
#   the SAO PGEs for the OMI Instrument                   #
#                                                         #
#                                                         #
#                                                         #
#   Author:  Thomas P. Kurosu                             #
#                                                         #
#            Harvard-Smithsonian Center for Astrophysics  #
#            Atomic and Molecular Physics Division        #
#            60 Garden Street (MS 50)                     #
#            Cambridge, MA 02138, USA                     #
#            Tel/Fax: +1 -- 617 - 495 7213                #
#            EMail tkurosu@cfa.harvard.edu                #
#                                                         #
#                                                         #
#   Last modified: April 2003                             #
#                                                         #
###########################################################

# ================================================
# Define some environment variables that
# are unlikely to change between host-types
# ================================================
AR      = ar
ARFLAGS = ruv
MV      = mv
RM      = rm -f
SHELL   = $(MACHSHELL)

# ==============================================================================
# Environment variables that used to be defined in $(PGEHOME)/bin/pge-env.(c)sh
# before the migration to the v0.9.0 directory structure. Currently not defined
# by the compilation/make environment and thus "fudged" here.
# ==============================================================================
PSPLINELIBS  = -lpspline -lezcdf
NETCDFLIBS   = -lnetcdf
HE4LIBS      = -lhdfeos -lmfhdf -lGctp -ldf -ljpeg -lz
HE5LIBS      = -lhe5_hdfeos -lhdf5_hl -lhdf5_fortran -lhdf5hl_fortran -lhdf5
PGSLIBS      = -lPGSTK

#===============================================================


# =======================================================
# Target Directories for Modules, Library, and Executable
# =======================================================
PGETMPDIR  = $(PGEHOME)/tmp
PGEBINDIR  = $(PGEHOME)/bin
PGEOUTDIR  = $(PGEIODIR)/

OMSAOMAIN  = $(SAOPGE)

MAIN       = $(SAOPGE)
TARGET     = $(SAOPGE).exe
EXECUTABLE = $(TARGET) 

include $(MKFDIR)/make.flags


VPATH = ./$(PGEBINDIR):$(PGETMPDIR):$(OMISAOSHARED)/src

# ================================================
# All sources are "sourced out" to an include file
# ================================================
include $(MKFDIR)/make.sources

# =================================================
#  Everything we want to make in this distribution
# =================================================
all : dirs messages $(EXECUTABLE)
	@for target in $^; do                                \
           $(MAKE) -f $(MKFDIR)/Makefile $$target;     \
        done


# ============================================
#  Here's how the executable is made from the
#  objects $(OBJECTS) and the various Modules
# ============================================
$(EXECUTABLE) : $(OBJECTS) $(MAIN).f90 $(CSOURCES) $(F90SOURCES)
	$(FC) $(FFLAGS) $(MAIN).f90 -o $(TARGET) $(LINKOBS) $(IFLAGS) $(LFLAGS) $(LIBS)


# =============================================================
# A list of directories that are empty at CVS checkin, and are
# thus not version tagged (files only). They must be created at
# the start of the PGE make process.
# =============================================================
emptydirs = $(PGETMPDIR) $(PGSMSG) $(PGEBINDIR) $(PGEOUTDIR)

# =====================
#  Various Make targets
# =====================
build: all

install: all
	$(MAKE) -f $(MKFDIR)/Makefile cleanlog links
	cp -fp $(EXECUTABLE) $(PGEOUTDIR)/
	chmod u+w ../bin/PGS*

prof: all
	$(MAKE) -f $(MKFDIR)/Makefile install
	cd $(PGEOUTDIR); mkdir -p ../prof; $(PGEOUTDIR)/$(EXECUTABLE); echo 'EXIT VALUE of PGE run is ' $$?

test: all
	$(MAKE) -f $(MKFDIR)/Makefile install
	cd $(PGEOUTDIR); $(PGEOUTDIR)/$(EXECUTABLE) 2> $(SAOPGE).stderr > $(SAOPGE).stdout; \
        echo 'EXIT VALUE of PGE run is ' $$? > $(SAOPGE).stdout

vtest: all
	$(MAKE) -f $(MKFDIR)/Makefile install
	cd $(PGEOUTDIR); $(PGEOUTDIR)/$(EXECUTABLE); echo 'EXIT VALUE of PGE run is ' $$?

runit: 
	@cd $(PGEOUTDIR); $(PGEOUTDIR)/$(EXECUTABLE); echo 'EXIT VALUE of PGE run is ' $$?


envtest:
	@echo $(LFLAGS)

# ----------------------------------------------------------------------
# The following target runs the executable, nothing else. In particular,
# no checking for dependencies. Else we will be running the risk that a
# "busy" (i.e., executing) target is attempted to be overwritten, which
# should lead to the unwanted failing of "gmake run".
# ----------------------------------------------------------------------
run: 
	cd $(PGEOUTDIR); $(PGEOUTDIR)/$(EXECUTABLE); echo 'EXIT VALUE of PGE run is ' $$?

include $(MKFDIR)/make.targets

include $(MKFDIR)/make.patterns

# =================
#  End of Makefile
# =================
