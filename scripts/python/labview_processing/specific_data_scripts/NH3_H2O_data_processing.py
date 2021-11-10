##   @package NH3_H2O_data_processing
#
#    @brief Script to read in all folders of NH3 + H2O Catalyst data
#
#    @details Python script to read in CLEERS transient data for
#                for all sets of folders of the NH3 and H2O transient
#                data and perform a series of analyses, compress the data,
#                output the data into a new compressed format, and prepare
#                a series of plots to visualize all data. This script works
#                in conjunction with the transient_data_sets.py script and
#                is meant to be uninteractive (i.e., the user does not need
#                to provide any live inputs beyond calling the script)
#
#    @author Austin Ladshaw
#
#    @date 02/27/2020
#
#    @copyright This software was designed and built at the Oak Ridge National
#                    Laboratory (ORNL) National Transportation Research Center
#                    (NTRC) by Austin Ladshaw for research in the catalytic
#                    reduction of NOx. Copyright (c) 2020, all rights reserved.

import sys
sys.path.append('../..')
from labview_processing.transient_data_sets import TransientDataFolder, TransientDataFolderSets
import os, getopt
import time

##Define a help message to display
def help_message():
    print()
    print("NH3_H2O_data_processing.py script command line options...")
    print()
    print("\t-h           Print this message")
    print("\t-i <folder>  Provide the name of the folder that contains folders of data")
    print("\t-o <folder>  Provide the name of a location to which output will be saved")
    print()
    print("Example Usage:")
    print()
    print("\tpython NH3_H2O_data_processing.py -i AllNH3Data/ -o output")
    print()

##Define a function that reads all data in a given subdirectory and performs standard processing
#
#   @param list list of the path and names of folders to read
#   @param output_folder where to put output information
def perform_standard_processing(list, output_folder):
    data = TransientDataFolderSets(list)
    data.retainOnlyColumns(['Elapsed Time (min)','NH3 (300,3000)', 'H2O% (20)', 'TC bot sample in (C)', 'TC bot sample mid 1 (C)', 'TC bot sample mid 2 (C)', 'TC bot sample out 1 (C)', 'TC bot sample out 2 (C)', 'P bottom in (bar)', 'P bottom out (bar)'])

    #Convert all temperatures from (C) to Kelvin, then delete old columns
    data.mathOperations('TC bot sample in (C)',"+",273.15, True, 'TC bot sample in (K)')
    data.deleteColumns('TC bot sample in (C)')
    data.mathOperations('TC bot sample mid 1 (C)',"+",273.15, True, 'TC bot sample mid 1 (K)')
    data.deleteColumns('TC bot sample mid 1 (C)')
    data.mathOperations('TC bot sample mid 2 (C)',"+",273.15, True, 'TC bot sample mid 2 (K)')
    data.deleteColumns('TC bot sample mid 2 (C)')
    data.mathOperations('TC bot sample out 1 (C)',"+",273.15, True, 'TC bot sample out 1 (K)')
    data.deleteColumns('TC bot sample out 1 (C)')
    data.mathOperations('TC bot sample out 2 (C)',"+",273.15, True, 'TC bot sample out 2 (K)')
    data.deleteColumns('TC bot sample out 2 (C)')
    #Delete the temperature columns from the bypass run that we don't need
    data.deleteColumns(['TC bot sample in (C)[bypass]','TC bot sample mid 1 (C)[bypass]','TC bot sample mid 2 (C)[bypass]','TC bot sample out 1 (C)[bypass]','TC bot sample out 2 (C)[bypass]'])

    #Now, convert all pressures from bar to kPa and delete the extra [bypass] columns
    data.mathOperations('P bottom in (bar)',"*",100,True,'P bottom in (kPa)')
    data.deleteColumns('P bottom in (bar)')
    data.mathOperations('P bottom out (bar)',"*",100,True,'P bottom out (kPa)')
    data.deleteColumns('P bottom out (bar)')

    #Delete the pressure columns from the bypass run that we also don't need
    data.deleteColumns(['P bottom in (bar)[bypass]','P bottom out (bar)[bypass]'])

    #Calculate NH3 and H2O in mol/L assuming ideal gas law
    data.mathOperations('NH3 (300,3000)',"/",1E6,True,'NH3 (mol/L)')    #From ppmv to molefraction
    data.mathOperations('NH3 (mol/L)',"*","P bottom out (kPa)")    #From molefraction to kPa
    data.mathOperations('NH3 (mol/L)',"/",8.314)
    data.mathOperations('NH3 (mol/L)',"/",'TC bot sample out 1 (K)') #From kPa to mol/L using Ideal gas law

    data.mathOperations('H2O% (20)',"/",100,True,'H2O (mol/L)')    #From vol % to molefraction
    data.mathOperations('H2O (mol/L)',"*","P bottom out (kPa)")    #From molefraction to kPa
    data.mathOperations('H2O (mol/L)',"/",8.314)
    data.mathOperations('H2O (mol/L)',"/",'TC bot sample out 1 (K)') #From kPa to mol/L using Ideal gas law

    data.mathOperations('NH3 (300,3000)[bypass]',"/",1E6,True,'NH3 (mol/L)[bypass]')    #From ppmv to molefraction
    data.mathOperations('NH3 (mol/L)[bypass]',"*","P bottom in (kPa)")    #From molefraction to kPa
    data.mathOperations('NH3 (mol/L)[bypass]',"/",8.314)
    data.mathOperations('NH3 (mol/L)[bypass]',"/",'TC bot sample in (K)') #From kPa to mol/L using Ideal gas law

    data.mathOperations('H2O% (20)[bypass]',"/",100,True,'H2O (mol/L)[bypass]')    #From vol % to molefraction
    data.mathOperations('H2O (mol/L)[bypass]',"*","P bottom in (kPa)")    #From molefraction to kPa
    data.mathOperations('H2O (mol/L)[bypass]',"/",8.314)
    data.mathOperations('H2O (mol/L)[bypass]',"/",'TC bot sample in (K)') #From kPa to mol/L using Ideal gas law

    #Calculate the mass retention for species of interest
    #       NOTE: calculation assumes time in min and flow rate in hours (and taking from file name)
    data.calculateRetentionIntegrals('NH3 (mol/L)')
    data.calculateRetentionIntegrals('H2O (mol/L)')

    #Save all plots in each time frame
    data.saveTimeFramePlots(output_folder)
    data.saveOverlayPlots('NH3 (300,3000)',None, output_folder)
    data.saveOverlayPlots('NH3 (300,3000)','TC bot sample out 1 (K)', output_folder)
    data.saveCrossOverlayPlots('NH3 (300,3000)',output_folder)
    #Compress the processed data for visualization in spreadsheets
    data.compressAllRows()
    #Print the results to a series of output files
    data.printAlltoFile(output_folder)
    return data.getTotalDataProcessed()
