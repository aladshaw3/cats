##   @package NH3_SCR_processing
#
#    @brief Script to read in all folders of NH3 + SCR data
#
#    @details Python script to read in CLEERS transient data for
#                for all sets of folders of the NH3 SCR transient
#                data and perform a series of analyses, compress the data,
#                output the data into a new compressed format, and prepare
#                a series of plots to visualize all data. This script works
#                in conjunction with the transient_data_sets.py script and
#                is meant to be uninteractive (i.e., the user does not need
#                to provide any live inputs beyond calling the script)
#
#    @author Austin Ladshaw
#
#    @date 12/06/2021
#
#    @copyright This software was designed and built at the Oak Ridge National
#                    Laboratory (ORNL) National Transportation Research Center
#                    (NTRC) by Austin Ladshaw for research in the catalytic
#                    reduction of NOx. Copyright (c) 2020, all rights reserved.

import sys
sys.path.append('../..')
from labview_processing.transient_data import TransientData, PairedTransientData
import os, getopt
import time

# Processing for data that must be manually paired
def perform_standard_processing_not_aligned(result_file, bypass_file, output_folder=""):
    data = TransientData(result_file)
    bp = TransientData(bypass_file)
    total_data = data.getNumCols()*data.getNumRows()
    data.compressColumns()
    bp.compressColumns()

    data.retainOnlyColumns(['Elapsed Time (min)','NH3 (300,3000)', 'H2O% (20)',
        'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150,2000)',
        'TC bot sample in (C)', 'TC bot sample mid 1 (C)', 'TC bot sample mid 2 (C)',
        'TC bot sample out 1 (C)', 'TC bot sample out 2 (C)', 'P bottom in (bar)', 'P bottom out (bar)'])
    bp.retainOnlyColumns(['Elapsed Time (min)','NH3 (300,3000)', 'H2O% (20)',
        'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150,2000)',
        'TC bot sample in (C)', 'TC bot sample mid 1 (C)', 'TC bot sample mid 2 (C)',
        'TC bot sample out 1 (C)', 'TC bot sample out 2 (C)', 'P bottom in (bar)', 'P bottom out (bar)'])

    #Convert all temperatures from (C) to Kelvin, then delete old columns
    data.mathOperation('TC bot sample in (C)',"+",273.15, True, 'TC bot sample in (K)')
    data.deleteColumns('TC bot sample in (C)')
    data.mathOperation('TC bot sample mid 1 (C)',"+",273.15, True, 'TC bot sample mid 1 (K)')
    data.deleteColumns('TC bot sample mid 1 (C)')
    data.mathOperation('TC bot sample mid 2 (C)',"+",273.15, True, 'TC bot sample mid 2 (K)')
    data.deleteColumns('TC bot sample mid 2 (C)')
    data.mathOperation('TC bot sample out 1 (C)',"+",273.15, True, 'TC bot sample out 1 (K)')
    data.deleteColumns('TC bot sample out 1 (C)')
    data.mathOperation('TC bot sample out 2 (C)',"+",273.15, True, 'TC bot sample out 2 (K)')
    data.deleteColumns('TC bot sample out 2 (C)')
    #Delete the temperature columns from the bypass run that we don't need
    data.deleteColumns(['TC bot sample in (C)[bypass]','TC bot sample mid 1 (C)[bypass]',
        'TC bot sample mid 2 (C)[bypass]','TC bot sample out 1 (C)[bypass]','TC bot sample out 2 (C)[bypass]'])

    #Now, convert all pressures from bar to kPa and delete the extra [bypass] columns
    data.mathOperation('P bottom in (bar)',"*",100,True,'P bottom in (kPa)')
    data.deleteColumns('P bottom in (bar)')
    data.mathOperation('P bottom out (bar)',"*",100,True,'P bottom out (kPa)')
    data.deleteColumns('P bottom out (bar)')

    #Delete the pressure columns from the bypass run that we also don't need
    data.deleteColumns(['P bottom in (bar)[bypass]','P bottom out (bar)[bypass]'])

    #Convert all temperatures from (C) to Kelvin, then delete old columns
    bp.mathOperation('TC bot sample in (C)',"+",273.15, True, 'TC bot sample in (K)')
    bp.deleteColumns('TC bot sample in (C)')
    bp.mathOperation('TC bot sample mid 1 (C)',"+",273.15, True, 'TC bot sample mid 1 (K)')
    bp.deleteColumns('TC bot sample mid 1 (C)')
    bp.mathOperation('TC bot sample mid 2 (C)',"+",273.15, True, 'TC bot sample mid 2 (K)')
    bp.deleteColumns('TC bot sample mid 2 (C)')
    bp.mathOperation('TC bot sample out 1 (C)',"+",273.15, True, 'TC bot sample out 1 (K)')
    bp.deleteColumns('TC bot sample out 1 (C)')
    bp.mathOperation('TC bot sample out 2 (C)',"+",273.15, True, 'TC bot sample out 2 (K)')
    bp.deleteColumns('TC bot sample out 2 (C)')
    #Delete the temperature columns from the bypass run that we don't need
    bp.deleteColumns(['TC bot sample in (C)[bypass]','TC bot sample mid 1 (C)[bypass]',
        'TC bot sample mid 2 (C)[bypass]','TC bot sample out 1 (C)[bypass]','TC bot sample out 2 (C)[bypass]'])

    #Now, convert all pressures from bar to kPa and delete the extra [bypass] columns
    bp.mathOperation('P bottom in (bar)',"*",100,True,'P bottom in (kPa)')
    bp.deleteColumns('P bottom in (bar)')
    bp.mathOperation('P bottom out (bar)',"*",100,True,'P bottom out (kPa)')
    bp.deleteColumns('P bottom out (bar)')

    #Delete the pressure columns from the bypass run that we also don't need
    bp.deleteColumns(['P bottom in (bar)[bypass]','P bottom out (bar)[bypass]'])

    # Append O2 info
    frame_list = [10]*len(data.getTimeFrames())
    data.appendColumnByFrame("O2%",frame_list)

    #Manually align by adding bypass data for NO, N2O, NO2, H2O, NH3 based on averages from bp
    avg = bp.getAverage('NH3 (300,3000)')
    frame_list = [avg]*len(data.getTimeFrames())
    data.appendColumnByFrame("NH3 (300,3000)[input]",frame_list)

    avg = bp.getAverage('H2O% (20)')
    frame_list = [avg]*len(data.getTimeFrames())
    data.appendColumnByFrame("H2O% (20)[input]",frame_list)

    avg = bp.getAverage('N2O (100,200,300)')
    frame_list = [avg]*len(data.getTimeFrames())
    data.appendColumnByFrame("N2O (100,200,300)[input]",frame_list)

    avg = bp.getAverage('NO (350,3000)')
    frame_list = [avg]*len(data.getTimeFrames())
    data.appendColumnByFrame("NO (350,3000)[input]",frame_list)

    avg = bp.getAverage('NO2 (150,2000)')
    frame_list = [avg]*len(data.getTimeFrames())
    data.appendColumnByFrame("NO2 (150,2000)[input]",frame_list)

    #Plots and Outputs
    if output_folder=="":
        output_folder = "output"
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)
    data.savePlots(folder=output_folder+"/Other-plots/"+data.input_file_name.split("-")[4]+"/")
    data.compressRows(factor=10)
    file_name = data.input_file_name.split(".")[0]+"-output.dat"
    data.printAlltoFile(output_folder+"/"+file_name)

    return total_data

