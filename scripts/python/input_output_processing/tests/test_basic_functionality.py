import sys
sys.path.append('../..')

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
        data = {"Outputs": {}}
        obj = CATS_InputFile(data, validate=True, raise_error=True)
        return obj

    @pytest.mark.unit
    def test_containers(self, basic_obj):
        obj = basic_obj
        assert hasattr(obj, 'data')