#END standard processing

##Define the 'main' function
#
#   argv is the list of arguments pass to the script at the command line
#
#   Accepted arguments include...
#
#       -h         ==>  display help information
#
#       -i dir/    ==>   path and name of the folder than contains other folders of data
#
#       -o dir/    ==>   path and name of the folder to place output into
def main(argv):
    input_folder = ""
    output_folder = ""
    #Check for valid arguments
    try:
        opts, args = getopt.getopt(argv,"hi:o:",["input_dir=","output_dir="])
    except:
        help_message()
        sys.exit(2)
    #Iterate through arguments and save some information
    for opt, arg in opts:
        if opt == '-h':
            help_message()
            sys.exit()
        if opt in ("-i", "--ifile"):
            input_folder = arg
            if input_folder[-1] == "/":
                input_folder = input_folder[0:-1]
        if opt in ("-o", "--ofile"):
            output_folder = arg
            if output_folder[-1] == "/":
                output_folder = output_folder[0:-1]

    #If we made it to this point, then no errors in input
    #Check to see if the input_folder does exist
    if os.path.isdir(input_folder) == False:
        print("Error! Given argument is not a folder!")
        help_message()
        sys.exit()
    #Create a list of valid folders to go through
    list = []
    for folder in os.listdir(input_folder):
        #Need to check to make sure the folder does not say -Output or -Plots
        if "Plots" not in folder and "Output" not in folder:
            list.append(input_folder+"/"+folder)
        else:
            continue

    #NOW: Iterate through all files/folders in the input directory
    if output_folder == "":
        output_folder = input_folder + "-Output"
    start = time.time()
    total = perform_standard_processing(list, output_folder)
    end = time.time()
    elapse_min = (end-start)/60
    print("\nCOMPLETED!!!")
    print("\tWe processed " + str(total) + " data points in " + str(elapse_min) + " min!\n")


##Directs python to call the main function
if __name__ == "__main__":
   main(sys.argv[1:])