# Processing for data that can be automatically paired
def perform_standard_processing_aligned(result_file, bypass_file, output_folder=""):
    data = PairedTransientData(bypass_file, result_file)
    total_data = data.getNumCols()*data.getNumRows()
    data.compressColumns()
    data.retainOnlyColumns(['Elapsed Time (min)','NH3 (300,3000)', 'H2O% (20)',
        'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150,2000)',
        'TC bot sample in (C)', 'TC bot sample mid 1 (C)', 'TC bot sample mid 2 (C)',
        'TC bot sample out 1 (C)', 'TC bot sample out 2 (C)', 'P bottom in (bar)', 'P bottom out (bar)'])

    data.alignData(addNoise = True, verticalAlignment = False)

    #Convert all temperatures from (C) to Kelvin, then delete old columns
    data.mathOperation('TC bot sample in (C)',"+",273.15, True, 'TC bot sample in (K)')
    data.deleteColumns('TC bot sample in (C)')
    data.mathOperation('TC bot sample mid 1 (C)',"+",273.15, True, 'TC bot sample mid 1 (K)')
    data.deleteColumns('TC bot sample mid 1 (C)')
    data.mathOperation('TC bot sample mid 2 (C)',"+",273.15, True, 'TC bot sample mid 2 (K)')
    data.deleteColumns('TC bot sample mid 2 (C)')
    data.mathOperation('TC bot sample out 1 (C)',"+",273.15, True, 'TC bot sample out 1 (K)')
    data.deleteColumns('TC bot sample out 1 (C)')
    data.mathOperation('TC bot sample out 2 (C)',"+",273.15, True, 'TC bot sample out 2 (K)')
    data.deleteColumns('TC bot sample out 2 (C)')
    #Delete the temperature columns from the bypass run that we don't need
    data.deleteColumns(['TC bot sample in (C)[bypass]','TC bot sample mid 1 (C)[bypass]',
        'TC bot sample mid 2 (C)[bypass]','TC bot sample out 1 (C)[bypass]','TC bot sample out 2 (C)[bypass]'])

    #Now, convert all pressures from bar to kPa and delete the extra [bypass] columns
    data.mathOperation('P bottom in (bar)',"*",100,True,'P bottom in (kPa)')
    data.deleteColumns('P bottom in (bar)')
    data.mathOperation('P bottom out (bar)',"*",100,True,'P bottom out (kPa)')
    data.deleteColumns('P bottom out (bar)')

    #Delete the pressure columns from the bypass run that we also don't need
    data.deleteColumns(['P bottom in (bar)[bypass]','P bottom out (bar)[bypass]'])

    # At time_frames[1], we have the start and stop times for the change in O2 levels (if the data can be aligned)
    data.appendColumnByFrame("O2%",[10,0.2,10,10,10,10,10,10,10,10])

    #Plots and Outputs
    if output_folder=="":
        output_folder = "output"
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)
    data.savePlots(folder=output_folder+"/NH3Inv-plots/"+data.result_trans_obj.input_file_name.split("-")[-1]+"/")
    data.compressRows(factor=10)
    file_name = data.result_trans_obj.input_file_name.split(".")[0]+"-AllPairedOutput.dat"
    data.printAlltoFile(output_folder+"/"+file_name)

    return total_data

