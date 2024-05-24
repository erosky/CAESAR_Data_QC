#!/usr/bin/python
# Above command must be placed on the first line, allowing use of command line arguments

# How to use this script:
# python3 plot_anything.py ncfile.nc var1 var2 ...


# Required Python Libraries
import sys                  # Command line arguments
from scipy.io import netcdf_file # Reading and writing netcdf files
import numpy as np          # Matrix and math operations
import csv                  # Read and write csv files
import matplotlib.pyplot as plt

# Verify that the correct number of input arguments is provided
n_inputs = len(sys.argv) # Number of commandline inputs
if n_inputs < 3:
    print("Incorrect number of input arguments. \nExample usage:")
    print("python3 plot_anything.py input_ncfile.nc var1 var2 ...")
    sys.exit(0)

# Verify that the correct files are being read and written
ncfilename = sys.argv[1]
netcdf_variables = sys.argv[2:]
print("Input netcdf file: " + ncfilename)
print(netcdf_variables)

################################
# Read in the netcdf variables #
################################
f = netcdf_file(ncfilename, 'r', mmap=False) # Open the netcdf file

time_values = f.variables['Time']
time = np.array(time_values[:])


fig = plt.figure()
for nc_var in netcdf_variables:             # For each variable in the netcdf_variables list
    values = f.variables[nc_var]            # Retrieve the variable values from the netcdf file
    array = np.array(values[:])             # Write the values to a Numpy array
    plt.plot(time, array, label=nc_var)
f.close()                                   # Close the netcdf file

plt.legend()
plt.show()