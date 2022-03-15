'''
    This file creates an object that can be used to write/create MOOSE formatted
    input files to control a simulation. In python, the data associated with the
    input file is stored as a regular dictionary. That dictionary contains all
    the information needed to create MOOSE 'blocks' for the structured input files.
    It will serve as the base object for creating MOOSE input files from other,
    more simple scripts and user inputs.

    Author:     Austin Ladshaw
    Date:       03/04/2022
    Copyright:  This kernel was designed and built at Oak Ridge National
                Laboratory by Austin Ladshaw for research in the area
                of adsorption, catalysis, and surface science.
'''
# import statements
import sys, os
import os.path
from os import path
import errno
import re

valid_blocks = ["GlobalParams"
                "Problem",
                "Mesh",
                "Variables",
                "AuxVariables",
                "Kernels",
                "DGKernels",
                "InterfaceKernels",
                "AuxKernels",
                "BCs",
                "ICs",
                "Postprocessors",
                "Executioner",
                "Preconditioning",
                "Outputs",
                "Materials",
                "UserObjects",
                "Functions",
                "Adaptivity",
                "Modules",
                "Constraints"]

end_block_sym = ["[]", "[../]"]

start_block_sym = ["[*]", "[./*]"]

def is_valid_integer(str_val):
    result = re.match("[-+]?\d+$", str_val)
    return result

def is_valid_float(str_val):
    try:
        num = float(str_val)
        return True
    except ValueError:
        return False

def is_valid_bool(str_val):
    return str_val.lower() in ("true", "false")

def str_to_bool(str_val):
    return str_val.lower() in ("true")

