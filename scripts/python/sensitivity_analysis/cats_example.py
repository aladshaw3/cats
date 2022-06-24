import math
import sys, os
# NOTE: If your function has multiple returns, you can return a numpy array to get all results
import numpy as np
from sensitivity import *
sys.path.append('..') #Jump out of directory 1 level
from input_output_processing.cats_input_file_writer import *
from input_output_processing.read_moose_csv_to_df import *


# CATS sensitivity run function (expects 3 states for all conditions)
def cats_co2_run(params, conds, other):
    cats_file_obj = other["CATS_obj"]               #class object
    folder = "co2_sens_input_2"
    output_file = other["result_file_basename"]     #string

    #Input file base name varies depending on channel_depth condition
    #   Channel depth conditions = (0.49, 0.98, 1.47)

    # expects depth = 1.47
    if conds["channel_depth"] > 0.99:
        input_file = "co2_sens_input_2/case01_CGFE.i"
    # expects depth = 0.98
    elif conds["channel_depth"] > 0.50:
        input_file = "co2_sens_input_2/case01_CGFE_short.i"
    # expects depth = 0.49
    else:
        input_file = "co2_sens_input_2/case01_CGFE_shorter.i"

    # Read the input file into the object
    cats_file_obj.construct_from_file(input_file)

    #Replace params/conds with those in given dict
    #   Number of simulations = num_states^num_conds
    cats_file_obj.data["AuxVariables"]["T_e"]["initial_condition"] = conds["temperature"]
    cats_file_obj.data["AuxVariables"]["T_s"]["initial_condition"] = conds["temperature"]

    cats_file_obj.data["AuxKernels"]["current_step_input"]["aux_vals"][0] = conds["applied_current"]

    cats_file_obj.data["AuxKernels"]["flowrate_step_input"]["aux_vals"][0] = conds["flowrate"]

    # What to do with particle size
    cats_file_obj.data["AuxVariables"]["dp"]["initial_condition"] = conds["particle_diameter"]
    cats_file_obj.data["AuxVariables"]["dp_inv"]["initial_condition"] = 1.0/conds["particle_diameter"]
    cats_file_obj.data["AuxVariables"]["As"]["initial_condition"] = 6.0*(1.0-0.8)/conds["particle_diameter"]


    #Rebuild the CATS input stream and write to new (or same file)
    new_file = output_file+"_"+other["RunNum"]
    cats_file_obj.write_stream_to_file(new_file, rebuild=True)

    #Call the executable for the simulation
    os.system("mpiexec --n 16 ../../../cats-opt -i " + new_file+".i")
    # NOTE: Sometimes MOOSE will hang on the last simulation step. If I kill
    #       the process, then the script will continue. It may be worth trying
    #       to find a way to auto-kill the process if it hangs for too long.

    #Remove the old input file
    #   Allows me to keep the result csv files while removing the .i files generated
    if os.path.exists(new_file+".i"):
        os.remove(new_file+".i")

    #Read in the result csv file
    result_file = new_file+"_out.csv"
    csv_obj = MOOSE_CVS_File(result_file)

    #Perform some computation
    #res = csv_obj.value(515,'C_CO_out_M') * -csv_obj.value(515,'Q_out_cu_mm_p_s') * 2 * 0.096485 / csv_obj.value(515,'I_in_Amps')
    res = csv_obj.value(515,'FE_CO')

    #Track the number of runs (so each output can have different name)
    other["RunNum"] = str(int(other["RunNum"])+1)   #string

    # Return the result
    return res

# ---------- Testing -------------
if __name__ == "__main__":
    test_params = {}

    test_conds = {}
    test_conds["temperature"] = 298 #to 353
    test_conds["applied_current"] = 0.001 #to 0.004
    test_conds["flowrate"] = 500 #to 1666.67
    test_conds["particle_diameter"] = 0.015 #to 0.03
    test_conds["channel_depth"] = 0.49 #to 1.47

    test_args = {}
    test_args["CATS_obj"] = CATS_InputFile()
    test_args["result_file_basename"] = "co2_sens_input_2/case01_CGFE"
    test_args["RunNum"] = "0"

    test_tuples = {}
    test_tuples["temperature"] = (test_conds["temperature"], 353)
    test_tuples["applied_current"] = (test_conds["applied_current"], 0.004)
    test_tuples["flowrate"] = (test_conds["flowrate"], 1666.67)
    test_tuples["particle_diameter"] = (test_conds["particle_diameter"], 0.03)
    test_tuples["channel_depth"] = (test_conds["channel_depth"], 1.47)


    test_obj = SensitivitySweep(cats_co2_run, test_params, test_tuples, test_args)
    test_obj.run_exhaustive_sweep("co2_sens_input_2/sens_res_co2","co2_sensitivity_cats_02",
                    relative=True,per=10,cond_limit=2,skip_partials=True)
