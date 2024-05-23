#!/usr/bin/python
# The code above must be placed on the first line, allowing use of command line arguments

# Required Python Libraries
import sys                          # Command line arguments
from scipy.io import netcdf_file    # Reading and writing netcdf files
import numpy as np                  # Matrix and math operations
import matplotlib.pyplot as plt     # Library for plotting

# Information about the script and command line inputs provided
n_inputs = len(sys.argv)    # Number of commandline inputs
scriptname = sys.argv[0]    # The first input is the script name

print("This script is called: " + scriptname)
print("If 3 or more arguments are provided, then this script will plot a cat.")
print("{} command line arguments were provided".format(n_inputs-1))

# If there are more input arguments beyond the script name, then print out each one.
if (n_inputs > 1):
    print("\nThe inputs are:")
    for i in range(1,n_inputs):
        print(sys.argv[i])

# Plot a cat if more than three arguments are provided
if (n_inputs > 3):
    print("\nEnjoy your cat!")

    forehead = plt.plot([2,3,4,5,7,8,9,10],[7,8,10,8,8,10,8,7])
    eyes = plt.scatter([4,8],[6.5,6.5], s=10**3, alpha=0.5)
    nose = plt.scatter([6],[5], s=10**3, marker='v', color='pink')
    mouth = plt.plot([4,5,6,6,6,7,8],[4,3,4,5,4,3,4], color='pink')
    chin = plt.plot([2,2,5,5.5,6,6.5,7,10,10],[7,4,1.5,2,1.5,2,1.5,4,7])
    #whiskers#
    plt.plot([1,5],[7,5], color='pink') 
    plt.plot([1,5],[6.5,4.5], color='pink') 
    plt.plot([7,11],[5,7], color='pink') 
    plt.plot([7,11],[4.5,6.5], color='pink') 
    #########
    plt.show()
