#!/usr/bin/python
# Above command must be placed on the first line, allowing use of command line arguments

# How to use this script:
# python3 automatic_QC.py ncfile.nc


# Required Python Libraries
import sys                  # Command line arguments
from scipy.io import netcdf_file # Reading and writing netcdf files
import numpy as np          # Matrix and math operations

# Verify correct number of input arguments
n_inputs = len(sys.argv) # Number of commandline inputs
ncfilename = sys.argv[1]
print(ncfilename)
# Verify that the filename provided exists



# List of netcdf variables that will be used in this script
netcdf_variables = \
[
"Time",
"PUSER_CVI", 
"PSAMP_CVI", 
"DRYFLW_CVI",
"BYPFLW_CVI",
"USRFLW_CVI"
]

# Read in the netcdf variables
f = netcdf_file(ncfilename, 'r', mmap=False) # Open the netcdf file

for nc_var in netcdf_variables:     # For each variable listed in netcdf_variables
    values = f.variables[nc_var]          # Retrieve the variable from the netcdf file
    array = np.array(values[:])          # Write the values to a Numpy array
    exec(nc_var + " = array")       # Assign the array to a variable with the same name as nc_var

f.close()                           # Close the netcdf file


# Derived variables
EXCESS = DRYFLW_CVI - (.64+BYPFLW_CVI+USRFLW_CVI)


boolean_mask = PUSER_CVI >= PSAMP_CVI
time_test = Time[boolean_mask]
print(np.count_nonzero(time_test))



###############
# CONDITION 1 #
###############

# array1 = np.array([12, 24, 16, 21, 32, 29, 7, 15])
# boolean_mask = array1 > 20