# This file is a demo for the 'Isothermal_Monolith_Simulator' object
import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

#Importing all reaction dictionaries
from rxns_v4 import *

# Read in the data (data is now a dictionary containing the data we want)
data = naively_read_data_file("inputfiles/SCR_all_data.txt",factor=2)

time_list = time_point_selector(data["time"], data, end_time=149)

#Factor 2x with a cutoff time of 149 gives 216 discretization points
print("Total number of data points = " + str(len(data["time"])*(len(data.keys())-1-4)))
print("Number of time-series data points = " + str(len(data["time"])))
print("Number of time-series model points = " + str(len(time_list)))