# Processing for a given folder of data (represents all runs from a specific aged catalyst)
def run_all_data_in_folder(input_folder, output_folder=""):
    unpairable_list = []
    pairable_list = []
    pairable_bp = ""
    unpairable_bp = []
    for file in os.listdir(input_folder):
        if (file.split("-")[4]=="NH3Inv"):
            if (file.split("-")[-1]!="bp"):
                pairable_list.append(file)
            else:
                pairable_bp=file
        else:
            if (file.split("-")[-1]!="bp"):
                unpairable_list.append(file)
            else:
                unpairable_bp.append(file)

    unpaired_tuples = []
    total_data=0
    for item in unpairable_list:
        for bp in unpairable_bp:
            if (item.split("-")[4]==bp.split("-")[4]):
                unpaired_tuples.append((item,bp))

    if (input_folder.split("/")[-1]!=''):
        input_folder = input_folder+"/"
    if (output_folder==""):
        output_folder = input_folder.split("/")[-2]+"-Output"
    for result in pairable_list:
        print("\n\nReading file "+result)
        total_data += perform_standard_processing_aligned(input_folder+result, input_folder+pairable_bp, output_folder)
    for pair in unpaired_tuples:
        print("\n\nReading file "+pair[0])
        total_data += perform_standard_processing_not_aligned(input_folder+pair[0], input_folder+pair[1], output_folder)

    return total_data

##Define a help message to display
def help_message():
    print()
    print("NH3_SCR_processing.py script command line options...")
    print()
    print("\t-h           Print this message")
    print("\t-i <folder>  Provide the name of the folder that contains folders of all SCR data files")
    print("\t-o <folder>  [Optional] Provide the name of a location to which output will be saved")
    print()
    print("Example Usage:")
    print()
    print("\tpython NH3_SCR_processing.py -i AllSCRData/ -o output")
    print()

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

    start = time.time()
    total=0
    for folder in os.listdir(input_folder):
        print("\n\nReading from " + input_folder+"/"+folder)
        total+=run_all_data_in_folder(input_folder+"/"+folder)

    end = time.time()
    elapse_min = (end-start)/60
    print("\nCOMPLETED!!!")
    print("\tWe processed " + str(total) + " data points in " + str(elapse_min) + " min!\n")

##Directs python to call the main function
if __name__ == "__main__":
    main(sys.argv[1:])
