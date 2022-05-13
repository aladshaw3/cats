'''
    This script will read MOOSE produced CSV files into a Pandas dataframe
    and allow the user to easily find values and interpolate values for the
    purpose of further post-processing of the information.

    Author:     Austin Ladshaw
    Date:       05/06/2022
    Copyright:  This kernel was designed and built at Oak Ridge National
                Laboratory by Austin Ladshaw for research in the area
                of adsorption, catalysis, and surface science.
'''
# import statements
import pandas
from bisect import bisect_left, bisect_right
from os import path
import sys, os
import errno

# Object to handle the data associated with MOOSE generated CSV files
class MOOSE_CVS_File(object):
    # Default constructor
    def __init__(self, file):
        if path.exists(file):
            self.df = pandas.read_csv(file)
        else:
            raise FileNotFoundError(errno.ENOENT, os.strerror(errno.ENOENT), file)

        self.valid_col_names = []
        for c in self.df:
            self.valid_col_names.append(c)
        if 'time' not in self.valid_col_names:
            raise IndexError("CSV file may be invalid or did not come from MOOSE simulation."
                            " Required to have a 'time' column.")
        self.num_rows = len(self.df['time'])


    # Read a new file into same object (override the previous)
    def read_new_file(self, file):
        if path.exists(file):
            self.df = pandas.read_csv(file)
        else:
            raise FileNotFoundError(errno.ENOENT, os.strerror(errno.ENOENT), file)

        self.valid_col_names = []
        for c in self.df:
            self.valid_col_names.append(c)
        if 'time' not in self.valid_col_names:
            raise IndexError("CSV file may be invalid or did not come from MOOSE simulation."
                            " Required to have a 'time' column.")
        self.num_rows = len(self.df['time'])

    # Return list of valid column names in df
    def column_names(self):
        return self.valid_col_names

    # Return value in df at given time (or closest value)
    def value(self, time, col):
        if col not in self.valid_col_names:
            raise IndexError("The given column name: (" + col + ") does not appear in "
                            "the list of valid names:\n {} ".format([p for p in self.valid_col_names]))

        # time is always sorted and unique, so use bisection to grab closest value
        idx = bisect_left(self.df['time'].values, time)

        # check edge cases
        if idx >= self.num_rows:
            return self.df[col][self.num_rows-1]
        if idx == 0:
            return self.df[col][idx]

        # all other cases are interior (look backwards for interpolation)
        time_next = self.df['time'][idx]
        time_old = self.df['time'][idx-1]
        slope = (self.df[col][idx]-self.df[col][idx-1])/(time_next-time_old)
        return slope*(time-time_old)+self.df[col][idx-1]


if __name__ == "__main__":
    file = "tests/test_input/input_file_out.csv"
    obj = MOOSE_CVS_File(file)
    print(obj.df)
    print(obj.value(0.1,'pressure_inlet'))

    obj.read_new_file("tests/test_input/input_file_out_2.csv")
    print(obj.df)
    print(obj.value(0.1,'pressure_inlet'))
