#!/usr/bin/python
# Above command must be placed on the first line, allowing use of command line arguments

# How to use this script:
# python3 XYrelationships.py ncfile.nc Xvar Yvar [starttime endtime]


# Required Python Libraries
import sys                  # Command line arguments
from scipy.io import netcdf_file # Reading and writing netcdf files
import numpy as np          # Matrix and math operations
import csv                  # Read and write csv files
import matplotlib.pyplot as plt

# Verify that the correct number of input arguments is provided
n_inputs = len(sys.argv) # Number of commandline inputs
if n_inputs != 4 and n_inputs != 6:
    print("Incorrect number of input arguments. \nExample usage:")
    print("python3 XYrelationships.py ncfile.nc Xvar Yvar [starttime endtime]")
    sys.exit(0)


# Verify that the correct files are being read and written
ncfilename = sys.argv[1]
X_var = sys.argv[2]
Y_var = sys.argv[3]
print("Input netcdf file: " + ncfilename)
print(X_var, Y_var)

################################
# Read in the netcdf variables #
################################
f = netcdf_file(ncfilename, 'r', mmap=False) # Open the netcdf file

time_values = f.variables['Time']
time = np.array(time_values[:])
X = f.variables[X_var] 
X = np.array(X[:])  
Y = f.variables[Y_var] 
Y = np.array(Y[:]) 

if n_inputs == 6:
    start = sys.argv[4]
    end = sys.argv[5]
    time_mask = np.logical_and(time>=start, time<=end)
    time = time[time_mask]
    X = X[time_mask]
    Y = Y[time_mask]


fig = plt.figure()
plt.scatter(X, Y, label="{} vs {}".format(X_var, Y_var))
f.close()                                   # Close the netcdf file

plt.legend()
plt.show()