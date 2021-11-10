##   @package transient_data_sets
#
#    @brief Script to read in all sets of CLEERS data of a particular folder
#
#    @details Python script to read in CLEERS transient data for
#                for a particular folder or folders. This script works
#                in tandem with the transient_data.py script which
#                contains the necessary objects for storing and operating
#                on a set of time series data. What this script does is
#                create new objects and methods for dealing with folders
#                filled with similar transient data and performing a series
#                of like actions on all that data and creating output files
#                in sub-folders with the newly processed data.
#
#    @author Austin Ladshaw
#
#    @date 02/24/2020
#
#    @copyright This software was designed and built at the Oak Ridge National
#                    Laboratory (ORNL) National Transportation Research Center
#                    (NTRC) by Austin Ladshaw for research in the catalytic
#                    reduction of NOx. Copyright (c) 2020, all rights reserved.

#Generally speaking, we do not know whether or not there is bypass data in the
#   folders that may need to be paired, so we import all objects from transient_data
from transient_data import TransientData, PairedTransientData
import os, sys, getopt
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
from matplotlib import cm
from matplotlib.ticker import LinearLocator, FormatStrFormatter
import numpy as np

## TransientDataFolder
#   This object creates a map of other transient data objects (paired or unpaired)
#
#    This object will iteratively read all data files in a given folder and store that
#    information into TransientData or PairedTransientData objects depending on the
#    typical file name flags used to distinguish between bypass runs and actual data
#    runs. The data in each file of the folder can have a bypass pairing or can be
#    solitary. HOWEVER, all data files should have all the same common column names.
#
#    NOTE:
#
#           ALL data files in the folder should have the same column name formatting!
#            This is so that we can process entire folders of data en masse by performing
#            the same set of actions across all data sets to a particular column.
#            IF DATA HAS DIFFERENT COLUMN NAMES, IT SHOULD BE IN DIFFERENT FOLDER!
#
#    For instance:
#
#                   If we want to perform a data reduction analysis and extract only
#                    a specific sub-set of columns from all the files, then those
#                    column names need to be all the same. That way we can use a single
#                    function call/operation to perform the analysis on all data.
#
class TransientDataFolder(object):
    ##Initialize the object by reading in all readable data
    #
    # @param folder name of the folder that contains sets of data files
    # @param addNoise whether or not to add random noise for missing data emulation
    #
    #   NOTE:
    #
    #       The code expects that the folder only contains a set of CLEERS data files.
    #       If there are non-CLEERS data files or sub-folders, then this may cause errors.
    def __init__(self,folder,addNoise = True):
        if os.path.isdir(folder) == False:
            print("Error! Given argument is not a folder!")
            return
        self.folder_name = folder
        ##List of file names for non-bypass files
        self.file_names = []
        ##List of file names for bypass files
        self.bypass_names = []
        ##Map of paired files: key ==> file_base_name --> (bypass_file, result_file)
        #
        #   NOTE:
        #
        #       file_base_name is taken as the name of the file without the "-bp.dat" suffix
        self.file_pairs = {}
        ##Map of Transient Data objects by file_name (unpaired)
        self.unpaired_data = {}
        ##Map of Paired Transient Data objects by file_name (paired)
        self.paired_data = {}
        ##Map of data sets that have specific similarities
        self.like_sets = {}
        ##Flag to denote whether or not folder contains unpaired data
        self.has_unpaired = False
        ##Flag to denote whether or not folder contains paired data (note: CAN have both)
        self.has_paired = False
        ##List to correlate with all file_names to determine if a file has been read or not
        self.unread = []
        ##Flag to denote whether or not user has requested row compression of data sets
        self.was_compressed = False
        ##Running total of the number of data points processed (based on rows and columns)
        self.total_data_processed = 0
        ##Map of conditions for like files
        self.conditions = {}
        self.conditions["material"] = {}
        self.conditions["aging_time"] = {}
        self.conditions["aging_temp"] = {}
        self.conditions["flow_rate"] = {}
        self.conditions["iso_temp"] = {}
        self.conditions["aging_cond"] = {}
        self.conditions["run_type"] = {}

        ##Quick access to the time key
        self.time_key = ""

        #First round of iterations is to change all file names to meet standards
        for file in os.listdir(self.folder_name):
            if len(file.split(".")) < 2:
                os.rename(self.folder_name+"/"+file,self.folder_name+"/"+file+".dat")
            elif file.split(".")[1] != "dat":
                os.rename(self.folder_name+"/"+file,self.folder_name+"/"+file.split(".")[0]+".dat")
            else:
                continue
        #Iterate through the files in the folder and store updated file names
        for file in os.listdir(self.folder_name):
            #Check to make sure the files have the correct extension
            if len(file.split(".")) < 2:
                print("Error! No file extension was given!")
                print("\t"+file+" has been skipped...")
            else:
                if file.split(".")[1] != "dat":
                    print("Error! Unexpected file extension or object is not a file!")
                    print("\t"+file+" has been skipped...")
                else:
                    if "-bp." in file:
                        self.bypass_names.append(file)
                        self.file_pairs[file.split("-bp.")[0]] = []
                        self.like_sets[file.split("-bp.")[0]] = []
                    else:
                        self.file_names.append(file)
                        self.unread.append(True)
                        base_list = file.split("-")
                        string = ""
                        i=0
                        for item in base_list[:-1]:
                            if i==0:
                                string+=item
                            else:
                                string+="-"+item
                            i+=1
                        self.like_sets[string] = []


        #Iterate through the files again to create the like_sets map
        for file in os.listdir(self.folder_name):
            if "-bp." not in file:
                for base in self.like_sets:
                    self.conditions["material"][base] = {}
                    self.conditions["aging_time"][base] = {}
                    self.conditions["aging_temp"][base] = {}
                    self.conditions["flow_rate"][base] = {}
                    self.conditions["iso_temp"][base] = {}
                    self.conditions["aging_cond"][base] = {}
                    self.conditions["run_type"][base] = "unknown"
                    if base in file:
                        self.like_sets[base].append(file)
                        self.conditions["material"][base][file] = "unknown"
                        self.conditions["aging_time"][base][file] = 0
                        self.conditions["aging_temp"][base][file] = 0
                        self.conditions["flow_rate"][base][file] = 0
                        self.conditions["iso_temp"][base][file] = 0
                        self.conditions["aging_cond"][base][file] = "unknown"

        #Determine what to do when no bypass files are provided
        if len(self.bypass_names) == 0:
            print("Warning! No bypass data provided...")
            print("\tPutting all data into unpaired_data structure as TransientData objects...")
            self.has_unpaired = True
            i = 0
            for file in self.file_names:
                print("\nReading the following...")
                print("\t"+file)
                self.unpaired_data[file] = TransientData(self.folder_name+"/"+file)
                self.unpaired_data[file].compressColumns()
                self.total_data_processed+=self.unpaired_data[file].getNumRows()*self.unpaired_data[file].getNumCols()
                self.time_key = self.unpaired_data[file].time_key
                self.unread[i] = False
                i+=1
        #Check for file_names that should correspond to bypass_names
        else:
            self.has_paired = True
            for base in self.file_pairs:
                i=0
                j=0
                for file in self.file_names:
                    if base in file:
                        self.file_pairs[base].append( (base+"-bp.dat",file) )
                        print("\nReading and pairing the following...")
                        print("\t"+self.file_pairs[base][i][0])
                        print("\t"+self.file_pairs[base][i][1])
                        self.paired_data[file] = PairedTransientData(self.folder_name+"/"+self.file_pairs[base][i][0],self.folder_name+"/"+self.file_pairs[base][i][1])
                        self.paired_data[file].compressColumns()
                        self.paired_data[file].alignData(addNoise)
                        self.total_data_processed+=2*self.paired_data[file].getNumRows()*self.paired_data[file].getNumCols()
                        self.time_key = self.paired_data[file].time_key
                        self.unread[j] = False
                        i+=1
                    j+=1

        #Check the unread list for any files that were unread/unpaired and read them as unpaired files
        j=0
        for check in self.unread:
            if check == True:
                print("\nReading the following skipped unpaired files...")
                print("\t"+self.file_names[j])
                self.unpaired_data[self.file_names[j]] = TransientData(self.folder_name+"/"+self.file_names[j])
                self.unpaired_data[self.file_names[j]].compressColumns()
            j+=1

        #After done reading, register the file conditions in the conditions map
        for base in self.like_sets:
            for file in self.like_sets[base]:
                self.conditions["material"][base][file] = self.grabDataObj(file).material_name
                self.conditions["aging_time"][base][file] = self.grabDataObj(file).aging_time
                self.conditions["aging_temp"][base][file] = self.grabDataObj(file).aging_temp
                self.conditions["flow_rate"][base][file] = self.grabDataObj(file).flow_rate
                self.conditions["iso_temp"][base][file] = self.grabDataObj(file).isothermal_temp
                self.conditions["aging_cond"][base][file] = self.grabDataObj(file).aging_condition
                self.conditions["run_type"][base] = self.grabDataObj(file).run_type

        #Lastly, order the conditions
        for cond in self.conditions:
            if cond != "run_type":
                for base in self.like_sets:
                    self.conditions[cond][base] = {k: v for k, v in sorted(self.conditions[cond][base].items(), key=lambda item: item[1], reverse=False)}

    ##Print object attributes to the console
    def __str__(self):
        message =  "\n ---- Folder: " + str(self.folder_name) + " ---- "
        message += "\n    Number of result files: " + str(len(self.file_names))
        message += "\n    Number of bypass files: " + str(len(self.bypass_names))
        if self.has_paired == True:
            message += "\n ---- Paired Data ---- "
            for base in self.file_pairs:
                message += "\n\t" + self.file_pairs[base][0][0] + " pairs with ..."
                for pair in self.file_pairs[base]:
                    message += "\n\t\t" + str(pair[1])
                message += "\n"
        if self.has_unpaired == True:
            message += "\n ---- Unpaired Data ---- "
            for obj in self.unpaired_data:
                message += "\n\t" + obj
        return message

    ##Display names of all columns for all data sets
    #
    #       NOTE:
    #
    #       ASSUMES ALL DATA SETS HAVE SAME COMMON COLUMN NAMES
    def displayColumnNames(self):
        if self.has_paired == True:
            print("\n ---- Paired Data Column Names ---- \n")
            self.paired_data[list(self.paired_data.keys())[-1]].displayColumnNames()
        if self.has_unpaired == True:
            print("\n ---- Unpaired Data Column Names ---- \n")
            self.unpaired_data[list(self.unpaired_data.keys())[-1]].displayColumnNames()

    ##Display the names of the file bases that are common to this object
    #
    #   This function will display to the console the file base names that are
    #   common among sets of files in the folder. This can be used to identify
    #   data sets that are related in a particular way
    #
    #   For instance:
    #
    #       All unaged data files for NH3 capacity are prefixed with...
    #
    #           20160205-CLRK-BASFCuSSZ13-700C4h-NH3DesIsoTPD-30k-0_2pctO2-5pctH2O
    #
    #       All unaged data files for H2O competition are prefixed with...
    #
    #           20160209-CLRK-BASFCuSSZ13-700C4h-NH3H2Ocomp-30k-0_2pctO2-11-3pctH2O-400ppmNH3
    #
    #   This information is used to create contour plots of various data over the
    #   conditions that do differ between those data files, such as isothermal temperature.
    def displayLikeFileNames(self):
        print(self.like_sets.keys())

    ##Display the file names that are valid under the given prefix (or all like sets of files)
    def displayFilesUnderSet(self, file_prefix=""):
        if file_prefix != "":
            if file_prefix not in self.like_sets.keys():
                print("Error! Unrecognized file prefix!")
                return
            print(str(file_prefix) + " contains the following...")
            for file in self.like_sets[file_prefix]:
                print("\t"+str(file))
            print()
        else:
            for pre in self.like_sets:
                print(str(pre) + " contains the following...")
                for file in self.like_sets[pre]:
                    print("\t"+str(file))
                print()

    ##Display the run types of the files read in
    def displayRunTypes(self):
        print("\nFolder: " + str(self.folder_name) + " contains the following run types...")
        for base in self.conditions["run_type"]:
            print("\t"+self.conditions["run_type"][base])

    ##Delete specific columns from all data sets that we do not need
    def deleteColumns(self, column_list):
        #For unpaired data, just call the corresponding sub-class method
        for item in self.unpaired_data:
            self.unpaired_data[item].deleteColumns(column_list)
        if self.has_paired == True  and self.was_compressed == True:
            print("Warning! Deleting columns after running compressRows() may cause errors in paired data!")
            print("\tYou should run deleteColumns() before running compressRows()...")
        #For the paired data, we need to expand the list to include the [bypass] suffixed info in results_trans_obj
        extended_column_list = []
        if type(column_list) is list:
            for name in column_list:
                extended_column_list.append(name)
                if "[bypass]" not in name:
                    extended_column_list.append(name+"[bypass]")
        else:
            extended_column_list.append(column_list)
            if "[bypass]" not in column_list:
                extended_column_list.append(column_list+"[bypass]")
        for item in self.paired_data:
            self.paired_data[item].deleteColumns(extended_column_list)

    ##Retain on specific columns from all data sets
    def retainOnlyColumns(self, column_list):
        #For unpaired data, just call the corresponding sub-class method
        for item in self.unpaired_data:
            self.unpaired_data[item].retainOnlyColumns(column_list)
        if self.has_paired == True  and self.was_compressed == True:
            print("Warning! Deleting columns after running compressRows() may cause errors in paired data!")
            print("\tYou should run deleteColumns() before running compressRows()...")
        #For the paired data, we need to expand the list to include the [bypass] suffixed info in results_trans_obj
        if self.has_paired == True:
            extended_column_list = []
            if type(column_list) is list:
                for name in column_list:
                    extended_column_list.append(name)
                    if "[bypass]" not in name:
                        if name != self.paired_data[list(self.paired_data.keys())[-1]].result_trans_obj.time_key:
                            extended_column_list.append(name+"[bypass]")
            else:
                extended_column_list.append(column_list)
                if "[bypass]" not in column_list:
                    if column_list != self.paired_data[list(self.paired_data.keys())[-1]].result_trans_obj.time_key:
                        extended_column_list.append(column_list+"[bypass]")
            for item in self.paired_data:
                #NOTE: After data has been aligned, we only need to operate on result_trans_obj
                self.paired_data[item].result_trans_obj.retainOnlyColumns(extended_column_list)
                self.paired_data[item].bypass_trans_obj.retainOnlyColumns(column_list) #May be unnecessary

    ##Function to return a list of all files in the folder
    def grabFileList(self):
        list = []
        for file in self.paired_data:
            list.append(file)
        for file in self.unpaired_data:
            list.append(file)
        return list

    ##Function to return an instance of the TransientData or PairedTransientData object given a file name
    #
    #   NOTE:
    #
    #       This function returns different data types depending on the argument it gets
    def grabDataObj(self,file):
        if file in self.paired_data.keys():
            return self.paired_data[file]
        elif file in self.unpaired_data.keys():
            return self.unpaired_data[file]
        else:
            print("Error! No such file was read by this object!")
            return

    ##Function to report total data processed
    def getTotalDataProcessed(self):
        return self.total_data_processed

    ##Function to compress all rows of data for each data object according to size of rows
    #
    #       NOTE:
    #
    #           This function should be called before printing to a file, but after everything else
    #
    #       This function accepts 2 optional arguments:
    #
    #           (i) num_rows_target
    #           (ii) max_factor
    #
    #       num_rows_target:
    #
    #                   is used to represent the number of rows of data we
    #                   want to compress the data to. For instance, num_rows_target = 1000
    #                   means that after compression, we want the data to fit within about
    #                   1000 rows of data.
    #
    #       max_factor:
    #
    #                    puts a cap on the maximum level of compression we will allow,
    #                   regardless of the num_rows_target. For intance, a max_factor of 10
    #                   means that the number of data rows will be reduced by a factor of 10
    #                   at most, and no more than that.
    def compressAllRows(self, num_rows_target = 1000, max_factor = 10):
        #Check the number of rows for each set of data and determine an appropriate compression factor
        for file in self.unpaired_data:
            num_rows = len(self.unpaired_data[file].data_map[self.unpaired_data[file].time_key])
            factor = int(num_rows/num_rows_target)
            if factor > max_factor:
                factor = max_factor
            self.unpaired_data[file].compressRows(factor)
        for file in self.paired_data:
            num_rows = len(self.paired_data[file].result_trans_obj.data_map[self.paired_data[file].result_trans_obj.time_key])
            factor = int(num_rows/num_rows_target)
            if factor > max_factor:
                factor = max_factor
            self.paired_data[file].compressRows(factor)
        self.was_compressed = True

    ##Function to perform a math operation to all like columns of data in all data objects
    def mathOperations(self, column_name, operator, value_or_column, append_new = False, append_name = ""):
        for file in self.unpaired_data:
            self.unpaired_data[file].mathOperation(column_name, operator, value_or_column, append_new, append_name)
        for file in self.paired_data:
            self.paired_data[file].mathOperation(column_name, operator, value_or_column, append_new, append_name)

    ##Function to determine whether or not the given file name is paired or unpaired
    #
    #       Returns True if paired, False if unpaired or doesn't exist
    def isPaired(self, file_name):
        paired = False
        if file_name in self.paired_data.keys():
            paired = True
        if file_name in self.unpaired_data.keys():
            paired = False
        return paired

    ##This function calculates a simple integral of a given column over the time range in one data file
    #
    #   Integral is calculated via the trapezoid rule and the result of the integral
    #   is returned as a single value. If the column does not contain numeric data,
    #   then no computation is performed.
    #
    #   Integral sums are computed as follows...
    #
    #   integrate( column, min, max) ==> integral(a,b)  [ f(t)*dt ]   \n
    #   sum += 0.5*[f(t+dt)+f(t)]*dt
    #
    #   NOTE:
    #
    #       If no file name is provided, then this method returns a map of integral sums for all files
    def calculateIntegralSum(self, column_name, file=None, min_time=None, max_time=None):
        if file != None:
            return self.grabDataObj(file).calculateIntegralSum(column_name, min_time, max_time)
        else:
            result_map = {}
            for file in self.unpaired_data:
                result_map[file] = self.unpaired_data[file].calculateIntegralSum(column_name, min_time, max_time)
            for file in self.paired_data:
                result_map[file] = self.paired_data[file].calculateIntegralSum(column_name, min_time, max_time)
            return result_map

    ##Function to compute a mass retention integral for all columns of the given name
    #
    #   NOTE:
    #
    #           This function SHOULD automatically handle both paired and unpaired data sets
    def calculateRetentionIntegrals(self, column_name, normalized = False, conv_factor = 1, input_col_name=""):
        if self.was_compressed == True:
            print("Warning! Computing integrals after data compression may cause inaccuracies in results!")
        for file in self.paired_data:
            self.paired_data[file].calculateRetentionIntegral(column_name, normalized, conv_factor, input_col_name)
        for file in self.unpaired_data:
            self.unpaired_data[file].createStepChangeInputData(column_name)
            input_name = column_name+"[input]"
            self.unpaired_data[file].calculateRetentionIntegral(input_name, column_name, normalized, conv_factor)

    ##Function to print all results (paired and unpaired) to a series of output files in a sub-directory
    def printAlltoFile(self, subdir = ""):
        if subdir == "":
            subdir = self.folder_name+"-Output"
        else:
            if subdir[-1] != "/":
                subdir += "/"
            subdir += self.folder_name+"-Output"
        #If the given subdirectory doesn't exits, then create one
        if not os.path.exists(subdir):
            os.makedirs(subdir)
        for file in self.paired_data:
            path_and_name = subdir+"/"+file.split(".")[0]+"-PairedOutput.dat"
            self.paired_data[file].printAlltoFile(path_and_name)
        for file in self.unpaired_data:
            path_and_name = subdir+"/"+file.split(".")[0]+"-UnpairedOutput.dat"
            self.unpaired_data[file].printAlltoFile(path_and_name)

    ##Function to create plots from columns of data
    #
    #   Options:
    #
    #       - obj_name: name of the file/obj for which the data we are plotting is held
    #
    #       - column_list: list of columns to create plots of (default is all columns of plottable data)
    #
    #       - range: tuple of the minimum to maximum time values that you want plotted (default is full range)
    #
    #       - display: if True, the images will be displayed once complete
    #
    #       - save: if True, the images will be saved to a file
    #
    #       - file_name: name of the file to save the plot to
    #
    #       - file_type: type of image file to save as (default = .png)
    #                       allowed types: .png, .pdf, .ps, .eps and .svg
    def createPlot(self, obj_name, column_list = [], range=None, display=False, save=True, file_name="",file_type=".png",subdir=""):
        if subdir == "" and save==True:
            subdir = self.folder_name+"-Plots/"+obj_name.split(".")[0]+"/"
        self.grabDataObj(obj_name).createPlot(column_list, range, display, save, file_name, file_type, subdir)
    
    ## Function to fit a 2-peak distribution to the TPD
    #
    #   This function will attempt to fit a 2-peak normal distribution to the last time_frame set of
    #   data for the given column_name. We can use the optimized parameters to then determine how
    #   much of the TPD can be contributed to low temperature binding and high temperature binding.
    #
    #   Options:
    #
    #       - obj_name: name of the file/obj for which the data we are plotting is held
    #
    #       - column_name: name of the column to fit the 2-peak normal distribution to
    #
    #       - display: if True, the images will be displayed once complete
    #
    #       - save: if True, the images will be saved to a file
    #
    #       - file_name: name of the file to save the plot to
    #
    #       - file_type: type of image file to save as (default = .png)
    #                       allowed types: .png, .pdf, .ps, .eps and .svg
    def fit2peakTPD(self, obj_name, column_name, display=False, save=True, file_name="",file_type=".png",subdir="", p0=[]):
        if subdir == "" and save==True:
            subdir = self.folder_name+"-TPDmodelPlots/"
        self.grabDataObj(obj_name).fit2peakTPD(column_name, display, save, file_name, file_type, subdir,p0)

    ##Function to save all plots of data to several files
    #
    #   Function will automatically pair result data and bypass data together
    #   File names will be automatically generated and plots will not be displayed live
    #   Folder names are choosen automatically as well
    def savePlots(self, range=None, folder="", file_type=".png"):
        if folder=="":
            folder = self.folder_name+"-Plots/"
        else:
            if folder[-1] != "/":
                folder += "/"
            folder += self.folder_name+"-Plots/"

        for file in self.paired_data:
            if range != None:
                print("\nPlotting all data for " + file + " in time range " + str(range) + ".\n\tPlease wait...")
                path = folder+file.split(".")[0]+"/range"+str(range)+"/"
            else:
                print("\nPlotting all data for " + file + " in full time range.\n\tPlease wait...")
                path = folder+file.split(".")[0]+"/range(All)"+"/"
            self.paired_data[file].savePlots(range,path,file_type)
            print("\nComplete!")
        for file in self.unpaired_data:
            if range != None:
                print("\nPlotting all data for " + file + " in time range " + str(range) + ".\n\tPlease wait...")
                path = folder+file.split(".")[0]+"/range"+str(range)+"/"
            else:
                print("\nPlotting all data for " + file + " in full time range.\n\tPlease wait...")
                path = folder+file.split(".")[0]+"/range(All)"+"/"
            self.unpaired_data[file].savePlots(range,path,file_type)
            print("\nComplete!")
    
    ##Function to save all fitted 2-peak TPD plots
    def save2peakTPDs(self, column_name, folder="", file_type=".png"):
        if folder=="":
            folder = self.folder_name+"-TPDmodelPlots/"
        else:
            if folder[-1] != "/":
                folder += "/"
            folder += self.folder_name+"-TPDmodelPlots/"
        params = []
        con = []
            
        print("\nComputing 2-peak TPD curve ratios for " + str(self.folder_name) + ". Please wait...")
        for file in self.paired_data:
            if "TPD" in file:
                params, con = self.paired_data[file].fit2peakTPD(column_name, False, True, "", file_type, folder, params)
                print(params)
        for file in self.unpaired_data:
            if "TPD" in file:
                params, con = self.unpaired_data[file].fit2peakTPD(column_name, False, True, "", file_type, folder, params)
                print(params)
        print("\nComplete!")

    ##Function to iteratively save all plots in all time frames separately
    def saveTimeFramePlots(self, folder="", file_type=".png"):
        if folder=="":
            folder = self.folder_name+"-Plots/"
        else:
            if folder[-1] != "/":
                folder += "/"
            folder += self.folder_name+"-Plots/"
        #Iterate through each paired and unpaired object and call their respective methods
        for file in self.unpaired_data:
            print("\nPlotting all data for " + file + " in full time range.\n\tPlease wait...")
            path = folder+file.split(".")[0]+"/range(All)"+"/"
            self.unpaired_data[file].savePlots(None,path,file_type)
            for range in self.unpaired_data[file].getTimeFrames():
                print("\nPlotting all data for " + file + " in time range " + str(range) + ".\n\tPlease wait...")
                path = folder+file.split(".")[0]+"/range("+str(int(range[0]))+"-" +str(int(range[1])) + ")/"
                self.unpaired_data[file].savePlots(range,path,file_type)
        for file in self.paired_data:
            print("\nPlotting all data for " + file + " in full time range.\n\tPlease wait...")
            path = folder+file.split(".")[0]+"/range(All)"+"/"
            self.paired_data[file].savePlots(None,path,file_type)
            for range in self.paired_data[file].getTimeFrames():
                print("\nPlotting all data for " + file + " in time range " + str(range) + ".\n\tPlease wait...")
                path = folder+file.split(".")[0]+"/range("+str(int(range[0]))+"-" +str(int(range[1])) + ")/"
                self.paired_data[file].savePlots(range,path,file_type)

    ##Function to create overlay plots from different runs in same time frame
    #
    #   This function will create a plot (or set of plots) of the same columns on the
    #   same figure for all files in a base file designation (or all base files). This
    #   is useful for viewing or saving figures of all conditions of a column variable
    #   on a single plot for comparison purposes. For example, you can plot the NH3
    #   TPD profile for all isothermal temperatures on the same figure to visually
    #   compare how changes in isothermal temperature impact the desorption profile
    #   for NH3.
    #
    #   @param column_name name of the columns in each file to plot on the same figure
    #   @param frame_index time frame index to indicate which section of time to plot the columns over
    #           Note: frame_index of -1 corresponds to the TDP section of a capacity curve
    #   @param condition condition used to distinguish the columns on the same plot
    #           Valid options: "material", "aging_time", "aging_temp", "iso_temp", and "flow_rate"
    #   @param base the base name of the set of files for which we are plotting. If left as None,
    #           then all plots for all base file names are plotted.
    #   @param display if True, then the created figure is plotted and displayed to the console
    #   @param save if True, then the created figure is saved to an output file
    #   @param file_name name of the file being saved
    #   @param file_type type of image file being created. Valid options: .png, .pdf, .ps, .eps and .svg
    #   @param subdir sub-directory where the file will be saved
    #   @param second_column name of the other column to plot the first column_name against
    #               if left None, then the time column is automatically used
    #
    #   NOTE 1:
    #
    #       We use frame_index instead of the actual time ranges to plot because the columns we want to
    #       plot together will often be misaligned in their respective time ranges. Thus, we instead
    #       plot based on the frame_index for the time frames, since each time frame is representative
    #       of the same "event" for all columns in the folder of files.
    #
    #   NOTE 2:
    #
    #       For the NH3 capacity data, the only valid condition is "iso_temp" because each folder of
    #       data has all the same other conditions.
    def createTimeFrameOverlayPlot(self, column_name, frame_index=-1, base=None, condition="iso_temp", display=False, save=True, file_name="",file_type=".png",subdir="", second_column=None):
        if type(column_name) is list:
            print("Error! Can only create a overlay plot of single column!")
            return
        if second_column == None:
            second_column = self.time_key
        if type(second_column) is not str:
            print("Error! Invalid x-axis column type!")
            return
        #Check for valid condition
        if condition != "iso_temp" and condition != "material" and condition != "aging_temp" and condition != "aging_time" and condition != "flow_rate" and condition != "aging_cond":
            print("Error! Invalid system condition encountered!")
            return
        #Check for valid file type
        if file_type != ".png" and file_type != ".pdf" and file_type != ".ps" and file_type != ".eps" and file_type != ".svg":
            print("Warning! Unsupported image file type...")
            print("\tDefaulting to .png")
            file_type = ".png"
        #If no file base is given, then loop through all file bases
        if base == None:
            #Check for potential problems with conditions
            for b in self.conditions[condition]:
                i=0
                for file in self.conditions[condition][b]:
                    if i == 0:
                        first_cond = self.conditions[condition][b][file]
                    else:
                        if first_cond == self.conditions[condition][b][file]:
                            print("Error! Cannot create overlay plot if given condition variable ("+condition+") is unchanged throughout files...")
                            return
                    i+=1

            for b in self.conditions[condition]:
                self.overlayPlotHelper(column_name, frame_index, b, condition, display, save, file_name, file_type, subdir, second_column)
        else:
            #Check for potential problems with conditions
            for b in self.conditions[condition]:
                i=0
                for file in self.conditions[condition][b]:
                    if i == 0:
                        first_cond = self.conditions[condition][b][file]
                    else:
                        if first_cond == self.conditions[condition][b][file]:
                            print("Error! Cannot create overlay plot if given condition variable ("+condition+") is unchanged throughout files...")
                            return
                    i+=1

            self.overlayPlotHelper(column_name, frame_index, base, condition, display, save, file_name, file_type, subdir, second_column)
        return

    ##Helper function for the createTimeFrameOverlayPlot() function [Not called by user]
    def overlayPlotHelper(self, column_name, frame_index, base, condition, display, save, file_name, file_type, subdir, second_column):
        #Check to see if folder exists and create if needed
        if subdir != "" and not os.path.exists(subdir) and save == True:
            os.makedirs(subdir)
            subdir+="/"

        #Check for valid base
        if base not in self.conditions[condition]:
            print("Error! Invalid base file name!")
            return
        xvals_set = {}
        yvals_set = {}
        time_set = {}
        #added = []
        frame_name = ""
        #grab all appropriate data
        for file in self.conditions[condition][base]:
            #check the time frame to find the appropriate xvals
            if frame_index > len(self.grabDataObj(file).getTimeFrames())-1:
                print("Error! The frame_index is out of bounds!")
                return
            xvals_set[file] = self.grabDataObj(file).extractRows(self.grabDataObj(file).getTimeFrames()[frame_index][0],self.grabDataObj(file).getTimeFrames()[frame_index][1])[second_column]
            time_set[file] = self.grabDataObj(file).extractRows(self.grabDataObj(file).getTimeFrames()[frame_index][0],self.grabDataObj(file).getTimeFrames()[frame_index][1])[self.time_key]
            frame_name = "frame(" + str(int(time_set[file][0])) + "," + str(int(time_set[file][-1])) + ")"

            yvals_set[file] = {}
            #extract yvals

            #Check to make sure column is valid
            if self.isPaired(file) == True:
                if column_name not in self.grabDataObj(file).result_trans_obj.data_map.keys():
                    print("Error! Invalid column name!")
                    return
            else:
                if column_name not in self.grabDataObj(file).data_map.keys():
                    print("Error! Invalid column name!")
                    return
            yvals_set[file][column_name] = self.grabDataObj(file).extractRows(time_set[file][0],time_set[file][-1])[column_name]

            if second_column == self.time_key:
                #Loop through the xvals and correct the time frames such that each starts from time = 0
                i=0
                start = xvals_set[file][0]
                for time in xvals_set[file]:
                    xvals_set[file][i] = xvals_set[file][i] - start
                    i+=1
        #Now, we should have all x and y values for everything we want to plot
        fig = plt.figure()
        leg = []
        ylab = column_name
        xlab = ""
        i=0
        for file in self.conditions[condition][base]:
            if xlab == "":
                if second_column == self.time_key:
                    xlab += "Time Change in "+self.grabDataObj(file).time_key.split("(")[1].split(")")[0]
                else:
                    xlab += second_column
            leg.append("@"+str(self.conditions[condition][base][file]))
            if condition == "iso_temp":
                leg[i] += " oC"
            if condition == "aging_time":
                leg[i] += " hr"
            if condition == "aging_temp":
                leg[i] += " oC"
            if condition == "flow_rate":
                leg[i] += " hr^-1"
            plt.plot(xvals_set[file],yvals_set[file][column_name])
            i+=1
        plt.legend(leg)
        plt.xlabel(xlab)
        plt.ylabel(ylab)
        plt.tight_layout()
        if file_name == "":
            file_name = base + "-" + column_name+"_vs_"+second_column + "-" + frame_name
        if save == True:
            plt.savefig(subdir+file_name+'-OverlayPlot'+file_type)
        if display == True:
            fig.show()
            print("\nDisplaying plot. Press enter to continue...(this closes the images)")
            input()
        plt.close()
        return

    ##Function to create contour plots from different runs in the same time frame
    #
    #   This function will create a plot (or set of plots) of the same columns on the
    #   same figure for all files in a base file designation (or all base files). This
    #   is useful for viewing or saving figures of all conditions of a column variable
    #   on a single plot for comparison purposes. For example, you can plot the NH3
    #   TPD profile for all isothermal temperatures on the same figure to visually
    #   compare how changes in isothermal temperature impact the desorption profile
    #   for NH3.
    #
    #   @param column_name name of the column to plot on the same figure
    #   @param frame_index time frame index to indicate which section of time to plot the columns over
    #           Note: frame_index of -1 corresponds to the TDP section of a capacity curve
    #   @param condition condition used to distinguish the columns on the same plot
    #           Valid options: "material", "aging_time", "aging_temp", "iso_temp", and "flow_rate"
    #   @param base the base name of the set of files for which we are plotting. If left as None,
    #           then all plots for all base file names are plotted.
    #   @param display if True, then the created figure is plotted and displayed to the console
    #   @param save if True, then the created figure is saved to an output file
    #   @param file_name name of the file being saved
    #   @param file_type type of image file being created. Valid options: .png, .pdf, .ps, .eps and .svg
    #   @param subdir sub-directory where the file will be saved
    #   @param second_column name of the other column to plot the first column_name against
    #               if left None, then the time column is automatically used
    #
    #   NOTE 1:
    #
    #       We use frame_index instead of the actual time ranges to plot because the columns we want to
    #       plot together will often be misaligned in their respective time ranges. Thus, we instead
    #       plot based on the frame_index for the time frames, since each time frame is representative
    #       of the same "event" for all columns in the folder of files.
    #
    #   NOTE 2:
    #
    #       For the NH3 capacity data, the only valid condition is "iso_temp" because each folder of
    #       data has all the same other conditions.
    def createTimeFrameContourPlot(self, column_name, frame_index=-1, base=None, condition="iso_temp", display=False, save=True, file_name="",file_type=".png",subdir="", second_column=None):
        if type(column_name) is list:
            print("Error! Can only create a contour plot of single column!")
            return
        if second_column == None:
            second_column = self.time_key
        if type(second_column) is not str:
            print("Error! Invalid x-axis column type!")
            return
        #Check for valid condition
        if condition != "iso_temp" and condition != "material" and condition != "aging_temp" and condition != "aging_time" and condition != "flow_rate" and condition != "aging_cond":
            print("Error! Invalid system condition encountered!")
            return
        #Check for valid file type
        if file_type != ".png" and file_type != ".pdf" and file_type != ".ps" and file_type != ".eps" and file_type != ".svg":
            print("Warning! Unsupported image file type...")
            print("\tDefaulting to .png")
            file_type = ".png"
        #If no file base is given, then loop through all file bases
        if base == None:
            #Check for potential problems with conditions
            for b in self.conditions[condition]:
                i=0
                for file in self.conditions[condition][b]:
                    if i == 0:
                        first_cond = self.conditions[condition][b][file]
                    else:
                        if first_cond == self.conditions[condition][ba][file]:
                            print("Error! Cannot create overlay plot if given condition variable ("+condition+") is unchanged throughout files...")
                            return
                    i+=1

            for b in self.conditions[condition]:
                self.contourPlotHelper(column_name, frame_index, b, condition, display, save, file_name, file_type, subdir, second_column)
        else:
            #Check for potential problems with conditions
            for b in self.conditions[condition]:
                i=0
                for file in self.conditions[condition][b]:
                    if i == 0:
                        first_cond = self.conditions[condition][b][file]
                    else:
                        if first_cond == self.conditions[condition][b][file]:
                            print("Error! Cannot create overlay plot if given condition variable ("+condition+") is unchanged throughout files...")
                            return
                    i+=1

            self.contourPlotHelper(column_name, frame_index, base, condition, display, save, file_name, file_type, subdir, second_column)
        return

    ##Helper function for the createTimeFrameContourPlot() function [Not called by user]
    def contourPlotHelper(self, column_name, frame_index, base, condition, display, save, file_name, file_type, subdir, second_column):
        #Check to see if folder exists and create if needed
        if subdir != "" and not os.path.exists(subdir) and save == True:
            os.makedirs(subdir)
            subdir+="/"

        #Check for valid base
        if base not in self.conditions[condition]:
            print("Error! Invalid base file name!")
            return
        xvals_set = {}
        yvals_set = {}
        time_set = {}
        #added = []
        frame_name = ""
        #grab all appropriate data
        for file in self.conditions[condition][base]:
            #check the time frame to find the appropriate xvals
            if frame_index > len(self.grabDataObj(file).getTimeFrames())-1:
                print("Error! The frame_index is out of bounds!")
                return
            xvals_set[file] = self.grabDataObj(file).extractRows(self.grabDataObj(file).getTimeFrames()[frame_index][0],self.grabDataObj(file).getTimeFrames()[frame_index][1])[second_column]
            time_set[file] = self.grabDataObj(file).extractRows(self.grabDataObj(file).getTimeFrames()[frame_index][0],self.grabDataObj(file).getTimeFrames()[frame_index][1])[self.time_key]
            frame_name = "frame(" + str(int(time_set[file][0])) + "," + str(int(time_set[file][-1])) + ")"

            yvals_set[file] = {}
            #extract yvals

            #Check to make sure column is valid
            if self.isPaired(file) == True:
                if column_name not in self.grabDataObj(file).result_trans_obj.data_map.keys():
                    print("Error! Invalid column name!")
                    return
            else:
                if column_name not in self.grabDataObj(file).data_map.keys():
                    print("Error! Invalid column name!")
                    return
            yvals_set[file][column_name] = self.grabDataObj(file).extractRows(time_set[file][0],time_set[file][-1])[column_name]

            if second_column == self.time_key:
                #Loop through the xvals and correct the time frames such that each starts from time = 0
                i=0
                start = xvals_set[file][0]
                for time in xvals_set[file]:
                    xvals_set[file][i] = xvals_set[file][i] - start
                    i+=1

        #Create X,Y, and Z numpy arrays for creating a surface plot
        X = []
        Y = []
        Z = []
        i=0
        for file in xvals_set:
            j=0
            for item in yvals_set[file][column_name]:
                X.append(xvals_set[file][j])
                Z.append(yvals_set[file][column_name][j])
                Y.append(self.conditions[condition][base][file])
                j+=1
            i+=1

        fig = plt.figure()
        ax = fig.gca(projection='3d')
        X = np.array(X)
        Y = np.array(Y)
        Z = np.array(Z)

        surf = ax.plot_trisurf(X, Y, Z, cmap=cm.coolwarm, linewidth=0, antialiased=False)
        ax.view_init(azim=120)
        ax.set_zlabel(column_name)
        if second_column == self.time_key:
            ax.set_xlabel("Time Change in "+self.grabDataObj(file).time_key.split("(")[1].split(")")[0])
        else:
            ax.set_xlabel(second_column)
        if condition == "iso_temp":
            ax.set_ylabel("Temperature (C)")
        if condition == "aging_time":
            ax.set_ylabel("Aging Time (hr)")
        if condition == "aging_temp":
            ax.set_ylabel("Aging Temperature (C)")
        if condition == "flow_rate":
            ax.set_ylabel("Flow Rate (per hr)")

        fig.colorbar(surf, shrink=0.5, aspect=5)
        plt.tight_layout()
        if file_name == "":
            file_name = base + "-" + column_name+"_vs_"+second_column + "-" + frame_name
        if save == True:
            plt.savefig(subdir+file_name+'-ContourPlot'+file_type)
        if display == True:
            fig.show()
            print("\nDisplaying plot. Press enter to continue...(this closes the images)")
            input()
        plt.close()
        return

    ##Function to save all overlay plots
    #
    #   This function will save all overlay plots for the given column name to a subfolder
    #   for all time frames that are associated with that data set. The base name is optional.
    #   if provided, then it will only perform this action for the given base file name.
    #   Otherwise, it will apply this function iteratively for all base file names in
    #   the data folder.
    #
    #   @param column_name name of the column to plot on the same figure
    #   @param second_column name of the other column to plot the first column_name against
    #               if left None, then the time column is automatically used
    #   @param condition condition used to distinguish the columns on the same plot
    #           Valid options: "material", "aging_time", "aging_temp", "iso_temp", and "flow_rate"
    #   @param base the base name of the set of files for which we are plotting. If left as None,
    #           then all plots for all base file names are plotted.
    #   @param folder name of the folder where all the plots will be saved
    #   @param file_type type of image file being created. Valid options: .png, .pdf, .ps, .eps and .svg
    def saveOverlayPlots(self, column_name, second_column=None, folder="", base=None, condition="iso_temp", file_type=".png"):
        #Check for valid condition
        if condition != "iso_temp" and condition != "material" and condition != "aging_temp" and condition != "aging_time" and condition != "flow_rate" and condition != "aging_cond":
            print("Error! Invalid system condition encountered!")
            return
        if second_column == None:
            second_column = self.time_key

        #Check folder name and update
        if folder == "":
            folder = self.folder_name + "-OverlayPlots/"
        else:
            if folder[-1] != "/":
                folder += "/"
            folder += self.folder_name + "-OverlayPlots/"

        if base == None:
            for b in self.conditions[condition]:
                for file in self.conditions[condition][b]:
                    frames = self.grabDataObj(file).getTimeFrames()
                    break
                print("\nPlotting all overlays of " + column_name + " data from set " + b + " for all time frames.\n\tPlease wait...")
                f=0
                for frame in frames:
                    self.createTimeFrameOverlayPlot(column_name, f, b, condition, False, True, column_name+"_vs_"+second_column, file_type, folder+b+"/"+"frame("+str(int(frame[0]))+","+str(int(frame[1]))+")/", second_column)
                    f+=1
        else:
            for file in self.conditions[condition][base]:
                frames = self.grabDataObj(file).getTimeFrames()
                break
            print("\nPlotting all overlays of " + column_name + " data from set " + base + " for all time frames.\n\tPlease wait...")
            f=0
            for frame in frames:
                self.createTimeFrameOverlayPlot(column_name, f, base, condition, False, True, column_name+"_vs_"+second_column, file_type, folder+base+"/"+"frame("+str(int(frame[0]))+","+str(int(frame[1]))+")/", second_column)
                f+=1
        return

    ##Function to save all contour plots
    #
    #   This function will save all contour plots for the given column name to a subfolder
    #   for all time frames that are associated with that data set. The base name is optional.
    #   if provided, then it will only perform this action for the given base file name.
    #   Otherwise, it will apply this function iteratively for all base file names in
    #   the data folder.
    #
    #   @param column_name name of the column to plot on the same figure
    #   @param second_column name of the other column to plot the first column_name against
    #               if left None, then the time column is automatically used
    #   @param condition condition used to distinguish the columns on the same plot
    #           Valid options: "material", "aging_time", "aging_temp", "iso_temp", and "flow_rate"
    #   @param base the base name of the set of files for which we are plotting. If left as None,
    #           then all plots for all base file names are plotted.
    #   @param folder name of the folder where all the plots will be saved
    #   @param file_type type of image file being created. Valid options: .png, .pdf, .ps, .eps and .svg
    def saveContourPlots(self, column_name, second_column=None, folder="", base=None, condition="iso_temp", file_type=".png"):
        #Check for valid condition
        if condition != "iso_temp" and condition != "material" and condition != "aging_temp" and condition != "aging_time" and condition != "flow_rate" and condition != "aging_cond":
            print("Error! Invalid system condition encountered!")
            return
        if second_column == None:
            second_column = self.time_key

        #Check folder name and update
        if folder == "":
            folder = self.folder_name + "-ContourPlots/"
        else:
            if folder[-1] != "/":
                folder += "/"
            folder += self.folder_name + "-ContourPlots/"

        if base == None:
            for b in self.conditions[condition]:
                for file in self.conditions[condition][b]:
                    frames = self.grabDataObj(file).getTimeFrames()
                    break
                print("\nPlotting all contours of " + column_name + " data from set " + b + " for all time frames.\n\tPlease wait...")
                f=0
                for frame in frames:
                    self.createTimeFrameContourPlot(column_name, f, b, condition, False, True, column_name+"_vs_"+second_column, file_type, folder+b+"/"+"frame("+str(int(frame[0]))+","+str(int(frame[1]))+")/", second_column)
                    f+=1
        else:
            for file in self.conditions[condition][base]:
                frames = self.grabDataObj(file).getTimeFrames()
                break
            print("\nPlotting all contours of " + column_name + " data from set " + base + " for all time frames.\n\tPlease wait...")
            f=0
            for frame in frames:
                self.createTimeFrameContourPlot(column_name, f, base, condition, False, True, column_name+"_vs_"+second_column, file_type, folder+base+"/"+"frame("+str(int(frame[0]))+","+str(int(frame[1]))+")/", second_column)
                f+=1
        return

