
# This example demonstrates how to create simulations of a packed-bed
#   including intraparticle diffusion using our hybrid FD/FE element
#   approach. This method seeks to resolve intraparticle concentration
#   gradients using a semi-discrete finite differences discretization
#   of the microscale and a fully discretized finite elements mesh in
#   a 2D column packed with spherical particles.
#
# The reaction system we are modeling is isothermal, reversible adsorption.
#   From this simple example, users should be able to work out how to add
#   more complexity piece-by-piece (e.g., adding more gas species, adding
#   more reactions, adding more adsorption sites, etc).
#
# All physical properties are calculated using the 'SimpleGas' auxiliary
#   system. With this paradigm, users only need to provide some very basic
#   properties and then correctly coupled the estimated terms inside of
#   each other kernel.

[GlobalParams]
  # 'dg_scheme' and 'sigma' are parameters for the DG kernels
  dg_scheme = nipg
  sigma = 10

  # Radius of the spherical particles in the packed bed
  #   MS3A pellets with radius of 1.2 mm
  micro_length = 0.12  # in cm

  # Final setup for the Microscale is done by specifying the number of nodes
  #   for the microscale, and the coord_id number.
  num_nodes = 5
  coord_id = 2  #0 ==> washcoat (1=cylindrical particles, 2=spherical particles)
[] #END GlobalParams

[Problem]
    coord_type = RZ
    #NOTE: For RZ coordinates, x ==> R and y ==> Z (and z ==> nothing)
[] #END Problem

