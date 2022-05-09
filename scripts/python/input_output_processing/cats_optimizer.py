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
#og_file = "tests/test_input/simple_react_test.i"
#og_file_copy = "tests/test_input/simple_react_test_copy"

og_file = "tests/test_input/case01_CGFE.i"
og_file_copy = "tests/test_input/case01_CGFE_copy"
obj = CATS_InputFile()

obj.construct_from_file(og_file)
obj.write_stream_to_file(og_file_copy)
#print(obj.data["Kernels"]["first_order_decay"]["forward_rate"])

#def _test_obj_func(x, par):
def _test_obj_func(x, p1, p2, p3, p4):
    y_vals = [0] * len(x)
    obj.construct_from_file(og_file_copy+".i")
    #print(par)
    #obj.data["Kernels"]["first_order_decay"]["forward_rate"] = par
    #print(obj.data["Kernels"]["first_order_decay"]["forward_rate"])

    obj.data["Kernels"]["r_H2_rxn"]["oxidized_state_stoich"][0] = abs(p1)
    obj.data["Kernels"]["r_H2_rxn"]["scale"] = abs(p2)

    obj.data["Kernels"]["r_CO_rxn"]["oxidized_state_stoich"][0] = abs(p3)
    obj.data["Kernels"]["r_CO_rxn"]["scale"] = abs(p4)

    obj.write_stream_to_file(og_file_copy, rebuild=True)

    os.system("mpiexec --n 16 ../../../cats-opt -i " + og_file_copy+".i")

    csv_file = og_file_copy+"_out.csv"
    csv_obj = MOOSE_CVS_File(csv_file)

    #x-values are time values
    i=0
    j=0
    for t in x:
        if i < 4:
            y_vals[i] = csv_obj.value(t,'C_CO_out_M')
        else:
            y_vals[i] = csv_obj.value(t,'C_H2_out_M')
        i+=1
        j+=1
        if j == 4:
            j=0

    return y_vals

if __name__ == "__main__":

    #y_target = [1,0.8,0.64,0.512,0.4096,0.32768,0.262144,0.2097152,0.16777216]
    #x_obs = [0,0.25,0.5,0.75,1,1.25,1.5,1.75,2]
    #params = [0.5]

    y_target = [0.0012338,
                0.0021105,
                0.002762,
                0.0030339,

                6.49e-5,
                0.000487,
                0.001134,
                0.002161]
    x_obs = [25,40,55,70,25,40,55,70]
    params = [0.1737, 1, 0.6774, 2.5e9]

    res1 = optimization.curve_fit(_test_obj_func, x_obs, y_target, p0=params, bounds=([0.1, 0.01, 0.1, 1e8], [1., 1e3, 1., 1e12]))

    print(res1)

    #list = _test_obj_func(x_obs,params[0],params[1],params[2],params[3])
    #print(list)

    #list = _test_obj_func(x_obs,params[0]+1)

    print("END")