## TransientDataFolderSets
#
#   This class object is used to create sets of TransientDataFolder objects for
#   sets of related data that are in a series of folders or subdirectories. All
#   data in all folders will be stored in this object and operated on.
#
#   NOTE:
#
#       This object will allow us to create plots of data for similar columns
#       across all folders, i.e., if each folder holds the same data, but at a
#       different aging condition, then it will be useful to compare time or
#       data frame information for the same information taken at a different
#       aging time.
class TransientDataFolderSets(object):
    ##Initialize the object by reading in all readable data in a set of folders
    #
    # @param folders list of namse of folders that contain sets of data files
    # @param addNoise whether or not to add random noise for missing data emulation
    #
    #   NOTE:
    #
    #       The code expects that the folders only contain sets of CLEERS data files.
    #       If there are non-CLEERS data files or sub-folders, then this may cause errors.
    def __init__(self,folders,addNoise = True):
        if type(folders) is not list:
            folders = [folders]
        self.folder_data = {}
        for folder in folders:
            if os.path.isdir(folder) == False:
                print("Error! Given argument is not a folder!")
                return

            self.folder_data[folder] = TransientDataFolder(folder)

    ##Function to display information to the console
    def __str__(self):
        message = ""
        for folder in self.folder_data:
            message += str(self.folder_data[folder])
            message += "\n"
        return message

    ##Display names of all columns for all data sets
    #
    #       NOTE:
    #
    #       ASSUMES ALL DATA SETS HAVE SAME COMMON COLUMN NAMES
    def displayColumnNames(self):
        folder = list(self.folder_data.keys())[-1]
        self.folder_data[folder].displayColumnNames()

    ##Display the names of the file bases that are common to this object
    #
    #   This function will display to the console the file base names that are
    #   common among sets of files in each folder. This can be used to identify
    #   data sets that are related in a particular way
    #
    #   For instance:
    #
    #       All unaged data files for NH3 capacity are prefixed with...
    #
    #           20160205-CLRK-BASFCuSSZ13-700C4h-NH3DesIsoTPD-30k-0_2pctO2-5pctH2O
    #
    #       All unaged data files for H2O competition are prefixed with...
    #
    #           20160209-CLRK-BASFCuSSZ13-700C4h-NH3H2Ocomp-30k-0_2pctO2-11-3pctH2O-400ppmNH3
    #
    #   This information is used to create contour plots of various data over the
    #   conditions that do differ between those data files, such as isothermal temperature.
    def displayLikeFileNames(self):
        for folder in self.folder_data:
            self.folder_data[folder].displayLikeFileNames()
            print()

    ##Display the file names that are valid under the given prefix (or all like sets of files)
    def displayFilesUnderSet(self, folder, file_prefix=""):
        if folder not in self.folder_data.keys():
            print("Error! Invalid folder name! Be sure to include path/to/folder...")
            return
        self.folder_data[folder].displayFilesUnderSet(file_prefix)

    ##Display the run types of the files read in
    def displayRunTypes(self):
        for folder in self.folder_data:
            self.folder_data[folder].displayRunTypes()

    ##Delete specific columns from all data sets that we do not need
    def deleteColumns(self, column_list):
        #print()
        #print("Running deleteColumns("+str(column_list)+")...")
        for folder in self.folder_data:
            self.folder_data[folder].deleteColumns(column_list)

    ##Retain on specific columns from all data sets
    def retainOnlyColumns(self, column_list):
        #print()
        #print("Running retainOnlyColumns("+str(column_list)+")...")
        for folder in self.folder_data:
            self.folder_data[folder].retainOnlyColumns(column_list)

    ##Funtion to grab a specific file from a specific folder
    def grabDataFromFolder(self, folder, file):
        if folder not in self.folder_data.keys():
            print("Error! Invalid folder!")
            return
        valid_files = self.folder_data[folder].grabFileList()
        if file not in valid_files:
            print("Error! Invalid file name!")
            return
        return self.folder_data[folder].grabDataObj(file)

    ##Function to return an instance of the TransientData or PairedTransientData object given a file name
    #
    #   NOTE:
    #
    #       This function returns different data types depending on the argument it gets
    def grabDataObj(self,file):
        for folder in self.folder_data:
            if file in self.folder_data[folder].paired_data.keys():
                found = True
                return self.folder_data[folder].paired_data[file]
            if file in self.folder_data[folder].unpaired_data.keys():
                found = True
                return self.folder_data[folder].paired_data[file]

        if found == False:
            print("Error! Given file name was not located in any folder set given!")
            return

    ##Function to return an instance of the TransientDataFolder object by folder name
    def grabFolderObj(self,folder):
        if folder in self.folder_data.keys():
            return self.folder_data[folder]
        else:
            print("Error! No such folder exists in the data object!")
            return

    ##Function to report total data processed
    def getTotalDataProcessed(self):
        sum = 0
        for folder in self.folder_data:
            sum+=self.folder_data[folder].getTotalDataProcessed()
        return sum

    ##Function to compress all rows of data for each data object according to size of rows
    #
    #       NOTE:
    #
    #           This function should be called before printing to a file, but after everything else
    #
    #       This function accepts 2 optional arguments:
    #
    #           (i) num_rows_target
    #           (ii) max_factor
    #
    #       num_rows_target:
    #
    #                   is used to represent the number of rows of data we
    #                   want to compress the data to. For instance, num_rows_target = 1000
    #                   means that after compression, we want the data to fit within about
    #                   1000 rows of data.
    #
    #       max_factor:
    #
    #                    puts a cap on the maximum level of compression we will allow,
    #                   regardless of the num_rows_target. For intance, a max_factor of 10
    #                   means that the number of data rows will be reduced by a factor of 10
    #                   at most, and no more than that.
    def compressAllRows(self, num_rows_target = 1000, max_factor = 10):
        print()
        print("Running compressAllRows(num_rows_target="+str(num_rows_target)+", max_factor="+str(max_factor)+")...")
        for folder in self.folder_data:
            self.folder_data[folder].compressAllRows(num_rows_target, max_factor)

    ##Function to perform a math operation to all like columns of data in all data objects
    def mathOperations(self, column_name, operator, value_or_column, append_new = False, append_name = ""):
        #print()
        #print("Running mathOperations("+str(column_name)+ str(operator)+str(value_or_column) +", append_new="+str(append_new)+", append_name="+str(append_name)+")...")
        for folder in self.folder_data:
            self.folder_data[folder].mathOperations(column_name, operator, value_or_column, append_new, append_name)

    ##Function to determine whether or not the given file name is paired or unpaired
    #
    #       Returns True if paired, False if unpaired or doesn't exist
    def isPaired(self, file_name):
        result = False
        for folder in self.folder_data:
            result = self.folder_data[folder].isPaired(file_name)
            if result == True:
                return result
        return result

    ##This function calculates a simple integral of a given column over the time range in one data file
    #
    #   Integral is calculated via the trapezoid rule and the result of the integral
    #   is returned as a single value. If the column does not contain numeric data,
    #   then no computation is performed.
    #
    #   Integral sums are computed as follows...
    #
    #   integrate( column, min, max) ==> integral(a,b)  [ f(t)*dt ]   \n
    #   sum += 0.5*[f(t+dt)+f(t)]*dt
    #
    #   NOTE:
    #
    #       If no file name is provided, then this method returns a map of integral sums for all files
    #
    #   NOTE:
    #
    #       If no folder is given, then this method returns a map of maps for all integral sums
    #       in all folders and files.
    def calculateIntegralSum(self, column_name, folder=None, file=None, min_time=None, max_time=None):
        if folder == None:
            result_map = {}
            for f in self.folder_data:
                if file == None:
                    result_map[f] = self.grabFolderObj(f).calculateIntegralSum(column_name, file, min_time, max_time)
                else:
                    result_map[f] = self.grabDataFromFolder(f, file).calculateIntegralSum(column_name, min_time, max_time)
            return result_map
        else:
            if file == None:
                return self.grabFolderObj(folder).calculateIntegralSum(column_name, file, min_time, max_time)
            else:
                return self.grabDataFromFolder(folder, file).calculateIntegralSum(column_name, min_time, max_time)

    ##Function to compute a mass retention integral for all columns of the given name
    #
    #   NOTE:
    #
    #           This function SHOULD automatically handle both paired and unpaired data sets
    def calculateRetentionIntegrals(self, column_name, normalized = False, conv_factor = 1, input_col_name=""):
        #print()
        #print("Running calculateRetentionIntegrals("+str(column_name)+", normalized="+str(normalized)+", conv_factor="+str(conv_factor)+", input_col_name"+str(input_col_name)+")...")
        for folder in self.folder_data:
            self.folder_data[folder].calculateRetentionIntegrals(column_name, normalized, conv_factor, input_col_name)

    ##Function to print all results (paired and unpaired) to a series of output files in a sub-directory
    def printAlltoFile(self, subdir = ""):
        print()
        print("Running printAlltoFile(suddir="+str(subdir)+")...")
        for folder in self.folder_data:
            self.folder_data[folder].printAlltoFile(subdir)

    ##Function to create plots from columns of data
    #
    #   Options:
    #
    #       - obj_name: name of the file/obj for which the data we are plotting is held
    #
    #       - column_list: list of columns to create plots of (default is all columns of plottable data)
    #
    #       - range: tuple of the minimum to maximum time values that you want plotted (default is full range)
    #
    #       - display: if True, the images will be displayed once complete
    #
    #       - save: if True, the images will be saved to a file
    #
    #       - file_name: name of the file to save the plot to
    #
    #       - file_type: type of image file to save as (default = .png)
    #                       allowed types: .png, .pdf, .ps, .eps and .svg
    def createPlot(self, obj_name, column_list = [], range=None, display=False, save=True, file_name="",file_type=".png",subdir=""):
        loc = ""
        #Find the folder that contains the file/obj
        for folder in self.folder_data:
            if obj_name in self.folder_data[folder].paired_data.keys():
                loc = folder
                break
            if obj_name in self.folder_data[folder].unpaired_data.keys():
                loc = folder
                break
        if loc == "":
            print("Error! File/object name not found in any folder!")
            return
        self.folder_data[loc].createPlot(obj_name, column_list, range, display, save, file_name, file_type, subdir)

    ##Function to save all plots of data to several files in all folders
    #
    #   Function will automatically pair result data and bypass data together
    #   File names will be automatically generated and plots will not be displayed live
    #   Folder names are choosen automatically as well
    def savePlots(self, range=None, file_type=".png"):
        for folder in self.folder_data:
            self.folder_data[folder].savePlots(range, file_type)
    
    ##Function to save all fitted 2-peak TPD plots
    def save2peakTPDs(self, column_name, subdir="", file_type=".png"):
        for folder in self.folder_data:
            self.folder_data[folder].save2peakTPDs(column_name, subdir, file_type)

    ##Function to iteratively save all plots in all time frames separately
    def saveTimeFramePlots(self, subdir="", file_type=".png"):
        for folder in self.folder_data:
            self.folder_data[folder].saveTimeFramePlots(subdir, file_type)

    ##Function to create overlay plots from different runs in same time frame
    #
    #   This function will create a plot (or set of plots) of the same columns on the
    #   same figure for all files in a base file designation (or all base files). This
    #   is useful for viewing or saving figures of all conditions of a column variable
    #   on a single plot for comparison purposes. For example, you can plot the NH3
    #   TPD profile for all isothermal temperatures on the same figure to visually
    #   compare how changes in isothermal temperature impact the desorption profile
    #   for NH3.
    #
    #   @param column_name name of the columns in each file to plot on the same figure
    #   @param frame_index time frame index to indicate which section of time to plot the columns over
    #           Note: frame_index of -1 corresponds to the TDP section of a capacity curve
    #   @param condition condition used to distinguish the columns on the same plot
    #           Valid options: "material", "aging_time", "aging_temp", "iso_temp", and "flow_rate"
    #   @param base the base name of the set of files for which we are plotting. If left as None,
    #           then all plots for all base file names are plotted.
    #   @param display if True, then the created figure is plotted and displayed to the console
    #   @param save if True, then the created figure is saved to an output file
    #   @param file_name name of the file being saved
    #   @param file_type type of image file being created. Valid options: .png, .pdf, .ps, .eps and .svg
    #   @param subdir sub-directory where the file will be saved
    #   @param second_column name of the other column to plot the first column_name against
    #               if left None, then the time column is automatically used
    #
    #   NOTE 1:
    #
    #       We use frame_index instead of the actual time ranges to plot because the columns we want to
    #       plot together will often be misaligned in their respective time ranges. Thus, we instead
    #       plot based on the frame_index for the time frames, since each time frame is representative
    #       of the same "event" for all columns in the folder of files.
    #
    #   NOTE 2:
    #
    #       For the NH3 capacity data, the only valid condition is "iso_temp" because each folder of
    #       data has all the same other conditions.
    def createTimeFrameOverlayPlot(self, column_name, frame_index=-1, base=None, condition="iso_temp", display=False, save=True, file_name="",file_type=".png",subdir="", second_column=None):
        loc = ""
        #Find the folder that contains the file/obj
        for folder in self.folder_data:
            if obj_name in self.folder_data[folder].paired_data.keys():
                loc = folder
                break
            if obj_name in self.folder_data[folder].unpaired_data.keys():
                loc = folder
                break
        if loc == "":
            print("Error! File/object name not found in any folder!")
            return
        self.folder_data[loc].createTimeFrameOverlayPlot(column_name, frame_index, base, condition, display, save, file_name, file_type, subdir, second_column)

    ##Function to create contour plots from different runs in the same time frame
    #
    #   This function will create a plot (or set of plots) of the same columns on the
    #   same figure for all files in a base file designation (or all base files). This
    #   is useful for viewing or saving figures of all conditions of a column variable
    #   on a single plot for comparison purposes. For example, you can plot the NH3
    #   TPD profile for all isothermal temperatures on the same figure to visually
    #   compare how changes in isothermal temperature impact the desorption profile
    #   for NH3.
    #
    #   @param column_name name of the column to plot on the same figure
    #   @param frame_index time frame index to indicate which section of time to plot the columns over
    #           Note: frame_index of -1 corresponds to the TDP section of a capacity curve
    #   @param condition condition used to distinguish the columns on the same plot
    #           Valid options: "material", "aging_time", "aging_temp", "iso_temp", and "flow_rate"
    #   @param base the base name of the set of files for which we are plotting. If left as None,
    #           then all plots for all base file names are plotted.
    #   @param display if True, then the created figure is plotted and displayed to the console
    #   @param save if True, then the created figure is saved to an output file
    #   @param file_name name of the file being saved
    #   @param file_type type of image file being created. Valid options: .png, .pdf, .ps, .eps and .svg
    #   @param subdir sub-directory where the file will be saved
    #   @param second_column name of the other column to plot the first column_name against
    #               if left None, then the time column is automatically used
    #
    #   NOTE 1:
    #
    #       We use frame_index instead of the actual time ranges to plot because the columns we want to
    #       plot together will often be misaligned in their respective time ranges. Thus, we instead
    #       plot based on the frame_index for the time frames, since each time frame is representative
    #       of the same "event" for all columns in the folder of files.
    #
    #   NOTE 2:
    #
    #       For the NH3 capacity data, the only valid condition is "iso_temp" because each folder of
    #       data has all the same other conditions.
    def createTimeFrameContourPlot(self, column_name, frame_index=-1, base=None, condition="iso_temp", display=False, save=True, file_name="",file_type=".png",subdir="", second_column=None):
        loc = ""
        #Find the folder that contains the file/obj
        for folder in self.folder_data:
            if obj_name in self.folder_data[folder].paired_data.keys():
                loc = folder
                break
            if obj_name in self.folder_data[folder].unpaired_data.keys():
                loc = folder
                break
        if loc == "":
            print("Error! File/object name not found in any folder!")
            return
        self.folder_data[loc].createTimeFrameContourPlot(column_name, frame_index, base, condition, display, save, file_name, file_type, subdir)

    ##Function to save all overlay plots
    #
    #   This function will save all overlay plots for the given column name to a subfolder
    #   for all time frames that are associated with that data set. The base name is optional.
    #   if provided, then it will only perform this action for the given base file name.
    #   Otherwise, it will apply this function iteratively for all base file names in
    #   the data folder.
    #
    #   @param column_name name of the column to plot on the same figure
    #   @param second_column name of the other column to plot the first column_name against
    #               if left None, then the time column is automatically used
    #   @param condition condition used to distinguish the columns on the same plot
    #           Valid options: "material", "aging_time", "aging_temp", "iso_temp", and "flow_rate"
    #   @param base the base name of the set of files for which we are plotting. If left as None,
    #           then all plots for all base file names are plotted.
    #   @param subdir name of the folder where all the plots will be saved
    #   @param file_type type of image file being created. Valid options: .png, .pdf, .ps, .eps and .svg
    def saveOverlayPlots(self, column_name, second_column=None, subdir="", base=None, condition="iso_temp", file_type=".png"):
        for folder in self.folder_data:
            self.folder_data[folder].saveOverlayPlots(column_name, second_column, subdir, base, condition, file_type)

    ##Function to save all contour plots
    #
    #   This function will save all contour plots for the given column name to a subfolder
    #   for all time frames that are associated with that data set. The base name is optional.
    #   if provided, then it will only perform this action for the given base file name.
    #   Otherwise, it will apply this function iteratively for all base file names in
    #   the data folder.
    #
    #   @param column_name name of the column to plot on the same figure
    #   @param second_column name of the other column to plot the first column_name against
    #               if left None, then the time column is automatically used
    #   @param condition condition used to distinguish the columns on the same plot
    #           Valid options: "material", "aging_time", "aging_temp", "iso_temp", and "flow_rate"
    #   @param base the base name of the set of files for which we are plotting. If left as None,
    #           then all plots for all base file names are plotted.
    #   @param subdir name of the folder where all the plots will be saved
    #   @param file_type type of image file being created. Valid options: .png, .pdf, .ps, .eps and .svg
    def saveContourPlots(self, column_name, second_column=None, subdir="", base=None, condition="iso_temp", file_type=".png"):
        for folder in self.folder_data:
            self.folder_data[folder].saveContourPlots(column_name, second_column, subdir, base, condition, file_type)

    ##Function to create an overlay plot from data across multiple files in multiple folders
    #
    #   This function is used to create a plot of data for a given column in a given time frame
    #   for a given constant variable condition vs several different conditions that vary. Generally,
    #   we will use this function to plot the differences in TPDs at a given isothermal temperature
    #   for a multitude of aging conditions.
    #
    #   @param column_name name of the column to plot on the same figure
    #   @param frame_index time frame index to indicate which section of time to plot the columns over
    #           Note: frame_index of -1 corresponds to the TDP section of a capacity curve
    #   @param rtype run type to specify which type of run to plot
    #           Similar to the "base" option createTimeFrameOverlayPlot()
    #   @param const_cond the variable condition that is to be held constant for a plot
    #   @param var_cond the variable condition that is to be changed on the plot
    #   @param display if True, then the created figure is plotted and displayed to the console
    #   @param save if True, then the created figure is saved to an output file
    #   @param file_name name of the file being saved
    #   @param file_type type of image file being created. Valid options: .png, .pdf, .ps, .eps and .svg
    #   @param subdir sub-directory where the file will be saved
    def createCrossFolderTimeFrameOverlayPlots(self, column_name, frame_index=-1, rtype=None, const_cond="iso_temp", var_cond="aging_cond", display=False, save=True, file_name="",file_type=".png",subdir=""):
        if type(column_name) is not str:
            print("Error! Can only create overlay plot of a single column!")
            return
        #Check for valid conditions
        if const_cond != "iso_temp" and const_cond != "material" and const_cond != "aging_temp" and const_cond != "aging_time" and const_cond != "flow_rate" and const_cond != "aging_cond":
            print("Error! Invalid system condition encountered!")
            return
        if var_cond != "iso_temp" and var_cond != "material" and var_cond != "aging_temp" and var_cond != "aging_time" and var_cond != "flow_rate" and var_cond != "aging_cond":
            print("Error! Invalid system condition encountered!")
            return
        if const_cond == var_cond:
            print("Error! Cannot have the same constant and variable conditions!")
            return
        #Check for valid file type
        if file_type != ".png" and file_type != ".pdf" and file_type != ".ps" and file_type != ".eps" and file_type != ".svg":
            print("Warning! Unsupported image file type...")
            print("\tDefaulting to .png")
            file_type = ".png"
        #Check run type
        if type(rtype) is not str and rtype != None:
            print("Error! The run type must be a string representing the type of run to plot data for!")
            return

        #Initialize a run_types list
        run_types = []
        if rtype != None:
            run_types.append(rtype)
        else:
            for folder in self.folder_data:
                for base in self.folder_data[folder].conditions["run_type"]:
                    if self.folder_data[folder].conditions["run_type"][base] not in run_types:
                        run_types.append(self.folder_data[folder].conditions["run_type"][base])

        #Now create maps of type->folder->file->(const_cond, var_cond) [temporary object]
        cond_map = {}
        for types in run_types:
            cond_map[types] = {}
            for folder in self.folder_data:
                cond_map[types][folder] = {}
                for base in self.folder_data[folder].conditions[const_cond]:
                    if types == self.folder_data[folder].conditions["run_type"][base]:
                        for file in self.folder_data[folder].conditions[const_cond][base]:
                            cond_map[types][folder][file] = (self.folder_data[folder].conditions[const_cond][base][file], self.folder_data[folder].conditions[var_cond][base][file])

        #Check cond_map for errors
        const_error = False
        var_error = False
        for types in cond_map:
            for folder in cond_map[types]:
                i=0
                for file in cond_map[types][folder]:
                    if i==0:
                        var_check = cond_map[types][folder][file][1]
                        const_check = cond_map[types][folder][file][0]
                    else:
                        if var_check != cond_map[types][folder][file][1]:
                            print("Error! The var_cond should be the same for all files in a given folder!")
                            return
                        if const_check == cond_map[types][folder][file][0]:
                            print("Error! The const_cond should be different for all files in a given folder!")
                            return
                    i+=1

        #Iterate through cond_map to prep data for plotting =>  info_map[const_cond_val][var_cond_val] -> (folder, file)
        info_map = {}
        for types in cond_map:
            info_map[types] = {}
            for folder in cond_map[types]:
                for file in cond_map[types][folder]:
                    if str(cond_map[types][folder][file][0]) not in info_map[types].keys():
                        info_map[types][str(cond_map[types][folder][file][0])] = {}
                    info_map[types][str(cond_map[types][folder][file][0])][str(cond_map[types][folder][file][1])] = (folder,file)

        #Now, we need to iterate through the info map to develop the plots
        for types in info_map:
            for con_con in info_map[types]:
                self.crossOverlayPlotHelper(column_name, frame_index, types, con_con, const_cond, info_map[types][con_con], var_cond, display, save, file_name, file_type, subdir)
        return

    ## Cross Folder Overlay Plot helper function [not called by user]
    #
    #   This helper function will create a single cross-folder plot of the requested data
    #
    #   red_info_map contains a reduced version of the full info_map. It only contains the
    #   data necessary to develop the current plot.
    #
    #   red_info_map = {}
    #   red_info_map[var_cond] = (folder, file)
    #
    #   var_cond are the keys representing the condition that is variable
    #   (folder, file) is the contents of the map at that key and holds the folder and file names
    def crossOverlayPlotHelper(self, column_name, frame_index, rtype, const_cond, cond_name, red_info_map, var_name, display, save, file_name, file_type, subdir):
        #Check to see if folder exists and create if needed
        if subdir != "" and not os.path.exists(subdir) and save == True:
            os.makedirs(subdir)
            subdir+="/"
        #Grab all data to plot
        xvals_set = {}
        yvals_set = {}
        frame_name = ""
        xlab = ""
        for var_cond in sorted(red_info_map.keys()):
            folder = red_info_map[var_cond][0]
            file = red_info_map[var_cond][1]
            if frame_index > len(self.folder_data[folder].grabDataObj(file).getTimeFrames())-1:
                print("Error! The frame_index is out of bounds!")
                return
            xvals_set[file] = self.folder_data[folder].grabDataObj(file).extractRows(self.folder_data[folder].grabDataObj(file).getTimeFrames()[frame_index][0],self.folder_data[folder].grabDataObj(file).getTimeFrames()[frame_index][1])[self.folder_data[folder].grabDataObj(file).time_key]
            frame_name = "frame(" + str(int(xvals_set[file][0])) + "," + str(int(xvals_set[file][-1])) + ")"

            #Check for valid column_name
            if self.folder_data[folder].isPaired(file) == True:
                if column_name not in self.folder_data[folder].grabDataObj(file).result_trans_obj.data_map.keys():
                    print("Error! Invalid column name!")
                    return
            else:
                if column_name not in self.folder_data[folder].grabDataObj(file).data_map.keys():
                    print("Error! Invalid column name!")
                    return
            yvals_set[file] = self.folder_data[folder].grabDataObj(file).extractRows(xvals_set[file][0],xvals_set[file][-1])[column_name]

            if xlab == "":
                xlab += "Time Change in "+self.folder_data[folder].grabDataObj(file).time_key.split("(")[1].split(")")[0]

            #Loop through the xvals and correct the time frames such that each starts from time = 0
            i=0
            start = xvals_set[file][0]
            for time in xvals_set[file]:
                xvals_set[file][i] = xvals_set[file][i] - start
                i+=1

        #Now, we should have all x and y values for everything we want to plot
        fig = plt.figure()
        leg = []
        ylab = column_name+"@"+const_cond
        if cond_name == "iso_temp":
            ylab += " oC"
        if cond_name == "aging_time":
            ylab += " hr"
        if cond_name == "aging_temp":
            ylab += " oC"
        if cond_name == "flow_rate":
            ylab += " hr^-1"

        i=0
        for var_cond in red_info_map:
            folder = red_info_map[var_cond][0]
            file = red_info_map[var_cond][1]
            leg.append("@"+str(var_cond))
            if var_name == "iso_temp":
                leg[i] += " oC"
            if var_name == "aging_time":
                leg[i] += " hr"
            if var_name == "aging_temp":
                leg[i] += " oC"
            if var_name == "flow_rate":
                leg[i] += " hr^-1"
            plt.plot(xvals_set[file],yvals_set[file])
            i+=1
        plt.legend(leg)
        plt.xlabel(xlab)
        plt.ylabel(ylab)
        plt.tight_layout()
        if file_name == "":
            file_name = rtype + "-" + ylab + "_vs_" + var_name + "-" + frame_name
        if save == True:
            if subdir != "":
                combined = subdir + "/" + rtype + "-" + cond_name + "_vs_" + var_name + "/"
            else:
                combined = rtype + "-" + cond_name + "_vs_" + var_name + "/"
            if not os.path.exists(combined):
                os.makedirs(combined)
            plt.savefig(combined+file_name+'-CrossOverlayPlot'+file_type)
        if display == True:
            fig.show()
            print("\nDisplaying plot. Press enter to continue to next plot...(this closes the images)")
            input()
        plt.close()
        return

    ##Function to save all cross-overlay plots
    #
    #   This function will save all cross overlay plots for the given column name to a subfolder
    #   for all time frames that are associated with that data set. The rtype (run type) is an
    #   optional value the user can provide if they only want to do this for a single type of run.
    #   Otherwise, it will apply this function iteratively for all run types in all data folders.
    #   Default is setup to plot the given column at each specific isothermal temperature on
    #   separate plots and include the data for various aging conditions on the same plot.
    #
    #   @param column_name name of the column to plot on the same figure
    #   @param rtype run type to specify which type of run to plot
    #           Similar to the "base" option createTimeFrameOverlayPlot()
    #   @param const_cond the variable condition that is to be held constant for a plot
    #   @param var_cond the variable condition that is to be changed on the plot
    #   @param subdir name of the folder where all the plots will be saved
    #   @param file_type type of image file being created. Valid options: .png, .pdf, .ps, .eps and .svg
    def saveCrossOverlayPlots(self, column_name, subdir="", rtype=None, const_cond="iso_temp", var_cond="aging_cond", file_type=".png"):
        #Check for valid conditions
        if const_cond != "iso_temp" and const_cond != "material" and const_cond != "aging_temp" and const_cond != "aging_time" and const_cond != "flow_rate" and const_cond != "aging_cond":
            print("Error! Invalid system condition encountered!")
            return
        if var_cond != "iso_temp" and var_cond != "material" and var_cond != "aging_temp" and var_cond != "aging_time" and var_cond != "flow_rate" and var_cond != "aging_cond":
            print("Error! Invalid system condition encountered!")
            return
        if const_cond == var_cond:
            print("Error! The variable condition and constant condition cannot be the same condition!")
            return

        #Check folder name and update
        if subdir == "":
            subdir = column_name+"-CrossOverlayPlots/"
        else:
            if subdir[-1] != "/":
                subdir += "/"
            subdir += column_name+"-CrossOverlayPlots/"

        #Initialize a run_types and num_frames list
        #NOTE: each list will be same size and each element in each list corresponds with the other element in the other list
        run_types = []
        num_frames = []
        approx_span = []
        if rtype != None:
            run_types.append(rtype)
            for folder in self.folder_data:
                for base in self.folder_data[folder].conditions["run_type"]:
                    if self.folder_data[folder].conditions["run_type"][base] in run_types:
                        for file in self.folder_data[folder].conditions[const_cond][base]:
                            num_frames.append(len(self.folder_data[folder].grabDataObj(file).getTimeFrames()))
                            approx_span.append(self.folder_data[folder].grabDataObj(file).getTimeFrames())
                            break
        else:
            for folder in self.folder_data:
                for base in self.folder_data[folder].conditions["run_type"]:
                    if self.folder_data[folder].conditions["run_type"][base] not in run_types:
                        run_types.append(self.folder_data[folder].conditions["run_type"][base])
                        for file in self.folder_data[folder].conditions[const_cond][base]:
                            num_frames.append(len(self.folder_data[folder].grabDataObj(file).getTimeFrames()))
                            approx_span.append(self.folder_data[folder].grabDataObj(file).getTimeFrames())
                            break

        #Loop through all run_types and all time_frames
        i=0
        for type in run_types:
            for frame in range(0,num_frames[i]):
                # file_name=""
                print("\nPlotting all cross-folder overlays of " + column_name + " from " + type + " for " + var_cond + " vs " + const_cond + " in frame (" + str(int(approx_span[i][frame][0]))+","+str(int(approx_span[i][frame][1])) +  ").\n\tPlease wait...")
                self.createCrossFolderTimeFrameOverlayPlots(column_name, frame, type, const_cond, var_cond, False, True, "", file_type, subdir+type+"/"+"frame("+str(int(approx_span[i][frame][0]))+","+str(int(approx_span[i][frame][1]))+")/")
            i+=1
        return

