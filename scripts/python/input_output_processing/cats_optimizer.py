'''
    This script will setup a simple scipy optimization routine by combining
    the 'CATS_InputFile' and 'MOOSE_CVS_File' classes. CATS_InputFile will
    be used to read or create a simulation run case. The dict is then used
    to identify a set of parameters to vary. Python will direct simulations
    to run and output results to .csv files. MOOSE_CVS_File object will read
    those outputs to provide feedback and then change the parameters as needed.

    Author:     Austin Ladshaw
    Date:       05/06/2022
    Copyright:  This kernel was designed and built at Oak Ridge National
                Laboratory by Austin Ladshaw for research in the area
                of adsorption, catalysis, and surface science.
'''
# import statements
from cats_input_file_writer import *
from read_moose_csv_to_df import *

# simple optimization (may change this later)
import scipy.optimize as optimization

# in global scope for testing
og_file = "tests/test_input/simple_react_test.i"
og_file_copy = "tests/test_input/simple_react_test_copy"
obj = CATS_InputFile()

obj.construct_from_file(og_file)
obj.write_stream_to_file(og_file_copy)
#print(obj.data["Kernels"]["first_order_decay"]["forward_rate"])

def _test_obj_func(x, par):
    y_vals = [0] * len(x)
    obj.construct_from_file(og_file_copy+".i")
    #print(par)
    obj.data["Kernels"]["first_order_decay"]["forward_rate"] = par
    #print(obj.data["Kernels"]["first_order_decay"]["forward_rate"])
    obj.write_stream_to_file(og_file_copy, rebuild=True)
    os.system("mpiexec --n 12 ../../../cats-opt -i " + og_file_copy+".i")

    csv_file = "tests/test_input/simple_react_test_copy_out.csv"
    csv_obj = MOOSE_CVS_File(csv_file)

    #x-values are time values
    i=0
    for t in x:
        y_vals[i] = csv_obj.value(t,'A')
        i+=1

    return y_vals

if __name__ == "__main__":

    y_target = [1,0.8,0.64,0.512,0.4096,0.32768,0.262144,0.2097152,0.16777216]
    x_obs = [0,0.25,0.5,0.75,1,1.25,1.5,1.75,2]
    params = [0.5]

    res1 = optimization.curve_fit(_test_obj_func, x_obs, y_target, p0=params)

    print(res1)

    #list = _test_obj_func(x_obs,params[0])

    #list = _test_obj_func(x_obs,params[0]+1)

    print("END")
