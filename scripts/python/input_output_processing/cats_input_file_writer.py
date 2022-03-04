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

# Object to handle the data associated with CATS input files
class CATS_InputFile(object):
    # Default constructor
    #   User MUST provide a dictionary object that contains the
    #   MOOSE control file inputs
    def __init__(self, user_dict, validate=False,
                                  raise_error=False,
                                  build_stream=False):
        if type(user_dict) != dict:
            raise TypeError("Given arg 'user_dict' is not a dict object!")
        self.data = user_dict   #Dictionary of data
        self.stream = ""        #String stream to output as file
        self.level = 0          #tracker for the level of dict

        if validate:
            self.validate_dict(raise_error=raise_error)

        if build_stream:
            self.build_stream()

    # builds the stream that will be printed
    def build_stream(self):
        # helper function for dealing with lists
        def _list_loop(data, level, max_length=5):
            liststream = "'"
            first = True
            len = 0
            for item in data:
                if first:
                    liststream += item
                    first = False
                else:
                    if len >= max_length:
                        liststream +="\n"
                        for i in range(0,10*level):
                            liststream += " "
                        len = 0
                    liststream += " " + item
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
                    for i in range(0,level):
                        spacing += " "
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
                        substream += spacing + item + " = " + _list_loop(data[item], level) +"\n"
                    else:
                        substream += spacing + item + " = " + str(data[item]) +"\n"
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
                        self.stream += space + item + " = " + _list_loop(self.data[key][item], self.level) + "\n"
                    else:
                        self.stream += space + item + " = " + str(self.data[key][item]) + "\n"
                    self.level -=1

            # end of block
            self.level -=1
            self.stream += "[]\n\n"

    # checks the dictionary for invalid user options
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


if __name__ == "__main__":
    data = {"Mesh":
                {"type": "GeneratedMesh",
                 "dim": 2,
                 "nx": 10,
                 "ny": 10},
            "Variables":
                {"u":
                    {"InitialCondition":
                        {"type": "ConstantIC",
                         "value": 0}
                    }
                },
            "Kernels":
                {"diff":
                    {"type": "Diffusion",
                     "variable": "u"}
                },
            "BCs":
                {"left":
                    {"type": "DirichletBC",
                     "variable": "u",
                     "boundary": "left",
                     "value": 0},
                "right":
                    {"type": "DirichletBC",
                     "variable": "u",
                     "boundary": "right",
                     "value": 1}
                },
            "Executioner":
                {"type": "Steady",
                 "solve_type": "pjfnk",
                 "petsc_options_iname": ['-pc_type', '-pc_hypre_type'],
                 "petsc_options_value": ['hypre', 'boomeramg'],
                },
            "Outputs":
                {"exodus": True}
            }
    obj = CATS_InputFile(data, validate=True, raise_error=True, build_stream=True)
    print(obj.stream)
