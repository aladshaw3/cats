## Python script to unv files and apply changes ##
## Run python scripts using Python 3.5 or newer ##

''' unv conversion script:
    ----------------
    Object-Oriented approach to reading unv files produced from Gmsh and converting
    the format to what MOOSE is expecting. When using Gmsh, you need to do the following:
    (i) Create groups for named boundaries in Gmsh under Geometry --> Physical Groups --> Surfaces
    (ii) Export mesh as .unv file saving all elements and groups
    (iii) This script will convert all FE ids of 21 with FE ids of 11 (2nd column of elements block)
    (iv) Replace the Groups tag of 2477 with tag of 2467
    (v) Remove any boundary types in Groups that are NOT type 8 (must also change number of items)
    
    Elements Group Descriptor ID = 2412 (fe ids of 24, 23, 22, 21 --> change to 11)
    -----------------------------------
    Record 1:        FORMAT(6I10)
                    Field 1       -- element label
                    Field 2       -- fe descriptor id (##### THIS IS WHAT WE CHANGE #####)
                    Field 3       -- physical property table number
                    Field 4       -- material property table number
                    Field 5       -- color
                    Field 6       -- number of nodes on element
    Record 2:  *** FOR NON-BEAM ELEMENTS ***
                    FORMAT(8I10)
                    Fields 1-n    -- node labels defining element
    Record 2:  *** FOR BEAM ELEMENTS ONLY ***
                    FORMAT(3I10)
                    Field 1       -- beam orientation node number
                    Field 2       -- beam fore-end cross section number
                    Field 3       -- beam  aft-end cross section number
    Record 3:  *** FOR BEAM ELEMENTS ONLY ***
                    FORMAT(8I10)
                    Fields 1-n    -- node labels defining element
                    Records 1 and 2 are repeated for each non-beam element in the model.
                    Records 1 - 3 are repeated for each beam element in the model.
                    
    Example:
                -1
                2412
                    1        11         1      5380         7         2
                    0         1         1
                    1         2
                    2       *21*        2      5380         7         2
                    0         1         1
                    3         4
                    3       *22*        3      5380         7         2
                    0         1         2
                    5         6
                    6        91         6      5380         7         3
                    11        18        12
                    9        95         6      5380         7         8
                    22        25        29        30        31        26        24        23
                    14       136         8         0         7         2
                    53        54
                    36       116        16      5380         7        20
                    152       159       168       167       166       158       150       151
                    154       170       169       153       157       161       173       172
                    171       160       155       156
                -1
                
    Groups Group Descriptor ID = 2477 (change to 2467)
    -----------------------------------
    Record 1:        FORMAT(8I10)
                    Field 1       -- group number
                    Field 2       -- active constraint set no. for group
                    Field 3       -- active restraint set no. for group
                    Field 4       -- active load set no. for group
                    Field 5       -- active dof set no. for group
                    Field 6       -- active temperature set no. for group
                    Field 7       -- active contact set no. for group
                    Field 8       -- number of entities in group        (#### Update this value ####)
    
    Record 2:        FORMAT(20A2)
                    Field 1       -- group name
    
    Record 3-N:      FORMAT(8I10)
                    Field 1       -- entity type code     (#### Remove all types that are NOT 8 ####)
                    Field 2       -- entity tag
                    Field 3       -- entity node leaf id.
                    Field 4       -- entity component/ ham id.
                    Field 5       -- entity type code     (#### Above Repeats on this line ####)
                    Field 6       -- entity tag
                    Field 7       -- entity node leaf id.
                    Field 8       -- entity component/ ham id.
    
    Repeat record 3 for all entities as defined by record 1, field 8.
    Records 1 thru n are repeated for each group in the model.
    Entity node leaf id. and the component/ ham id. are zero for all
    entities except "reference point", "reference point series"
    and "coordinate system".
    
    Example:
        ORIGINAL
        -1
        2477
            1         0         0         0         0         0         0         3
        Group1
            1         1         2         1         7         1         0         0
            8        38         0         0
        -1
        
        CONVERTED
        -1
        2477
            1         0         0         0         0         0         0         1
        Group1
            8        38         0         0
        -1
    
    Author:     Austin Ladshaw
    Date:       05/22/2019
    Copyright:  This software was designed and built at the Georgia Institute
                of Technology by Austin Ladshaw for research in the area of
                radioactive particle decay and transport. Copyright (c) 2019,
                all rights reserved.
'''

import sys

