##   @package FuelBlends_data_processing
#
#    @brief Script to read in data from Co-Optima fuel blend experiments
#
#    @details Python script to read in Co-Optima transient data for
#                for fuel blends data folders and compress that data
#                to form average behavior during light-off. The formatting
#                of the data is fairly different from the SCR data sets, so
#                much of the coding here is custom to account for variations
#                in data handling and custom processing operations.
#
#    @author Austin Ladshaw
#
#    @date 12/07/2020
#
#    @copyright This software was designed and built at the Oak Ridge National
#                    Laboratory (ORNL) National Transportation Research Center
#                    (NTRC) by Austin Ladshaw for research in the catalytic
#                    reduction of NOx. Copyright (c) 2020, all rights reserved.

from transient_data import TransientData
import os, sys, getopt
import time

## Function to read in a single file, do basic data pre-processing, and return transient object for post-processing
def readCoOptimaFile(run_name, bypass_name):
    # NOTE: The 5 index of the file name (after split on '-') is the name of the blend
    #       HOWEVER, in some cases, we need both the 5th and 6th index
    #       The last index is always the run number
    #       The first index is the date (which needs to be combined with the run #)

    # Use the fuel name as the folder to store processed data
    #       Sub-directory in that folder will be named after date and run #
    print("Reading file: " + run_name + "...")

    base_folder = run_name.split("/")[1].split("-")[5]
    if run_name.split("/")[1].split("-")[6] != "5Cramp":
        base_folder += run_name.split("/")[1].split("-")[6]
    sub_folder =  run_name.split("/")[0] + "/" + run_name.split("/")[1].split("-")[0] + "_run" + run_name.split("/")[1].split("-")[-1]
    print(sub_folder)
    sub_folder = sub_folder.split("/")[1]

    bypass = TransientData(bypass_name)
    run = TransientData(run_name)

    # Next, the Ethanol and CO columns have different tolerances, but with different units.
    # To deal with this, we need to first do some column manipulation to create new columns based
    # on the ppm tolerances.
    bypass.mathOperation('CO% (1)',"*",10000,True,'CO (10000)')
    run.mathOperation('CO% (1)',"*",10000,True,'CO (10000)')

    bypass.mathOperation('Ethanol% (1)',"*",10000,True,'Ethanol (10000)')
    run.mathOperation('Ethanol% (1)',"*",10000,True,'Ethanol (10000)')

    bypass.deleteColumns(['CO% (1)','Ethanol% (1)'])
    run.deleteColumns(['CO% (1)','Ethanol% (1)'])

    # Now we can compress the columns for each AND delete columns we don't need...
    bypass.compressColumns()
    run.compressColumns()

    #       NOTE: Many of these items to retain may change from file to file, which is why we have to do this manually

    # 50% toluene and 50% n-heptane
    if base_folder == "50pctToluene50pctNheptane":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)',
         'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Toluene (1000)',
          'Isobutylene (500)', 'Propylene (200,1000)', 'Isopentane (500)', 'AI 71', 'AI 91', 'AI (#3)', 'AI (#4)',
           'FID THC (ppm C1)',
         'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)',
          'P tup in (bar)', 'P top out (bar)',
         'NH3 (300,3000)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # 25% toluene and 75% n-heptane
    if base_folder == "25pctToluene75pctNheptane":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)',
         'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Toluene (1000)',
          'Isobutylene (500)', 'Propylene (200,1000)', 'Isopentane (500)', 'AI 71', 'AI 91', 'AI (#3)', 'AI (#4)',
           'FID THC (ppm C1)',
         'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)',
          'P tup in (bar)', 'P top out (bar)',
         'NH3 (300,3000)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # 10% toluene and 90% n-heptane
    if base_folder == "10pctToluene90pctNheptane":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)',
         'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Toluene (1000)',
          'Isobutylene (500)', 'Propylene (200,1000)', 'Isopentane (500)', 'AI 71', 'AI 91', 'AI (#3)', 'AI (#4)',
           'FID THC (ppm C1)',
         'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)',
          'P tup in (bar)', 'P top out (bar)',
         'NH3 (300,3000)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # 5% toluene and 95% n-heptane
    if base_folder == "5pctToluene95pctNheptane":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)',
         'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Toluene (1000)',
          'Isobutylene (500)', 'Propylene (200,1000)', 'Isopentane (500)', 'AI 71', 'AI 91', 'AI (#3)', 'AI (#4)',
           'FID THC (ppm C1)',
         'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)',
          'P tup in (bar)', 'P top out (bar)',
         'NH3 (300,3000)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # BOB-baseline
    if base_folder == "BobBOB":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)',
         'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Toluene (1000)',
          'Isobutylene (500)', 'Propylene (200,1000)', 'Isopentane (500)', 'AI 57', 'AI 71', 'AI 84', 'AI 91',
           'FID THC (ppm C1)',
         'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)',
          'P tup in (bar)', 'P top out (bar)',
         'NH3 (300,3000)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # BOB-E10
    if base_folder == "EtOH10pctBobBOB":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)',
         'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Toluene (1000)',
          'Isobutylene (500)', 'Propylene (200,1000)', 'Isopentane (500)', 'AI 57', 'AI 71', 'AI 84', 'AI 91',
           'FID THC (ppm C1)',
         'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)',
          'P tup in (bar)', 'P top out (bar)',
         'NH3 (300,3000)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # BOB-E20
    if base_folder == "EtOH20pctBobBOB":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)',
         'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Toluene (1000)',
          'Isobutylene (500)', 'Propylene (200,1000)', 'Isopentane (500)', 'AI 57', 'AI 71', 'AI 84', 'AI 91',
           'FID THC (ppm C1)',
         'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)',
          'P tup in (bar)', 'P top out (bar)',
         'NH3 (300,3000)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # BOB-E30
    if base_folder == "EtOH30pctBobBOB":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)',
         'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Toluene (1000)',
          'Isobutylene (500)', 'Propylene (200,1000)', 'Isopentane (500)', 'AI 57', 'AI 71', 'AI 84', 'AI 91',
           'FID THC (ppm C1)',
         'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)',
          'P tup in (bar)', 'P top out (bar)',
         'NH3 (300,3000)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    #End if statements for folder names

    # Uncomment out these lines to view the column names at this point
    #run.displayColumnNames()
    #print(list)
    #sys.exit()

    bypass.retainOnlyColumns(list)
    run.retainOnlyColumns(list)

    # If no errors are reported, then both the bypass and the run will have the same columns/names at this point

    # Next, remove any negative values from observations since they are not physically relavent
    bypass.removeNegatives(list)
    run.removeNegatives(list)

    # Now, we need to use the bypass data to find the average input values for each column
    avg = {}
    for item in list:
        avg[item] = bypass.getAverage(item)

    # Next, append columns to the run using the average inlet values just calculated from the bypass
    # Have to use appendColumnByFrame even though each frame will have same values
    frame_list = [0.]*len(run.getTimeFrames())
    for item in avg:
        if item != 'Elapsed Time (min)' and item != 'TC top sample in (C)' and item != 'TC top sample mid 2 (C)' and item != 'TC top sample out (C)' and item != 'P tup in (bar)' and item != 'P top out (bar)':
            i=0
            for v in frame_list:
                frame_list[i] = avg[item]
                i+=1
            run.appendColumnByFrame(item+'[bypass]', frame_list)

    # Now, we can apply some additional pre-processing, such as normalization or scaling of data based on the bypass
    AI_list = []
    for item in list:
        if "AI" in item and "bypass" not in item:
            AI_list.append(item)
    for item in AI_list:
        # This line will automatically override the existing AI columns and normalize them to the bypass AI columns
        # Then, for specific AI columns, we can multiply through by the ppm specific value
        # NOTE: Since the AI columns change from folder to folder, we can't really automate more than AI 2 for H2

        if item == 'AI 2' or item == 'AI 2)':
            run.mathOperation(item,"/",item+'[bypass]')
            run.mathOperation(item,"*",1670, True, 'H2 (ppm)')
            frame_list = [1670]*len(run.getTimeFrames())
            run.appendColumnByFrame('H2 (ppm)[bypass]', frame_list)
        else:
            run.mathOperation(item+'[bypass]',"-",run.getMinimum(item))
            run.mathOperation(item,"-",run.getMinimum(item))
            run.mathOperation(item,"/",item+'[bypass]')
    #End AI_list loop

    #Special case for E10 mixture
    #if base_folder == "CH3CH2OH+iC8H18+C6H5CH3":
    #    for item in AI_list:
    #        if item == 'AI 31':
    #            run.mathOperation(item,"*",0.10, True, 'ethanol (ppm C1)')
    #            run.mathOperation('ethanol (ppm C1)',"*",3000)
    #            frame_list = [300]*len(run.getTimeFrames())
    #            run.appendColumnByFrame('ethanol (ppm C1)[bypass]', frame_list)
    #        if item == 'AI 57':
    #            run.mathOperation(item,"*",0.65, True, 'iso-octane (ppm C1)')
    #            run.mathOperation('iso-octane (ppm C1)',"*",3000)
    #            frame_list = [1950]*len(run.getTimeFrames())
    #            run.appendColumnByFrame('iso-octane (ppm C1)[bypass]', frame_list)
    #        if item == 'AI 91':
    #            run.mathOperation(item,"*",0.25, True, 'toluene (ppm C1)')
    #            run.mathOperation('toluene (ppm C1)',"*",3000)
    #            frame_list = [750]*len(run.getTimeFrames())
    #            run.appendColumnByFrame('toluene (ppm C1)[bypass]', frame_list)

    # AI values...
    #       2 = H2
    #       57 = iso-octane
    #       31 = ethanol
    #       91 = toluene
    #       43 = n-octane

    #       E10 (blend)
    #           65% iso-octane
    #           25% toluene
    #           10% ethanol

    # Next, scale the 'FID THC (ppm C1)' column by dividing by the corresponding bypass, then multiplying by 3000
    run.mathOperation('FID THC (ppm C1)',"/",'FID THC (ppm C1)[bypass]')
    run.mathOperation('FID THC (ppm C1)',"*",3000)
    run.mathOperation('FID THC (ppm C1)[bypass]',"/",'FID THC (ppm C1)[bypass]')
    run.mathOperation('FID THC (ppm C1)[bypass]',"*",3000)

    # Next, create columns for the appropriate O2 concentrations based on Sreshtha's paper (table 4)
    #       Fuel Blend                  O2 %
    #       ---------                   -----
    #       BOB Baseline                 0.706
    #       BOB E-10%                    0.706
    #       BOB E-20%                    0.707
    #       BOB E-30%                    0.707
    #       50/50 tol/hep                0.685
    #       25/75 tol/hep                0.708
    #       10/90 tol/hep                0.724
    #        5/95 tol/hep                0.729

    # 50% toluene and 50% n-heptane
    if base_folder == "50pctToluene50pctNheptane":
        frame_list = [0.685]*len(run.getTimeFrames())

    # 25% toluene and 75% n-heptane
    if base_folder == "25pctToluene75pctNheptane":
        frame_list = [0.708]*len(run.getTimeFrames())

    # 10% toluene and 90% n-heptane
    if base_folder == "10pctToluene90pctNheptane":
        frame_list = [0.724]*len(run.getTimeFrames())

    # 5% toluene and 95% n-heptane
    if base_folder == "5pctToluene95pctNheptane":
        frame_list = [0.729]*len(run.getTimeFrames())

    # BOB-baseline
    if base_folder == "BobBOB":
        frame_list = [0.706]*len(run.getTimeFrames())

    # BOB-E10
    if base_folder == "EtOH10pctBobBOB":
        frame_list = [0.706]*len(run.getTimeFrames())

    # BOB-E20
    if base_folder == "EtOH20pctBobBOB":
        frame_list = [0.707]*len(run.getTimeFrames())

    # BOB-E30
    if base_folder == "EtOH30pctBobBOB":
        frame_list = [0.707]*len(run.getTimeFrames())

    #End if statements for different blends

    run.appendColumnByFrame('O2%', frame_list)

    # Now, create column for FID Conversion %, CO conversion %, and NOx conversion %
    run.mathOperation('FID THC (ppm C1)[bypass]',"-",'FID THC (ppm C1)', True, 'THC Conversion %')
    run.mathOperation('THC Conversion %',"/",'FID THC (ppm C1)[bypass]')
    run.mathOperation('THC Conversion %',"*",100)

    run.mathOperation('CO (500,10000)[bypass]',"-",'CO (500,10000)', True, 'CO Conversion %')
    run.mathOperation('CO Conversion %',"/",'CO (500,10000)[bypass]')
    run.mathOperation('CO Conversion %',"*",100)

    frame_list = [0.]*len(run.getTimeFrames())
    run.appendColumnByFrame('NOx (ppm)', frame_list)
    run.appendColumnByFrame('NOx (ppm)[bypass]', frame_list)
    run.mathOperation('NOx (ppm)',"+",'NO (350,3000)')
    run.mathOperation('NOx (ppm)',"+",'NO2 (150)')
    run.mathOperation('NOx (ppm)[bypass]',"+",'NO (350,3000)[bypass]')
    run.mathOperation('NOx (ppm)[bypass]',"+",'NO2 (150)[bypass]')

    run.mathOperation('NOx (ppm)[bypass]',"-",'NOx (ppm)', True, 'NOx Conversion %')
    run.mathOperation('NOx Conversion %',"/",'NOx (ppm)[bypass]')
    run.mathOperation('NOx Conversion %',"*",100)

    # Next, we will create a column for the average internal temperature. This temperature will
    # be just a simple average since each zone of the catalyst is the same length.
    run.mathOperation('TC top sample out (C)',"+",'TC top sample mid 2 (C)', True, 'Avg Internal Temp (C)')
    run.mathOperation('Avg Internal Temp (C)',"/",2)

    return run