## Function for testing the data folder object
def testing():
    test01 = TransientDataFolderSets(["AllNH3Data/BASFCuSSZ13-700C4h-NH3storage","AllNH3Data/BASFCuSSZ13-800C2h-NH3storage"])
    #test01 = TransientDataFolderSets(["AllNH3Data/BASFCuSSZ13-700C4h-NH3storage"])
    #test01.displayRunTypes()
    #test01.createCrossFolderTimeFrameOverlayPlots('NH3 (300,3000)')
    #test01 = TransientDataFolder("BASFCuSSZ13-700C4h-NH3storage")
    test01.retainOnlyColumns(['Elapsed Time (min)','NH3 (300,3000)', 'H2O% (20)', 'TC bot sample in (C)', 'TC bot sample mid 1 (C)', 'TC bot sample mid 2 (C)', 'TC bot sample out 1 (C)', 'TC bot sample out 2 (C)', 'P bottom in (bar)', 'P bottom out (bar)'])
    #test01.displayColumnNames()
    #print(test01.grabDataObj("20160209-CLRK-BASFCuSSZ13-700C4h-NH3H2Ocomp-30k-0_2pctO2-11-3pctH2O-400ppmNH3-200C.dat"))
    #test01.grabFolderObj("AllNH3Data/BASFCuSSZ13-700C4h-NH3storage").fit2peakTPD("20160209-CLRK-BASFCuSSZ13-700C4h-NH3H2Ocomp-30k-0_2pctO2-11-3pctH2O-400ppmNH3-200C.dat",'NH3 (300,3000)')
    #print(test01)  #This will display the names of the objects/files you have access to and whether they are paired or not

    #test01.grabFolderObj("AllNH3Data/BASFCuSSZ13-700C4h-NH3storage").save2peakTPDs('NH3 (300,3000)',"test")
    #test01.save2peakTPDs('NH3 (300,3000)',"test")
    
    
    #print("Calculating sum...")
    #print(test01.calculateIntegralSum('NH3 (300,3000)',None,None,15,24))

    #test01.displayLikeFileNames()
    #test01.displayFilesUnderSet("20160209-CLRK-BASFCuSSZ13-700C4h-NH3H2Ocomp-30k-0_2pctO2-11-3pctH2O-400ppmNH3")

    #Convert all temperatures from (C) to Kelvin, then delete old columns
    test01.mathOperations('TC bot sample in (C)',"+",273.15, True, 'TC bot sample in (K)')
    test01.deleteColumns('TC bot sample in (C)')
    test01.mathOperations('TC bot sample mid 1 (C)',"+",273.15, True, 'TC bot sample mid 1 (K)')
    test01.deleteColumns('TC bot sample mid 1 (C)')
    test01.mathOperations('TC bot sample mid 2 (C)',"+",273.15, True, 'TC bot sample mid 2 (K)')
    test01.deleteColumns('TC bot sample mid 2 (C)')
    test01.mathOperations('TC bot sample out 1 (C)',"+",273.15, True, 'TC bot sample out 1 (K)')
    test01.deleteColumns('TC bot sample out 1 (C)')
    test01.mathOperations('TC bot sample out 2 (C)',"+",273.15, True, 'TC bot sample out 2 (K)')
    test01.deleteColumns('TC bot sample out 2 (C)')

    #Delete the temperature columns from the bypass run that we don't need
    test01.deleteColumns(['TC bot sample in (C)[bypass]','TC bot sample mid 1 (C)[bypass]','TC bot sample mid 2 (C)[bypass]','TC bot sample out 1 (C)[bypass]','TC bot sample out 2 (C)[bypass]'])

    #Now, convert all pressures from bar to kPa and delete the extra [bypass] columns
    test01.mathOperations('P bottom in (bar)',"*",100,True,'P bottom in (kPa)')
    test01.deleteColumns('P bottom in (bar)')
    test01.mathOperations('P bottom out (bar)',"*",100,True,'P bottom out (kPa)')
    test01.deleteColumns('P bottom out (bar)')

    #Delete the pressure columns from the bypass run that we also don't need
    test01.deleteColumns(['P bottom in (bar)[bypass]','P bottom out (bar)[bypass]'])

    #Calculate the mass retention for species of interest
    test01.calculateRetentionIntegrals('NH3 (300,3000)')
    test01.calculateRetentionIntegrals('H2O% (20)')

    #NH3 has units of ppmv, want to convert this to mol adsorbed / L catalyst
    test01.mathOperations('NH3 (300,3000)-Retained',"/",1E6)                     #From ppmv to molefraction
    test01.mathOperations('NH3 (300,3000)-Retained',"*","P bottom out (kPa)")    #From molefraction to kPa
    test01.mathOperations('NH3 (300,3000)-Retained',"/",8.314)
    test01.mathOperations('NH3 (300,3000)-Retained',"/",'TC bot sample out 1 (K)') #From kPa to mol/L using Ideal gas law
    test01.mathOperations('NH3 (300,3000)-Retained',"*",0.015708)                #From mol/L to total moles (multiply by total volume)
    #From total moles to mol ads / L cat using solids fraction, then store in new column and delete old column
    test01.mathOperations('NH3 (300,3000)-Retained',"/",(1-0.3309)*0.015708,True,"NH3 ads (mol/L)")
    test01.deleteColumns('NH3 (300,3000)-Retained')

    #H2O has units of %, want to convert this to mol adsorbed / L catalyst
    test01.mathOperations('H2O% (20)-Retained',"/",100)                     #From % to molefraction
    test01.mathOperations('H2O% (20)-Retained',"*","P bottom out (kPa)")    #From molefraction to kPa
    test01.mathOperations('H2O% (20)-Retained',"/",8.314)
    test01.mathOperations('H2O% (20)-Retained',"/",'TC bot sample out 1 (K)') #From kPa to mol/L using Ideal gas law
    test01.mathOperations('H2O% (20)-Retained',"*",0.015708)                #From mol/L to total moles (multiply by total volume)
    #From total moles to mol ads / L cat using solids fraction, then store in new column and delete old column
    test01.mathOperations('H2O% (20)-Retained',"/",(1-0.3309)*0.015708,True,"H2O ads (mol/L)")
    test01.deleteColumns('H2O% (20)-Retained')

    #Test the createPlot function
    #test01.createPlot("20160209-CLRK-BASFCuSSZ13-700C4h-NH3H2Ocomp-30k-0_2pctO2-11-3pctH2O-400ppmNH3-200C.dat",'NH3 (300,3000)')
    #test01.savePlots()
    #test01.savePlots((200,350))
    #test01.saveTimeFramePlots("test")
    #test01.createTimeFrameOverlayPlot('NH3 (300,3000)',-1,"20160205-CLRK-BASFCuSSZ13-700C4h-NH3DesIsoTPD-30k-0_2pctO2-5pctH2O")
    #test01.createTimeFrameOverlayPlot('NH3 (300,3000)',-1)
    #test01.createTimeFrameOverlayPlot('NH3 (300,3000)')
    #test01.createTimeFrameContourPlot('NH3 (300,3000)',-1,"20160205-CLRK-BASFCuSSZ13-700C4h-NH3DesIsoTPD-30k-0_2pctO2-5pctH2O")
    #test01.createTimeFrameContourPlot('NH3 (300,3000)')
    #test01.saveOverlayPlots('NH3 (300,3000)','TC bot sample out 1 (K)', "test")
    #test01.saveOverlayPlots('NH3 (300,3000)',None, "test")
    #test01.saveCrossOverlayPlots('NH3 (300,3000)', "test", "NH3DesIsoTPD")
    #test01.saveContourPlots('NH3 (300,3000)')

    #test01.grabFolderObj("AllNH3Data/BASFCuSSZ13-700C4h-NH3storage").createTimeFrameOverlayPlot('NH3 (300,3000)', -1, "20160205-CLRK-BASFCuSSZ13-700C4h-NH3DesIsoTPD-30k-0_2pctO2-5pctH2O", "iso_temp", True, False, "",".png","", 'TC bot sample in (K)')
    #test01.grabFolderObj("AllNH3Data/BASFCuSSZ13-700C4h-NH3storage").createTimeFrameContourPlot('NH3 (300,3000)', -1, "20160205-CLRK-BASFCuSSZ13-700C4h-NH3DesIsoTPD-30k-0_2pctO2-5pctH2O", "iso_temp", True, False, "",".png","", 'TC bot sample in (K)')

    test01.save2peakTPDs('NH3 (300,3000)',"test")
    #Compress the processed data for visualization in spreadsheets
    test01.compressAllRows()

    #test01.savePlots()
    #test01.savePlots((200,350))

    #Print the results to a series of output files
    test01.printAlltoFile("test")

##Directs python to call the testing function
if __name__ == "__main__":
   testing()
