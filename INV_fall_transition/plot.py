#!/usr/bin/python
# -*- coding: utf-8 -*-
import matplotlib
#from numpy.random import randn
import matplotlib.pyplot as plt
#from matplotlib.ticker import FuncFormatter
import numpy as np
import sys

# Get the title from the results
Title = sys.argv[1] 

# Read results from simasureu
tab = np.genfromtxt('measurements.dat', skip_header=1)
# Loop on each input slope
for islope in range(0, 7):
    # Get one dimensional array 
    ltab = tab[islope]
    # Get the slope value
    label = str(ltab[0])
    # Get the list of pairs (loaad_cap, fall_cell)
    ltab = np.delete(ltab, 0)
    # Extract the load_cap values
    xtab = ltab[0::2]
    # Extract the output values
    ytab = ltab[1::2]
    plt.plot(xtab,ytab, label=label)
    # print label
    # print xtab
    # print ytab

## Le titre
plt.title(Title)
plt.xlabel('Load capacitor (ff)')
plt.ylabel(r'Output fall transition time (ns)')
# Now add the legend with some customizations.
legend = plt.legend(loc='upper left', shadow=True)
# Now add a line at the maximum allowed slope
#plt.axhline(y=0.20, hold=None)
plt.axhline(y=0.20)
# and annotate the line
plt.annotate("max allowed transition",xy=(12, 0.20))


plt.show()

#xl = np.genfromtxt('results/cumulated_results',  usecols=2)
#yl = np.genfromtxt('results/cumulated_results',  usecols=0)
#
#fig = plt.figure()
#ax = fig.gca()
#ax.set_xticks(np.arange(-1000,1000,250))
#ax.set_yticks(np.arange(-15,15.,2.5))
#
## Make a scatter plot
#plt.scatter(xl,yl,alpha=0.6) 
##plt.xlim(-1000,1000) 
##plt.ylim(-15,15) 
#plt.grid()
#


plt.show()
