import sys
sys.path.append('../..')

import os.path
from os import path

import pytest
from input_output_processing.cats_input_file_writer import *
from input_output_processing.read_moose_csv_to_df import *

# Start single tests
@pytest.mark.unit
def test_build_error():
    with pytest.raises(TypeError):
        data = 5
        obj = CATS_InputFile()
        obj.construct_from_dict(data)

@pytest.mark.unit
def test_validation_of_blocks_error():
    with pytest.raises(TypeError):
        data = {"BadKey": "blah"}
        obj = CATS_InputFile()
        obj.construct_from_dict(data, validate=True, raise_error=True)

@pytest.mark.unit
def test_validation_of_data_in_blocks():
    with pytest.raises(TypeError):
        data = {"Outputs": "bad-data"}
        obj = CATS_InputFile()
        obj.construct_from_dict(data, validate=True, raise_error=True)

# Start test class for functionality
class TestBasicFunctionality():
    @pytest.fixture(scope="class")
    def basic_obj(self):
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
        obj = CATS_InputFile()
        obj.construct_from_dict(data, validate=True, raise_error=True, build_stream=False)
        return obj

    @pytest.mark.unit
    def test_containers(self, basic_obj):
        obj = basic_obj
        assert hasattr(obj, 'data')
        assert hasattr(obj, 'stream')

        assert obj.stream_built == False
        obj.build_stream()
        assert "[Outputs]\n  exodus = True" in obj.stream

    @pytest.mark.unit
    def test_output(self, basic_obj):
        obj = basic_obj
        obj.write_stream_to_file(file_name="test", folder="test_output")

        assert path.exists("test_output/test.i") == True

# Start test class for file reading functionality
class TestBasicFileReadingFunctionality():
    @pytest.fixture(scope="class")
    def file_obj(self):
        obj = CATS_InputFile()
        obj.construct_from_file("test_input/input_file.i")
        return obj

    @pytest.mark.unit
    def test_dict_container(self, file_obj):
        obj = file_obj
        assert hasattr(obj, 'data')

        assert 'GlobalParams' in obj.data
        assert type(obj.data['GlobalParams']) == dict
        assert 'sigma' in obj.data['GlobalParams']
        assert type(obj.data['GlobalParams']['sigma']) == int

        assert 'BCs' in obj.data
        assert type(obj.data['BCs']) == dict
        assert 'press_at_exit' in obj.data['BCs']
        assert type(obj.data['BCs']['press_at_exit']) == dict
        assert 'boundary' in obj.data['BCs']['press_at_exit']
        assert type(obj.data['BCs']['press_at_exit']['boundary']) == list
        assert len(obj.data['BCs']['press_at_exit']['boundary']) == 1
        assert 'value' in obj.data['BCs']['press_at_exit']
        assert type(obj.data['BCs']['press_at_exit']['value']) == float

        assert 'Executioner' in obj.data
        assert type(obj.data['Executioner']) == dict
        assert 'petsc_options_iname' in obj.data['Executioner']
        assert 'petsc_options_value' in obj.data['Executioner']
        assert type(obj.data['Executioner']['petsc_options_iname']) == list
        assert type(obj.data['Executioner']['petsc_options_value']) == list
        assert len(obj.data['Executioner']['petsc_options_iname']) == \
            len(obj.data['Executioner']['petsc_options_value']) == 12

    @pytest.mark.unit
    def test_output_again(self, file_obj):
        obj = file_obj
        obj.write_stream_to_file(file_name="test_in_to_out", folder="test_output")

        assert path.exists("test_output/test_in_to_out.i") == True


# Start test class for csv functions
class TestCSVfileReader():
    @pytest.fixture(scope="class")
    def csv_obj(self):
        obj = MOOSE_CVS_File("test_input/input_file_out.csv")
        return obj

    @pytest.mark.unit
    def test_csv_obj_contents(self, csv_obj):
        obj = csv_obj
        assert hasattr(obj, 'df')
        assert hasattr(obj, 'valid_col_names')
        assert hasattr(obj, 'num_rows')

        assert type(obj.valid_col_names) == list
        assert obj.num_rows == 41

    @pytest.mark.unit
    def test_csv_obj_funcs(self, csv_obj):
        obj = csv_obj

        assert len(obj.column_names()) == 8

        obj.read_new_file("test_input/input_file_out_2.csv")
        assert obj.num_rows == 11

        assert obj.value(0,'pressure_inlet') == 0
        assert obj.value(-1,'pressure_inlet') == 0
        assert obj.value(100,'pressure_inlet') == 13

        assert obj.value(0.1,'pressure_inlet') == 2.6
        assert obj.value(0.12,'pressure_inlet') == 3.12
