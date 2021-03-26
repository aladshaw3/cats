from isothermal_monolith_catalysis import *

# Create a simulator object and Load a full model from json
test = Isothermal_Monolith_Simulator()
test.load_model_state_as_IC('output/example.json', new_time_window=(60,80), tstep=20)
