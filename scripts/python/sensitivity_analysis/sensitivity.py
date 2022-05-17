##   @package sensitivity
#
#    @brief Simple Sensitivity Analysis
#
#    @details Python script to perform a sensitivity analysis on a simple model
#                by taking finite partial derivatives of that model given a set of
#                parameters.
#
#    @author Austin Ladshaw
#
#    @date 02/12/2020
#
#    @copyright This software was designed and built at the Oak Ridge National
#                    Laboratory (ORNL) National Transportation Research Center
#                    (NTRC) by Austin Ladshaw for research in the catalytic
#                    reduction of NOx. Copyright (c) 2020, all rights reserved.

import math
import sys, os
sys.path.append('..') #Jump out of directory 1 level
from input_output_processing.cats_input_file_writer import *
from input_output_processing.read_moose_csv_to_df import *

## Sensivity class object for simple analyses
#
#   This object is used to perform small to medium scale sensitivity analyses
#   on a model function written in python. It provides a quick an easy way to
#   check a simple model to see the responsiveness in the model to changes in
#   its parameters. Changes can be computed as finite difference derivatives or
#   percent changes in function response
#
#
#   NOTE:
#
#       func_params and func_conds are (or can be) used interchangibly. The
#       difference is when the routine looks to compute sensitivity, it only
#       does so for the func_params under the conditions of the system.
class Sensitivity(object):
    ##Constructor for the object
    #
    #   @param func pointer to a func defined and written in python
    #   @param func_params map or dictionary of parameters the function depends on
    #   @param func_conds map or dictionary of conditions the function depends on
    #   @param func_args map or dictionary of other function arguments passed to function
    def __init__(self, func, func_params, func_conds, func_args):
        # Check to make sure the arguments are dictionaries
        if type(func_params) is not dict:
            raise RuntimeError("Error! func_params must be a dictionary object!")
        if type(func_conds) is not dict:
            raise RuntimeError("Error! func_conds must be a dictionary object!")

        # Check to make sure func is a Function
        if callable(func) == False:
            raise RuntimeError("Error! func must be a callable function object!")

        #NOTE: func_params and func_conds should be map objects whose keys are the names of parameters or conditions of interest
        ##A function that produces a single output given a set of parameters and conditions
        self.func = func
        ##A set of parameters that the sensitivity analysis will be performed on
        self.func_params = func_params
        ##A set of other conditions or information the model needs to use
        self.func_conds = func_conds
        ##A set of other function arguments that the function needs to operate
        self.func_args = func_args
        ##Computed set of partial derivatives or percent changes
        self.partials = {}
        ##When set to True, the partials are computed based on a percent change to the variable
        self.relative_sensitivity = False
        ##Percent change to apply to parameters when relative_sensitivity = True
        self.percent_change = 0.0
        self.partials_computed = False
        self.lowest_sensitivity = ""
        self.highest_sensitivity = ""
        ##Stores a sorted map of most to least sensitve parameters
        self.sorted_param_sensitivity = {}

        #Initialize the list of partial derivatives and look for errors
        for item in self.func_params:
            if item in self.partials.keys():
                raise RuntimeError("Error! Duplicate parameter name!")
            #Check the func_params at the item to make sure it is a number
            if type(self.func_params[item]) is not int and type(self.func_params[item]) is not float:
                raise RuntimeError("Error! Parameters must be numbers!")

            self.partials[item] = 0.0

    ##Function to print the results of the analysis to the console
    def __str__(self):
        if self.partials_computed == False:
            return "Analysis not yet performed! Call function 'compute_partials' first...\n"
        else:
            if self.relative_sensitivity == False:
                message = " ------------ Sensitivity Analysis Performed using Standard Finite Differences ------------ \n"
            else:
                message = " ------------ Sensitivity Analysis Performed using " + str(self.percent_change)+ "% Change in Parameters ------------ \n"
            message += "Function parameters:\n"
            for item in self.func_params:
                message += "\t" + str(item) + "\t" + str(self.func_params[item]) + "\n"
            message += "Function conditions:\n"
            for item in self.func_conds:
                message += "\t" + str(item) + "\t" + str(self.func_conds[item]) + "\n"
            message += "Function Arguments:\n"
            for item in self.func_args:
                message += "\t" + str(item) + "\t" + str(self.func_args[item]) + "\n"
            message += "Partial derivatives:\n"
            for item in self.partials:
                message += "\t" + str(item) + "\t" + str(self.partials[item]) + "\n"
            message += "Sorted Sensitivity:\n"
            for item in self.sorted_param_sensitivity:
                message += "\t" + str(item) + "\t" + str(self.sorted_param_sensitivity[item]) + "\n"
            message += "Most sensitive parameter: " + self.highest_sensitivity + "\n"
            message += "Least sensitive parameter: " + self.lowest_sensitivity + "\n"
            return message

    ##Function to call the users function with their parameters and conditions
    def eval_func(self):
        return self.func(self.func_params,self.func_conds,self.func_args)

    ##Function to compute all partials
    #
    #   @param relative if False, then partials are computed via finite difference derivatives \n
    #                   if True, then partials are computed as percent changes in function for percent change in parameters
    #   @param per the percentage change to use in the parameters (only used if relative == True)
    def compute_partials(self, relative = False, per = 1):
        old_func = self.eval_func()
        self.relative_sensitivity = relative
        self.percent_change = per
        i = 0
        smallest = 0
        largest = 0
        for param_name in self.partials:
            old_value = self.func_params[param_name]
            if relative == False:
                new_value = old_value + math.sqrt(sys.float_info.epsilon)
            else:
                new_value = (1 + (per/100))*old_value
            self.func_params[param_name] = new_value
            new_func = self.eval_func()
            self.func_params[param_name] = old_value
            try:
                if relative == False:
                    self.partials[param_name] = (new_func-old_func)/(new_value-old_value)
                else:
                    try:
                        self.partials[param_name] = (new_func-old_func)/old_func*100
                    except:
                        try:
                            self.partials[param_name] = (new_func-old_func)/new_func*100
                        except:
                            self.partials[param_name] = 0
            except:
                new_value = 1.01*old_value
                self.func_params[param_name] = new_value
                new_func = self.eval_func()
                self.func_params[param_name] = old_value
                if relaive == False:
                    self.partials[param_name] = (new_func-old_func)/(new_value-old_value)
                else:
                    try:
                        self.partials[param_name] = (new_func-old_func)/old_func*100
                    except:
                        try:
                            self.partials[param_name] = (new_func-old_func)/new_func*100
                        except:
                            self.partials[param_name] = 0
            if i == 0:
                smallest = abs(self.partials[param_name])
                self.lowest_sensitivity = param_name
                largest = abs(self.partials[param_name])
                self.highest_sensitivity = param_name
            else:
                try:
                    if abs(self.partials[param_name].any()) > largest.any():
                        largest = abs(self.partials[param_name])
                        self.highest_sensitivity = param_name
                except:
                    if abs(self.partials[param_name]) > largest:
                        largest = abs(self.partials[param_name])
                        self.highest_sensitivity = param_name
                try:
                    if abs(self.partials[param_name].any()) < smallest.any():
                        smallest = abs(self.partials[param_name])
                        self.lowest_sensitivity = param_name
                except:
                    if abs(self.partials[param_name]) < smallest:
                        smallest = abs(self.partials[param_name])
                        self.lowest_sensitivity = param_name
            i += 1
        self.partials_computed = True
        #Sort the parameters from most to least sensitive
        try:
            self.sorted_param_sensitivity = {k: v for k, v in sorted(self.partials.items(), key=lambda item: abs(item[1].any()), reverse=True)}
        except:
            self.sorted_param_sensitivity = {k: v for k, v in sorted(self.partials.items(), key=lambda item: abs(item[1]), reverse=True)}