## Function to calculate various T-n values and print them to a file
def printTnValues(obj, out_dir):
    # For simplification, we will calculate and print out T-10, T-30, T-50, T-70, and T-90
    conv_per = [10,20,30,40,50,60,70,80,90]  #unit: %
    span = 2  # +/- 1%
    temp = 'TC top sample in (C)'
    chem_name = out_dir.split("/")[0].split("-")[0]

    #Iterate through the data map of the obj and record temperatures from +/- 5 conversion % for each category
    #   Categories:  'THC Conversion %', 'CO Conversion %', and 'NOx Conversion %'
    conv_map = {}
    conv_map['THC Conversion %'] = [0.]*len(conv_per)
    conv_map['CO Conversion %'] = [0.]*len(conv_per)
    conv_map['NOx Conversion %'] = [0.]*len(conv_per)

    for item in conv_map:
        i=0
        for per in conv_per:
            count = 0
            j=0
            for value in obj.data_map[item]:
                if value >= per - span and value <= per + span:
                    conv_map[item][i] += obj.data_map[temp][j]
                    count+=1
                j+=1
            if count != 0:
                conv_map[item][i] = conv_map[item][i]/count
            else:
                conv_map[item][i] = 100
            i+=1

    file_name = out_dir + "ConversionTemperatures.dat"
    file = open(file_name,'w')
    file.write("T-n")
    for item in conv_map:
        file.write("\t"+item)
    file.write("\n")
    i=0
    for value in conv_per:
        file.write(str(value))
        for item in conv_map:
            file.write("\t"+str(conv_map[item][i]))
        i+=1
        file.write("\n")
    file.close()
    return

