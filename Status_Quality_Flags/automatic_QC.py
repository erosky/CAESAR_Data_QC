#!/usr/bin/python
# Above command must be placed on the first line, allowing use of command line arguments

# How to use this script:
# python3 automatic_QC.py ncfile.nc output.csv


# Required Python Libraries
import sys                  # Command line arguments
from scipy.io import netcdf_file # Reading and writing netcdf files
import numpy as np          # Matrix and math operations
import csv                  # Read and write csv files
from scipy.ndimage import label

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
outputfieldnames = ['time', 'qc_variable', 'flag_name']
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
"USRFLW_CVI",
"H2O_WVISO1",
"H2O_WVISO2",
"d18O_WVISO1",
"d18O_WVISO2"
]

################################
# Read in the netcdf variables #
################################
f = netcdf_file(ncfilename, 'r', mmap=False) # Open the netcdf file
v = {}  # Empty dictionary to store the variables

for nc_var in netcdf_variables:             # For each variable in the netcdf_variables list
    values = f.variables[nc_var]            # Retrieve the variable values from the netcdf file
    array = np.array(values[:])             # Write the values to a Numpy array
    v[nc_var] = array                      # Store the array in the dictionary

f.close()                                   # Close the netcdf file

#####################
# Derived variables #
#####################
v['EXCESS'] = v['DRYFLW_CVI'] - (.64+v['BYPFLW_CVI']+v['USRFLW_CVI'])


# boolean_mask = PUSER_CVI >= PSAMP_CVI
# time_test = Time[boolean_mask]
# print(np.count_nonzero(time_test))


#########################################################
# CONDITION                                             #
# Backflow: User pressure larger than sample pressure   #
#########################################################
backflow_mask = v['PUSER_CVI'] >= v['PSAMP_CVI']  # backflow_mask is a boolean array: 1 if the condition is satisfied, 0 when not.
backflow_times = v['Time'][backflow_mask]    # The boolean array is used to extract just the times that the condition is satisfied.

print("{} seconds of backflow.".format(len(backflow_times)))

for t in backflow_times:
    outputwriter.writerow({'time': t, 'qc_variable': 'CVI_quality', 'flag_name': 'bad'})
    outputwriter.writerow({'time': t, 'qc_variable': 'WVISO1_quality', 'flag_name': 'bad'})


#########################################################
# CONDITION                                             #
# Condensed water or total water sampling in WVISO1     #
#########################################################
condensedwater_mask = np.logical_and(v['DRYFLW_CVI']>2, abs(v['EXCESS'])>(0.4-0.15))
condensedwater_times = v['Time'][condensedwater_mask]

totalwater_mask = v['DRYFLW_CVI']<0.15
totalwater_times = v['Time'][totalwater_mask]

print("{} seconds of condensed water sampling on CVI.".format(len(condensedwater_times)))
print("{} seconds of total water sampling on CVI.".format(len(totalwater_times)))

for t in condensedwater_times:
    outputwriter.writerow({'time': t, 'qc_variable': 'CVI_status', 'flag_name': 'condensed_water'})
    outputwriter.writerow({'time': t, 'qc_variable': 'WVISO1_status', 'flag_name': 'condensed_water'})
for t in totalwater_times:
    outputwriter.writerow({'time': t, 'qc_variable': 'CVI_status', 'flag_name': 'total_water'})
    outputwriter.writerow({'time': t, 'qc_variable': 'WVISO1_status', 'flag_name': 'total_water'})


#########################################################
# CONDITION                                             #
# Poor signal level in WVISO1&2 due to low humidity     #
#########################################################
# low humidity should last at least 3 seconds to justify flagging
humidity_threshold = 30
time_threshold = 3

### WVISO1 cvi 
WVISO1_humidity_mask = v['H2O_WVISO1'] <= humidity_threshold 
WVISO1_labeled_array, WVISO1_num_events = label(WVISO1_humidity_mask)

