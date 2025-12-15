# Put here the name of the file containing the device under test
#
# The Verilog-ams file (xxx.vams). The name off the file should
# be the name of the module to test.
DUT_FILE=TSPCFF.vams
# The original Spice file (xxx.scs). Empty for INV testing
SP_FILE=

### File used for plotting the results
PLOT_FILE=plot_prop+setup.py

### Modules names are forged from the Device Under Test name
DUTDIR = $(shell basename $(CURDIR))
# Device name
DUT = $(basename $(DUT_FILE))
# LIBRARY for the DEVICE
LIBNAME = ${DUT}_LIB
# The board module
BD=board
# The testbench module
TB=testbench
# The name of the control file
CTR=amsXrunControl
# Where is the gpdk045 design kit ?
TECHLIBNAME:="gpdk045"
KITDIR=/comelec/softs/opt/opus_kits/CADENCE_PDKS/gpdk045_v_4_0
PDKITROOT:=/comelec/softs/opt/opus_kits/CADENCE_PDKS/tpt_gpdk045
# Where are COMELEC goodies
GOODIES=${KITDIR}/COMELEC
# Where are the tools
TOOLSDIR=/comelec/softs/bin
# Temporary directory
TMPDIR=tmp
export CDLFILE=${TMPDIR}/${DUT}.cdl


##### File names are forged from module names


# The the board file
BD_FILE=${BD}.vams
# The testbench file
TB_FILE=${TB}_setup.sv
# The control file
CTR_FILE=${CTR}.scs

all:
	@echo "simu          : simulation"
	@echo "show_waves    : examine simulation waveforms"
	@echo "plot_results  : examine simulation results"
	@echo "clean         : cleaning of the simulation directory, yet keeping last results"
	@echo "ultraclean    : cleaning of the simulation directory, removing all results"
	@echo "template_dir  : create a template dir for a new chararecterization job"
	@echo "import_cell   : import vams netlist as a Virtuoso schematic"

#IRUN_OPT= -disable_sem2009  -input probes.tcl  -spectre_args "++aps=conservative"
IRUN_OPT= -disable_sem2009  -input probes.tcl -spectre_args "+errpreset=conservative"

simu:real_simu

# If needed a precompiled library
#-reflib /comelec/softs/opt/opus_kits/CADENCE_PDKS/COMELEC/lib_scs/gsclib045_basicCells \

real_simu: ${CTR_FILE} | results
	-${TOOLSDIR}/xrun ${IRUN_OPT} \
	${CTR_FILE} \
    -top ${TB} \
    ${TB_FILE} \
    ${BD_FILE} \
	cmos_transition.vams \
	${DUT_FILE}
	@echo "Simu finished"

show_waves:
	${TOOLSDIR}/viva -datadir psf &

plot_results:
	python3 ${PLOT_FILE} ${DUTDIR}


results:
	    mkdir -p results

clean:
	@rm -rf INCA_libs
	@rm -rf irun.history
	@rm -rf irun.log
	@rm -rf ${CTR}.raw
	@rm -rf ${CTR}.shm
	@rm -rf amsIrunControl.ahdlSimDB
	@rm -rf irun.key
	@rm -rf waves.shm
	@rm -rf .simvision
	@rm -rf CDS*
	@rm -rf log.*
	@rm -rf .*.swp
	@rm -rf .cadence
	@rm -rf xcelium.d
	@rm -rf amsXrunControl.ams
	@rm -rf xrun.log
	@rm -rf xrun.history
	@rm -rf *.log
	@rm -rf tmp
	@rm -f .tmp_netlist.vams.adms
	@rm -f .adms.implicit.xml
	@rm -f .interface.xml

ultraclean: clean
	@rm -rf results
	@rm -rf psf
	
template_dir:
	mkdir ../template_dir
	cp *.vams ../template_dir
	cp *.sv ../template_dir
	cp *.scs ../template_dir
	cp plot.py ../template_dir
	cp probes.tcl ../template_dir
	cp .cdsenv  ../template_dir
	cp Makefile ../template_dir

import_cell: ../${LIBNAME}/${DUT}/schematic

############# ${TMPDIR}: a directory for logfiles ##########################
${TMPDIR}:
	@mkdir -p $@

############# Cell Library creation #############################################################################################
../${LIBNAME}: | ${TMPDIR}
	@echo "Creating ../${LIBNAME} library with GPDK045 initialisation, it may take some time..."
	@echo "userlib=dbCreateLib(\"${LIBNAME}\")" > ../.tmp.il
	@echo "techSetTechLibName(userlib \"${TECHLIBNAME}\")" >> ../.tmp.il
	@echo "exit" >> ../.tmp.il
	@cd .. && ${TOOLSDIR}/virtuoso -log ${DUTDIR}/${TMPDIR}/CDS_init.log -nograph -replay .tmp.il
	@rm -f ../.tmp.il
	@echo "Done"

############# Importation of a VAMS hierarchical netlist into the openAccess library
############# And generation of associated schematics and symbols
../${LIBNAME}/${DUT}/schematic: ${DUT}.vams | ../${LIBNAME} ${TMPDIR}
	@echo "Importing ${DUT}.vams netlist into ../${LIBNAME} library"
	@echo "//***********************************" > ${TMPDIR}/tmp_netlist.vams
	@echo "// Auto generated file: do not edit"   >> ${TMPDIR}/tmp_netlist.vams
	@echo "//***********************************" >> ${TMPDIR}/tmp_netlist.vams
	@cat ${PDKITROOT}/tools/adms/gpdk045.vams $< >> ${TMPDIR}/tmp_netlist.vams
	@${PDKITROOT}/tools/adms/ADMS/admsXml/admsXml -I ${PDKITROOT}/tools/adms ${TMPDIR}/tmp_netlist.vams -e ${PDKITROOT}/tools/adms/vlatocdl.xml 2>&1 | tee ${TMPDIR}/admsXml.log
	@ cd .. && ${TOOLSDIR}/spiceIn \
	-param ${PDKITROOT}/tools/spiceIn/spiceIn.params \
	-devmapFile ${PDKITROOT}/tools/spiceIn/dev.map \
	-outputLib ${LIBNAME} \
	-netlistFile ${DUTDIR}/${CDLFILE} \
	2>&1 | tee  ${DUTDIR}/${TMPDIR}/spiceInErr.log
	@mv -f ../c2s*.log ${TMPDIR}
	@mv -f ../spiceIn.log ${TMPDIR}
	@mv -f ../conn2sch.log ${TMPDIR}
	@echo "Done"


