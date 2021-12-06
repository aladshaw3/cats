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

def perform_standard_processing_not_aligned(result_file, bypass_file):
    data = TransientData(result_file)
    bp = TransientData(bypass_file)
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
    data.savePlots()

    data.compressRows(factor=10)
    data.printAlltoFile()


def perform_standard_processing_aligned(result_file, bypass_file):
    data = PairedTransientData(bypass_file, result_file)
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
    data.savePlots()

    data.compressAllRows(factor=10)
    data.printAlltoFile()

##Directs python to call the main function
if __name__ == "__main__":
    folder = "raw/BASFCuSSZ13-700C4h-SCRprotocol/"
    #file = "20160202-CLRK-BASFCuSSZ13-700C4h-NH3Inv-60k-a1_0-250C"
    #bp =   "20160202-CLRK-BASFCuSSZ13-700C4h-NH3Inv-60k-a1_0-bp"
    #perform_standard_processing_aligned(folder+file,folder+bp)

    file = "20160202-CLRK-BASFCuSSZ13-700C4h-NO+NO2SCR-60k-a1_0-250-150C"
    bp =   "20160202-CLRK-BASFCuSSZ13-700C4h-NO+NO2SCR-60k-a1_0-bp"
    perform_standard_processing_not_aligned(folder+file,folder+bp)