# ----------- End: Definition of Class object for Sensitivity --------------------

##Helper function to iterate through all permutations of conditions
#
#   What this function does is update the given list of cond_value according to
#       the corresponding limits given. This allows the sensitivity sweep object
#       to iteratively move through all permutations of conditions, within the
#       specified limits, to check all combinations of conditions for parameter
#       sensivitity.
#
#   Number of permutations = S^c
#       where S = number of states  &&  c = number of conditions
#
#   For Instance:
#
#       Consider a state machine that has 3 conditions (A, B, C), each of which can
#       have 3 different states (0, 1, 2). To exhaustively test all the states
#       possible, we have to iterate through all permutations of the variables
#       A, B, and C, at all possible states they can be in (0, 1, 2). In total,
#       there would be 3^3 (=27) permutations to produce.
#
#   The above example would need to produce the following...
#
#   A B C   |  A B C   |  A B C \n
#   --------------------------- \n
#   0 0 0   |  0 0 1   |  0 0 2 \n
#   1 0 0   |  1 0 1   |  1 0 2 \n
#   2 0 0   |  2 0 1   |  2 0 2 \n
#   0 1 0   |  0 1 1   |  0 1 2 \n
#   1 1 0   |  1 1 1   |  1 1 2 \n
#   2 1 0   |  2 1 1   |  2 1 2 \n
#   0 2 0   |  0 2 1   |  0 2 2 \n
#   1 2 0   |  1 2 1   |  1 2 2 \n
#   2 2 0   |  2 2 1   |  2 2 2 \n
#
#
#   The function only changes one state at a time and that changed state is based on
#   the current state passed to it. It is meant to be coupled with a while loop that
#   will start from an initial state and continue until this function returns true.
#   When this function returns false, this means that states can still be updated.
#
#
#   Function will return True after the last permutation has been made
#
# @param cond_value  current list of values of conditions that needs updating
# @param cond_limit_lower  list of the upper limits of the conditions
# @param cond_limit_upper  list of the upper limits of the conditions
def update_cond(cond_value, cond_limit_lower, cond_limit_upper, user_base=None):
    complete = False
    i = 0
    for value in cond_value:
        dist = cond_limit_upper[i] - cond_limit_lower[i]
        if abs(dist) <= 10*math.sqrt(sys.float_info.epsilon):
            #print("Skipped this analysis... Spacing between bounds is too small\n")
            cond_value[i] = cond_limit_lower[i]
            if i == len(cond_limit_upper)-1:
                complete = True
        else:
            #base is calculated based on the number of conditions to vary
            #       min_base = 2 (can't do less than this) -->  max_base = 10 (don't need more than this)
            if user_base == None:
                base = int(math.pow(10,math.log10(100000)/len(cond_value)))
                if base > 10:
                    base = 10
                if base < 2:
                    base = 2
            else:
                base = user_base
            if base == 0:
                complete = True
                return complete
            update = dist/base
            if value+update <= cond_limit_upper[i]:
                cond_value[i] = value+update
                break
            else:
                cond_value[i] = cond_limit_lower[i]
                if i == len(cond_limit_upper)-1:
                    complete = True
        i+=1
    return complete