[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = 3
    ny = 10
    xmin = 0.0
    xmax = 1.0    #2cm diameter (1cm radius)
    ymin = 0.0
    ymax = 5.0    #5cm length
[] # END Mesh

[Variables]

## Gas phase variable lists (mol/L unit basis)
    [./H2O]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    # To solve the diffusion in the particle requires the
    #   user to define a 'nodal' variable for every point
    #   in the microscale (e.g., we specified 5 nodes, thus
    #   there will be 5 variables in the microscale).
    # We denote these variables as *_n where n is the corresponding
    #   node number. Node 0 is the inner most node and node 4
    #   is the outer most node (i.e., node at the interface between
    #   the particle and the bulk void space).
    # 5 interior nodes inside the washcoat
    [./H2Op_0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./H2Op_1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./H2Op_2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./H2Op_3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./H2Op_4]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    # Since we are doing adsorption, we also want to add microscale
    #   variables for the surface concentrations (mol/kg unit basis).
    #   We set the initial conditions to zero here to represent adsorbents
    #   that are initially empty.
    [./q_0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./q_1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./q_2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./q_3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./q_4]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    # We will also need variables for the available adsorption sites
    #   within the microscale particles. Here, we will also set initial
    #   conditions here to the theoretical maximum amount of free sites
    #   for water to bind to (11.7 mol/kg of open sites).
    [./S_0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 11.7
    [../]
    [./S_1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 11.7
    [../]
    [./S_2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 11.7
    [../]
    [./S_3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 11.7
    [../]
    [./S_4]
        order = FIRST
        family = MONOMIAL
        initial_condition = 11.7
    [../]


    # Just like with primary variables (i.e., gas-species and surface-species)
    #   we must also create variables for reaction rates at all nodes
    #   in the microscale domain. This is because each reaction variable
    #   must be coupled with the concentrations that are local within
    #   that microscale domain.
    #
    # NOTE: In this example, we are using the MicroscaleScaledWeightedCoupledSumFunction
    #   for adding up reaction terms and using the solids fraction (1-e_b) as the
    #   scaling factor. This means that our full mass balance is on a total volume
    #   basis and our reaction terms are on a solids volume basis (i.e., the units
    #   of each 'r_n' term is in moles per volume of particles per time).

    ## Reaction variable list
    # 5 interior nodes inside the particle
    [./r_0]
        order = FIRST
        family = MONOMIAL
    [../]
    [./r_1]
        order = FIRST
        family = MONOMIAL
    [../]
    [./r_2]
        order = FIRST
        family = MONOMIAL
    [../]
    [./r_3]
        order = FIRST
        family = MONOMIAL
    [../]
    [./r_4]
        order = FIRST
        family = MONOMIAL
    [../]

[] #END Variables

# Here we are adding aux variables where some calculations
#   for system parameters and properties will be made.
[AuxVariables]

  [./temp]
      order = FIRST
      family = MONOMIAL
      initial_condition = 298  # in K
  [../]

  [./press]
      order = FIRST
      family = MONOMIAL
      initial_condition = 101.35  # in kPa
  [../]

  # dispersion coefficient - calculated in properties
  [./Disp]
    order = FIRST
    family = MONOMIAL
  [../]

  # e_b (bulk porosity) - calculated in properties
  [./pore]
      order = FIRST
      family = MONOMIAL
  [../]

  # non_pore = (1 - e_b) - calculated in properties
  [./non_pore]
      order = FIRST
      family = MONOMIAL
  [../]

  # e_p value (particle porosity)
  [./micro_pore]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.4
  [../]

  # total_pore = e_p* (1 - e_b) - auto calculated in properties
  [./total_pore]
      order = FIRST
      family = MONOMIAL
  [../]

  # area to volume ratio for spherical particles - calculated in properties
  [./Ga]
      order = FIRST
      family = MONOMIAL
  [../]

  # hydraulic diameter for spherical particles
  [./dh]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.12  # in cm
  [../]

  # Mass transfer coefficient - calculated in properties
  [./km]
      order = FIRST
      family = MONOMIAL
  [../]

  # Effective pore diffusion - calculated in properties
  #   This is pore diffusivity as Deff = e_p*(1-e_b)*Dp
  [./Deff]
      order = FIRST
      family = MONOMIAL
  [../]

  # We are assuming an average linear velocity in the axial
  #   direction, so other velocities are set to 0
  [./vel_x]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

  # Effective average linear velocity is calculated from the
  #   reactor size and the gas-hourly space-velocity (which here
  #   is given in per minutes instead of per hour).
  [./vel_y]
      order = FIRST
      family = MONOMIAL
  [../]

  # We are assuming an average linear velocity in the axial
  #   direction, so other velocities are set to 0
  [./vel_z]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

  # Auxilary kernels to keep track of average adsorbed concentrations
  #   and average open sites.
  [./qAvg]
      order = FIRST
      family = MONOMIAL
  [../]
  [./SAvg]
      order = FIRST
      family = MONOMIAL
  [../]
  [./H2OpAvg]
      order = FIRST
      family = MONOMIAL
  [../]

[] #END AuxVariables

[Kernels]
# ------------------- Start Gas Balances ----------------------
# -------------------------------------------------------------
    # =============== Bulk phase H2O ===============
    [./H2O_dot]
        type = VariableCoefTimeDerivative
        variable = H2O
        coupled_coef = pore
    [../]
    [./H2O_gadv]
        type = GPoreConcAdvection
        variable = H2O
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./H2O_gdiff]
        type = GVarPoreDiffusion
        variable = H2O
        porosity = pore
        Dx = Disp
        Dy = Disp
        Dz = Disp
    [../]
    [./H2Op_trans]
        type = FilmMassTransfer
        variable = H2O
        coupled = H2Op_4   # couples at outer most node of microscale

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]

    # =============== Particle pore phase H2O ===============
    # Exterior node
    [./H2Op_4_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = H2Op_4
        nodal_time_var = total_pore
        node_id = 4
    [../]
    [./H2Op_4_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = H2Op_4
        node_id = 4
        macro_variable = H2O     #Couple with the macroscale variable here
        lower_neighbor = H2Op_3
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    [./H2Op_4_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = H2Op_4
        node_id = 4
        coupled_list = 'r_4'
        # Reaction: H2O + S <--> q
        #   Every time this occurs, 1 mole of H2O is removed
        #   Thus, the 'weight' for r is -1.
        weights = '-1'
        scale = 1
    [../]

    # Interior node 3
    [./H2Op_3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = H2Op_3
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./H2Op_3_diff]
        type = MicroscaleVariableDiffusion
        variable = H2Op_3
        node_id = 3
        upper_neighbor = H2Op_4
        lower_neighbor = H2Op_2
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./H2Op_3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = H2Op_3
        node_id = 3
        coupled_list = 'r_3'
        # Reaction: H2O + S <--> q
        #   Every time this occurs, 1 mole of H2O is removed
        #   Thus, the 'weight' for r is -1.
        weights = '-1'
        scale = 1
    [../]

    # Interior node 2
    [./H2Op_2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = H2Op_2
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./H2Op_2_diff]
        type = MicroscaleVariableDiffusion
        variable = H2Op_2
        node_id = 2
        upper_neighbor = H2Op_3
        lower_neighbor = H2Op_1
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./H2Op_2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = H2Op_2
        node_id = 2
        coupled_list = 'r_2'
        # Reaction: H2O + S <--> q
        #   Every time this occurs, 1 mole of H2O is removed
        #   Thus, the 'weight' for r is -1.
        weights = '-1'
        scale = 1
    [../]

    # Interior node 1
    [./H2Op_1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = H2Op_1
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./H2Op_1_diff]
        type = MicroscaleVariableDiffusion
        variable = H2Op_1
        node_id = 1
        upper_neighbor = H2Op_2
        lower_neighbor = H2Op_0
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./H2Op_1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = H2Op_1
        node_id = 1
        coupled_list = 'r_1'
        # Reaction: H2O + S <--> q
        #   Every time this occurs, 1 mole of H2O is removed
        #   Thus, the 'weight' for r is -1.
        weights = '-1'
        scale = 1
    [../]

    # Interior node 0 : BC
    [./H2Op_0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = H2Op_0
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./H2Op_0_diff]
        type = MicroscaleVariableDiffusionInnerBC
        variable = H2Op_0
        node_id = 0
        upper_neighbor = H2Op_1
        current_diff = Deff
        upper_diff = Deff
    [../]
    [./H2Op_0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = H2Op_0
        node_id = 0
        coupled_list = 'r_0'
        # Reaction: H2O + S <--> q
        #   Every time this occurs, 1 mole of H2O is removed
        #   Thus, the 'weight' for r is -1.
        weights = '-1'
        scale = 1
    [../]

# ------------------- Start Reactions ----------------------
# -------------------------------------------------------------

## ======= H2O adsorption rates ======
#   NOTE: The units on the forward_pre_exponential term
#         are whatever units that make the full model work
#         out. Since r needs units of mol/L/min, and H2O is
#         in mol/L and S is in mol/kg, then this pre_exponential
#         term must have units of kg/mol/min.
#
#   If you want your material balance to be on a different unit
#       basis, then that changes what units your pre_exponential
#       ends up as. If you have existing pre_exponentials in a
#       given unit set, then you need to first perform a unit
#       conversion, or change how your overall mass balance is
#       setup.

    # Reaction: H2O + S <--> q   @ node 4
    [./r_4_val]
        type = Reaction
        variable = r_4
    [../]
    [./r_4_rx]
      type = ArrheniusEquilibriumReaction
      variable = r_4
      this_variable = r_4

      forward_activation_energy = 0      #J/mol
      forward_pre_exponential = 2500  #kg/mol/min
      enthalpy = -32000  #J/mol
      entropy = -25      #J/K/mol

      temperature = temp
      scale = 1.0
      reactants = 'H2Op_4 S_4'
      reactant_stoich = '1 1'
      products = 'q_4'
      product_stoich = '1'
    [../]

    # Reaction: H2O + S <--> q   @ node 3
    [./r_3_val]
        type = Reaction
        variable = r_3
    [../]
    [./r_3_rx]
      type = ArrheniusEquilibriumReaction
      variable = r_3
      this_variable = r_3

      forward_activation_energy = 0      #J/mol
      forward_pre_exponential = 2500  #kg/mol/min
      enthalpy = -32000  #J/mol
      entropy = -25      #J/K/mol

      temperature = temp
      scale = 1.0
      reactants = 'H2Op_3 S_3'
      reactant_stoich = '1 1'
      products = 'q_3'
      product_stoich = '1'
    [../]

    # Reaction: H2O + S <--> q   @ node 2
    [./r_2_val]
        type = Reaction
        variable = r_2
    [../]
    [./r_2_rx]
      type = ArrheniusEquilibriumReaction
      variable = r_2
      this_variable = r_2

      forward_activation_energy = 0      #J/mol
      forward_pre_exponential = 2500  #kg/mol/min
      enthalpy = -32000  #J/mol
      entropy = -25      #J/K/mol

      temperature = temp
      scale = 1.0
      reactants = 'H2Op_2 S_2'
      reactant_stoich = '1 1'
      products = 'q_2'
      product_stoich = '1'
    [../]

    # Reaction: H2O + S <--> q   @ node 1
    [./r_1_val]
        type = Reaction
        variable = r_1
    [../]
    [./r_1_rx]
      type = ArrheniusEquilibriumReaction
      variable = r_1
      this_variable = r_1

      forward_activation_energy = 0      #J/mol
      forward_pre_exponential = 2500  #kg/mol/min
      enthalpy = -32000  #J/mol
      entropy = -25      #J/K/mol

      temperature = temp
      scale = 1.0
      reactants = 'H2Op_1 S_1'
      reactant_stoich = '1 1'
      products = 'q_1'
      product_stoich = '1'
    [../]

    # Reaction: H2O + S <--> q   @ node 0
    [./r_0_val]
        type = Reaction
        variable = r_0
    [../]
    [./r_0_rx]
      type = ArrheniusEquilibriumReaction
      variable = r_0
      this_variable = r_0

      forward_activation_energy = 0      #J/mol
      forward_pre_exponential = 2500  #kg/mol/min
      enthalpy = -32000  #J/mol
      entropy = -25      #J/K/mol

      temperature = temp
      scale = 1.0
      reactants = 'H2Op_0 S_0'
      reactant_stoich = '1 1'
      products = 'q_0'
      product_stoich = '1'
    [../]

# ------------------- ODEs for Sites and Surface Species ----------------------
# -----------------------------------------------------------------------------
# Our adsorbed amount (q) and remaining surface species (S) can be resolved
#   using ODEs that represent their rates of change.
#
# # Reaction: H2O + S <--> q
#
#   dq/dt = r   && dS/dt = -r
#
#     (i.e., everytime the reaction occurs, we form 1 mole of q
#           and consume 1 mole of S).
#     We can use the WeightedCoupledSumFunction to represent
#       each as a weighted sum of r terms at every node in the microscale.

    # ODEs for q
    [./q_4_dot]
        type = TimeDerivative
        variable = q_4
    [../]
    [./q_4_rate]
        type = WeightedCoupledSumFunction
        variable = q_4
        coupled_list = 'r_4'
        weights = '1'
    [../]

    [./q_3_dot]
        type = TimeDerivative
        variable = q_3
    [../]
    [./q_3_rate]
        type = WeightedCoupledSumFunction
        variable = q_3
        coupled_list = 'r_3'
        weights = '1'
    [../]

    [./q_2_dot]
        type = TimeDerivative
        variable = q_2
    [../]
    [./q_2_rate]
        type = WeightedCoupledSumFunction
        variable = q_2
        coupled_list = 'r_2'
        weights = '1'
    [../]

    [./q_1_dot]
        type = TimeDerivative
        variable = q_1
    [../]
    [./q_1_rate]
        type = WeightedCoupledSumFunction
        variable = q_1
        coupled_list = 'r_1'
        weights = '1'
    [../]

    [./q_0_dot]
        type = TimeDerivative
        variable = q_0
    [../]
    [./q_0_rate]
        type = WeightedCoupledSumFunction
        variable = q_0
        coupled_list = 'r_0'
        weights = '1'
    [../]

    # ODEs for S
    [./S_4_dot]
        type = TimeDerivative
        variable = S_4
    [../]
    [./S_4_rate]
        type = WeightedCoupledSumFunction
        variable = S_4
        coupled_list = 'r_4'
        weights = '-1'
    [../]

    [./S_3_dot]
        type = TimeDerivative
        variable = S_3
    [../]
    [./S_3_rate]
        type = WeightedCoupledSumFunction
        variable = S_3
        coupled_list = 'r_3'
        weights = '-1'
    [../]

    [./S_2_dot]
        type = TimeDerivative
        variable = S_2
    [../]
    [./S_2_rate]
        type = WeightedCoupledSumFunction
        variable = S_2
        coupled_list = 'r_2'
        weights = '-1'
    [../]

    [./S_1_dot]
        type = TimeDerivative
        variable = S_1
    [../]
    [./S_1_rate]
        type = WeightedCoupledSumFunction
        variable = S_1
        coupled_list = 'r_1'
        weights = '-1'
    [../]

    [./S_0_dot]
        type = TimeDerivative
        variable = S_0
    [../]
    [./S_0_rate]
        type = WeightedCoupledSumFunction
        variable = S_0
        coupled_list = 'r_0'
        weights = '-1'
    [../]

[] #END Kernels


[DGKernels]

    # =========== H2O DG kernels ===========
    [./H2O_dgadv]
        type = DGPoreConcAdvection
        variable = H2O
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./H2O_dgdiff]
        type = DGVarPoreDiffusion
        variable = H2O
        porosity = pore
        Dx = Disp
        Dy = Disp
        Dz = Disp
    [../]

[] #END DGKernels

# The AuxKernels are where all the properties are calculated that
#   get used in the other kernels above.
[AuxKernels]

    # The system is assumed isothermal, but after we adsorb water,
    #   we are going to raise the temperature to perform a Temperature
    #   Programmed Desorption (TPD). To simulate this, we can use
    #   the following aux kernel to linearly raise the temperature
    #   at a specified start and end time up to a specified level.
    [./temp_increase]
        type = LinearChangeInTime
        variable = temp
        start_time = 350   # time at which we start ramping (in min)
        end_time = 850    # time at which we reach 500 K (in min)
        end_value = 500   # final temp in K
        execute_on = 'initial timestep_end'
    [../]

    # If we do not know our fixed-bed porosity, we can estimate this
    #   value from our average particle size, the average mass of a
    #   particle, and the bulk packing density of the bed. This kernel
    #   will also check your estimated porosity and report a warning
    #   if the value calculated is unreasonable and automatically revert
    #   to a theoretical max or min value. This reversion of the value
    #   to a max or min can be overriden. Pay close attention to any
    #   messages that this kernel prints.
    [./pore_calc]
        type = VoidsVolumeFraction
        variable = pore
        particle_diameter = 0.12    #cm
        particle_mass = 0.0015      #g
        packing_density = 0.8       #g/cm^3
        execute_on = 'initial timestep_end'
    [../]

    # There are other ways to calculate average linear velocity, but
    #   in this demo, we will calculate it using the 'space_velocity'
    #   parameter, which is the standard volume of gas per material
    #   volume per unit time. Then, the velocity is also adjusted
    #   to match an equivalent volume of gas at the specified
    #   temperature and pressure.
    #
    # NOTE: This is most commonly used in catalysis, where it is
    #   volumes of material per hour. In the case of fixed-beds,
    #   it may make more sense to calculate this using the AuxAvgLinearVelocity
    #   auxiliary kernel, where you provide a true volumetric flow rate, reactor
    #   size, and porosity. However, that kernel does not currently update with
    #   temperature.
    [./velocity]
        # NOTE: velocity must use same shape function type as
        #     all other variables.
        type = GasVelocityCylindricalReactor
        variable = vel_y
        # 'space_velocity' is volume of gas per volumes of solids per time
        porosity = pore
        space_velocity = 50   # volumes of gas per volume of solids per min
        inlet_temperature = temp
        ref_pressure = 101.35
        ref_temperature = 273.15
        radius = 1  #cm
        length = 5  #cm
        execute_on = 'initial timestep_end'
    [../]

    [./Ga_calc]
        type = SphericalAreaVolumeRatio
        variable = Ga
        particle_diameter = 0.12 #in cm
        porosity = pore
        per_solids_volume = true
        execute_on = 'initial timestep_end'
    [../]

    [./non_pore_calc]
        type = SolidsVolumeFraction
        variable = non_pore
        porosity = pore
        execute_on = 'initial timestep_end'
    [../]

    [./total_pore_calc]
        type = MicroscalePoreVolumePerTotalVolume
        variable = total_pore
        porosity = pore
        microscale_porosity = micro_pore
        execute_on = 'initial timestep_end'
    [../]

    [./km_calc]
        type = SimpleGasSphericalMassTransCoef
        variable = km

        pressure = press
        temperature = temp
        micro_porosity = micro_pore
        macro_porosity = pore

        # characteristic_length is particle diameter for this case
        characteristic_length = dh
        char_length_unit = "cm"

        velocity = vel_y
        vel_length_unit = "cm"
        vel_time_unit = "min"

        # molecular diffusivity of H2O in air
        #   at a reference temperature of 20 C (293 K)
        # Often these values can be looked up in data tables
        ref_diffusivity = 0.242
        diff_length_unit = "cm"
        diff_time_unit = "s"
        ref_diff_temp = 293

        # Our model uses 'cm' as the base length
        #   and 'min' as the base time, so these args
        #   will ensure we get those units for km
        output_length_unit = "cm"
        output_time_unit = "min"

        execute_on = 'initial timestep_end'
    [../]

    [./Deff_calc]
        type = SimpleGasEffectivePoreDiffusivity
        variable = Deff

        pressure = press
        temperature = temp
        micro_porosity = micro_pore
        macro_porosity = pore
        characteristic_length = dh
        char_length_unit = "cm"

        velocity = vel_y
        vel_length_unit = "cm"
        vel_time_unit = "min"

        # molecular diffusivity of H2O in air
        #   at a reference temperature of 20 C (293 K)
        # Often these values can be looked up in data tables
        ref_diffusivity = 0.242
        diff_length_unit = "cm"
        diff_time_unit = "s"
        ref_diff_temp = 293

        output_length_unit = "cm"
        output_time_unit = "min"
        # NOTE: Because we are using this inside
        #     our Microscale kernels, we actually DO NOT
        #     want this on the per solids volume basis.
        #     This is because we want this to lump everything
        #     into a single term, instead of adding additional
        #     conversion terms (as we did with the FilmMassTransfer
        #     kernel).
        per_solids_volume = false

        execute_on = 'initial timestep_end'
    [../]

    [./Disp_calc]
        type = SimpleGasDispersion
        variable = Disp

        pressure = press
        temperature = temp
        micro_porosity = micro_pore
        macro_porosity = pore

        # NOTE: For this calculation, use bed diameter as char_length
        characteristic_length = 2
        char_length_unit = "cm"

        velocity = vel_y
        vel_length_unit = "cm"
        vel_time_unit = "min"

        # molecular diffusivity of H2O in air
        #   at a reference temperature of 20 C (293 K)
        # Often these values can be looked up in data tables
        ref_diffusivity = 0.242
        diff_length_unit = "cm"
        diff_time_unit = "s"
        ref_diff_temp = 293

        output_length_unit = "cm"
        output_time_unit = "min"

        execute_on = 'initial timestep_end'
    [../]

    [./q_avg]
        type = MicroscaleIntegralAvg
        variable = qAvg
        first_node = 0
        # This list of variables need to be in node order starting from the first node
        micro_vars = 'q_0 q_1 q_2 q_3 q_4'
        execute_on = 'initial timestep_end'
    [../]

    [./S_avg]
        type = MicroscaleIntegralAvg
        variable = SAvg
        first_node = 0
        # This list of variables need to be in node order starting from the first node
        micro_vars = 'S_0 S_1 S_2 S_3 S_4'
        execute_on = 'initial timestep_end'
    [../]

    [./H2Op_avg]
        type = MicroscaleIntegralAvg
        variable = H2OpAvg
        first_node = 0
        # This list of variables need to be in node order starting from the first node
        micro_vars = 'H2Op_0 H2Op_1 H2Op_2 H2Op_3 H2Op_4'
        execute_on = 'initial timestep_end'
    [../]

[] #END AuxKernels

[BCs]
    # NOTE: Here we are using a stepwise inlet
    #       for BCs to represent switching of
    #       a valve from off, to on, to off again.
    # ============== H2O BCs ================
    [./H2O_FluxIn]
      type = DGPoreConcFluxStepwiseBC
      variable = H2O
      boundary = 'bottom'   #bottom boundary is the feed side
      u_input = 1E-15       #initial inlet value
      porosity = pore
      ux = vel_x
      uy = vel_y
      uz = vel_z
      # At time 0, there is no H2O flowing, then at 5 min, a valve is
      #   opened and we start flowing H2O. At 50 min, the valve is shut off.
      input_vals = '0.001    1e-15'
      input_times = '5    350'
      # Time spans are the time it takes to reach a specific inlet value
      #   based on valve delays. It also smooths the inlet term to stabilize
      #   the FE methods.
      time_spans = '0.25    0.25'
    [../]
    [./H2O_FluxOut]
      type = DGPoreConcFluxBC
      variable = H2O
      boundary = 'top'    #top boundary is the exit side
      porosity = pore
      ux = vel_x
      uy = vel_y
      uz = vel_z
    [../]

[] #END BCs

[Postprocessors]

    [./H2O_out]
        type = SideAverageValue
        boundary = 'top'
        variable = H2O
        execute_on = 'initial timestep_end'
    [../]

    [./H2O_bypass]
        type = SideAverageValue
        boundary = 'bottom'
        variable = H2O
        execute_on = 'initial timestep_end'
    [../]

    [./temp_avg]
        type = ElementAverageValue
        variable = temp
        execute_on = 'initial timestep_end'
    [../]

    [./q_avg]
        type = ElementAverageValue
        variable = qAvg
        execute_on = 'initial timestep_end'
    [../]

    [./S_avg]
        type = ElementAverageValue
        variable = SAvg
        execute_on = 'initial timestep_end'
    [../]

    [./H2Op_avg]
        type = ElementAverageValue
        variable = H2OpAvg
        execute_on = 'initial timestep_end'
    [../]

    # Outputs below are to view the interior pellet concentrations
    #   for surface species, sites, and water vapor at specific
    #   nodal locations of the microscale. These outs are integral
    #   averages at the 'bottom' of the macroscale mesh, thus,
    #   would represent interior particle concentrations for the
    #   pellets located at the bed inlet.
    [./q_0_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = q_0
        execute_on = 'initial timestep_end'
    [../]

    [./q_1_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = q_1
        execute_on = 'initial timestep_end'
    [../]

    [./q_2_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = q_2
        execute_on = 'initial timestep_end'
    [../]

    [./q_3_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = q_3
        execute_on = 'initial timestep_end'
    [../]

    [./q_4_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = q_4
        execute_on = 'initial timestep_end'
    [../]

    [./S_0_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = S_0
        execute_on = 'initial timestep_end'
    [../]

    [./S_1_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = S_1
        execute_on = 'initial timestep_end'
    [../]

    [./S_2_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = S_2
        execute_on = 'initial timestep_end'
    [../]

    [./S_3_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = S_3
        execute_on = 'initial timestep_end'
    [../]

    [./S_4_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = S_4
        execute_on = 'initial timestep_end'
    [../]

    [./H2Op_0_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = H2Op_0
        execute_on = 'initial timestep_end'
    [../]

    [./H2Op_1_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = H2Op_1
        execute_on = 'initial timestep_end'
    [../]

    [./H2Op_2_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = H2Op_2
        execute_on = 'initial timestep_end'
    [../]

    [./H2Op_3_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = H2Op_3
        execute_on = 'initial timestep_end'
    [../]

    [./H2Op_4_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = H2Op_4
        execute_on = 'initial timestep_end'
    [../]

    # In addition to outputting our model simulated results
    #   to the csv file. Here, we can also output all of the
    #   values that were automatically calculated by the auxilary
    #   kernel system. This is useful for picking out the
    #   MonolithMicroscaleTotalThickness value, as well as
    #   checking the calculated values used in the model.
    [./vel_in]
        type = SideAverageValue
        boundary = 'bottom'
        variable = vel_y
        execute_on = 'initial timestep_end'
    [../]

    [./Ga]
        type = ElementAverageValue
        variable = Ga
        execute_on = 'initial timestep_end'
    [../]

    [./non_pore]
        type = ElementAverageValue
        variable = non_pore
        execute_on = 'initial timestep_end'
    [../]

    [./pore]
        type = ElementAverageValue
        variable = pore
        execute_on = 'initial timestep_end'
    [../]

    [./total_pore]
        type = ElementAverageValue
        variable = total_pore
        execute_on = 'initial timestep_end'
    [../]

    [./km]
        type = ElementAverageValue
        variable = km
        execute_on = 'initial timestep_end'
    [../]

    [./Deff]
        type = ElementAverageValue
        variable = Deff
        execute_on = 'initial timestep_end'
    [../]

    [./Disp]
        type = ElementAverageValue
        variable = Disp
        execute_on = 'initial timestep_end'
    [../]

[] #END Postprocessors


[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
    solve_type = pjfnk   #default to newton, but use pjfnk if newton too slow
  [../]
[] #END Preconditioning

[Executioner]
  type = Transient
  scheme = implicit-euler
  petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -pc_type -sub_pc_type -snes_max_it -sub_pc_factor_shift_type -pc_asm_overlap -snes_atol -snes_rtol'
  petsc_options_value = 'gmres asm ilu 100 NONZERO 2 1E-14 1E-12'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = bt
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-4
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0
  end_time = 850.0
  dtmax = 2.5

  [./TimeStepper]
     type = ConstantDT
     dt = 2.5
  [../]
[] #END Executioner

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
[] #END Outputs