##Function to print out conversion rates at different temperatures
def printConvRates(obj, out_dir, tau, inlet_temp=True):
    conv_temp = [120,140,160,180,200,220,240,260,280,300,320,340,360,380,400,420,440,460,480,500]
    span = 5
    if inlet_temp == True:
        temp = 'TC top sample in (C)'
    else:
        temp = 'Avg Internal Temp (C)'
        conv_temp.append(520)
    chem_name = out_dir.split("/")[0].split("-")[0]

    conv_map = {}
    conv_map['TC top sample in (C)'] = [0.]*len(conv_temp)
    conv_map['THC Conversion %'] = [0.]*len(conv_temp)
    conv_map['CO Conversion %'] = [0.]*len(conv_temp)
    conv_map['NOx Conversion %'] = [0.]*len(conv_temp)
    conv_map['TC top sample mid 2 (C)'] = [0.]*len(conv_temp)
    conv_map['TC top sample out (C)'] = [0.]*len(conv_temp)
    conv_map['Avg Internal Temp (C)'] = [0.]*len(conv_temp)
    conv_map['O2%'] = [0.]*len(conv_temp)

    for item in obj.data_map:
        #What we want from all files
        if 'N2O' in item and 'bypass' not in item:
            conv_map[item] = [0.]*len(conv_temp)
            conv_map[item+'[bypass]'] = [0.]*len(conv_temp)
            conv_map['N2O'+'[Mrxn]'] = [0.]*len(conv_temp)
        if 'NO' in item and 'bypass' not in item and 'NOx' not in item and 'NO2' not in item:
            conv_map[item] = [0.]*len(conv_temp)
            conv_map[item+'[bypass]'] = [0.]*len(conv_temp)
            conv_map['NO'+'[Mrxn]'] = [0.]*len(conv_temp)
        if 'NO2' in item and 'bypass' not in item:
            conv_map[item] = [0.]*len(conv_temp)
            conv_map[item+'[bypass]'] = [0.]*len(conv_temp)
            conv_map['NO2'+'[Mrxn]'] = [0.]*len(conv_temp)
        if 'H2O' in item and 'bypass' not in item:
            conv_map[item] = [0.]*len(conv_temp)
            conv_map[item+'[bypass]'] = [0.]*len(conv_temp)
            conv_map['H2O'+'[Mrxn]'] = [0.]*len(conv_temp)
        if 'CO2' in item and 'bypass' not in item:
            conv_map[item] = [0.]*len(conv_temp)
            conv_map[item+'[bypass]'] = [0.]*len(conv_temp)
            conv_map['CO2'+'[Mrxn]'] = [0.]*len(conv_temp)
        if 'FID' in item and 'bypass' not in item:
            conv_map[item] = [0.]*len(conv_temp)
            conv_map[item+'[bypass]'] = [0.]*len(conv_temp)
            conv_map['FID'+'[Mrxn]'] = [0.]*len(conv_temp)
        if 'NH3' in item and 'bypass' not in item:
            conv_map[item] = [0.]*len(conv_temp)
            conv_map[item+'[bypass]'] = [0.]*len(conv_temp)
            conv_map['NH3'+'[Mrxn]'] = [0.]*len(conv_temp)
        if 'CO' in item and 'bypass' not in item and 'Conversion' not in item and 'CO2' not in item:
            conv_map[item] = [0.]*len(conv_temp)
            conv_map[item+'[bypass]'] = [0.]*len(conv_temp)
            conv_map['CO'+'[Mrxn]'] = [0.]*len(conv_temp)

        #Special Case
        #if chem_name == "CH3CH2OH+iC8H18+C6H5CH3":
        #    if 'ethanol' in item and 'bypass' not in item:
        #        conv_map[item] = [0.]*len(conv_temp)
        #        conv_map[item+'[bypass]'] = [0.]*len(conv_temp)
        #        conv_map['ethanol'+'[Mrxn]'] = [0.]*len(conv_temp)
        #    if 'iso-octane' in item and 'bypass' not in item:
        #        conv_map[item] = [0.]*len(conv_temp)
        #        conv_map[item+'[bypass]'] = [0.]*len(conv_temp)
        #        conv_map['iso-octane'+'[Mrxn]'] = [0.]*len(conv_temp)
        #    if 'toluene' in item and 'bypass' not in item:
        #        conv_map[item] = [0.]*len(conv_temp)
        #        conv_map[item+'[bypass]'] = [0.]*len(conv_temp)
        #        conv_map['toluene'+'[Mrxn]'] = [0.]*len(conv_temp)

    #Loop for form conv map at specified temperatures
    for item in conv_map:
        if item in obj.data_map:
            i=0
            for ct in conv_temp:
                count = 0
                j=0
                for value in obj.data_map[item]:
                    if obj.data_map[temp][j] >= ct - span and obj.data_map[temp][j] <= ct + span:
                        conv_map[item][i] += obj.data_map[item][j]
                        count+=1
                    j+=1
                conv_map[item][i] = conv_map[item][i]/count
                i+=1

    #One more loop to calculate the overall conversion rates
    for item in obj.data_map:
        #What we want from all files
        if 'N2O' in item and 'bypass' not in item:
            j=0
            for value in conv_map[item]:
                conv_map['N2O'+'[Mrxn]'][j] = (conv_map[item][j] - conv_map[item+'[bypass]'][j])*tau
                j+=1
        if 'NO' in item and 'bypass' not in item and 'NOx' not in item and 'NO2' not in item:
            j=0
            for value in conv_map[item]:
                conv_map['NO'+'[Mrxn]'][j] = (conv_map[item][j] - conv_map[item+'[bypass]'][j])*tau
                j+=1
        if 'NO2' in item and 'bypass' not in item:
            j=0
            for value in conv_map[item]:
                conv_map['NO2'+'[Mrxn]'][j] = (conv_map[item][j] - conv_map[item+'[bypass]'][j])*tau
                j+=1
        if 'H2O' in item and 'bypass' not in item:
            j=0
            for value in conv_map[item]:
                conv_map['H2O'+'[Mrxn]'][j] = (conv_map[item][j] - conv_map[item+'[bypass]'][j])*tau
                j+=1
        if 'CO2' in item and 'bypass' not in item:
            j=0
            for value in conv_map[item]:
                conv_map['CO2'+'[Mrxn]'][j] = (conv_map[item][j] - conv_map[item+'[bypass]'][j])*tau
                j+=1
        if 'FID' in item and 'bypass' not in item:
            j=0
            for value in conv_map[item]:
                conv_map['FID'+'[Mrxn]'][j] = (conv_map[item][j] - conv_map[item+'[bypass]'][j])*tau
                j+=1
        if 'NH3' in item and 'bypass' not in item:
            j=0
            for value in conv_map[item]:
                conv_map['NH3'+'[Mrxn]'][j] = (conv_map[item][j] - conv_map[item+'[bypass]'][j])*tau
                j+=1
        if 'CO' in item and 'bypass' not in item and 'Conversion' not in item and 'CO2' not in item:
            j=0
            for value in conv_map[item]:
                conv_map['CO'+'[Mrxn]'][j] = (conv_map[item][j] - conv_map[item+'[bypass]'][j])*tau
                j+=1

        #Special Case
        #if chem_name == "CH3CH2OH+iC8H18+C6H5CH3":
        #    if 'ethanol' in item and 'bypass' not in item:
        #        j=0
        #        for value in conv_map[item]:
        #            conv_map['ethanol'+'[Mrxn]'][j] = (conv_map[item][j] - conv_map[item+'[bypass]'][j])*tau
        #            j+=1
        #    if 'iso-octane' in item and 'bypass' not in item:
        #        j=0
        #        for value in conv_map[item]:
        #            conv_map['iso-octane'+'[Mrxn]'][j] = (conv_map[item][j] - conv_map[item+'[bypass]'][j])*tau
        #            j+=1
        #    if 'toluene' in item and 'bypass' not in item:
        #        j=0
        #        for value in conv_map[item]:
        #            conv_map['toluene'+'[Mrxn]'][j] = (conv_map[item][j] - conv_map[item+'[bypass]'][j])*tau
        #            j+=1


    if inlet_temp == True:
        file_name = out_dir + "ConversionRates.dat"
    else:
        file_name = out_dir + "ConversionRates-CatTemp.dat"
    file = open(file_name,'w')
    file.write("RefTemp (C)")
    for item in conv_map:
        file.write("\t"+item)
    file.write("\n")
    i=0
    for value in conv_temp:
        file.write(str(value))
        for item in conv_map:
            file.write("\t"+str(conv_map[item][i]))
        i+=1
        file.write("\n")
    file.close()

    return