## SensitivitySweep class object for performing a full sensivitity analysis
#
# The SensitivitySweep object is an object that uses the Sensitivity object to
#    calculation partials or changes in a model with changes in parameters, but
#    also repeats this process for a ranged of conditions to produce sensitivity
#    matrices that are output to a file. This is necessary for complex models as
#    it is possible that a model will not be sensitive to a certain parameter under
#    certain conditions, but becomes more sensitive as the conditions change.
class SensitivitySweep(object):
    ## Constructor for the sweep object
    #
    #   @param func pointer to a func defined and written in python
    #   @param func_params map or dictionary of parameters the function depends on
    #   @param func_conds_tuples map of tuples of conditions to sweep through
    #           where the first tuple arg is the lower_limit and the second is the upper_limit
    #
    #   NOTE:
    #
    #         func_conds_tuples must be a dictionary whose keys are the simulation/model
    #        condtions and whose values are tuples representing the lower and upper
    #        bounds of the conditions, respectively.
    #
    #            e.g.,  func_conds_tuples["Temp"] = (273, 373)
    #
    #                        a condition for temperature that spans 100 degrees
    def __init__(self, func, func_params, func_conds_tuples, func_args):
        self.sweep_computed = False
        start_conditions = {}
        if type(func_conds_tuples) is not dict:
            raise RuntimeError("Error! func_conds_tuples must be a dictionary object!")
        for item in func_conds_tuples:
            if type(func_conds_tuples[item]) is not tuple:
                raise RuntimeError("Error! Items in func_conds_tuples must be tuples!")

            start_conditions[item] = func_conds_tuples[item][0]
        self.cond_tuples = func_conds_tuples
        self.sens_obj = Sensitivity(func, func_params, start_conditions, func_args)
        ##Initialize a list of maps for sensitivity results to be stored digitally
        #
        # The below object (self.sens_maps) has the following format...
        #
        #        self.sens_maps[i] = {}                          // i = permutation number  -->  map of data
        #
        #        self.sens_maps[i]["func_result"]                // = result of the function for that permutation
        #
        #        self.sens_maps[i]["cond_set"] = {}              // map of conditions for the given permutation
        #
        #        self.sens_maps[i]["param_response"] = {}        // map of function responses or partials for the parameters at that permutation
        #
        #        self.sens_maps[i]["cond_set"][cond]             // = value of the given condition (cond) for the given permutation
        #
        #        self.sens_maps[i]["param_response"][param]      // = value of the function response to a change in the given parameter (param) for that permutation
        #
        self.sens_maps = []

        ## Map of each parameter's maximum sensitivity
        # The below objects (max_* and min_* sens_map) have the following format...
        #
        #        self.*_sens_map[param] = {}                     // map of max or min parameter results for the given param
        #                                                        //      Keys in this map include: func_result, param_response, and cond_set
        #
        #        self.*_sens_map[param]["func_result"]           // = result of the function for that max or min param sensitivity result
        #
        #        self.*_sens_map[param]["param_response"]        // = value of the function response to the param change under these conditions
        #                                                        //      This will be the max or min response for the parameter
        #
        #        self.*_sens_map[param]["cond_set"] = {}         // map of conditions for the max or min parameter response
        #
        #        self.*_sens_map[param]["cond_set"][cond]        // = value of the given condition (cond) for the max or min parameter response
        self.max_sens_map = {}
        ## Map of each parameter's minimum sensitivity
        # The below objects (max_* and min_* sens_map) have the following format...
        #
        #        self.*_sens_map[param] = {}                     // map of max or min parameter results for the given param
        #                                                        //      Keys in this map include: func_result, param_response, and cond_set
        #
        #        self.*_sens_map[param]["func_result"]           // = result of the function for that max or min param sensitivity result
        #
        #        self.*_sens_map[param]["param_response"]        // = value of the function response to the param change under these conditions
        #                                                        //      This will be the max or min response for the parameter
        #
        #        self.*_sens_map[param]["cond_set"] = {}         // map of conditions for the max or min parameter response
        #
        #        self.*_sens_map[param]["cond_set"][cond]        // = value of the given condition (cond) for the max or min parameter response
        self.min_sens_map = {}
        for param in func_params:
            self.max_sens_map[param] = {}
            self.min_sens_map[param] = {}
            self.max_sens_map[param]["func_result"] = 0
            self.min_sens_map[param]["func_result"] = 0
            self.max_sens_map[param]["param_response"] = 0
            self.min_sens_map[param]["param_response"] = 0
            self.max_sens_map[param]["cond_set"] = {}
            self.min_sens_map[param]["cond_set"] = {}
            for cond in start_conditions:
                self.max_sens_map[param]["cond_set"][cond] = 0
                self.min_sens_map[param]["cond_set"][cond] = 0

    ##Function to print out results to console (Only useful for quick visualization. Sweeps automatically puts this info in a text file)
    def __str__(self):
        message = "\n"
        if self.sweep_computed == False:
            message += "Sensitivity Analysis has not yet been performed... Need to execute run_sweep() or run_exhaustive_sweep() first...\n"
        else:
            message += "------------- Sensitivity Analysis Report -------------\n"
            message += "\nPermutation\tfunc_result"
            for cond in self.sens_maps[0]["cond_set"]:
                message += "\t" + cond
            for param in self.sens_maps[0]["param_response"]:
                message += "\t" + param
            i = 0
            for map in self.sens_maps:
                message += "\n" + str(i) + "\t" + str(map["func_result"])
                for cond in map["cond_set"]:
                    message += "\t" + str(map["cond_set"][cond])
                for param in map["param_response"]:
                    message += "\t" + str(map["param_response"][param])
                i+=1
        return message

    ##Run the Sensitivity Sweep Analysis and print results to a file
    #
    #       User may also specify whether or not to use relative parameter changes and the percent to change
    #
    #   @param folder where to save the results
    #   @param sensitivity_file_name name of the file to save
    #   @param relative True=relative differences with 'per' percentage change, False=Partial derivatives
    #   @param cond_limit Number of steps to take in conditions loop
    #   @param skip_partials True=Just evaluate function at the given conditions, False=Evaluate and get partials
    def run_sweep(self, folder = "",
                        sensitivity_file_name = "SensitivitySweepAnalysis.dat",
                        relative = False,
                        per = 1,
                        cond_limit=1,
                        skip_partials=False):
        #Enfore a .dat file extension. This is used to flag the file as very large so that
        #   our git tracking ignores that file. May be unnecessary, but better safe than sorry.
        if folder != "":
            if folder[-1] != "/":
                folder += "/"
            if not os.path.exists(folder):
                os.makedirs(folder)

        set = sensitivity_file_name.split('.')
        sensitivity_file_name = set[0] + ".dat"
        max_min_file = set[0] + "-MaxMinAnalysis.dat"
        file = open(folder+sensitivity_file_name,'w')
        mmfile = open(folder+max_min_file,'w')
        #Write out header information
        file.write("-------------- Sensitivity Sweep Results ---------------\n")
        if relative == False:
            file.write("\tAnalysis performed using Finite Differences\n")
        else:
            file.write("\tAnalysis performed using " + str(per) + "% Change in baseline parameter values\n")
        file.write("\nSystem Parameters:\n")
        for item in self.sens_obj.func_params:
            file.write(str(item) + "\t" + str(self.sens_obj.func_params[item]) + "\n")
        file.write("\nSystem Baseline Conditions:\n")
        for item in self.sens_obj.func_conds:
            file.write(str(item) + "\t" + str(self.sens_obj.func_conds[item]) + "\n")
        file.write("\nSystem Function Arguments:\n")
        for item in self.sens_obj.func_args:
            file.write(str(item) + "\t" + str(self.sens_obj.func_args[item]) + "\n")

        mmfile.write("-------------- Sensitivity Sweep Results (Max and Min Sensitivities) ---------------\n")
        if relative == False:
            mmfile.write("\tAnalysis performed using Finite Differences\n")
        else:
            mmfile.write("\tAnalysis performed using " + str(per) + "% Change in baseline parameter values\n")
        mmfile.write("\nSystem Parameters:\n")
        for item in self.sens_obj.func_params:
            mmfile.write(str(item) + "\t" + str(self.sens_obj.func_params[item]) + "\n")
        mmfile.write("\nSystem Function Arguments:\n")
        for item in self.sens_obj.func_args:
            mmfile.write(str(item) + "\t" + str(self.sens_obj.func_args[item]) + "\n")

        #Begin looping through conditions, running sensitivity analyses, and printing results in a matrix
        i = 0
        j = 0
        for cond in self.sens_obj.func_conds:
            file.write("\n")
            file.write("Sensitivity Matrix for " + str(cond) + "\n-----------------------------\n")
            file.write(str(cond))
            file.write("\tfunc_result")
            for param in self.sens_obj.func_params:
                if relative == False:
                    file.write("\tdf/d("+str(param)+")")
                else:
                    file.write("\tdf(%)@d("+str(param)+")")
            file.write("\n")

            og_cond = self.sens_obj.func_conds[cond]
            #Check to see what type of data the condition is (should be number or boolean)
            if type(self.sens_obj.func_conds[cond]) is int or type(self.sens_obj.func_conds[cond]) is float:
                dist = self.cond_tuples[cond][-1] - self.cond_tuples[cond][0]
                if abs(dist) <= 10*math.sqrt(sys.float_info.epsilon):
                    file.write("Skipped this analysis... Spacing between bounds is too small\n")
                else:
                    if cond_limit > 0:
                        dx = dist/cond_limit
                    else:
                        dx = 0
                    for n in range(0,cond_limit+1):
                        update = self.cond_tuples[cond][0] + n*dx
                        #print(str(cond) + "\t" + str(update))
                        self.sens_obj.func_conds[cond] = update
                        if skip_partials == False:
                            self.sens_obj.compute_partials(relative, per)
                        func_value = self.sens_obj.eval_func()
                        self.sens_maps.append({})
                        self.sens_maps[j]["func_result"] = func_value
                        self.sens_maps[j]["cond_set"] = {}
                        self.sens_maps[j]["param_response"] = {}

                        for c in self.sens_obj.func_conds:
                            self.sens_maps[j]["cond_set"][c] = self.sens_obj.func_conds[c]
                        file.write(str(self.sens_obj.func_conds[cond]))
                        file.write("\t"+str(func_value))
                        for param in self.sens_obj.func_params:
                            file.write("\t"+str(self.sens_obj.partials[param]))
                            self.sens_maps[j]["param_response"][param] = self.sens_obj.partials[param]

                            #Check and record maximum and minmum responses for each parameter
                            if j == 0:
                                self.max_sens_map[param]["param_response"] = self.sens_maps[j]["param_response"][param]
                                self.min_sens_map[param]["param_response"] = self.sens_maps[j]["param_response"][param]
                                self.max_sens_map[param]["func_result"] = func_value
                                self.min_sens_map[param]["func_result"] = func_value
                                for c in self.sens_obj.func_conds:
                                    self.max_sens_map[param]["cond_set"][c] = self.sens_obj.func_conds[c]
                                    self.min_sens_map[param]["cond_set"][c] = self.sens_obj.func_conds[c]
                            else:
                                try:
                                    if abs(self.sens_maps[j]["param_response"][param].any()) > abs(self.max_sens_map[param]["param_response"].any()):
                                        self.max_sens_map[param]["param_response"] = self.sens_maps[j]["param_response"][param]
                                        self.max_sens_map[param]["func_result"] = func_value
                                        for c in self.sens_obj.func_conds:
                                            self.max_sens_map[param]["cond_set"][c] = self.sens_obj.func_conds[c]
                                except:
                                    if abs(self.sens_maps[j]["param_response"][param]) > abs(self.max_sens_map[param]["param_response"]):
                                        self.max_sens_map[param]["param_response"] = self.sens_maps[j]["param_response"][param]
                                        self.max_sens_map[param]["func_result"] = func_value
                                        for c in self.sens_obj.func_conds:
                                            self.max_sens_map[param]["cond_set"][c] = self.sens_obj.func_conds[c]
                                try:
                                    if abs(self.sens_maps[j]["param_response"][param].any()) < abs(self.min_sens_map[param]["param_response"].any()):
                                        self.min_sens_map[param]["param_response"] = self.sens_maps[j]["param_response"][param]
                                        self.min_sens_map[param]["func_result"] = func_value
                                        for c in self.sens_obj.func_conds:
                                            self.min_sens_map[param]["cond_set"][c] = self.sens_obj.func_conds[c]
                                except:
                                    if abs(self.sens_maps[j]["param_response"][param]) < abs(self.min_sens_map[param]["param_response"]):
                                        self.min_sens_map[param]["param_response"] = self.sens_maps[j]["param_response"][param]
                                        self.min_sens_map[param]["func_result"] = func_value
                                        for c in self.sens_obj.func_conds:
                                            self.min_sens_map[param]["cond_set"][c] = self.sens_obj.func_conds[c]

                        file.write("\n")
                        j+=1
            elif type(self.sens_obj.func_conds[cond]) is bool:
                #Run simulation as is
                if skip_partials == False:
                    self.sens_obj.compute_partials(relative, per)
                func_value = self.sens_obj.eval_func()
                self.sens_maps.append({})
                self.sens_maps[j]["func_result"] = func_value
                self.sens_maps[j]["cond_set"] = {}
                self.sens_maps[j]["param_response"] = {}

                for c in self.sens_obj.func_conds:
                    self.sens_maps[j]["cond_set"][c] = self.sens_obj.func_conds[c]
                file.write(str(self.sens_obj.func_conds[cond]))
                file.write("\t"+str(func_value))
                for param in self.sens_obj.func_params:
                    file.write("\t"+str(self.sens_obj.partials[param]))
                    self.sens_maps[j]["param_response"][param] = self.sens_obj.partials[param]

                    #Check and record maximum and minmum responses for each parameter
                    if j == 0:
                        self.max_sens_map[param]["param_response"] = self.sens_maps[j]["param_response"][param]
                        self.min_sens_map[param]["param_response"] = self.sens_maps[j]["param_response"][param]
                        self.max_sens_map[param]["func_result"] = func_value
                        self.min_sens_map[param]["func_result"] = func_value
                        for c in self.sens_obj.func_conds:
                            self.max_sens_map[param]["cond_set"][c] = self.sens_obj.func_conds[c]
                            self.min_sens_map[param]["cond_set"][c] = self.sens_obj.func_conds[c]
                    else:
                        try:
                            if abs(self.sens_maps[j]["param_response"][param].any()) > abs(self.max_sens_map[param]["param_response"].any()):
                                self.max_sens_map[param]["param_response"] = self.sens_maps[j]["param_response"][param]
                                self.max_sens_map[param]["func_result"] = func_value
                                for c in self.sens_obj.func_conds:
                                    self.max_sens_map[param]["cond_set"][c] = self.sens_obj.func_conds[c]
                        except:
                            if abs(self.sens_maps[j]["param_response"][param]) > abs(self.max_sens_map[param]["param_response"]):
                                self.max_sens_map[param]["param_response"] = self.sens_maps[j]["param_response"][param]
                                self.max_sens_map[param]["func_result"] = func_value
                                for c in self.sens_obj.func_conds:
                                    self.max_sens_map[param]["cond_set"][c] = self.sens_obj.func_conds[c]
                        try:
                            if abs(self.sens_maps[j]["param_response"][param].any()) < abs(self.min_sens_map[param]["param_response"].any()):
                                self.min_sens_map[param]["param_response"] = self.sens_maps[j]["param_response"][param]
                                self.min_sens_map[param]["func_result"] = func_value
                                for c in self.sens_obj.func_conds:
                                    self.min_sens_map[param]["cond_set"][c] = self.sens_obj.func_conds[c]
                        except:
                            if abs(self.sens_maps[j]["param_response"][param]) < abs(self.min_sens_map[param]["param_response"]):
                                self.min_sens_map[param]["param_response"] = self.sens_maps[j]["param_response"][param]
                                self.min_sens_map[param]["func_result"] = func_value
                                for c in self.sens_obj.func_conds:
                                    self.min_sens_map[param]["cond_set"][c] = self.sens_obj.func_conds[c]

                file.write("\n")
                j+=1
                #Run simulation changing the boolean
                if self.sens_obj.func_conds[cond] == True:
                    self.sens_obj.func_conds[cond] = False
                else:
                    self.sens_obj.func_conds[cond] = True
                if skip_partials == False:
                    self.sens_obj.compute_partials(relative, per)
                func_value = self.sens_obj.eval_func()
                self.sens_maps.append({})
                self.sens_maps[j]["func_result"] = func_value
                self.sens_maps[j]["cond_set"] = {}
                self.sens_maps[j]["param_response"] = {}

                for c in self.sens_obj.func_conds:
                    self.sens_maps[j]["cond_set"][c] = self.sens_obj.func_conds[c]
                file.write(str(self.sens_obj.func_conds[cond]))
                for param in self.sens_obj.func_params:
                    file.write("\t"+str(self.sens_obj.partials[param]))
                    self.sens_maps[j]["param_response"][param] = self.sens_obj.partials[param]

                    #Check and record maximum and minmum responses for each parameter
                    if j == 0:
                        self.max_sens_map[param]["param_response"] = self.sens_maps[j]["param_response"][param]
                        self.min_sens_map[param]["param_response"] = self.sens_maps[j]["param_response"][param]
                        self.max_sens_map[param]["func_result"] = func_value
                        self.min_sens_map[param]["func_result"] = func_value
                        for c in self.sens_obj.func_conds:
                            self.max_sens_map[param]["cond_set"][c] = self.sens_obj.func_conds[c]
                            self.min_sens_map[param]["cond_set"][c] = self.sens_obj.func_conds[c]
                    else:
                        try:
                            if abs(self.sens_maps[j]["param_response"][param].any()) > abs(self.max_sens_map[param]["param_response"].any()):
                                self.max_sens_map[param]["param_response"] = self.sens_maps[j]["param_response"][param]
                                self.max_sens_map[param]["func_result"] = func_value
                                for c in self.sens_obj.func_conds:
                                    self.max_sens_map[param]["cond_set"][c] = self.sens_obj.func_conds[c]
                        except:
                            if abs(self.sens_maps[j]["param_response"][param]) > abs(self.max_sens_map[param]["param_response"]):
                                self.max_sens_map[param]["param_response"] = self.sens_maps[j]["param_response"][param]
                                self.max_sens_map[param]["func_result"] = func_value
                                for c in self.sens_obj.func_conds:
                                    self.max_sens_map[param]["cond_set"][c] = self.sens_obj.func_conds[c]
                        try:
                            if abs(self.sens_maps[j]["param_response"][param].any()) < abs(self.min_sens_map[param]["param_response"].any()):
                                self.min_sens_map[param]["param_response"] = self.sens_maps[j]["param_response"][param]
                                self.min_sens_map[param]["func_result"] = func_value
                                for c in self.sens_obj.func_conds:
                                    self.min_sens_map[param]["cond_set"][c] = self.sens_obj.func_conds[c]
                        except:
                            if abs(self.sens_maps[j]["param_response"][param]) < abs(self.min_sens_map[param]["param_response"]):
                                self.min_sens_map[param]["param_response"] = self.sens_maps[j]["param_response"][param]
                                self.min_sens_map[param]["func_result"] = func_value
                                for c in self.sens_obj.func_conds:
                                    self.min_sens_map[param]["cond_set"][c] = self.sens_obj.func_conds[c]

                file.write("\n")
                j+=1
            else:
                print("Non-numeric function conditions/args are not varied in search methods...")
                print("Variations of the {" + str(cond) + "} condition will be skipped...")
                file.write("Non-numeric function argument {" + str(cond) + "} is skipped \n")

            #Recover original condition before proceeding to next
            self.sens_obj.func_conds[cond] = og_cond
            i += 1
        #End func_conds loop
        file.close()

        #Write out the max and min sensitivity results to a file
        mmfile.write("\nMaximum Function Responses to the Parameter Changes")
        mmfile.write("\n---------------------------------------------------\n")
        mmfile.write("Parameter")
        for cond in self.sens_obj.func_conds:
            mmfile.write("\t"+str(cond))
        mmfile.write("\tFunc_Result")
        if relative == False:
            mmfile.write("\tMax df/dp")
        else:
            mmfile.write("\tMax % Change")

        mmfile.write("\n")
        for param in self.max_sens_map:
            mmfile.write(str(param))
            for cond in self.max_sens_map[param]["cond_set"]:
                mmfile.write("\t"+str(self.max_sens_map[param]["cond_set"][cond]))
            mmfile.write("\t"+str(self.max_sens_map[param]["func_result"]))
            mmfile.write("\t"+str(self.max_sens_map[param]["param_response"]))
            mmfile.write("\n")

        mmfile.write("\nMinimum Function Responses to the Parameter Changes")
        mmfile.write("\n---------------------------------------------------\n")
        mmfile.write("Parameter")
        for cond in self.sens_obj.func_conds:
            mmfile.write("\t"+str(cond))
        mmfile.write("\tFunc_Result")
        if relative == False:
            mmfile.write("\tMin df/dp")
        else:
            mmfile.write("\tMin % Change")

        mmfile.write("\n")
        for param in self.min_sens_map:
            mmfile.write(str(param))
            for cond in self.min_sens_map[param]["cond_set"]:
                mmfile.write("\t"+str(self.min_sens_map[param]["cond_set"][cond]))
            mmfile.write("\t"+str(self.min_sens_map[param]["func_result"]))
            mmfile.write("\t"+str(self.min_sens_map[param]["param_response"]))
            mmfile.write("\n")

        mmfile.close()
        self.sweep_computed = True

    ##Function to perform an Exhaustive Sensitivity Analysis
    #
    #   The exhaustive sweep uses the helper function update_cond() to go through all condition permutations
    #   within the specified boundaries of each condition variable.
    #
    #   @param folder where to save the results
    #   @param sensitivity_file_name name of the file to save
    #   @param relative True=relative differences with 'per' percentage change, False=Partial derivatives
    #   @param cond_limit Number of steps to take in conditions loop
    #   @param skip_partials True=Just evaluate function at the given conditions, False=Evaluate and get partials
    def run_exhaustive_sweep(self, folder = "",
                                    sensitivity_file_name = "ExhaustiveSensitivitySweepAnalysis.dat",
                                    relative = False,
                                    per = 1,
                                    cond_limit = 1,
                                    skip_partials = False):
        #Enfore a .dat file extension. This is used to flag the file as very large so that
        #   our git tracking ignores that file. May be unnecessary, but better safe than sorry.
        if folder != "":
            if folder[-1] != "/":
                folder += "/"
            if not os.path.exists(folder):
                os.makedirs(folder)

        set = sensitivity_file_name.split('.')
        sensitivity_file_name = set[0] + ".dat"
        max_min_file = set[0] + "-MaxMinAnalysis.dat"
        file = open(folder+sensitivity_file_name,'w')
        mmfile = open(folder+max_min_file,'w')
        #Write out header information
        file.write("-------------- Exhaustive Sensitivity Sweep Results ---------------\n")
        if relative == False:
            file.write("\tAnalysis performed using Finite Differences\n")
        else:
            file.write("\tAnalysis performed using " + str(per) + "% Change in baseline parameter values\n")
        file.write("\nSystem Parameters:\n")
        for item in self.sens_obj.func_params:
            file.write(str(item) + "\t" + str(self.sens_obj.func_params[item]) + "\n")
        file.write("\nSystem Function Arguments:\n")
        for item in self.sens_obj.func_args:
            file.write(str(item) + "\t" + str(self.sens_obj.func_args[item]) + "\n")

        mmfile.write("-------------- Sensitivity Sweep Results (Max and Min Sensitivities) ---------------\n")
        if relative == False:
            mmfile.write("\tAnalysis performed using Finite Differences\n")
        else:
            mmfile.write("\tAnalysis performed using " + str(per) + "% Change in baseline parameter values\n")
        mmfile.write("\nSystem Parameters:\n")
        for item in self.sens_obj.func_params:
            mmfile.write(str(item) + "\t" + str(self.sens_obj.func_params[item]) + "\n")
        mmfile.write("\nSystem Function Arguments:\n")
        for item in self.sens_obj.func_args:
            mmfile.write(str(item) + "\t" + str(self.sens_obj.func_args[item]) + "\n")

        cond_list = []
        cond_value = []
        cond_limit_upper = []
        cond_limit_lower = []
        for cond in self.sens_obj.func_conds:
            if type(self.sens_obj.func_conds[cond]) is not int and type(self.sens_obj.func_conds[cond]) is not float:
                print("Non-numeric function conditions/args are not varied in search methods...")
                print("Variations of the {" + str(cond) + "} condition will be skipped...")
            else:
                cond_list.append(cond)
                cond_value.append(self.cond_tuples[cond][0])
                cond_limit_lower.append(self.cond_tuples[cond][0])
                cond_limit_upper.append(self.cond_tuples[cond][-1])

        #NOTE: This limitation keeps the total permutation count around 100,000.
        #       Beyond this point, the analysis is too complex for this script
        if len(cond_list) > 15:
            print("Too many conditions to vary! Number of permutations exceeds limits!")
            print("Try using run_sweep() instead or reduce the number of conditions to below 15...")

            file.write("\nToo many conditions to vary! Number of permutations exceeds limits!\n")
            file.write("Try using run_sweep() instead or reduce the number of conditions to below 15...\n")
            file.close()
            raise RuntimeError("Too many conditions to vary!")
        #Print out a header line for conditions and parameters
        file.write("\n")
        file.write("\t")
        n = 0
        for cond in self.sens_obj.func_conds:
            file.write("\tcond_"+str(n))
            n+=1
        n = 0
        for param in self.sens_obj.func_params:
            file.write("\tpartial_"+str(n))
            n+=1
        file.write("\nPermutation")
        file.write("\tfunc_result")
        for cond in self.sens_obj.func_conds:
            file.write("\t"+str(cond))
        for param in self.sens_obj.func_params:
            if relative == False:
                file.write("\tdf/d("+str(param)+")")
            else:
                file.write("\tdf(%)@d("+str(param)+")")
        file.write("\n")

        #Changing conditions by going through all permuntations
        complete = False
        perm = 0
        while complete == False:
            #Run current case
            i = 0
            for cond in cond_list:
                self.sens_obj.func_conds[cond] = cond_value[i]
                i += 1
            if skip_partials == False:
                self.sens_obj.compute_partials(relative, per)
            func_value = self.sens_obj.eval_func()
            self.sens_maps.append({})
            self.sens_maps[perm]["func_result"] = func_value
            self.sens_maps[perm]["cond_set"] = {}
            self.sens_maps[perm]["param_response"] = {}
            file.write(str(perm))
            file.write("\t"+str(func_value))
            for cond in self.sens_obj.func_conds:
                file.write("\t"+str(self.sens_obj.func_conds[cond]))
                self.sens_maps[perm]["cond_set"][cond] = self.sens_obj.func_conds[cond]
            for param in self.sens_obj.func_params:
                file.write("\t"+str(self.sens_obj.partials[param]))
                self.sens_maps[perm]["param_response"][param] = self.sens_obj.partials[param]

                #Check and record maximum and minmum responses for each parameter
                if perm == 0:
                    self.max_sens_map[param]["param_response"] = self.sens_maps[perm]["param_response"][param]
                    self.min_sens_map[param]["param_response"] = self.sens_maps[perm]["param_response"][param]
                    self.max_sens_map[param]["func_result"] = func_value
                    self.min_sens_map[param]["func_result"] = func_value
                    for cond in self.sens_obj.func_conds:
                        self.max_sens_map[param]["cond_set"][cond] = self.sens_obj.func_conds[cond]
                        self.min_sens_map[param]["cond_set"][cond] = self.sens_obj.func_conds[cond]
                else:
                    try:
                        if abs(self.sens_maps[perm]["param_response"][param].any()) > abs(self.max_sens_map[param]["param_response"].any()):
                            self.max_sens_map[param]["param_response"] = self.sens_maps[perm]["param_response"][param]
                            self.max_sens_map[param]["func_result"] = func_value
                            for cond in self.sens_obj.func_conds:
                                self.max_sens_map[param]["cond_set"][cond] = self.sens_obj.func_conds[cond]
                    except:
                        if abs(self.sens_maps[perm]["param_response"][param]) > abs(self.max_sens_map[param]["param_response"]):
                            self.max_sens_map[param]["param_response"] = self.sens_maps[perm]["param_response"][param]
                            self.max_sens_map[param]["func_result"] = func_value
                            for cond in self.sens_obj.func_conds:
                                self.max_sens_map[param]["cond_set"][cond] = self.sens_obj.func_conds[cond]
                    try:
                        if abs(self.sens_maps[perm]["param_response"][param].any()) < abs(self.min_sens_map[param]["param_response"].any()):
                            self.min_sens_map[param]["param_response"] = self.sens_maps[perm]["param_response"][param]
                            self.min_sens_map[param]["func_result"] = func_value
                            for cond in self.sens_obj.func_conds:
                                self.min_sens_map[param]["cond_set"][cond] = self.sens_obj.func_conds[cond]
                    except:
                        if abs(self.sens_maps[perm]["param_response"][param]) < abs(self.min_sens_map[param]["param_response"]):
                            self.min_sens_map[param]["param_response"] = self.sens_maps[perm]["param_response"][param]
                            self.min_sens_map[param]["func_result"] = func_value
                            for cond in self.sens_obj.func_conds:
                                self.min_sens_map[param]["cond_set"][cond] = self.sens_obj.func_conds[cond]
            file.write("\n")
            #Update Values
            complete = update_cond(cond_value, cond_limit_lower, cond_limit_upper, user_base=cond_limit)
            perm+=1
        file.close()

        #Write out the max and min sensitivity results to a file
        mmfile.write("\nMaximum Function Responses to the Parameter Changes")
        mmfile.write("\n---------------------------------------------------\n")
        mmfile.write("Parameter")
        for cond in self.sens_obj.func_conds:
            mmfile.write("\t"+str(cond))
        mmfile.write("\tFunc_Result")
        if relative == False:
            mmfile.write("\tMax df/dp")
        else:
            mmfile.write("\tMax % Change")

        mmfile.write("\n")
        for param in self.max_sens_map:
            mmfile.write(str(param))
            for cond in self.max_sens_map[param]["cond_set"]:
                mmfile.write("\t"+str(self.max_sens_map[param]["cond_set"][cond]))
            mmfile.write("\t"+str(self.max_sens_map[param]["func_result"]))
            mmfile.write("\t"+str(self.max_sens_map[param]["param_response"]))
            mmfile.write("\n")

        mmfile.write("\nMinimum Function Responses to the Parameter Changes")
        mmfile.write("\n---------------------------------------------------\n")
        mmfile.write("Parameter")
        for cond in self.sens_obj.func_conds:
            mmfile.write("\t"+str(cond))
        mmfile.write("\tFunc_Result")
        if relative == False:
            mmfile.write("\tMin df/dp")
        else:
            mmfile.write("\tMin % Change")

        mmfile.write("\n")
        for param in self.min_sens_map:
            mmfile.write(str(param))
            for cond in self.min_sens_map[param]["cond_set"]:
                mmfile.write("\t"+str(self.min_sens_map[param]["cond_set"][cond]))
            mmfile.write("\t"+str(self.min_sens_map[param]["func_result"]))
            mmfile.write("\t"+str(self.min_sens_map[param]["param_response"]))
            mmfile.write("\n")

        mmfile.close()
        self.sweep_computed = True


