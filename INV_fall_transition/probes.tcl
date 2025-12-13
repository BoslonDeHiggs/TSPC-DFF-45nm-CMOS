#
# Database settings
#
database -open ams_database -into psf -default

#
# Probe settings
#
probe -create -database ams_database -all -depth all
probe -create -emptyok -database ams_database -flow -ports -index  {testbench.bdut.dut}
# And start the simulation
run 
quit
