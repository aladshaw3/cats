
[GlobalParams]
  # 'dg_scheme' and 'sigma' are parameters for the DG kernels
  dg_scheme = nipg
  sigma = 10

  # Maximum effective wall thickness for diffusion
  #   This value is calculated in the MonolithMicroscaleTotalThickness kernel,
  #   but cannot be automatically linked here due to the implementation standards
  #   of the Microscale kernel base. Thus, users should calculate this value
  #   first in an input file using the MonolithMicroscaleTotalThickness kernel.
  #   Then, place that value here to use the Microscale kernels to simulate
  #   mass-transfer and intralayer diffusion for monolith domains.
  micro_length = 0.1 #cm thick
  num_nodes = 5
  coord_id = 0  #0 ==> washcoat (1=cylindrical particles, 2=spherical particles)
[] #END GlobalParams

[Problem]
    coord_type = RZ
    #NOTE: For RZ coordinates, x ==> R and y ==> Z (and z ==> nothing)
[] #END Problem

[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = 1
    ny = 10
    xmin = 0.0
    xmax = 1.0    #2cm diameter (1cm radius)
    ymin = 0.0
    ymax = 5.0    #5cm length
[] # END Mesh

[Variables]

## Gas phase variable lists
    [./O2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    # 5 interior nodes inside the washcoat
    [./O2w_0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./O2w_1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./O2w_2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./O2w_3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./O2w_4]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./CO]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    # 5 interior nodes inside the washcoat
    [./COw_0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./COw_1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./COw_2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./COw_3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./COw_4]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./CO2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    # 5 interior nodes inside the washcoat
    [./CO2w_0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./CO2w_1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./CO2w_2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./CO2w_3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./CO2w_4]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

## Reaction variable list
    # 5 interior nodes inside the washcoat
    [./r1_0]
        order = FIRST
        family = MONOMIAL
    [../]
    [./r1_1]
        order = FIRST
        family = MONOMIAL
    [../]
    [./r1_2]
        order = FIRST
        family = MONOMIAL
    [../]
    [./r1_3]
        order = FIRST
        family = MONOMIAL
    [../]
    [./r1_4]
        order = FIRST
        family = MONOMIAL
    [../]

[] #END Variables

[AuxVariables]

  [./temp]
      order = FIRST
      family = MONOMIAL
      initial_condition = 379
  [../]

  [./press]
      order = FIRST
      family = MONOMIAL
      initial_condition = 101.35
  [../]

  [./Disp]
    order = FIRST
    family = MONOMIAL
    initial_condition = 2400.0  #Approximate dispersion
  [../]

  # e_b
  [./pore]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.3309
  [../]

  # non_pore = (1 - pore)  # auto calc
  [./non_pore]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.6691
  [../]

  # ew value
  [./micro_pore]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.4
  [../]

  # total_pore = ew* (1 - pore) # auto calc
  [./total_pore]
      order = FIRST
      family = MONOMIAL
  [../]

  # area to volume ratio for monolith # auto calc
  [./Ga]
      order = FIRST
      family = MONOMIAL
  [../]

  # hydraulic diameter for monolith # auto calc
  [./dh]
      order = FIRST
      family = MONOMIAL
  [../]

  # effective thickness of microscale
  [./wt]
      order = FIRST
      family = MONOMIAL
  [../]

  [./km]
      order = FIRST
      family = MONOMIAL
  [../]

  [./Dp]
      order = FIRST
      family = MONOMIAL
  [../]

  [./Deff]
      order = FIRST
      family = MONOMIAL
  [../]

  [./vel_x]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

  [./vel_y] # auto calc
      order = FIRST
      family = MONOMIAL
  [../]

  [./vel_z]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

[] #END AuxVariables

[ICs]

[] #END ICs

[Kernels]
# ------------------- Start Gas Balances ----------------------
# -------------------------------------------------------------
    # =============== Bulk phase O2 ===============
    [./O2_dot]
        type = VariableCoefTimeDerivative
        variable = O2
        coupled_coef = pore
    [../]
    [./O2_gadv]
        type = GPoreConcAdvection
        variable = O2
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./O2_gdiff]
        type = GVarPoreDiffusion
        variable = O2
        porosity = pore
        Dx = Disp
        Dy = Disp
        Dz = Disp
    [../]
    [./O2w_trans]
        type = FilmMassTransfer
        variable = O2
        coupled = O2w_4   # couples at outer most node of microscale

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]

    # =============== Washcoat phase O2 ===============
    # Exterior node
    [./O2w_4_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_4
        nodal_time_var = total_pore
        node_id = 4
    [../]
    # NOTE: not completely sure about the form of this BC
    #   The diff coef may be something else (or km may need unit conv)
    [./O2w_4_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = O2w_4
        node_id = 4
        macro_variable = O2     #Couple with the macroscale variable here
        lower_neighbor = O2w_3
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    [./O2w_4_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_4
        node_id = 4
        coupled_list = 'r1_4'
        weights = '-0.5'
        scale = non_pore
    [../]

    # Interior node 3
    [./O2w_3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_3
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./O2w_3_diff]
        type = MicroscaleVariableDiffusion
        variable = O2w_3
        node_id = 3
        upper_neighbor = O2w_4
        lower_neighbor = O2w_2
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./O2w_3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_3
        node_id = 3
        coupled_list = 'r1_3'
        weights = '-0.5'
        scale = non_pore
    [../]

    # Interior node 2
    [./O2w_2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_2
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./O2w_2_diff]
        type = MicroscaleVariableDiffusion
        variable = O2w_2
        node_id = 2
        upper_neighbor = O2w_3
        lower_neighbor = O2w_1
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./O2w_2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_2
        node_id = 2
        coupled_list = 'r1_2'
        weights = '-0.5'
        scale = non_pore
    [../]

    # Interior node 1
    [./O2w_1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_1
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./O2w_1_diff]
        type = MicroscaleVariableDiffusion
        variable = O2w_1
        node_id = 1
        upper_neighbor = O2w_2
        lower_neighbor = O2w_0
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./O2w_1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_1
        node_id = 1
        coupled_list = 'r1_1'
        weights = '-0.5'
        scale = non_pore
    [../]

    # Interior node 0 : BC
    [./O2w_0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_0
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./O2w_0_diff]
        type = MicroscaleVariableDiffusionInnerBC
        variable = O2w_0
        node_id = 0
        upper_neighbor = O2w_1
        current_diff = Deff
        upper_diff = Deff
    [../]
    [./O2w_0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_0
        node_id = 0
        coupled_list = 'r1_0'
        weights = '-0.5'
        scale = non_pore
    [../]

    # =============== Bulk phase CO ===============
    [./CO_dot]
        type = VariableCoefTimeDerivative
        variable = CO
        coupled_coef = pore
    [../]
    [./CO_gadv]
        type = GPoreConcAdvection
        variable = CO
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./CO_gdiff]
        type = GVarPoreDiffusion
        variable = CO
        porosity = pore
        Dx = Disp
        Dy = Disp
        Dz = Disp
    [../]
    [./COw_trans]
        type = FilmMassTransfer
        variable = CO
        coupled = COw_4   # couples at outer most node of microscale

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]

    # =============== Washcoat phase CO ===============
    # Exterior node
    [./COw_4_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_4
        nodal_time_var = total_pore
        node_id = 4
    [../]
    # NOTE: not completely sure about the form of this BC
    #   The diff coef may be something else (or km may need unit conv)
    [./COw_4_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = COw_4
        node_id = 4
        macro_variable = CO     #Couple with the macroscale variable here
        lower_neighbor = COw_3
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    [./COw_4_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_4
        coupled_list = 'r1_4'
        weights = '-1'
        node_id = 4
        scale = non_pore
    [../]

    # Interior node 3
    [./COw_3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_3
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./COw_3_diff]
        type = MicroscaleVariableDiffusion
        variable = COw_3
        node_id = 3
        upper_neighbor = COw_4
        lower_neighbor = COw_2
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./COw_3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_3
        node_id = 3
        coupled_list = 'r1_3'
        weights = '-1'
        scale = non_pore
    [../]

    # Interior node 2
    [./COw_2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_2
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./COw_2_diff]
        type = MicroscaleVariableDiffusion
        variable = COw_2
        node_id = 2
        upper_neighbor = COw_3
        lower_neighbor = COw_1
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./COw_2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_2
        node_id = 2
        coupled_list = 'r1_2'
        weights = '-1'
        scale = non_pore
    [../]

    # Interior node 1
    [./COw_1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_1
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./COw_1_diff]
        type = MicroscaleVariableDiffusion
        variable = COw_1
        node_id = 1
        upper_neighbor = COw_2
        lower_neighbor = COw_0
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./COw_1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_1
        node_id = 1
        coupled_list = 'r1_1'
        weights = '-1'
        scale = non_pore
    [../]

    # Interior node 0 : BC
    [./COw_0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_0
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./COw_0_diff]
        type = MicroscaleVariableDiffusionInnerBC
        variable = COw_0
        node_id = 0
        upper_neighbor = COw_1
        current_diff = Deff
        upper_diff = Deff
    [../]
    [./COw_0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_0
        node_id = 0
        coupled_list = 'r1_0'
        weights = '-1'
        scale = non_pore
    [../]

    # =============== Bulk phase CO2 ===============
    [./CO2_dot]
        type = VariableCoefTimeDerivative
        variable = CO2
        coupled_coef = pore
    [../]
    [./CO2_gadv]
        type = GPoreConcAdvection
        variable = CO2
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./CO2_gdiff]
        type = GVarPoreDiffusion
        variable = CO2
        porosity = pore
        Dx = Disp
        Dy = Disp
        Dz = Disp
    [../]
    [./CO2w_trans]
        type = FilmMassTransfer
        variable = CO2
        coupled = CO2w_4    # couples at outer most node of microscale

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]

    # =============== Washcoat phase CO2 ===============
    # Exterior node
    [./CO2w_4_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_4
        nodal_time_var = total_pore
        node_id = 4
    [../]
    # NOTE: not completely sure about the form of this BC
    #   The diff coef may be something else (or km may need unit conv)
    [./CO2w_4_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = CO2w_4
        node_id = 4
        macro_variable = CO2     #Couple with the macroscale variable here
        lower_neighbor = CO2w_3
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    [./CO2w_4_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_4
        coupled_list = 'r1_4'
        weights = '1'
        node_id = 4
        scale = non_pore
    [../]

    # Interior node 3
    [./CO2w_3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_3
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./CO2w_3_diff]
        type = MicroscaleVariableDiffusion
        variable = CO2w_3
        node_id = 3
        upper_neighbor = CO2w_4
        lower_neighbor = CO2w_2
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./CO2w_3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_3
        node_id = 3
        coupled_list = 'r1_3'
        weights = '1'
        scale = non_pore
    [../]

    # Interior node 2
    [./CO2w_2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_2
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./CO2w_2_diff]
        type = MicroscaleVariableDiffusion
        variable = CO2w_2
        node_id = 2
        upper_neighbor = CO2w_3
        lower_neighbor = CO2w_1
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./CO2w_2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_2
        node_id = 2
        coupled_list = 'r1_2'
        weights = '1'
        scale = non_pore
    [../]

    # Interior node 1
    [./CO2w_1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_1
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./CO2w_1_diff]
        type = MicroscaleVariableDiffusion
        variable = CO2w_1
        node_id = 1
        upper_neighbor = CO2w_2
        lower_neighbor = CO2w_0
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./CO2w_1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_1
        node_id = 1
        coupled_list = 'r1_1'
        weights = '1'
        scale = non_pore
    [../]

    # Interior node 0 : BC
    [./CO2w_0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_0
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./CO2w_0_diff]
        type = MicroscaleVariableDiffusionInnerBC
        variable = CO2w_0
        node_id = 0
        upper_neighbor = CO2w_1
        current_diff = Deff
        upper_diff = Deff
    [../]
    [./CO2w_0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_0
        node_id = 0
        coupled_list = 'r1_0'
        weights = '1'
        scale = non_pore
    [../]

# ------------------- Start Reaction Balances ----------------------
# -------------------------------------------------------------

## ======= CO Oxidation ======
# CO + 0.5 O2 --> CO2   @ node 4
    [./r1_4_val]
        type = Reaction
        variable = r1_4
    [../]
    [./r1_4_rx]
      type = ArrheniusReaction
      variable = r1_4
      this_variable = r1_4

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_4 O2w_4'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

# CO + 0.5 O2 --> CO2   @ node 3
    [./r1_3_val]
        type = Reaction
        variable = r1_3
    [../]
    [./r1_3_rx]
      type = ArrheniusReaction
      variable = r1_3
      this_variable = r1_3

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_3 O2w_3'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

# CO + 0.5 O2 --> CO2   @ node 2
    [./r1_2_val]
        type = Reaction
        variable = r1_2
    [../]
    [./r1_2_rx]
      type = ArrheniusReaction
      variable = r1_2
      this_variable = r1_2

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_2 O2w_2'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

# CO + 0.5 O2 --> CO2   @ node 1
    [./r1_1_val]
        type = Reaction
        variable = r1_1
    [../]
    [./r1_1_rx]
      type = ArrheniusReaction
      variable = r1_1
      this_variable = r1_1

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_1 O2w_1'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

# CO + 0.5 O2 --> CO2   @ node 0
    [./r1_0_val]
        type = Reaction
        variable = r1_0
    [../]
    [./r1_0_rx]
      type = ArrheniusReaction
      variable = r1_0
      this_variable = r1_0

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_0 O2w_0'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

[] #END Kernels

[DGKernels]

    # =========== O2 DG kernels ===========
    [./O2_dgadv]
        type = DGPoreConcAdvection
        variable = O2
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./O2_dgdiff]
        type = DGVarPoreDiffusion
        variable = O2
        porosity = pore
        Dx = Disp
        Dy = Disp
        Dz = Disp
    [../]

    # =========== CO DG kernels ===========
    [./CO_dgadv]
        type = DGPoreConcAdvection
        variable = CO
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./CO_dgdiff]
        type = DGVarPoreDiffusion
        variable = CO
        porosity = pore
        Dx = Disp
        Dy = Disp
        Dz = Disp
    [../]

    # =========== CO2 DG kernels ===========
    [./CO2_dgadv]
        type = DGPoreConcAdvection
        variable = CO2
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./CO2_dgdiff]
        type = DGVarPoreDiffusion
        variable = CO2
        porosity = pore
        Dx = Disp
        Dy = Disp
        Dz = Disp
    [../]

[] #END DGKernels

[AuxKernels]

    [./velocity]
        # NOTE: velocity must use same shape function type as temperature and space-velocity
        type = GasVelocityCylindricalReactor
        variable = vel_y
        porosity = pore
        space_velocity = 500   #volumes per min
        inlet_temperature = temp
        ref_pressure = 101.35
        ref_temperature = 273.15
        radius = 1  #cm
        length = 5  #cm
        execute_on = 'initial timestep_end'
    [../]

    [./Ga_calc]
        type = MonolithAreaVolumeRatio
        variable = Ga
        cell_density = 62   #cells/cm^2
        channel_vol_ratio = pore
        per_solids_volume = true
        execute_on = 'initial timestep_end'
    [../]

    [./dh_calc]
        type = MonolithHydraulicDiameter
        variable = dh
        cell_density = 62   #cells/cm^2
        channel_vol_ratio = pore
        execute_on = 'initial timestep_end'
    [../]

    [./wt_calc]
        type = MonolithMicroscaleTotalThickness
        variable = wt
        cell_density = 62   #cells/cm^2
        channel_vol_ratio = pore
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
        type = SimpleGasMonolithMassTransCoef
        variable = km

        pressure = press
        temperature = temp
        micro_porosity = micro_pore
        macro_porosity = pore
        characteristic_length = dh
        char_length_unit = "cm"

        velocity = vel_y
        vel_length_unit = "cm"
        vel_time_unit = "min"

        ref_diffusivity = 0.561
        diff_length_unit = "cm"
        diff_time_unit = "s"
        ref_diff_temp = 473

        output_length_unit = "cm"
        output_time_unit = "min"

        execute_on = 'initial timestep_end'
    [../]

    [./Dp_calc]
        type = SimpleGasPoreDiffusivity
        variable = Dp

        pressure = press
        temperature = temp
        micro_porosity = micro_pore
        macro_porosity = pore
        characteristic_length = dh
        char_length_unit = "cm"

        velocity = vel_y
        vel_length_unit = "cm"
        vel_time_unit = "min"

        ref_diffusivity = 0.561
        diff_length_unit = "cm"
        diff_time_unit = "s"
        ref_diff_temp = 473

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

        ref_diffusivity = 0.561
        diff_length_unit = "cm"
        diff_time_unit = "s"
        ref_diff_temp = 473

        output_length_unit = "cm"
        output_time_unit = "min"
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

        ref_diffusivity = 0.561
        diff_length_unit = "cm"
        diff_time_unit = "s"
        ref_diff_temp = 473

        output_length_unit = "cm"
        output_time_unit = "min"
        per_solids_volume = false

        execute_on = 'initial timestep_end'
    [../]

    [./temp_AuxK]
      type = FunctionAux
      variable = temp
      function = data_fun
    [../]

[] #END AuxKernels

[Functions]
  [./data_fun]
    type = PiecewiseMultilinear
    data_file = E10_temperature.txt
  [../]
[]

[BCs]

    # ============== O2 BCs ================
    [./O2_FluxIn]
        type = DGPoreConcFluxBC_ppm
        variable = O2
        boundary = 'bottom'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        pressure = press
        temperature = temp
        inlet_ppm = 7080
    [../]
    [./O2_FluxOut]
        type = DGPoreConcFluxBC
        variable = O2
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== CO BCs ================
    [./CO_FluxIn]
        type = DGPoreConcFluxBC_ppm
        variable = CO
        boundary = 'bottom'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        pressure = press
        temperature = temp
        inlet_ppm = 5100
    [../]
    [./CO_FluxOut]
        type = DGPoreConcFluxBC
        variable = CO
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== CO2 BCs ================
    [./CO2_FluxIn]
        type = DGPoreConcFluxBC_ppm
        variable = CO2
        boundary = 'bottom'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        pressure = press
        temperature = temp
        inlet_ppm = 130000
    [../]
    [./CO2_FluxOut]
        type = DGPoreConcFluxBC
        variable = CO2
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

[] #END BCs

[Materials]

[] #END Materials

[Postprocessors]

    [./O2_out]
        type = SideAverageValue
        boundary = 'top'
        variable = O2
        execute_on = 'initial timestep_end'
    [../]

    [./O2_bypass]
        type = SideAverageValue
        boundary = 'bottom'
        variable = O2
        execute_on = 'initial timestep_end'
    [../]

    [./CO_out]
        type = SideAverageValue
        boundary = 'top'
        variable = CO
        execute_on = 'initial timestep_end'
    [../]

    [./CO_bypass]
        type = SideAverageValue
        boundary = 'bottom'
        variable = CO
        execute_on = 'initial timestep_end'
    [../]

    [./CO2_out]
        type = SideAverageValue
        boundary = 'top'
        variable = CO2
        execute_on = 'initial timestep_end'
    [../]

    [./CO2_bypass]
        type = SideAverageValue
        boundary = 'bottom'
        variable = CO2
        execute_on = 'initial timestep_end'
    [../]

    [./temp_avg]
        type = ElementAverageValue
        variable = temp
        execute_on = 'initial timestep_end'
    [../]

    [./temp_in]
        type = SideAverageValue
        boundary = 'bottom'
        variable = temp
        execute_on = 'initial timestep_end'
    [../]

    [./temp_out]
        type = SideAverageValue
        boundary = 'top'
        variable = temp
        execute_on = 'initial timestep_end'
    [../]

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

    [./dh]
        type = ElementAverageValue
        variable = dh
        execute_on = 'initial timestep_end'
    [../]

    [./wt]
        type = ElementAverageValue
        variable = wt
        execute_on = 'initial timestep_end'
    [../]

    [./non_pore]
        type = ElementAverageValue
        variable = non_pore
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

    [./Dp]
        type = ElementAverageValue
        variable = Dp
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
  petsc_options_value = 'gmres lu ilu 100 NONZERO 2 1E-14 1E-12'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = bt
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-4
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

  start_time = -1.0
  end_time = 102.0
  dtmax = 0.25

  [./TimeStepper]
     type = ConstantDT
     dt = 0.25
  [../]
[] #END Executioner

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
[] #END Outputs