##Function to print out the rate map
def printRateMap(obj, map, out_dir):
    file_name = out_dir + "ApproximateRateData.dat"
    file = open(file_name,'w')
    i=0
    first = ""
    for item in obj.data_map:
        if "bypass" not in item:
            if i==0:
                file.write(item)
                if item != obj.time_key:
                    if item+"[bypass]" in obj.data_map.keys():
                        file.write(item+"[bypass]")
                first = item
                if item != obj.time_key:
                    file.write("\t"+"d{"+item+"}/dt")
            else:
                file.write("\t"+item)
                if item != obj.time_key:
                    if item+"[bypass]" in obj.data_map.keys():
                        file.write("\t"+item+"[bypass]")
                if item != obj.time_key and "bypass" not in item:
                    file.write("\t"+"d{"+item+"}/dt")
        i+=1

    file.write("\n")
    j=0
    for value in map[first]:
        i = 0
        for item in obj.data_map:
            if "bypass" not in item:
                if i == 0:
                    file.write(str(map[item][j]))
                    if item != obj.time_key:
                        if item+"[bypass]" in obj.data_map.keys():
                            file.write(str(map[item+"[bypass]"][j]))
                    if item != obj.time_key:
                        file.write("\t"+str(map["d{"+item+"}/dt"][j]))
                else:
                    file.write("\t"+str(map[item][j]))
                    if item != obj.time_key:
                        if item+"[bypass]" in obj.data_map.keys():
                            file.write("\t"+str(map[item+"[bypass]"][j]))
                    if item != obj.time_key:
                        file.write("\t"+str(map["d{"+item+"}/dt"][j]))
            i+=1
        file.write("\n")
        j+=1
    file.close()
    return