# ----------- End: Definition of Class object for SensitivitySweep --------------------



# ---------- Testing -------------

if __name__ == "__main__":
    '''
    # Test 1: Basic python function
    def test_func(params, conds, other):
        # B^2*A + x*A + y + z*B = f(x,y,z)
        return params["B"]*params["B"]*params["A"] + conds["X"]*params["A"] + conds["Y"]+conds["Z"]*params["B"]

    test_params = {}
    test_params["A"] = 20
    test_params["B"] = 3

    test_conds = {}
    test_conds["X"] = 1
    test_conds["Y"] = 1
    test_conds["Z"] = 1

    test_tuples = {}

    test_other = {}
    test_other["Apple"] = "Banana"

    for item in test_conds:
        test_tuples[item] = (test_conds[item], test_conds[item]+2)

    test_obj = SensitivitySweep(test_func,test_params,test_tuples,test_other)
    test_obj.run_sweep("test_output","test_analysis-simple",True,10,2,True)
    test_obj.run_exhaustive_sweep("test_output","test_analysis-exhaustive",True,10,2,True)
    '''


    '''
    # Test 2: Using cats
    def test_func2(params, conds, other):
        cats_file_obj = other["CATS"]       #class object
        folder = other["folder"]            #string
        input_file = other["file"]          #string
        output_file = other["out_file_base"]     #string

        # Read the input file into the object
        cats_file_obj.construct_from_file(input_file)

        #Replace params with those in given dict
        cats_file_obj.data["Kernels"]["first_order_decay"]["forward_rate"] = conds["reaction_rate_A"]
        #cats_file_obj.data["Kernels"]["first_order_decay"]["scale"] = params["reaction_scale_A"]

        #Rebuild the CATS input stream and write to new (or same file)
        new_file = output_file+"_"+other["RunNum"]
        #new_file = output_file
        cats_file_obj.write_stream_to_file(new_file, rebuild=True)

        #Call the executable for the simulation
        os.system("mpiexec --n 16 ../../../cats-opt -i " + new_file+".i")

        #Remove the old input file
        #   Allows me to keep the result csv files while removing the .i files generated
        if os.path.exists(new_file+".i"):
            os.remove(new_file+".i")

        #Read in the result csv file
        result_file = new_file+"_out.csv"
        csv_obj = MOOSE_CVS_File(result_file)

        #Perform some computation
        #   Here we just grab the last time value as a demo
        res = csv_obj.value(2,'A') * 1

        #Track the number of runs (so each output can have different name)
        other["RunNum"] = str(int(other["RunNum"])+1)   #string

        # Return the result
        return res

    # NOTE: You can skip partials by passing an empty param dict
    test_params = {}
    #test_params["reaction_scale_A"] = -1.0

    test_conds = {}
    test_conds["reaction_rate_A"] = 0.5

    test_other = {}
    test_other["CATS"] = CATS_InputFile()
    test_other["folder"] = "test_input/"
    test_other["file"] = "test_input/simple_react_test.i"
    test_other["out_file_base"] = "test_input/simple_react_test"
    test_other["RunNum"] = "0"

    test_tuples = {}
    for item in test_conds:
        test_tuples[item] = (test_conds[item], 1.5)

    test_obj = SensitivitySweep(test_func2,test_params, test_tuples, test_other)
    test_obj.run_sweep("test_input/sens_res","test_analysis-simple-with-cats",True,10,2,True)
    #test_obj.run_exhaustive_sweep("test_input/sens_res","test_analysis-exhaustive-with-cats",True,10,1,True)

    # Reference of args run_sweep(folder = "",
    #                    sensitivity_file_name = "SensitivitySweepAnalysis.dat",
    #                    relative = False,
    #                    per = 1,
    #                    cond_limit=1,
    #                    skip_partials=False)
    '''


    # Test 3: Using cats for CO2 analysis
    def test_func3(params, conds, other):
        cats_file_obj = other["CATS"]       #class object
        folder = other["folder"]            #string
        input_file = other["file"]          #string
        output_file = other["out_file_base"]     #string

        # Read the input file into the object
        cats_file_obj.construct_from_file(input_file)

        #Replace params/conds with those in given dict
        #   Number of simulations = num_states^num_conds
        cats_file_obj.data["AuxVariables"]["T_e"]["initial_condition"] = conds["temperature"]
        cats_file_obj.data["AuxVariables"]["T_s"]["initial_condition"] = conds["temperature"]

        cats_file_obj.data["AuxKernels"]["current_step_input"]["aux_vals"][0] = conds["applied_current"]

        cats_file_obj.data["AuxKernels"]["flowrate_step_input"]["aux_vals"][0] = conds["flowrate"]

        cats_file_obj.data["AuxVariables"]["As"]["initial_condition"] = conds["active_surface_area"]


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
        res = csv_obj.value(515,'C_CO_out_M') * -csv_obj.value(515,'Q_out_cu_mm_p_s') * 2 * 0.096485 / csv_obj.value(515,'I_in_Amps')

        #Track the number of runs (so each output can have different name)
        other["RunNum"] = str(int(other["RunNum"])+1)   #string

        # Return the result
        return res

    # NOTE: You can skip partials by passing an empty param dict
    test_params = {}

    test_conds = {}
    test_conds["temperature"] = 298 #to 353
    test_conds["applied_current"] = 0.001 #to 0.004
    test_conds["flowrate"] = 500 #to 1666.67
    test_conds["active_surface_area"] = 1.0e+4 #to 3.0e+4

    test_args = {}
    test_args["CATS"] = CATS_InputFile()
    test_args["folder"] = "test_input/"
    test_args["file"] = "test_input/case01_CGFE.i"
    test_args["out_file_base"] = "test_input/case01_CGFE"
    test_args["RunNum"] = "0"

    test_tuples = {}
    test_tuples["temperature"] = (test_conds["temperature"], 353)
    test_tuples["applied_current"] = (test_conds["applied_current"], 0.004)
    test_tuples["flowrate"] = (test_conds["flowrate"], 1666.67)
    test_tuples["active_surface_area"] = (test_conds["active_surface_area"], 3.0e+4)

    #res = test_func3(test_params, test_conds, test_args)

    test_obj = SensitivitySweep(test_func3,test_params, test_tuples, test_args)
    #test_obj.run_sweep("test_input/sens_res_co2","co2_sensitivity_cats_01",
    #                                relative=True,per=10,cond_limit=2,skip_partials=True)
    test_obj.run_exhaustive_sweep("test_input/sens_res_co2","co2_sensitivity_cats_01",
                                    relative=True,per=10,cond_limit=2,skip_partials=True)
