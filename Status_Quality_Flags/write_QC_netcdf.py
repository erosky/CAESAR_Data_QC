#!/usr/bin/python
# Above command must be placed on the first line, allowing use of command line arguments

# How to use this script:
# python3 write_QC_netcdf.py RF_ncfile.nc output.nc auto_qc.csv [manual_qc.csv]

# Required Python Libraries
import sys                              # Command line arguments
from scipy.io import netcdf_file        # Reading and writing netcdf files
import numpy as np                      # Matrix and math operations
import csv                              # Read and write csv files
from collections import OrderedDict     # Ordered dictionary tool

# Verify that the correct number of input arguments is provided
n_inputs = len(sys.argv) # Number of commandline inputs
if n_inputs < 4:
    print("Incorrect number of input arguments. \nExample usage:")
    print("python3 write_QC_netcdf.py RF_ncfile.nc output.nc auto_qc.csv [manual_qc.csv]")
    sys.exit(0)

# Verify that the correct files are being read and written
ncfilename = sys.argv[1]
outputfilename = sys.argv[2]
autoqcfilename = sys.argv[3]
print("Input netcdf file: " + ncfilename)
print("Output netcdf file: " + outputfilename)
print("Auto QC data file: " + autoqcfilename)
if n_inputs == 5:
    manualexists = True
    manualqcfilename = sys.argv[4]
    print("Manual QC data file: " + manualqcfilename)
else:
    manualexists = False
    print("No manual QC")

verify = input("Is this correct? (Y/N): ") # Ask user to verify
if verify == "N":
    sys.exit(0)

#########################################################
# Get the time dimensions from the original netcdf file #
#########################################################
f_in = netcdf_file(ncfilename, 'r', mmap=False) # Open the netcdf file
time_values = f_in.variables['Time']            # Get the time variable
time = np.char.mod('%d', time_values[:])        # Convert times values into strings so they can be used more easily later
f_in.close()                                    # Close the netcdf file

print(len(time))

###########################################
# assign flag values using dictionaries   #
###########################################
''' 
For example, the 'total_water' flag is assigned the value 1.
'''
status_flag_values = {'total_water': 0, 'condensed_water': 1, 'calibration': 2, 'unknown': 3}
quality_flag_values = {'best_quality': 0, 'caution_low_humidity': 1, 'caution_inlet_flooding': 2, 'caution_residual_vapor': 3, 'bad': 4}


####################################################
# Create ordered dictionaries for each QC variable #
####################################################
''' 
Each timestamp in the netcdf file will be a dictionary Key,
and the qc flag will be its corresponding value.
All timestamps will start with a value of 0. 
The values will be updated for certain timestamps as we read in from the csv files.
'''
CVI_status_dict = OrderedDict() # Create the dictionary
for t in time:                  # Create one dictionary key for every timestamp of the original netcdf
    CVI_status_dict[t]=0        # Assign the keys a value of 0

print(len(CVI_status_dict.keys())) # Print as sanity check

CVI_quality_dict = OrderedDict()
for t in time:
    CVI_quality_dict[t]=0

WVISO1_quality_dict = OrderedDict()
for t in time:
    WVISO1_quality_dict[t]=0

WVISO2_quality_dict = OrderedDict()
for t in time:
    WVISO2_quality_dict[t]=0


######################################################################
# Read the automatic QC file and update the timestamps with qc flags #
######################################################################

autoqcfile = open(autoqcfilename, newline='')   # Open the csv file
reader = csv.DictReader(autoqcfile)             # Read the csv file

# Look for each qc_variable and reassign the value of the timestamp in the qc variable dictionary
for row in reader:
    if row['qc_variable']=='CVI_status':
        CVI_status_dict[row['time']] = status_flag_values[row['flag_name']]
    elif row['qc_variable']=='CVI_quality':
        CVI_quality_dict[row['time']] = quality_flag_values[row['flag_name']]
    elif row['qc_variable']=='WVISO1_quality':
        WVISO1_quality_dict[row['time']] = quality_flag_values[row['flag_name']]
    elif row['qc_variable']=='WVISO2_quality':
        WVISO2_quality_dict[row['time']] = quality_flag_values[row['flag_name']]

print(len(CVI_status_dict.keys())) # Print for sanity check
print(len(CVI_quality_dict.keys())) # Print for sanity check


######################################################################
# Read the manual QC file and update the timestamps with qc flags    #
######################################################################

if manualexists==True:
    manualqcfile = open(manualqcfilename, newline='')   # Open the csv file
    reader = csv.DictReader(manualqcfile)               # Read the csv file
    # Look for each qc_variable and reassign the value of the timestamp in the qc variable dictionary
    for row in reader:
        start = int(row['starttime'])
        end = int(row['endtime'])
        if row['qc_variable']=='CVI_status':
            for r in range(start,end):
                CVI_status_dict[str(r)] = status_flag_values[row['flag_name']]
        elif row['qc_variable']=='CVI_quality':
            for r in range(start,end):
                CVI_quality_dict[str(r)] = quality_flag_values[row['flag_name']]
        elif row['qc_variable']=='WVISO1_quality':
            for r in range(start,end):
                WVISO1_quality_dict[str(r)] = quality_flag_values[row['flag_name']]
        elif row['qc_variable']=='WVISO2_quality':
            for r in range(start,end):
                WVISO2_quality_dict[str(r)] = quality_flag_values[row['flag_name']]

    print(len(CVI_status_dict.keys())) # Print for sanity check
    print(len(CVI_quality_dict.keys())) # Print for sanity check

#====================================================================
#====================================================================
#====================================================================
# CREATE THE QC NETCDF FILE
#====================================================================
#====================================================================
#====================================================================

f = netcdf_file(outputfilename, 'w', mmap=False)    # Open the netcdf file
f.history = 'Created for a test'
f.createDimension('Time', len(time))                # Assign the time dimension
Time = f.createVariable('Time', 'i', ('Time',))     # Create the time variable
Time[:] = time                                      # Add the same timestamps from the RF netcdf
Time.units = time_values.units                      # Add the same time units from the RF netcdf

########################
# Add the QC variables #
########################

# CVI_status
CVI_status = f.createVariable('CVI_status', 'i', ('Time',))
CVI_status.flag_values = list(status_flag_values.values())
CVI_status.flag_meanings = ' '.join(list(status_flag_values))
CVI_status[:] = list(CVI_status_dict.values())

# CVI_quality
CVI_quality = f.createVariable('CVI_quality', 'i', ('Time',))
CVI_quality.flag_values = list(quality_flag_values.values())
CVI_quality.flag_meanings = ' '.join(list(quality_flag_values))
CVI_quality[:] = list(CVI_quality_dict.values())

# WVISO1_quality
WVISO1_quality = f.createVariable('WVISO1_quality', 'i', ('Time',))
WVISO1_quality.flag_values = list(quality_flag_values.values())
WVISO1_quality.flag_meanings = ' '.join(list(quality_flag_values))
WVISO1_quality[:] = list(WVISO1_quality_dict.values())

# WVISO2_quality
WVISO2_quality = f.createVariable('WVISO2_quality', 'i', ('Time',))
WVISO2_quality.flag_values = list(quality_flag_values.values())
WVISO2_quality.flag_meanings = ' '.join(list(quality_flag_values))
WVISO2_quality[:] = list(WVISO2_quality_dict.values())

f.close()   # Close the netcdf file