import sys
sys.path.append('../..')

import os.path
from os import path

import pytest
from input_output_processing.cats_input_file_writer import *

# Start single tests
@pytest.mark.unit
def test_build_error():
    with pytest.raises(TypeError):
        data =5
        obj = CATS_InputFile(data)

@pytest.mark.unit
def test_validation_of_blocks_error():
    with pytest.raises(TypeError):
        data = {"BadKey": "blah"}
        obj = CATS_InputFile(data, validate=True, raise_error=True)

@pytest.mark.unit
def test_validation_of_data_in_blocks():
    with pytest.raises(TypeError):
        data = {"Outputs": "bad-data"}
        obj = CATS_InputFile(data, validate=True, raise_error=True)

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
        obj = CATS_InputFile(data, validate=True, raise_error=True, build_stream=False)
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