class UNV_Conversion(object):
    def __init__(self):
        self.og_map = {}
        self.co_map = {}
        self.og_name = ""
        self.co_name = ""

    def __str__(self):
        ### Nodes ###
        string = "    -1\n"
        string += "  " + "2411\n"
        #Loop through lines in 2411
        for line in self.co_map["2411"]:
            string += line
        string += "    -1\n"

        ### Elements ###
        string += "    -1\n"
        string += "  " + "2412\n"
        #Loop through lines in 2412
        for line in self.co_map["2412"]:
            string += line
        string += "    -1\n"

        ### Groups ###
        string += "    -1\n"
        string += "  " + "2467\n"
        #Loop through lines in 2477 - for og_map
        for group in self.co_map["2467"]:
            for line in self.co_map["2467"][group]:
                string += line
        string += "    -1\n"

        return string

    def convertFile(self, file):
        self.og_name = file
        if file.split(".")[1] != "unv":
            print("Error!!!\nUnexpected file type...\n")
            return
        self.co_name = file.split(".")[0] + "-Converted.unv"
        start_section = False
        in_nodes = False
        in_elems = False
        in_groups = False
        group_name = ""
        group_items = 0
        valid_group_items = []
        cur_item = -1
        group_num = 0
        elem_line = 0
        elem_max_lines = 0
        isBeam = False
        type = 0
        for line in open(file,"r"):
            line_list = line.split()
            #Check for start of section, name of section, or name of group
            if len(line_list) == 1:
                if line_list[0] == "-1" and start_section == False:
                    start_section = True
                elif line_list[0] == "-1" and start_section == True:
                    start_section = False
                elif line_list[0] == "2411" and start_section == True:
                    in_nodes = True
                    in_elems = False
                    in_groups = False
                    self.og_map["2411"] = []
                    self.co_map["2411"] = []
                elif line_list[0] == "2412" and start_section == True:
                    in_nodes = False
                    in_elems = True
                    in_groups = False
                    self.og_map["2412"] = []
                    self.co_map["2412"] = []
                elif line_list[0] == "2477" and start_section == True:
                    in_nodes = False
                    in_elems = False
                    in_groups = True
                    self.og_map["2477"] = {}
                    self.co_map["2467"] = {}
                else:
                    if in_groups == True:
                        group_name = line_list[0]
                        self.og_map["2477"][str(group_num)].append(line)
                        self.co_map["2467"][str(group_num)].append(line)
            else:
                #Perform actions based on where we are in input file
                if in_nodes == True:
                    # No changes to input file under the Nodes section
                    self.og_map["2411"].append(line)
                    self.co_map["2411"].append(line)
                if in_elems == True:
                    self.og_map["2412"].append(line)
                    new_line = ""
                    
                    #Figure out the type of element
                    if elem_line == 0:
                        type = int(line.split()[1])
                        #print(line)
                        if type == 11 or type == 21 or type == 22 or type == 23 or type == 24:
                            isBeam = True
                            elem_max_lines = 3
                        else:
                            isBeam = False
                            elem_max_lines = 2
                        #Change type if needed
                        if type == 21 or type == 22 or type == 23 or type == 24:
                            type = 11
                        
                        #Check for issues
                        if type != 11 and type !=41 and type != 91 and type != 42 and type != 92 and type != 44 and type != 94 and type != 45 and type != 95 and type != 300 and type != 111 and type != 112 and type != 115 and type != 116 and type != 118:
                            print("\nPotential Type Error Detected in Conversion!!!\n")
    
                        #Replace line with new_line
                        swap_size = len(line.split()[1])
                        new_size = len(str(type))
                        if swap_size == new_size:
                            new_line += line[0:20-swap_size] + str(type) + line[20:]
                        elif swap_size > new_size:
                            add_spaces = swap_size - new_size
                            new_line += line[0:20-swap_size]
                            for j in range(add_spaces):
                                new_line += " "
                            new_line += str(type) + line[20:]
                        else:
                            remove_spaces = new_size - swap_size
                            new_line += line[0:20-swap_size-remove_spaces] + str(type) + line[20:]
                        self.co_map["2412"].append(new_line)
                    else:
                        self.co_map["2412"].append(line)
                
                    if elem_line != elem_max_lines-1:
                        elem_line += 1
                    else:
                        elem_line = 0
                if in_groups == True:
                    #Check groups
                    if cur_item == -1:
                        group_items = int(line_list[len(line_list)-1])
                        valid_group_items.append(0)
                        self.og_map["2477"][str(group_num)] = []
                        self.co_map["2467"][str(group_num)] = []
                        #First line of new group
                        self.og_map["2477"][str(group_num)].append(line)
                        self.co_map["2467"][str(group_num)].append(line)
                        cur_item += 1
                    else:
                        cur_item += int(len(line_list)/4)
                        #Each data line of a group
                        self.og_map["2477"][str(group_num)].append(line)
                        if (line_list[0] == "8"):
                            self.co_map["2467"][str(group_num)].append(line)
                            valid_group_items[group_num] += int(len(line_list)/4)
                        if cur_item == group_items:
                            cur_item = -1
                            group_num += 1
        #End For Loop for lines in file
        
        #Fix the group_items value on first line of each group
        i = 0
        for group in self.co_map["2467"]:
            line = self.co_map["2467"][group][0]
            swap_size = len(line.split()[7])
            new_size = len(str(valid_group_items[i]))
            new_line = ""
            if swap_size == new_size:
                new_line += line[:-(swap_size+1)] + str(valid_group_items[i])
            elif swap_size > new_size:
                add_spaces = swap_size - new_size
                new_line += line[:-(swap_size+1)]
                for j in range(add_spaces):
                    new_line += " "
                new_line += str(valid_group_items[i])
            else:
                remove_spaces = new_size - swap_size
                new_line += line[:-(swap_size+1+remove_spaces)] + str(valid_group_items[i])
            self.co_map["2467"][group][0] = new_line +"\n"
            i += 1

        #Print new converted data to a file
        file_out = open(self.co_name, 'w')
        info = str(self)
        file_out.write(info)
        file_out.close()



### Running the script ###
'''
    To run this script and convert a given file, pass the 
    file name to convert as the second argument when calling
    the script from command line.
    
    e.g., bash:  python3 unv-converter.py Box-Valley.unv
    
    The script will read in the given file and write out the
    converted form of that file with the sub-name "-Converted.unv"
'''


if len(sys.argv) == 2:
    convert = UNV_Conversion()
    convert.convertFile(sys.argv[1])