## Function to read in a specific folder
def readCoOptimaBlendFolder(folder, tau):
    # Read in the bypass and run files separately
    run = []

    # 50-50_toluene-nheptane (3)
    if folder == "50-50_toluene-nheptane":
        bypass_name = "20190131-CPTMA-MalibuTWC-SGDI-30k-50pctToluene50pctNheptane-5Cramp-lambda0_999-bp-1"
        run_name =    "20190131-CPTMA-MalibuTWC-SGDI-30k-50pctToluene50pctNheptane-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20190131-CPTMA-MalibuTWC-SGDI-30k-50pctToluene50pctNheptane-5Cramp-lambda0_999-bp-2"
        run_name =    "20190131-CPTMA-MalibuTWC-SGDI-30k-50pctToluene50pctNheptane-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20190131-CPTMA-MalibuTWC-SGDI-30k-50pctToluene50pctNheptane-5Cramp-lambda0_999-bp-3"
        run_name =    "20190131-CPTMA-MalibuTWC-SGDI-30k-50pctToluene50pctNheptane-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # 25-75_toluene-nheptane (3)
    if folder == "25-75_toluene-nheptane":
        bypass_name = "20190208-CPTMA-MalibuTWC-SGDI-30k-25pctToluene-75pctNheptane-5Cramp-lambda0_999-bp-1"
        run_name =    "20190208-CPTMA-MalibuTWC-SGDI-30k-25pctToluene-75pctNheptane-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20190208-CPTMA-MalibuTWC-SGDI-30k-25pctToluene-75pctNheptane-5Cramp-lambda0_999-bp-2"
        run_name =    "20190208-CPTMA-MalibuTWC-SGDI-30k-25pctToluene-75pctNheptane-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20190208-CPTMA-MalibuTWC-SGDI-30k-25pctToluene-75pctNheptane-5Cramp-lambda0_999-bp-3"
        run_name =    "20190208-CPTMA-MalibuTWC-SGDI-30k-25pctToluene-75pctNheptane-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # 10-90_toluene-nheptane-30k (2)
    if folder == "10-90_toluene-nheptane-30k":
        bypass_name = "20190204-CPTMA-MalibuTWC-SGDI-30k-10pctToluene-90pctNheptane-5Cramp-lambda0_999-bp-1"
        run_name =    "20190204-CPTMA-MalibuTWC-SGDI-30k-10pctToluene-90pctNheptane-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20190205-CPTMA-MalibuTWC-SGDI-30k-10pctToluene-90pctNheptane-REPEAT-5Cramp-lambda0_999-bp-2"
        run_name =    "20190205-CPTMA-MalibuTWC-SGDI-30k-10pctToluene-90pctNheptane-REPEAT-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # 10-90_toluene-nheptane-60k (2)
    if folder == "10-90_toluene-nheptane-60k":
        bypass_name = "20190205-CPTMA-MalibuTWC-SGDI-60k-10pctToluene-90pctNheptane-REPEAT-5Cramp-lambda0_999-bp-4"
        run_name =    "20190205-CPTMA-MalibuTWC-SGDI-60k-10pctToluene-90pctNheptane-REPEAT-5Cramp-lambda0_999-4"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20190205-CPTMA-MalibuTWC-SGDI-60k-10pctToluene-90pctNheptane-REPEAT-5Cramp-lambda0_999-bp-5"
        run_name =    "20190205-CPTMA-MalibuTWC-SGDI-60k-10pctToluene-90pctNheptane-REPEAT-5Cramp-lambda0_999-5"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # 05-95_toluene-nheptane (3)
    if folder == "05-95_toluene-nheptane":
        bypass_name = "20190212-CPTMA-MalibuTWC-SGDI-30k-5pctToluene-95pctNheptane-5Cramp-lambda0_999-bp-1"
        run_name =    "20190212-CPTMA-MalibuTWC-SGDI-30k-5pctToluene-95pctNheptane-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20190212-CPTMA-MalibuTWC-SGDI-30k-5pctToluene-95pctNheptane-5Cramp-lambda0_999-bp-2"
        run_name =    "20190212-CPTMA-MalibuTWC-SGDI-30k-5pctToluene-95pctNheptane-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20190212-CPTMA-MalibuTWC-SGDI-30k-5pctToluene-95pctNheptane-5Cramp-lambda0_999-bp-3"
        run_name =    "20190212-CPTMA-MalibuTWC-SGDI-30k-5pctToluene-95pctNheptane-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # BOB-baseline (3)
    if folder == "BOB-baseline":
        bypass_name = "20180614-CPTMA-MalibuTWC-SGDI-30k-BobBOB-5Cramp-lambda0_999-bp-1"
        run_name =    "20180614-CPTMA-MalibuTWC-SGDI-30k-BobBOB-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20180614-CPTMA-MalibuTWC-SGDI-30k-BobBOB-5Cramp-lambda0_999-bp-2"
        run_name =    "20180614-CPTMA-MalibuTWC-SGDI-30k-BobBOB-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20180614-CPTMA-MalibuTWC-SGDI-30k-BobBOB-5Cramp-lambda0_999-bp-3"
        run_name =    "20180614-CPTMA-MalibuTWC-SGDI-30k-BobBOB-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # BOB-E10 (3)
    if folder == "BOB-E10":
        bypass_name = "20180618-CPTMA-MalibuTWC-SGDI-30k-EtOH10pctBobBOB-5Cramp-lambda0_999-bp-1"
        run_name =    "20180618-CPTMA-MalibuTWC-SGDI-30k-EtOH10pctBobBOB-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20180618-CPTMA-MalibuTWC-SGDI-30k-EtOH10pctBobBOB-5Cramp-lambda0_999-bp-2"
        run_name =    "20180618-CPTMA-MalibuTWC-SGDI-30k-EtOH10pctBobBOB-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20180618-CPTMA-MalibuTWC-SGDI-30k-EtOH10pctBobBOB-5Cramp-lambda0_999-bp-3"
        run_name =    "20180618-CPTMA-MalibuTWC-SGDI-30k-EtOH10pctBobBOB-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # BOB-E20 (6)
    if folder == "BOB-E20":
        bypass_name = "20180719-CPTMA-MalibuTWC-SGDI-30k-EtOH20pctBobBOB-5Cramp-lambda0_999-bp-1"
        run_name =    "20180719-CPTMA-MalibuTWC-SGDI-30k-EtOH20pctBobBOB-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20180719-CPTMA-MalibuTWC-SGDI-30k-EtOH20pctBobBOB-5Cramp-lambda0_999-bp-2"
        run_name =    "20180719-CPTMA-MalibuTWC-SGDI-30k-EtOH20pctBobBOB-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20180719-CPTMA-MalibuTWC-SGDI-30k-EtOH20pctBobBOB-5Cramp-lambda0_999-bp-3"
        run_name =    "20180719-CPTMA-MalibuTWC-SGDI-30k-EtOH20pctBobBOB-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20180720-CPTMA-MalibuTWC-SGDI-30k-EtOH20pctBobBOB-5Cramp-lambda0_999-bp-1"
        run_name =    "20180720-CPTMA-MalibuTWC-SGDI-30k-EtOH20pctBobBOB-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20180723-CPTMA-MalibuTWC-SGDI-30k-EtOH20pctBobBOB-5Cramp-lambda0_999-bp-1"
        run_name =    "20180723-CPTMA-MalibuTWC-SGDI-30k-EtOH20pctBobBOB-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20180723-CPTMA-MalibuTWC-SGDI-30k-EtOH20pctBobBOB-5Cramp-lambda0_999-bp-2"
        run_name =    "20180723-CPTMA-MalibuTWC-SGDI-30k-EtOH20pctBobBOB-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # BOB-E30 (3)
    if folder == "BOB-E30":
        bypass_name = "20180726-CPTMA-MalibuTWC-SGDI-30k-EtOH30pctBobBOB-5Cramp-lambda0_999-bp-1"
        run_name =    "20180726-CPTMA-MalibuTWC-SGDI-30k-EtOH30pctBobBOB-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20180726-CPTMA-MalibuTWC-SGDI-30k-EtOH30pctBobBOB-5Cramp-lambda0_999-bp-2"
        run_name =    "20180726-CPTMA-MalibuTWC-SGDI-30k-EtOH30pctBobBOB-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20180726-CPTMA-MalibuTWC-SGDI-30k-EtOH30pctBobBOB-5Cramp-lambda0_999-bp-3"
        run_name =    "20180726-CPTMA-MalibuTWC-SGDI-30k-EtOH30pctBobBOB-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    #End if statements for folder names

    #After the nested if statements, the run list should be holding all pre-processed data
    # Loop through this data to produce plots, charts, output, and post-processing
    i=0
    for obj in run:
        #Start aggregating runs to create the average
        if i > 0:
            for item in avg_run.data_map:
                j=0
                for value in avg_run.data_map[item]:
                    try:
                        avg_run.data_map[item][j] += obj.data_map[item][j]
                    except:
                        avg_run.data_map[item][j] += obj.data_map[item][-1]
                    j+=1

        # At this point, we can automatically create and save some plots for visualization
        # NOTE: The time frame indexed by 1 represents the temperature ramp
        base_name = obj.input_file_name.split(".")[0]

        base_folder = base_name.split("-")[5]
        if base_name.split("-")[6] != "5Cramp":
            base_folder += base_name.split("-")[6]
        sub_folder = base_name.split("-")[0] + "_run" + base_name.split("-")[-1]

        obj.createPlot('THC Conversion %', range=obj.getTimeFrames()[1], display=False, save=True, file_name=base_name+"--THC_Conv",file_type=".png",subdir=base_folder+"-output/"+sub_folder+"/",x_col='TC top sample in (C)')

        obj.createPlot('CO Conversion %', range=obj.getTimeFrames()[1], display=False, save=True, file_name=base_name+"--CO_Conv",file_type=".png",subdir=base_folder+"-output/"+sub_folder+"/",x_col='TC top sample in (C)')

        obj.createPlot('NOx Conversion %', range=obj.getTimeFrames()[1], display=False, save=True, file_name=base_name+"--NOx_Conv",file_type=".png",subdir=base_folder+"-output/"+sub_folder+"/",x_col='TC top sample in (C)')

        # At this point, we would attempt to calculate rate information (prior to row compression)
        rate_map = obj.createRateMap()
        printRateMap(obj, rate_map, out_dir=base_folder+"-output/"+sub_folder+"/")

        # May also want to calculate different T-n values and print to another file
        printTnValues(obj, out_dir=base_folder+"-output/"+sub_folder+"/")

        # Print the conversion rates (NOTE: We may have to pass the folder because each folder has different headers)
        printConvRates(obj, base_folder+"-output/"+sub_folder+"/", tau)
        printConvRates(obj, base_folder+"-output/"+sub_folder+"/", tau, False)

        i+=1


    #Output information for the average run
    # First, loop to average the sum
    for item in avg_run.data_map:
        j=0
        for value in avg_run.data_map[item]:
            avg_run.data_map[item][j] = avg_run.data_map[item][j]/len(run)
            j+=1


    #Next create the plots and calculate some specific rate info
    base_name = avg_run.input_file_name.split(".")[0]

    base_folder = base_name.split("-")[5]
    if base_name.split("-")[6] != "5Cramp":
        base_folder += base_name.split("-")[6]
    sub_folder = base_name.split("-")[0] + "_avg"

    avg_run.createPlot('THC Conversion %', range=avg_run.getTimeFrames()[1], display=False, save=True, file_name=base_name+"--THC_Conv_Avg",file_type=".png",subdir=base_folder+"-output/"+sub_folder+"/",x_col='TC top sample in (C)')

    avg_run.createPlot('CO Conversion %', range=avg_run.getTimeFrames()[1], display=False, save=True, file_name=base_name+"--CO_Conv_Avg",file_type=".png",subdir=base_folder+"-output/"+sub_folder+"/",x_col='TC top sample in (C)')

    avg_run.createPlot('NOx Conversion %', range=avg_run.getTimeFrames()[1], display=False, save=True, file_name=base_name+"--NOx_Conv_Avg",file_type=".png",subdir=base_folder+"-output/"+sub_folder+"/",x_col='TC top sample in (C)')

    # At this point, we would attempt to calculate rate information (prior to row compression)
    rate_map = avg_run.createRateMap()
    printRateMap(avg_run, rate_map, out_dir=base_folder+"-output/"+sub_folder+"/")

    # May also want to calculate different T-n values and print to another file
    printTnValues(avg_run, out_dir=base_folder+"-output/"+sub_folder+"/")

    # Print the conversion rates (NOTE: We may have to pass the folder because each folder has different headers)
    printConvRates(avg_run, base_folder+"-output/"+sub_folder+"/", tau)
    printConvRates(avg_run, base_folder+"-output/"+sub_folder+"/", tau, False)


    # Lastly, we will compress the rows and print the data to a file
    i=0
    for obj in run:
        base_name = obj.input_file_name.split(".")[0]

        base_folder = base_name.split("-")[5]
        if base_name.split("-")[6] != "5Cramp":
            base_folder += base_name.split("-")[6]
        sub_folder = base_name.split("-")[0] + "_run" + base_name.split("-")[-1]

        obj.compressRows(10)
        obj.printAlltoFile(base_folder+"-output/"+sub_folder+"/"+base_name+"_output.dat")
        i+=1

    #Output for the averaged data
    base_name = avg_run.input_file_name.split(".")[0]

    base_folder = base_name.split("-")[5]
    if base_name.split("-")[6] != "5Cramp":
        base_folder += base_name.split("-")[6]
    sub_folder = base_name.split("-")[0] + "_avg"

    avg_run.compressRows(10)
    avg_run.printAlltoFile(base_folder+"-output/"+sub_folder+"/"+base_name+"_Avg_output.dat")
    return


## Main function
def main(argv):
    # Co-Optima data cannot be automatically paired with by-pass data since the data frames for
    # the runs and by-pass do not match exactly. Instead, we will read in each seperately and
    # combine manually.

    #readCoOptimaBlendFolder("50-50_toluene-nheptane", tau=8.3333)
    #readCoOptimaBlendFolder("25-75_toluene-nheptane", tau=8.3333)
    #readCoOptimaBlendFolder("10-90_toluene-nheptane-30k", tau=8.3333)
    #readCoOptimaBlendFolder("10-90_toluene-nheptane-60k", tau=16.6666)
    #readCoOptimaBlendFolder("05-95_toluene-nheptane", tau=8.3333)

    #readCoOptimaBlendFolder("BOB-baseline", tau=8.3333)
    #readCoOptimaBlendFolder("BOB-E10", tau=8.3333)
    #readCoOptimaBlendFolder("BOB-E20", tau=8.3333)
    readCoOptimaBlendFolder("BOB-E30", tau=8.3333)

    return

##Directs python to call the main function
if __name__ == "__main__":
   main(sys.argv[1:])