# Object to handle the data associated with CATS input files
class CATS_InputFile(object):
    # Default constructor
    def __init__(self):
        self.data = {}          #Dictionary of data (empty by default)
        self.stream = ""        #String stream to output as file
        self.level = 0          #tracker for the level of dict
        self.stream_built = False


    def construct_from_dict(self, user_dict, validate=False,
                                  raise_error=False,
                                  build_stream=False):
        if type(user_dict) != dict:
            raise TypeError("Given arg 'user_dict' is not a dict object!")
        self.data = user_dict   #Dictionary of data (shallow copy, just a pointer)
        self.stream = ""        #String stream to output as file
        self.level = 0          #tracker for the level of dict
        self.stream_built = False

        if validate:
            self.validate_dict(raise_error=raise_error)

        if build_stream:
            self.build_stream()

    def construct_from_file(self, file_name):

        # Helper function to convert string to non-string type
        def _convert_type(str_val):
            if is_valid_integer(str_val):
                return int(str_val)
            if is_valid_float(str_val):
                return float(str_val)
            if is_valid_bool(str_val):
                return str_to_bool(str_val)
            return str_val

        # Helper function to read a list
        def _read_list(data_file, list):
            for line in data_file:
                readable, sep, tail = line.partition('#')

                if len(readable.strip()) > 0:
                    for item in readable.strip().partition("'")[0].split():
                        list.append(item)
                    if readable.strip()[-1] == "'":
                        break

        # Helper function to read a block
        def _read_block(data_file, block_data):

            for line in data_file:
                readable, sep, tail = line.partition('#')

                # Ends the block, return to _read_file
                if "[]" in readable or "[../]" in readable:
                    break

                # This would start a sub-block
                if "[" in readable:
                    # grab first result of all text in brackets
                    res = re.findall(r'\[.*?\]', readable)[0]
                    # remove brackets (and other symbols) from result
                    key = re.sub(r"[\[\]\.\/]", "", res)
                    block_data[key] = {}
                    _read_block(data_file, block_data[key])
                # Read in key-value pairs
                else:
                    k = re.findall(r'.*\=', readable)
                    res = re.findall(r'\=.*', readable)

                    key = ""
                    value = ""
                    if len(k) > 0:
                        key = k[0]
                    if len(res) > 0:
                        value = res[0]

                    key_name = ""
                    if len(key.split()) > 0:
                        key_name = key.split()[0]

                    # Check to see if 'value' is a list or just a single piece of data
                    value = value.partition("=")[2].strip()
                    value_list = []
                    is_list = False
                    value_res = re.findall(r'\'.*', value)
                    # indicates a list has opened
                    if len(value_res) > 0:
                        value_list = re.sub(r"[\'\']", "", value_res[0]).split()
                        is_list = True

                        if value_res[0][-1] != "'":
                            _read_list(data_file, value_list)

                        i=0
                        for item in value_list:
                            new_val = _convert_type(value_list[i])
                            value_list[i] = new_val
                            i+=1


                    # add value to data set
                    if key_name != "" and is_list == False:
                        new_val = _convert_type(value)
                        block_data[key_name] = new_val
                    if key_name != "" and is_list == True:
                        block_data[key_name] = value_list

        # Helper function to read in data
        def _read_file(data_file, data):
            for line in data_file:
                readable, sep, tail = line.partition('#')

                # If this character is present, it means
                #   we are starting a block
                if "[" in readable:
                    # grab first result of all text in brackets
                    res = re.findall(r'\[.*?\]', readable)[0]
                    # remove brackets (and other symbols) from result
                    key = re.sub(r"[\[\]\.\/]", "", res)
                    data[key] = {}
                    _read_block(data_file, data[key])
                # End if

        if path.exists(file_name):
            data_file = open(file_name,"r")
            _read_file(data_file, self.data)
            data_file.close()
        else:
            raise FileNotFoundError(errno.ENOENT, os.strerror(errno.ENOENT), file_name)

    # builds the stream that will be printed
    def build_stream(self, list_length=4):
        self.stream = ""
        # helper function for dealing with lists
        def _list_loop(data, level, max_length=4):
            liststream = "'"
            first = True
            len = 0
            for item in data:
                if first:
                    liststream += str(item)
                    first = False
                else:
                    if len >= max_length:
                        liststream +="\n"
                        for i in range(0,10*level):
                            liststream += " "
                        len = 0
                    liststream += " " + str(item)
                len +=1
            return liststream+"'"

        # helper function for dealing with sub-dicts
        def _sub_dict_loop(data, level):

            substream = "\n"
            spacing = ""
            level +=1
            first = True
            for item in data:
                if type(data[item]) == dict:
                    level +=1
                    if first:
                        for i in range(0,level):
                            spacing += " "
                        first = False
                    substream += spacing + "[./" + item + "]"
                    substream += _sub_dict_loop(data[item], level)
                    substream += spacing + "[../]\n"
                    level -=1
                else:
                    level +=1
                    if first:
                        for i in range(0,level):
                            spacing += " "
                        first = False
                    if isinstance(data[item], list):
                        substream += spacing + str(item) + " = " + _list_loop(data[item], level, max_length=list_length) +"\n"
                    else:
                        substream += spacing + str(item) + " = " + str(data[item]) +"\n"
                    level -=1

            return substream+""

        for key in self.data:
            # top of block
            self.level +=1
            self.stream += "[" + key +"]\n"

            # iterate through items in current dict
            first = True
            space = ""
            for item in self.data[key]:
                # determine if item is another dict
                if type(self.data[key][item]) == dict:
                    self.level +=1
                    space = ""
                    for i in range(0, self.level):
                        space += " "
                    self.stream += space + "[./" + item + "]"
                    self.stream += _sub_dict_loop(self.data[key][item], self.level)
                    self.stream += space + "[../]\n\n"
                    self.level -=1
                else:
                    self.level +=1
                    if first:
                        for i in range(0,self.level):
                            space += " "
                        first = False
                    if isinstance(self.data[key][item], list):
                        self.stream += space + str(item) + " = " + _list_loop(self.data[key][item], self.level, max_length=list_length) + "\n"
                    else:
                        self.stream += space + str(item) + " = " + str(self.data[key][item]) + "\n"
                    self.level -=1

            # end of block
            self.level -=1
            self.stream += "[]\n\n"

        # end of stream
        self.stream_built = True

    # checks the dictionary for invalid user options
    # # TODO: Complete validation of dict
    def validate_dict(self, raise_error=False):
        for key in self.data:
            if key not in valid_blocks:
                if raise_error:
                    raise TypeError("The given key: (" + key + ") does not appear in "
                                    "the list of valid blocks:\n {} ".format([p for p in valid_blocks]))
                else:
                    print("WARNGING!")
                    print("The given key: (" + key + ") does not appear in "
                                    "the list of valid blocks:\n {} ".format([p for p in valid_blocks]))

            if type(self.data[key]) != dict:
                raise TypeError("The data stored at the key (" + key + ") is not a dict!")

    # method to write the stream to an file for MOOSE/CATS to read
    def write_stream_to_file(self, file_name="", folder=""):
        if self.stream_built == False:
            self.build_stream()
        if file_name == "":
            file_name+="input"
        file_name+=".i"

        if folder != "":
            if folder[-1] != "/":
                folder += "/"
            if not os.path.exists(folder):
                os.makedirs(folder)

        file = open(folder+file_name,"w")
        file.write(self.stream)
        file.close()


if __name__ == "__main__":
    obj = CATS_InputFile()

    obj.construct_from_file("tests/test_input/input_file.i")
    print(obj.data["GlobalParams"])
    print(obj.data["Executioner"]["petsc_options_value"])
    print(obj.data["Outputs"]["print_linear_residuals"])
    obj.build_stream()
    print(obj.stream)
    obj.write_stream_to_file(file_name="test_in_to_out", folder="tests/test_output")
