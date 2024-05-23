#!/usr/bin/python
# Above command must be placed on the first line, allowing use of command line arguments

# How to use this script:
# python3 automatic_QC.py ncfile.nc output.csv


# Required Python Libraries
import sys                  # Command line arguments
from scipy.io import netcdf_file # Reading and writing netcdf files
import numpy as np          # Matrix and math operations
import csv                  # Read and write csv files

# Verify that the correct number of input arguments is provided
n_inputs = len(sys.argv) # Number of commandline inputs
if n_inputs != 3:
    print("Incorrect number of input arguments. \nExample usage:")
    print("python3 automatic_QC.py input_ncfile.nc output.csv")
    sys.exit(0)

# Verify that the correct files are being read and written
ncfilename = sys.argv[1]
outputfilename = sys.argv[2]
print("Input netcdf file: " + ncfilename)
print("Output data file: " + outputfilename)
verify = input("Is this correct? (Y/N): ") # Ask user to verify
if verify == "N":
    sys.exit(0)

# Create output file to store the QC data
outputfieldnames = ['time', 'qc_variable', 'flag_name', 'flag_value']
csvfile = open(outputfilename, 'w', newline='')
outputwriter = csv.DictWriter(csvfile, fieldnames=outputfieldnames)
outputwriter.writeheader()


###########################################################
# List of netcdf variables that will be used in this script
###########################################################
netcdf_variables = \
[
"Time",
"PUSER_CVI", 
"PSAMP_CVI", 
"DRYFLW_CVI",
"BYPFLW_CVI",
"USRFLW_CVI"
]

################################
# Read in the netcdf variables #
################################
f = netcdf_file(ncfilename, 'r', mmap=False) # Open the netcdf file

for nc_var in netcdf_variables:             # For each variable in the netcdf_variables list
    values = f.variables[nc_var]            # Retrieve the variable values from the netcdf file
    array = np.array(values[:])             # Write the values to a Numpy array
    exec(nc_var + " = array")               # Give this array the same name as the variable (Note: this is extremely unconventional, but works well in this case!)

f.close()                                   # Close the netcdf file

#####################
# Derived variables #
#####################
EXCESS = DRYFLW_CVI - (.64+BYPFLW_CVI+USRFLW_CVI)


# boolean_mask = PUSER_CVI >= PSAMP_CVI
# time_test = Time[boolean_mask]
# print(np.count_nonzero(time_test))


#########################################################
# CONDITION                                             #
# Backflow: User pressure larger than sample pressure   #
#########################################################
backflow_mask = PUSER_CVI >= PSAMP_CVI  # backflow_mask is a boolean array: 1 if the condition is satisfied, 0 when not.
backflow_times = Time[backflow_mask]    # The boolean array is used to extract just the times that the condition is satisfied.

print("{} seconds of backflow.".format(len(backflow_times)))

for t in backflow_times:
    outputwriter.writerow({'time': t, 'qc_variable': 'CVI_quality_flag', 'flag_name': 'bad_flows', 'flag_value': 1})


#########################################################
# CONDITION                                             #
# Condensed water or total water sampling in WVISO1     #
#########################################################
condensedwater_mask = np.logical_and(DRYFLW_CVI>2, abs(EXCESS)>(0.4-0.15))
condensedwater_times = Time[condensedwater_mask]

totalwater_mask = np.invert(condensedwater_mask)
totalwater_times = Time[totalwater_mask]

print("{} seconds of condensed water sampling on CVI.".format(len(condensedwater_times)))
print("{} seconds of total water sampling on CVI.".format(len(totalwater_times)))

for t in condensedwater_times:
    outputwriter.writerow({'time': t, 'qc_variable': 'CVI_status_flag', 'flag_name': 'condensed_water', 'flag_value': 1})
for t in totalwater_times:
    outputwriter.writerow({'time': t, 'qc_variable': 'CVI_status_flag', 'flag_name': 'total_water', 'flag_value': 0})


#########################################################
# CONDITION                                             #
# Poor signal level in WVISO1&2 due to low humidity     #
#########################################################