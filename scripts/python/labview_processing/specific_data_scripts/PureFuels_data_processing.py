##   @package PureFuels_data_processing
#
#    @brief Script to read in all folders of Co-Optima Pure Fuels Data
#
#    @details Python script to read in Co-Optima transient data for
#                for all sets of folders of the Pure Fuels transient
#                data and perform a series of analyses, compress the data,
#                output the data into a new compressed format, and prepare
#                a series of plots to visualize all data. This script works
#                in conjunction with the transient_data.py script.
#
#    @author Austin Ladshaw
#
#    @date 08/10/2020
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
    # NOTE: The 5 index of the file name (after split on '-') is the name of the pure fuel
    #       HOWEVER, in the case of 1-octene, we need both the 5th and 6th index
    #       The last index is always the run number
    #       The first index is the date (which needs to be combined with the run #)

    # Use the fuel name as the folder to store processed data
    #       Sub-directory in that folder will be named after date and run #
    print("Reading file: " + run_name + "...")

    base_folder = run_name.split("/")[1].split("-")[5]
    if base_folder == "1":
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

    # 1-hexene
    if base_folder == "1Hexene":
        list = ['Elapsed Time (min)','NH3 (300,3000)', 'H2O% (20)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'CO2% (20)', 'CO (500,10000)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Ethanol (1000,10000)', 'Toluene (1000)', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Propylene (200,1000)', 'Ethane (1000)', '2-Pentanone 150c', 'Isobutylene (500)', 'Isopentane (500)', 'CH4 (250,3000)', 'AI 2', 'AI 41', 'AI 43', 'AI 91', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)']

    # 1-octene
    if base_folder == "1Octene":
        list = ['Elapsed Time (min)','NH3 (3000,300)', 'H2O% (20)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'CO2% (20)', 'CO (500,10000)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Ethanol (1000,10000)', 'Toluene (1000)', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Propylene (200,1000)', 'Ethane (1000)', '2-Pentanone 150c', 'Isobutylene (500)', 'Isopentane (500)', 'CH4 (250,3000)', 'AI 2', 'AI 55', 'AI 56', 'AI 91', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)']

    # 1-propanol
    if base_folder == "1Propanol":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Anisole 150c', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Toluene (1000)', 'Isobutylene (500)', 'Ethane (1000)', 'Propylene (200,1000)', 'Isopentane (500)', 'AI 2', 'AI 31', 'AI 57', 'AI 91', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (3000,300)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # 2-Butanone
    if base_folder == "2Butanone":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Toluene (1000)', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Propylene (200,1000)', 'Isobutylene (500)', 'Ethane (1000)', 'Isopentane (500)', 'Methyl ethyl ketone', 'AI 2', 'AI 43', 'AI 96', 'AI 91', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (3000,300)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # 2-methylpentane
    if base_folder == "2MethylPentane":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Toluene (1000)', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Propylene (200,1000)', 'Ethane (1000)', '2-Pentanone 150c', 'Isobutylene (500)', 'Isopentane (500)', 'AI 2', 'AI 41', 'AI 42', 'AI 43', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (300,3000)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # 2-pentanone
    if base_folder == "2Pentaone":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Toluene (1000)', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Propylene (200,1000)', 'Ethane (1000)', '2-Pentanone 150c', 'Isobutylene (500)', 'Isopentane (500)', 'AI 2', 'AI 42', 'AI 43', 'AI 91', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (300,3000)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    ## ------- WARNING -------- This data set has an incorrectly labeled MS column for AI 2 --> 'AI 2)'
    ## ------------------------------------- see below -----------------------------------------------
    # 2-propanol
    if base_folder == "2Propanol":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', '2-Pentanone 150c', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Toluene (1000)', 'Isobutylene (500)', 'Ethane (1000)', 'Propylene (200,1000)', 'Isopentane (500)', 'AI 2)', 'AI 45', 'AI 57', 'AI 91', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (3000,300)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # anisole
    if base_folder == "Anisole":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Anisole 150c', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Toluene (1000)', 'Isobutylene (500)', 'Ethane (1000)', 'Propylene (200,1000)', 'Isopentane (500)', 'AI 2', 'AI 65', 'AI 78', 'AI 93', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (3000,300)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # butylacetate
    if base_folder == "ButylAcetate":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Ethyl Acetate 150c', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Propylene (200,1000)', 'Isobutylene (500)', 'Ethane (1000)', 'Toluene (1000)', 'Isopentane (500)', 'AI 2', 'AI 43', 'AI 57', 'AI 91', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (300,3000)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # cyclopentanone
    if base_folder == "Cyclopentanone":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', '2-Pentanone 150c', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Toluene (1000)', 'Isobutylene (500)', 'Ethane (1000)', 'Propylene (200,1000)', 'Isopentane (500)', 'AI 2', 'AI 43', 'AI 57', 'AI 91', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (3000,300)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # diisobutylene
    if base_folder == "Diisobutylene":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Methyl ethyl ketone', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Toluene (1000)', 'Isobutylene (500)', 'Ethane (1000)', 'Propylene (200,1000)', 'Isopentane (500)', 'AI 2', 'AI 97', 'AI 57', 'AI 91', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (3000,300)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # E10
    if base_folder == "CH3CH2OH+iC8H18+C6H5CH3":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Methyl ethyl ketone', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Toluene (1000)', 'Isobutylene (500)', 'Ethane (1000)', 'Propylene (200,1000)', 'Isopentane (500)', 'AI 2', 'AI 31', 'AI 57', 'AI 91', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (3000,300)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # ethanol
    if base_folder == "CH3CH2OH":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Methyl ethyl ketone', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Toluene (1000)', 'Isobutylene (500)', 'Ethane (1000)', 'Propylene (200,1000)', 'Isopentane (500)', 'AI 2', 'AI 31', 'AI 57', 'AI 91', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (3000,300)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # ethene
    if base_folder == "C2H4ONLY":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Toluene (1000)', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Propylene (200,1000)', 'Isobutylene (500)', 'Ethane (1000)', 'Propane', 'Anisole 150c', 'AI 2', 'AI 26', 'AI 57', 'AI 91', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (300,3000)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # ethyl acetate
    if base_folder == "EthylAcetate":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Ethyl Acetate 150c', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Toluene (1000)', 'Isobutylene (500)', 'Ethane (1000)', 'Propylene (200,1000)', 'Isopentane (500)', 'AI 2', 'AI 43', 'AI 57', 'AI 91', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (3000,300)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # furan mix
    if base_folder == "FuranMix":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Methyl ethyl ketone', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Toluene (1000)', 'Isobutylene (500)', 'Ethane (1000)', 'Propylene (200,1000)', 'Isopentane (500)', 'AI 2', 'AI 82', 'AI 96', 'AI 91', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (3000,300)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # iso-butanol
    if base_folder == "iBuOH":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Toluene (1000)', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Propylene (200,1000)', 'Isobutylene (500)', 'Ethane (1000)', 'Isopentane (500)', 'Methyl ethyl ketone', 'AI 2', 'AI 43', 'AI 96', 'AI 91', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (3000,300)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # iso-butylacetate (and repeat)
    if base_folder == "isoButylAcetate":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Ethyl Acetate 150c', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Propylene (200,1000)', 'Isobutylene (500)', 'Ethane (1000)', 'Toluene (1000)', 'Isopentane (500)', 'AI 2', 'AI 43', 'AI 56', 'AI 91', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (300,3000)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # iso-octane
    if base_folder == "isooctane":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', '2-Pentanone 150c', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Toluene (1000)', 'Isobutylene (500)', 'Ethane (1000)', 'Propylene (200,1000)', 'Isopentane (500)', 'AI 2', 'AI 31', 'AI 57', 'AI 91', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (3000,300)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # m-xylene
    if base_folder == "mXylene":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', '2-Pentanone 150c', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Toluene (1000)', 'Isobutylene (500)', 'Ethane (1000)', 'Propylene (200,1000)', 'Isopentane (500)', 'AI 2', 'AI 31', 'AI 77', 'AI 91', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (3000,300)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # mesitylene
    if base_folder == "mesitylene":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Methyl ethyl ketone', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Toluene (1000)', 'Isobutylene (500)', 'Ethane (1000)', 'Propylene (200,1000)', 'Isopentane (500)', 'AI 2', 'AI 77', 'AI 57', 'AI 91', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (3000,300)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # methane
    if base_folder == "CH4ONLY":
        list = ['Elapsed Time (min)', 'NO (350,3000)', 'NO2 (150)', 'Propylene (200,1000)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Propane', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Anisole 150c', 'Isobutylene (500)', 'Ethane (1000)', 'Toluene (1000)', 'N2O (100,200,300)', 'AI 2', 'AI 15', 'AI 57', 'AI 91', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (3000,300)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # methylcyclohexane
    if base_folder == "MCH":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', '2-Pentanone 150c', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Toluene (1000)', 'Isobutylene (500)', 'Ethane (1000)', 'Propylene (200,1000)', 'Isopentane (500)', 'AI 2', 'AI 41', 'AI 55', 'AI 83', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (3000,300)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # methylcyclopentane
    if base_folder == "MCP":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', '2-Pentanone 150c', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Toluene (1000)', 'Isobutylene (500)', 'Ethane (1000)', 'Propylene (200,1000)', 'Isopentane (500)', 'AI 2', 'AI 56', 'AI 57', 'AI 91', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (3000,300)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # methylisobutylketone
    if base_folder == "MIBK":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', '2-Pentanone 150c', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Propylene (200,1000)', 'Isobutylene (500)', 'Ethane (1000)', 'Toluene (1000)', 'Isopentane (500)', 'AI 2', 'AI 43', 'AI 57', 'AI 91', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (300,3000)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # n-butanol
    if base_folder == "nButanol":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Toluene (1000)', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Propylene (200,1000)', 'Ethane (1000)', 'Isopentane (500)', 'Isobutylene (500)', 'Anisole 150c', 'AI 2', 'AI 42', 'AI 57', 'AI 91', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (300,3000)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # n-heptane
    if base_folder == "nHeptane":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Toluene (1000)', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Propylene (200,1000)', 'Ethane (1000)', '2-Pentanone 150c', 'Isobutylene (500)', 'Isopentane (500)', 'AI 2', 'AI 43', 'AI 57', 'AI 71', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (300,3000)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # n-octane
    if base_folder == "nOctane":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', '2-Pentanone 150c', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Toluene (1000)', 'Isobutylene (500)', 'Ethane (1000)', 'Propylene (200,1000)', 'Isopentane (500)', 'AI 2', 'AI 43', 'AI 57', 'AI 91', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (3000,300)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # propane
    if base_folder == "C3H8ONLY":
        list = ['Elapsed Time (min)', 'NO (350,3000)', 'NO2 (150)', 'Propylene (200,1000)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Propane', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Anisole 150c', 'Isobutylene (500)', 'Ethane (1000)', 'Toluene (1000)', 'N2O (100,200,300)', 'AI 2', 'AI 15', 'AI 30', 'AI 43', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (3000,300)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # propene
    if base_folder == "C3H6ONLY":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Toluene (1000)', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Propylene (200,1000)', 'Ethane (1000)', 'Propane', 'Isobutylene (500)', 'Anisole 150c', 'AI 2', 'AI 39', 'AI 41', 'AI 42', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (300,3000)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    # toluene
    if base_folder == "Toluene":
        list = ['Elapsed Time (min)', 'N2O (100,200,300)', 'NO (350,3000)', 'NO2 (150)', 'H2O% (20)', 'CO2% (20)', 'Formaldehyde (70)', 'Acetaldehyde (1000)', 'Methyl ethyl ketone', 'Cyclohexane (100) 150C', 'Acetylene (1000)', 'Ethylene (100,3000)', 'Toluene (1000)', 'Isobutylene (500)', 'Ethane (1000)', 'Propylene (200,1000)', 'Isopentane (500)', 'AI 2', 'AI 31', 'AI 57', 'AI 91', 'FID THC (ppm C1)', 'TC top sample in (C)', 'TC top sample mid 2 (C)', 'TC top sample out (C)', 'P tup in (bar)', 'P top out (bar)', 'NH3 (3000,300)', 'CO (500,10000)', 'Ethanol (1000,10000)', 'CH4 (250,3000)']

    bypass.retainOnlyColumns(list)
    run.retainOnlyColumns(list)

    # If not errors are reported, then both the bypass and the run will have the same columns/names at this point

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

    #Special case for E10 mixture
    if base_folder == "CH3CH2OH+iC8H18+C6H5CH3":
        for item in AI_list:
            if item == 'AI 31':
                run.mathOperation(item,"*",0.10, True, 'ethanol (ppm C1)')
                run.mathOperation('ethanol (ppm C1)',"*",3000)
                frame_list = [300]*len(run.getTimeFrames())
                run.appendColumnByFrame('ethanol (ppm C1)[bypass]', frame_list)
            if item == 'AI 57':
                run.mathOperation(item,"*",0.65, True, 'iso-octane (ppm C1)')
                run.mathOperation('iso-octane (ppm C1)',"*",3000)
                frame_list = [1950]*len(run.getTimeFrames())
                run.appendColumnByFrame('iso-octane (ppm C1)[bypass]', frame_list)
            if item == 'AI 91':
                run.mathOperation(item,"*",0.25, True, 'toluene (ppm C1)')
                run.mathOperation('toluene (ppm C1)',"*",3000)
                frame_list = [750]*len(run.getTimeFrames())
                run.appendColumnByFrame('toluene (ppm C1)[bypass]', frame_list)

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
    #       Fuel                   O2 %
    #       ---------               -----
    #       ethanol                 0.71
    #       n-propanol              0.71
    #       iso-propanol            0.71
    #       n-butanol               0.71
    #       iso-butanol             0.71
    #       2-butanone              0.68
    #       2-pentanone             0.68
    #       cyclopentanone          0.65
    #       methylisobutylketone    0.69
    #       ethyl acetate           0.64
    #       butyl acetate           0.66
    #       iso-butyl acetate       0.66
    #       anisole                 0.63
    #       2,5-dimethylfuran
    #       (+) 2-methylfuran       0.63
    #       toluene                 0.65
    #       m-xylene                0.66
    #       mesitylene              0.66
    #       ethene                  0.71
    #       propene                 0.71
    #       1-hexene                0.71
    #       1-octene                0.71
    #       diisobutylene           0.71
    #       methane                 0.86
    #       propane                 0.76
    #       n-heptane               0.74
    #       n-octane                0.73
    #       2-methylpentane         0.74
    #       iso-octane              0.73
    #       methylcyclohexane       0.71
    #       methylcyclopentane      0.71
    #       E10 (blend)
    #           65% iso-octane
    #           25% toluene
    #           10% ethanol         0.708

    # 1-hexene
    if base_folder == "1Hexene":
        frame_list = [0.71]*len(run.getTimeFrames())

    # 1-octene
    if base_folder == "1Octene":
        frame_list = [0.71]*len(run.getTimeFrames())

    # 1-propanol
    if base_folder == "1Propanol":
        frame_list = [0.71]*len(run.getTimeFrames())

    # 2-Butanone
    if base_folder == "2Butanone":
        frame_list = [0.68]*len(run.getTimeFrames())

    # 2-methylpentane
    if base_folder == "2MethylPentane":
        frame_list = [0.74]*len(run.getTimeFrames())

    # 2-pentanone
    if base_folder == "2Pentaone":
        frame_list = [0.68]*len(run.getTimeFrames())

    # 2-propanol
    if base_folder == "2Propanol":
        frame_list = [0.71]*len(run.getTimeFrames())

    # anisole
    if base_folder == "Anisole":
        frame_list = [0.63]*len(run.getTimeFrames())

    # butylacetate
    if base_folder == "ButylAcetate":
        frame_list = [0.66]*len(run.getTimeFrames())

    # cyclopentanone
    if base_folder == "Cyclopentanone":
        frame_list = [0.65]*len(run.getTimeFrames())

    # diisobutylene
    if base_folder == "Diisobutylene":
        frame_list = [0.71]*len(run.getTimeFrames())

    # E10
    if base_folder == "CH3CH2OH+iC8H18+C6H5CH3":
        frame_list = [0.708]*len(run.getTimeFrames())

    # ethanol
    if base_folder == "CH3CH2OH":
        frame_list = [0.71]*len(run.getTimeFrames())

    # ethene
    if base_folder == "C2H4ONLY":
        frame_list = [0.71]*len(run.getTimeFrames())

    # ethyl acetate
    if base_folder == "EthylAcetate":
        frame_list = [0.64]*len(run.getTimeFrames())

    # furan mix
    if base_folder == "FuranMix":
        frame_list = [0.63]*len(run.getTimeFrames())

    # iso-butanol
    if base_folder == "iBuOH":
        frame_list = [0.71]*len(run.getTimeFrames())

    # iso-butylacetate (and repeat)
    if base_folder == "isoButylAcetate":
        frame_list = [0.66]*len(run.getTimeFrames())

    # iso-octane
    if base_folder == "isooctane":
        frame_list = [0.73]*len(run.getTimeFrames())

    # m-xylene
    if base_folder == "mXylene":
        frame_list = [0.66]*len(run.getTimeFrames())

    # mesitylene
    if base_folder == "mesitylene":
        frame_list = [0.66]*len(run.getTimeFrames())

    # methane
    if base_folder == "CH4ONLY":
        frame_list = [0.86]*len(run.getTimeFrames())

    # methylcyclohexane
    if base_folder == "MCH":
        frame_list = [0.71]*len(run.getTimeFrames())

    # methylcyclopentane
    if base_folder == "MCP":
        frame_list = [0.71]*len(run.getTimeFrames())

    # methylisobutylketone
    if base_folder == "MIBK":
        frame_list = [0.69]*len(run.getTimeFrames())

    # n-butanol
    if base_folder == "nButanol":
        frame_list = [0.71]*len(run.getTimeFrames())

    # n-heptane
    if base_folder == "nHeptane":
        frame_list = [0.74]*len(run.getTimeFrames())

    # n-octane
    if base_folder == "nOctane":
        frame_list = [0.73]*len(run.getTimeFrames())

    # propane
    if base_folder == "C3H8ONLY":
        frame_list = [0.76]*len(run.getTimeFrames())

    # propene
    if base_folder == "C3H6ONLY":
        frame_list = [0.71]*len(run.getTimeFrames())

    # toluene
    if base_folder == "Toluene":
        frame_list = [0.65]*len(run.getTimeFrames())

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
        if 'H2' in item and 'bypass' not in item and 'H2O' not in item:
            conv_map[item] = [0.]*len(conv_temp)
            conv_map[item+'[bypass]'] = [0.]*len(conv_temp)
            conv_map['H2'+'[Mrxn]'] = [0.]*len(conv_temp)

        #Special Case
        if chem_name == "CH3CH2OH+iC8H18+C6H5CH3":
            if 'ethanol' in item and 'bypass' not in item:
                conv_map[item] = [0.]*len(conv_temp)
                conv_map[item+'[bypass]'] = [0.]*len(conv_temp)
                conv_map['ethanol'+'[Mrxn]'] = [0.]*len(conv_temp)
            if 'iso-octane' in item and 'bypass' not in item:
                conv_map[item] = [0.]*len(conv_temp)
                conv_map[item+'[bypass]'] = [0.]*len(conv_temp)
                conv_map['iso-octane'+'[Mrxn]'] = [0.]*len(conv_temp)
            if 'toluene' in item and 'bypass' not in item:
                conv_map[item] = [0.]*len(conv_temp)
                conv_map[item+'[bypass]'] = [0.]*len(conv_temp)
                conv_map['toluene'+'[Mrxn]'] = [0.]*len(conv_temp)

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
        if 'H2' in item and 'bypass' not in item and 'H2O' not in item:
            j=0
            for value in conv_map[item]:
                conv_map['H2'+'[Mrxn]'][j] = (conv_map[item][j] - conv_map[item+'[bypass]'][j])*tau
                j+=1

        #Special Case
        if chem_name == "CH3CH2OH+iC8H18+C6H5CH3":
            if 'ethanol' in item and 'bypass' not in item:
                j=0
                for value in conv_map[item]:
                    conv_map['ethanol'+'[Mrxn]'][j] = (conv_map[item][j] - conv_map[item+'[bypass]'][j])*tau
                    j+=1
            if 'iso-octane' in item and 'bypass' not in item:
                j=0
                for value in conv_map[item]:
                    conv_map['iso-octane'+'[Mrxn]'][j] = (conv_map[item][j] - conv_map[item+'[bypass]'][j])*tau
                    j+=1
            if 'toluene' in item and 'bypass' not in item:
                j=0
                for value in conv_map[item]:
                    conv_map['toluene'+'[Mrxn]'][j] = (conv_map[item][j] - conv_map[item+'[bypass]'][j])*tau
                    j+=1


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
def readCoOptimaPureFuelFolder(folder, tau):
    # Read in the bypass and run files separately
    run = []

    # 1-hexene (3)
    if folder == "1-hexene":
        bypass_name = "20170807-CPTMA-MalibuTWC-SGDI-30k-1Hexene-5Cramp-lambda0_999-bp-1"
        run_name =    "20170807-CPTMA-MalibuTWC-SGDI-30k-1Hexene-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170807-CPTMA-MalibuTWC-SGDI-30k-1Hexene-5Cramp-lambda0_999-bp-2"
        run_name =    "20170807-CPTMA-MalibuTWC-SGDI-30k-1Hexene-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170807-CPTMA-MalibuTWC-SGDI-30k-1Hexene-5Cramp-lambda0_999-bp-3"
        run_name =    "20170807-CPTMA-MalibuTWC-SGDI-30k-1Hexene-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # 1-octene (4)
    if folder == "1-octene":
        bypass_name = "20170522-CPTMA-MalibuTWC-SGDI-30k-1-Octene-5Cramp-lambda0_999-bp-1"
        run_name =    "20170522-CPTMA-MalibuTWC-SGDI-30k-1-Octene-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170522-CPTMA-MalibuTWC-SGDI-30k-1-Octene-5Cramp-lambda0_999-bp-2"
        run_name =    "20170522-CPTMA-MalibuTWC-SGDI-30k-1-Octene-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170522-CPTMA-MalibuTWC-SGDI-30k-1-Octene-5Cramp-lambda0_999-bp-3"
        run_name =    "20170522-CPTMA-MalibuTWC-SGDI-30k-1-Octene-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170522-CPTMA-MalibuTWC-SGDI-30k-1-Octene-5Cramp-lambda0_999-bp-4"
        run_name =    "20170522-CPTMA-MalibuTWC-SGDI-30k-1-Octene-5Cramp-lambda0_999-4"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # 1-propanol (3)
    if folder == "1-propanol":
        bypass_name = "20170706-CPTMA-MalibuTWC-SGDI-30k-1Propanol-5Cramp-REPEAT-lambda0_999-bp-1"
        run_name =    "20170706-CPTMA-MalibuTWC-SGDI-30k-1Propanol-5Cramp-REPEAT-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170706-CPTMA-MalibuTWC-SGDI-30k-1Propanol-5Cramp-REPEAT-lambda0_999-bp-2"
        run_name =    "20170706-CPTMA-MalibuTWC-SGDI-30k-1Propanol-5Cramp-REPEAT-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170706-CPTMA-MalibuTWC-SGDI-30k-1Propanol-5Cramp-REPEAT-lambda0_999-bp-3"
        run_name =    "20170706-CPTMA-MalibuTWC-SGDI-30k-1Propanol-5Cramp-REPEAT-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # 2-Butanone (3)
    if folder == "2-Butanone":
        bypass_name = "20170411-CPTMA-MalibuTWC-SGDI-30k-2Butanone-5Cramp-lambda0_999-bp-1"
        run_name =    "20170411-CPTMA-MalibuTWC-SGDI-30k-2Butanone-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170411-CPTMA-MalibuTWC-SGDI-30k-2Butanone-5Cramp-lambda0_999-bp-2"
        run_name =    "20170411-CPTMA-MalibuTWC-SGDI-30k-2Butanone-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170411-CPTMA-MalibuTWC-SGDI-30k-2Butanone-5Cramp-lambda0_999-bp-3"
        run_name =    "20170411-CPTMA-MalibuTWC-SGDI-30k-2Butanone-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # 2-methylpentane (3)
    if folder == "2-methylpentane":
        bypass_name = "20170810-CPTMA-MalibuTWC-SGDI-30k-2MethylPentane-5Cramp-lambda0_999-bp-1"
        run_name =    "20170810-CPTMA-MalibuTWC-SGDI-30k-2MethylPentane-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170810-CPTMA-MalibuTWC-SGDI-30k-2MethylPentane-5Cramp-lambda0_999-bp-2"
        run_name =    "20170810-CPTMA-MalibuTWC-SGDI-30k-2MethylPentane-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170810-CPTMA-MalibuTWC-SGDI-30k-2MethylPentane-5Cramp-lambda0_999-bp-3"
        run_name =    "20170810-CPTMA-MalibuTWC-SGDI-30k-2MethylPentane-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # 2-pentanone (3)
    if folder == "2-pentanone":
        bypass_name = "20170804-CPTMA-MalibuTWC-SGDI-30k-2Pentaone-5Cramp-lambda0_999-bp-1"
        run_name =    "20170804-CPTMA-MalibuTWC-SGDI-30k-2Pentaone-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170804-CPTMA-MalibuTWC-SGDI-30k-2Pentaone-5Cramp-lambda0_999-bp-2"
        run_name =    "20170804-CPTMA-MalibuTWC-SGDI-30k-2Pentaone-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170804-CPTMA-MalibuTWC-SGDI-30k-2Pentaone-5Cramp-lambda0_999-bp-3"
        run_name =    "20170804-CPTMA-MalibuTWC-SGDI-30k-2Pentaone-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # 2-propanol (3)
    if folder == "2-propanol":
        bypass_name = "20170614-CPTMA-MalibuTWC-SGDI-30k-2Propanol-5Cramp-REPEAT-lambda0_999-bp-1"
        run_name =    "20170614-CPTMA-MalibuTWC-SGDI-30k-2Propanol-5Cramp-REPEAT-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170614-CPTMA-MalibuTWC-SGDI-30k-2Propanol-5Cramp-REPEAT-lambda0_999-bp-2"
        run_name =    "20170614-CPTMA-MalibuTWC-SGDI-30k-2Propanol-5Cramp-REPEAT-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170614-CPTMA-MalibuTWC-SGDI-30k-2Propanol-5Cramp-REPEAT-lambda0_999-bp-3"
        run_name =    "20170614-CPTMA-MalibuTWC-SGDI-30k-2Propanol-5Cramp-REPEAT-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # anisole (3)
    if folder == "anisole":
        bypass_name = "20170629-CPTMA-MalibuTWC-SGDI-30k-Anisole-5Cramp-lambda0_999-bp-1"
        run_name =    "20170629-CPTMA-MalibuTWC-SGDI-30k-Anisole-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170629-CPTMA-MalibuTWC-SGDI-30k-Anisole-5Cramp-lambda0_999-bp-2"
        run_name =    "20170629-CPTMA-MalibuTWC-SGDI-30k-Anisole-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170629-CPTMA-MalibuTWC-SGDI-30k-Anisole-5Cramp-lambda0_999-bp-3"
        run_name =    "20170629-CPTMA-MalibuTWC-SGDI-30k-Anisole-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # butylacetate (3)
    if folder == "butylacetate":
        bypass_name = "20170815-CPTMA-MalibuTWC-SGDI-30k-ButylAcetate-5Cramp-lambda0_999-bp-1"
        run_name =    "20170815-CPTMA-MalibuTWC-SGDI-30k-ButylAcetate-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170815-CPTMA-MalibuTWC-SGDI-30k-ButylAcetate-5Cramp-lambda0_999-bp-2"
        run_name =    "20170815-CPTMA-MalibuTWC-SGDI-30k-ButylAcetate-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170815-CPTMA-MalibuTWC-SGDI-30k-ButylAcetate-5Cramp-lambda0_999-bp-3"
        run_name =    "20170815-CPTMA-MalibuTWC-SGDI-30k-ButylAcetate-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # cyclopentanone (3)
    if folder == "cyclopentanone":
        bypass_name = "20170511-CPTMA-MalibuTWC-SGDI-30k-Cyclopentanone-5Cramp-lambda0_999-bp-1"
        run_name =    "20170511-CPTMA-MalibuTWC-SGDI-30k-Cyclopentanone-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170511-CPTMA-MalibuTWC-SGDI-30k-Cyclopentanone-5Cramp-lambda0_999-bp-2"
        run_name =    "20170511-CPTMA-MalibuTWC-SGDI-30k-Cyclopentanone-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170511-CPTMA-MalibuTWC-SGDI-30k-Cyclopentanone-5Cramp-lambda0_999-bp-3"
        run_name =    "20170511-CPTMA-MalibuTWC-SGDI-30k-Cyclopentanone-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # diisobutylene (3)
    if folder == "diisobutylene":
        bypass_name = "20170427-CPTMA-MalibuTWC-SGDI-30k-Diisobutylene-5Cramp-lambda0_999-bp-1"
        run_name =    "20170427-CPTMA-MalibuTWC-SGDI-30k-Diisobutylene-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170427-CPTMA-MalibuTWC-SGDI-30k-Diisobutylene-5Cramp-lambda0_999-bp-2"
        run_name =    "20170427-CPTMA-MalibuTWC-SGDI-30k-Diisobutylene-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170427-CPTMA-MalibuTWC-SGDI-30k-Diisobutylene-5Cramp-lambda0_999-bp-3"
        run_name =    "20170427-CPTMA-MalibuTWC-SGDI-30k-Diisobutylene-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # E10 (3)
    if folder == "E10-baseline":
        bypass_name = "20170421-CPTMA-MalibuTWC-SGDI-30k-CH3CH2OH+iC8H18+C6H5CH3-5Cramp-lambda0_999-bp-1"
        run_name =    "20170421-CPTMA-MalibuTWC-SGDI-30k-CH3CH2OH+iC8H18+C6H5CH3-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170421-CPTMA-MalibuTWC-SGDI-30k-CH3CH2OH+iC8H18+C6H5CH3-5Cramp-lambda0_999-bp-2"
        run_name =    "20170421-CPTMA-MalibuTWC-SGDI-30k-CH3CH2OH+iC8H18+C6H5CH3-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170421-CPTMA-MalibuTWC-SGDI-30k-CH3CH2OH+iC8H18+C6H5CH3-5Cramp-lambda0_999-bp-3"
        run_name =    "20170421-CPTMA-MalibuTWC-SGDI-30k-CH3CH2OH+iC8H18+C6H5CH3-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # ethanol (3)
    if folder == "ethanol":
        bypass_name = "20170424-CPTMA-MalibuTWC-SGDI-30k-CH3CH2OH-5Cramp-lambda0_999-bp-1"
        run_name =    "20170424-CPTMA-MalibuTWC-SGDI-30k-CH3CH2OH-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170424-CPTMA-MalibuTWC-SGDI-30k-CH3CH2OH-5Cramp-lambda0_999-bp-2"
        run_name =    "20170424-CPTMA-MalibuTWC-SGDI-30k-CH3CH2OH-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170424-CPTMA-MalibuTWC-SGDI-30k-CH3CH2OH-5Cramp-lambda0_999-bp-3"
        run_name =    "20170424-CPTMA-MalibuTWC-SGDI-30k-CH3CH2OH-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # ethene (3)
    if folder == "ethene":
        bypass_name = "20170718-CPTMA-MalibuTWC-SGDI-30k-C2H4ONLY-5Cramp-lambda0_999-bp-1"
        run_name =    "20170718-CPTMA-MalibuTWC-SGDI-30k-C2H4ONLY-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170718-CPTMA-MalibuTWC-SGDI-30k-C2H4ONLY-5Cramp-lambda0_999-bp-2"
        run_name =    "20170718-CPTMA-MalibuTWC-SGDI-30k-C2H4ONLY-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170718-CPTMA-MalibuTWC-SGDI-30k-C2H4ONLY-5Cramp-lambda0_999-bp-3"
        run_name =    "20170718-CPTMA-MalibuTWC-SGDI-30k-C2H4ONLY-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # ethyl acetate (3)
    if folder == "ethyl-acetate":
        bypass_name = "20170510-CPTMA-MalibuTWC-SGDI-30k-EthylAcetate-5Cramp-lambda0_999-bp-1"
        run_name =    "20170510-CPTMA-MalibuTWC-SGDI-30k-EthylAcetate-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170510-CPTMA-MalibuTWC-SGDI-30k-EthylAcetate-5Cramp-lambda0_999-bp-2"
        run_name =    "20170510-CPTMA-MalibuTWC-SGDI-30k-EthylAcetate-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170510-CPTMA-MalibuTWC-SGDI-30k-EthylAcetate-5Cramp-lambda0_999-bp-3"
        run_name =    "20170510-CPTMA-MalibuTWC-SGDI-30k-EthylAcetate-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # furan mix (4)
    if folder == "furan-mix":
        bypass_name = "20170425-CPTMA-MalibuTWC-SGDI-30k-FuranMix-5Cramp-lambda0_999-bp-1"
        run_name =    "20170425-CPTMA-MalibuTWC-SGDI-30k-FuranMix-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170425-CPTMA-MalibuTWC-SGDI-30k-FuranMix-5Cramp-lambda0_999-bp-2"
        run_name =    "20170425-CPTMA-MalibuTWC-SGDI-30k-FuranMix-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170425-CPTMA-MalibuTWC-SGDI-30k-FuranMix-5Cramp-lambda0_999-bp-3"
        run_name =    "20170425-CPTMA-MalibuTWC-SGDI-30k-FuranMix-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170425-CPTMA-MalibuTWC-SGDI-30k-FuranMix-5Cramp-lambda0_999-bp-4"
        run_name =    "20170425-CPTMA-MalibuTWC-SGDI-30k-FuranMix-5Cramp-lambda0_999-4"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # iso-butanol (3)
    if folder == "iso-butanol":
        bypass_name = "20170412-CPTMA-MalibuTWC-SGDI-30k-iBuOH-5Cramp-lambda0_999-bp-1"
        run_name =    "20170412-CPTMA-MalibuTWC-SGDI-30k-iBuOH-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170412-CPTMA-MalibuTWC-SGDI-30k-iBuOH-5Cramp-lambda0_999-bp-2"
        run_name =    "20170412-CPTMA-MalibuTWC-SGDI-30k-iBuOH-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170412-CPTMA-MalibuTWC-SGDI-30k-iBuOH-5Cramp-lambda0_999-bp-3"
        run_name =    "20170412-CPTMA-MalibuTWC-SGDI-30k-iBuOH-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # iso-butylacetate (3+3repeat)
    if folder == "iso-butylacetate":
        bypass_name = "20170823-CPTMA-MalibuTWC-SGDI-30k-isoButylAcetate-5Cramp-lambda0_999-bp-1"
        run_name =    "20170823-CPTMA-MalibuTWC-SGDI-30k-isoButylAcetate-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170823-CPTMA-MalibuTWC-SGDI-30k-isoButylAcetate-5Cramp-lambda0_999-bp-2"
        run_name =    "20170823-CPTMA-MalibuTWC-SGDI-30k-isoButylAcetate-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170823-CPTMA-MalibuTWC-SGDI-30k-isoButylAcetate-5Cramp-lambda0_999-bp-3"
        run_name =    "20170823-CPTMA-MalibuTWC-SGDI-30k-isoButylAcetate-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170824-CPTMA-MalibuTWC-SGDI-30k-isoButylAcetate-REPEAT-5Cramp-lambda0_999-bp-1"
        run_name =    "20170824-CPTMA-MalibuTWC-SGDI-30k-isoButylAcetate-REPEAT-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170824-CPTMA-MalibuTWC-SGDI-30k-isoButylAcetate-REPEAT-5Cramp-lambda0_999-bp-2"
        run_name =    "20170824-CPTMA-MalibuTWC-SGDI-30k-isoButylAcetate-REPEAT-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170824-CPTMA-MalibuTWC-SGDI-30k-isoButylAcetate-REPEAT-5Cramp-lambda0_999-bp-3"
        run_name =    "20170824-CPTMA-MalibuTWC-SGDI-30k-isoButylAcetate-REPEAT-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))


    # iso-octane (3)
    if folder == "iso-octane":
        bypass_name = "20170518-CPTMA-MalibuTWC-SGDI-30k-isooctane-5Cramp-lambda0_999-bp-1"
        run_name =    "20170518-CPTMA-MalibuTWC-SGDI-30k-isooctane-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170518-CPTMA-MalibuTWC-SGDI-30k-isooctane-5Cramp-lambda0_999-bp-2"
        run_name =    "20170518-CPTMA-MalibuTWC-SGDI-30k-isooctane-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170518-CPTMA-MalibuTWC-SGDI-30k-isooctane-5Cramp-lambda0_999-bp-3"
        run_name =    "20170518-CPTMA-MalibuTWC-SGDI-30k-isooctane-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # m-xylene (3)
    if folder == "m-xylene":
        bypass_name = "20170524-CPTMA-MalibuTWC-SGDI-30k-mXylene-5Cramp-lambda0_999-bp-1"
        run_name =    "20170524-CPTMA-MalibuTWC-SGDI-30k-mXylene-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170524-CPTMA-MalibuTWC-SGDI-30k-mXylene-5Cramp-lambda0_999-bp-2"
        run_name =    "20170524-CPTMA-MalibuTWC-SGDI-30k-mXylene-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170524-CPTMA-MalibuTWC-SGDI-30k-mXylene-5Cramp-lambda0_999-bp-3"
        run_name =    "20170524-CPTMA-MalibuTWC-SGDI-30k-mXylene-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # mesitylene (3)
    if folder == "mesitylene":
        bypass_name = "20170428-CPTMA-MalibuTWC-SGDI-30k-mesitylene-5Cramp-lambda0_999-bp-1"
        run_name =    "20170428-CPTMA-MalibuTWC-SGDI-30k-mesitylene-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170428-CPTMA-MalibuTWC-SGDI-30k-mesitylene-5Cramp-lambda0_999-bp-2"
        run_name =    "20170428-CPTMA-MalibuTWC-SGDI-30k-mesitylene-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170428-CPTMA-MalibuTWC-SGDI-30k-mesitylene-5Cramp-lambda0_999-bp-3"
        run_name =    "20170428-CPTMA-MalibuTWC-SGDI-30k-mesitylene-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # methane (3)
    if folder == "methane":
        bypass_name = "20170720-CPTMA-MalibuTWC-SGDI-30k-CH4ONLY-5Cramp-lambda0_999-bp-1"
        run_name =    "20170720-CPTMA-MalibuTWC-SGDI-30k-CH4ONLY-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170720-CPTMA-MalibuTWC-SGDI-30k-CH4ONLY-5Cramp-lambda0_999-bp-2"
        run_name =    "20170720-CPTMA-MalibuTWC-SGDI-30k-CH4ONLY-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170720-CPTMA-MalibuTWC-SGDI-30k-CH4ONLY-5Cramp-lambda0_999-bp-3"
        run_name =    "20170720-CPTMA-MalibuTWC-SGDI-30k-CH4ONLY-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # methylcyclohexane (2+2)
    if folder == "methylcyclohexane":
        bypass_name = "20170622-CPTMA-MalibuTWC-SGDI-30k-MCH-5Cramp-REPEAT-lambda0_999-bp-1"
        run_name =    "20170622-CPTMA-MalibuTWC-SGDI-30k-MCH-5Cramp-REPEAT-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170622-CPTMA-MalibuTWC-SGDI-30k-MCH-5Cramp-REPEAT-lambda0_999-bp-2"
        run_name =    "20170622-CPTMA-MalibuTWC-SGDI-30k-MCH-5Cramp-REPEAT-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170627-CPTMA-MalibuTWC-SGDI-30k-MCH-5Cramp-REPEAT-lambda0_999-bp-1"
        run_name =    "20170627-CPTMA-MalibuTWC-SGDI-30k-MCH-5Cramp-REPEAT-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170627-CPTMA-MalibuTWC-SGDI-30k-MCH-5Cramp-REPEAT-lambda0_999-bp-2"
        run_name =    "20170627-CPTMA-MalibuTWC-SGDI-30k-MCH-5Cramp-REPEAT-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # methylcyclopentane (3)
    if folder == "methylcyclopentane":
        bypass_name = "20170621-CPTMA-MalibuTWC-SGDI-30k-MCP-5Cramp-REPEAT-lambda0_999-bp-1"
        run_name =    "20170621-CPTMA-MalibuTWC-SGDI-30k-MCP-5Cramp-REPEAT-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170621-CPTMA-MalibuTWC-SGDI-30k-MCP-5Cramp-REPEAT-lambda0_999-bp-2"
        run_name =    "20170621-CPTMA-MalibuTWC-SGDI-30k-MCP-5Cramp-REPEAT-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170621-CPTMA-MalibuTWC-SGDI-30k-MCP-5Cramp-REPEAT-lambda0_999-bp-3"
        run_name =    "20170621-CPTMA-MalibuTWC-SGDI-30k-MCP-5Cramp-REPEAT-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # methylisobutylketone (3)
    if folder == "methylisobutylketone":
        bypass_name = "20170822-CPTMA-MalibuTWC-SGDI-30k-MIBK-5Cramp-lambda0_999-bp-1"
        run_name =    "20170822-CPTMA-MalibuTWC-SGDI-30k-MIBK-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170822-CPTMA-MalibuTWC-SGDI-30k-MIBK-5Cramp-lambda0_999-bp-2"
        run_name =    "20170822-CPTMA-MalibuTWC-SGDI-30k-MIBK-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170822-CPTMA-MalibuTWC-SGDI-30k-MIBK-5Cramp-lambda0_999-bp-3"
        run_name =    "20170822-CPTMA-MalibuTWC-SGDI-30k-MIBK-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # n-butanol (3+2+3)
    if folder == "n-butanol":
        bypass_name = "20170728-CPTMA-MalibuTWC-SGDI-30k-nButanol-5Cramp-REPEAT-lambda0_999-bp-1"
        run_name =    "20170728-CPTMA-MalibuTWC-SGDI-30k-nButanol-5Cramp-REPEAT-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170728-CPTMA-MalibuTWC-SGDI-30k-nButanol-5Cramp-REPEAT-lambda0_999-bp-2"
        run_name =    "20170728-CPTMA-MalibuTWC-SGDI-30k-nButanol-5Cramp-REPEAT-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170728-CPTMA-MalibuTWC-SGDI-30k-nButanol-5Cramp-REPEAT-lambda0_999-bp-3"
        run_name =    "20170728-CPTMA-MalibuTWC-SGDI-30k-nButanol-5Cramp-REPEAT-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170731-CPTMA-MalibuTWC-SGDI-30k-nButanol-5Cramp-REPEAT-lambda0_999-bp-1"
        run_name =    "20170731-CPTMA-MalibuTWC-SGDI-30k-nButanol-5Cramp-REPEAT-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170731-CPTMA-MalibuTWC-SGDI-30k-nButanol-5Cramp-REPEAT-lambda0_999-bp-2"
        run_name =    "20170731-CPTMA-MalibuTWC-SGDI-30k-nButanol-5Cramp-REPEAT-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170801-CPTMA-MalibuTWC-SGDI-30k-nButanol-5Cramp-REPEAT-lambda0_999-bp-1"
        run_name =    "20170801-CPTMA-MalibuTWC-SGDI-30k-nButanol-5Cramp-REPEAT-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170801-CPTMA-MalibuTWC-SGDI-30k-nButanol-5Cramp-REPEAT-lambda0_999-bp-2"
        run_name =    "20170801-CPTMA-MalibuTWC-SGDI-30k-nButanol-5Cramp-REPEAT-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170801-CPTMA-MalibuTWC-SGDI-30k-nButanol-5Cramp-REPEAT-lambda0_999-bp-3"
        run_name =    "20170801-CPTMA-MalibuTWC-SGDI-30k-nButanol-5Cramp-REPEAT-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # n-heptane (3)
    if folder == "n-heptane":
        bypass_name = "20170808-CPTMA-MalibuTWC-SGDI-30k-nHeptane-5Cramp-lambda0_999-bp-1"
        run_name =    "20170808-CPTMA-MalibuTWC-SGDI-30k-nHeptane-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170808-CPTMA-MalibuTWC-SGDI-30k-nHeptane-5Cramp-lambda0_999-bp-2"
        run_name =    "20170808-CPTMA-MalibuTWC-SGDI-30k-nHeptane-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170808-CPTMA-MalibuTWC-SGDI-30k-nHeptane-5Cramp-lambda0_999-bp-3"
        run_name =    "20170808-CPTMA-MalibuTWC-SGDI-30k-nHeptane-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # n-octane (3)
    if folder == "n-octane":
        bypass_name = "20170519-CPTMA-MalibuTWC-SGDI-30k-nOctane-5Cramp-lambda0_999-bp-1"
        run_name =    "20170519-CPTMA-MalibuTWC-SGDI-30k-nOctane-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170519-CPTMA-MalibuTWC-SGDI-30k-nOctane-5Cramp-lambda0_999-bp-2"
        run_name =    "20170519-CPTMA-MalibuTWC-SGDI-30k-nOctane-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170519-CPTMA-MalibuTWC-SGDI-30k-nOctane-5Cramp-lambda0_999-bp-3"
        run_name =    "20170519-CPTMA-MalibuTWC-SGDI-30k-nOctane-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # propane (3)
    if folder == "propane":
        bypass_name = "20170717-CPTMA-MalibuTWC-SGDI-30k-C3H8ONLY-5Cramp-lambda0_999-bp-1"
        run_name =    "20170717-CPTMA-MalibuTWC-SGDI-30k-C3H8ONLY-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170717-CPTMA-MalibuTWC-SGDI-30k-C3H8ONLY-5Cramp-lambda0_999-bp-2"
        run_name =    "20170717-CPTMA-MalibuTWC-SGDI-30k-C3H8ONLY-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170717-CPTMA-MalibuTWC-SGDI-30k-C3H8ONLY-5Cramp-lambda0_999-bp-3"
        run_name =    "20170717-CPTMA-MalibuTWC-SGDI-30k-C3H8ONLY-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # propene (3+3)
    if folder == "propene":
        bypass_name = "20170724-CPTMA-MalibuTWC-SGDI-30k-C3H6ONLY-5Cramp-lambda0_999-bp-1"
        run_name =    "20170724-CPTMA-MalibuTWC-SGDI-30k-C3H6ONLY-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170724-CPTMA-MalibuTWC-SGDI-30k-C3H6ONLY-5Cramp-lambda0_999-bp-2"
        run_name =    "20170724-CPTMA-MalibuTWC-SGDI-30k-C3H6ONLY-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170724-CPTMA-MalibuTWC-SGDI-30k-C3H6ONLY-5Cramp-lambda0_999-bp-3"
        run_name =    "20170724-CPTMA-MalibuTWC-SGDI-30k-C3H6ONLY-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170725-CPTMA-MalibuTWC-SGDI-30k-C3H6ONLY-5Cramp-lambda0_999-bp-1"
        run_name =    "20170725-CPTMA-MalibuTWC-SGDI-30k-C3H6ONLY-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170725-CPTMA-MalibuTWC-SGDI-30k-C3H6ONLY-5Cramp-lambda0_999-bp-2"
        run_name =    "20170725-CPTMA-MalibuTWC-SGDI-30k-C3H6ONLY-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170725-CPTMA-MalibuTWC-SGDI-30k-C3H6ONLY-5Cramp-lambda0_999-bp-3"
        run_name =    "20170725-CPTMA-MalibuTWC-SGDI-30k-C3H6ONLY-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

    # toluene (3)
    if folder == "toluene":
        bypass_name = "20170505-CPTMA-MalibuTWC-SGDI-30k-Toluene-5Cramp-lambda0_999-bp-1"
        run_name =    "20170505-CPTMA-MalibuTWC-SGDI-30k-Toluene-5Cramp-lambda0_999-1"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))
        avg_run = readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name)

        bypass_name = "20170505-CPTMA-MalibuTWC-SGDI-30k-Toluene-5Cramp-lambda0_999-bp-2"
        run_name =    "20170505-CPTMA-MalibuTWC-SGDI-30k-Toluene-5Cramp-lambda0_999-2"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))

        bypass_name = "20170505-CPTMA-MalibuTWC-SGDI-30k-Toluene-5Cramp-lambda0_999-bp-3"
        run_name =    "20170505-CPTMA-MalibuTWC-SGDI-30k-Toluene-5Cramp-lambda0_999-3"

        run.append(readCoOptimaFile(folder+"/"+run_name, folder+"/"+bypass_name))


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
        if base_folder == "1":
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
    if base_folder == "1":
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
        if base_folder == "1":
            base_folder += base_name.split("-")[6]
        sub_folder = base_name.split("-")[0] + "_run" + base_name.split("-")[-1]

        obj.compressRows(10)
        obj.printAlltoFile(base_folder+"-output/"+sub_folder+"/"+base_name+"_output.dat")
        i+=1

    #Output for the averaged data
    base_name = avg_run.input_file_name.split(".")[0]

    base_folder = base_name.split("-")[5]
    if base_folder == "1":
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

    readCoOptimaPureFuelFolder("1-hexene", tau=8.3333)
    #readCoOptimaPureFuelFolder("1-octene", tau=8.3333)
    #readCoOptimaPureFuelFolder("1-propanol", tau=8.3333)
    #readCoOptimaPureFuelFolder("2-Butanone", tau=8.3333)
    #readCoOptimaPureFuelFolder("2-methylpentane", tau=8.3333)
    #readCoOptimaPureFuelFolder("2-pentanone", tau=8.3333)
    #readCoOptimaPureFuelFolder("2-propanol", tau=8.3333)
    #readCoOptimaPureFuelFolder("anisole", tau=8.3333)
    #readCoOptimaPureFuelFolder("butylacetate", tau=8.3333)
    #readCoOptimaPureFuelFolder("cyclopentanone", tau=8.3333)
    #readCoOptimaPureFuelFolder("diisobutylene", tau=8.3333)
    #readCoOptimaPureFuelFolder("E10-baseline", tau=8.3333)
    #readCoOptimaPureFuelFolder("ethanol", tau=8.3333)
    #readCoOptimaPureFuelFolder("ethene", tau=8.3333)
    #readCoOptimaPureFuelFolder("ethyl-acetate", tau=8.3333)
    #readCoOptimaPureFuelFolder("furan-mix", tau=8.3333)
    #readCoOptimaPureFuelFolder("iso-butanol", tau=8.3333)
    #readCoOptimaPureFuelFolder("iso-butylacetate", tau=8.3333)
    #readCoOptimaPureFuelFolder("iso-octane", tau=8.3333)
    #readCoOptimaPureFuelFolder("m-xylene", tau=8.3333)
    #readCoOptimaPureFuelFolder("mesitylene", tau=8.3333)
    #readCoOptimaPureFuelFolder("methane", tau=8.3333)
    #readCoOptimaPureFuelFolder("methylcyclohexane", tau=8.3333)
    #readCoOptimaPureFuelFolder("methylcyclopentane", tau=8.3333)
    #readCoOptimaPureFuelFolder("methylisobutylketone", tau=8.3333)
    #readCoOptimaPureFuelFolder("n-butanol", tau=8.3333)
    #readCoOptimaPureFuelFolder("n-heptane", tau=8.3333)
    #readCoOptimaPureFuelFolder("n-octane", tau=8.3333)
    #readCoOptimaPureFuelFolder("propane", tau=8.3333)
    #readCoOptimaPureFuelFolder("propene", tau=8.3333)
    #readCoOptimaPureFuelFolder("toluene", tau=8.3333)

    return

##Directs python to call the main function
if __name__ == "__main__":
   main(sys.argv[1:])