for low_h2o in range(WVISO1_num_events):
    if sum(WVISO1_labeled_array == low_h2o) < time_threshold:              # If the low himidy doesn't last more than 3 seconds
        low_h2o_indexes = np.where(WVISO1_labeled_array == low_h2o)[0]     # Find the indexes corresponding to these times
        WVISO1_humidity_mask[low_h2o_indexes] = 0                          # Remove these times from the low humidity mask

WVISO1_lowH2O_times = v['Time'][WVISO1_humidity_mask]    # The boolean array is used to extract just the times that the condition is satisfied.
print("{} seconds of low humidity on WVISO1.".format(len(WVISO1_lowH2O_times)))

for t in WVISO1_lowH2O_times:
    outputwriter.writerow({'time': t, 'qc_variable': 'WVISO1_quality', 'flag_name': 'caution_low_humidity'})

### WVISO2 sdi
WVISO2_humidity_mask = v['H2O_WVISO2'] <= humidity_threshold 
WVISO2_labeled_array, WVISO2_num_events = label(WVISO2_humidity_mask)

for low_h2o in range(WVISO2_num_events):
    if sum(WVISO2_labeled_array == low_h2o) < time_threshold:              # If the low himidy doesn't last more than 3 seconds
        low_h2o_indexes = np.where(WVISO2_labeled_array == low_h2o)[0]     # Find the indexes corresponding to these times
        WVISO2_humidity_mask[low_h2o_indexes] = 0                          # Remove these times from the low humidity mask

WVISO2_lowH2O_times = v['Time'][WVISO2_humidity_mask]    # The boolean array is used to extract just the times that the condition is satisfied.
print("{} seconds of low humidity on WVISO2.".format(len(WVISO2_lowH2O_times)))

for t in WVISO2_lowH2O_times:
    outputwriter.writerow({'time': t, 'qc_variable': 'WVISO2_quality', 'flag_name': 'caution_low_humidity'})





#########################################################
# CONDITION                                             #
# sufficient signal level but d180 is positive          #
#########################################################
### WVISO1 cvi
WVISO1_d180_mask = np.logical_and(v['d18O_WVISO1']>0, WVISO1_humidity_mask==0)
WVISO1_d180_times = v['Time'][WVISO1_d180_mask]    # The boolean array is used to extract just the times that the condition is satisfied.

print("{} seconds of positive d180 on WVISO1.".format(len(WVISO1_d180_times)))

# for t in WVISO1_d180_times:
#     outputwriter.writerow({'time': t, 'qc_variable': 'WVISO1_quality', 'flag_name': 'caution_residual_vapor'})


### WVISO2 sdi
WVISO2_d180_mask = np.logical_and(v['d18O_WVISO2']>0, WVISO2_humidity_mask==0)
WVISO2_d180_times = v['Time'][WVISO2_d180_mask]    # The boolean array is used to extract just the times that the condition is satisfied.
print("{} seconds of positive d180 on WVISO2.".format(len(WVISO2_d180_times)))

for t in WVISO2_d180_times:
    outputwriter.writerow({'time': t, 'qc_variable': 'WVISO2_quality', 'flag_name': 'caution_residual_vapor'})


#########################################################
# CONDITION                                             #
# switched from off CVI to on CVI                       #
#########################################################
# Couple seconds after turning on counterflow, the WVISO1 H2O and isotope values won't be real as they transition.
buffer_duration = 10

# find change in counterflow using gradient
dt = 1.0 # 1 second interval between each datapoint
flow_derivative = np.gradient(v['DRYFLW_CVI'], dt)
off2on = abs(flow_derivative) > 2.0
print(flow_derivative[off2on])

flow_off2on_times = v['Time'][off2on]    # The boolean array is used to extract just the times that the condition is satisfied.
print("{} transitions from low to high dry counterflow.".format(len(flow_off2on_times)))

for t in flow_off2on_times:
    for b in range(buffer_duration+1):
        outputwriter.writerow({'time': t+b, 'qc_variable': 'WVISO1_quality', 'flag_name': 'bad'})