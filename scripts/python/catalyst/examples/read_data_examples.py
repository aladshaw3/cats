# This file is a demo for the 'Isothermal_Monolith_Simulator' object
import sys
sys.path.append('../..')

from catalyst.isothermal_monolith_catalysis import *

# Reading data files
data_tup = naively_read_data_file("inputfiles/sample_tuple_data.txt", factor=3, dict_of_tuples=True)
data = naively_read_data_file("inputfiles/sample_tuple_data.txt", factor=3, dict_of_tuples=False)


i=0
print("Old Dict")
for time in data["time"]:
    print(str(time) + "\t" + str(data["NH3"][i]))
    i+=1
print()
print("New Dict")
for set in data_tup["NH3"]:
    print(str(set[0]) + "\t" + str(set[1]))

#NOTE: Since the read function can now return a list of tuples, that data can
#       be used to setup BCs in the model object using the 'set_time_dependent_BC'
#       function. 
