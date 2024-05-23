#!/usr/bin/python
# Above command must be placed on the first line, allowing use of command line arguments

# Required Python Libraries
import sys                  # Command line arguments
from scipy.io import netcdf_file # Reading and writing netcdf files
import numpy as np          # Matrix and math operations

# Verify correct number of input arguments
n_inputs = len(sys.argv) # Number of commandline inputs
ncfilename = sys.argv[1]
print(ncfilename)
# Verify that the input filenames exists

# Check the output filename and verify if it will be overwritten

f = netcdf_file(ncfilename, 'w', mmap=False) # Open the netcdf file
f.history = 'Created for a test'
f.createDimension('time', 10)
time = f.createVariable('time', 'i', ('time',))
time[:] = np.arange(10)
time.units = 'days since 2008-01-01'

f.close()