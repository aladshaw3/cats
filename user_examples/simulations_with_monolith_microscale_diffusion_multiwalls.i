
# This example demonstrates how to create simulations of a monolith
#   including intralayer diffusion using our hybrid FD/FE element
#   approach. Typically, for very high fidelity, users may want to
#   use the subdomain approach instead. However, the subdomain approach
#   requires more complicated meshing, which may be too complex if
#   users want to include 2D (or 3D) radial temperature distributions.
#   Thus, we offer a way to simulate the intralayer diffusion for monoliths
#   that does not require very complex meshing.
#
# The difference between this example and the 'simulations_with_monolith_microscale_diffuison.i'
#   are that in this example, we separate out the diffusion in the microscale into
#   individual walls of the monolith (instead on into a singular set of microscale
#   diffusion kernels). In this way, we can change the reactions and/or diffusion
#   characteristics into individual walls of the monolith. This method is also
#   slightly more accurate for the microscale, as the wall thickness parameter
#   would be more representative of true wall thickness. However, doing this
#   requires significantly more kernels and variables, as each wall now has
#   its own set of microscale variables and kernels.
#
# Here, we create a 2D cylindrical mesh to represent the full reactor system.
#   Then, we use the Microscale kernels to simulate the diffusion of gases
#   through the micropores of the washcoat on the monolith. The actual wall
#   thickness needed can be calculated using the MonolithMicroscaleTotalThickness
#   aux kernel and providing the number of walls to represent. Users are still required
#   to manually input that calculated value into the 'micro_length' parameter in
#   [GlobalParams] (see below). This is due to how those Microscale kernels are setup.
#
# This demo is showing the lightoff of CO in a TWC. Temperature gradients
#   are imported from a data file, so no energy balance is needed for this
#   example. Additionally, this example demos how to use the 'SimpleGas'
#   properties calculations, which allow users to pick their unit basis
#   and use simpler approximations to major gas properties.

[GlobalParams]
  # 'dg_scheme' and 'sigma' are parameters for the DG kernels
  dg_scheme = nipg
  sigma = 10

  # Actual effective wall thickness for diffusion
  #   This value is calculated in the MonolithMicroscaleTotalThickness kernel,
  #   but cannot be automatically linked here due to the implementation standards
  #   of the Microscale kernel base. Thus, users should calculate this value
  #   first in an input file using the MonolithMicroscaleTotalThickness kernel.
  #   Then, place that value here to use the Microscale kernels to simulate
  #   mass-transfer and intralayer diffusion for monolith domains.
  micro_length = 0.0090663815 #cm thick

  # Final setup for the Microscale is done by specifying the number of nodes
  #   for the microscale, and the coord_id number.
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

    # To solve the diffusion in the washcoat requires the
    #   user to define a 'nodal' variable for every point
    #   in the microscale (e.g., we specified 5 nodes, thus
    #   there will be 5 variables in the microscale).
    # We denote these variables as *_n where n is the corresponding
    #   node number. Node 0 is the inner most node and node 4
    #   is the outer most node (i.e., node at the interface between
    #   the washcoat and the bulk channel space).
    # IN ADDITION, for this example, we separate out the physics
    #   for each individual wall of the monolith, so we denote
    #   which wall this variable belongs to with the *_w IDs.
    #   By doing so, we can give each wall different diffusion
    #   and/or reaction characteristics if desired.
    # 5 interior nodes inside the washcoat
    [./O2w_n0_w0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./O2w_n1_w0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./O2w_n2_w0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./O2w_n3_w0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./O2w_n4_w0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    # Set for wall ID 1
    [./O2w_n0_w1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./O2w_n1_w1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./O2w_n2_w1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./O2w_n3_w1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./O2w_n4_w1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    # Set for wall ID 2
    [./O2w_n0_w2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./O2w_n1_w2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./O2w_n2_w2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./O2w_n3_w2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./O2w_n4_w2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    # Set for wall ID 3
    [./O2w_n0_w3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./O2w_n1_w3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./O2w_n2_w3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./O2w_n3_w3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./O2w_n4_w3]
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
    # Set for wall ID 0
    [./COw_n0_w0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./COw_n1_w0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./COw_n2_w0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./COw_n3_w0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./COw_n4_w0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    # 5 interior nodes inside the washcoat
    # Set for wall ID 1
    [./COw_n0_w1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./COw_n1_w1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./COw_n2_w1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./COw_n3_w1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./COw_n4_w1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    # 5 interior nodes inside the washcoat
    # Set for wall ID 2
    [./COw_n0_w2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./COw_n1_w2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./COw_n2_w2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./COw_n3_w2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./COw_n4_w2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    # 5 interior nodes inside the washcoat
    # Set for wall ID 3
    [./COw_n0_w3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./COw_n1_w3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./COw_n2_w3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./COw_n3_w3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./COw_n4_w3]
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
    # Set for wall ID 0
    [./CO2w_n0_w0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./CO2w_n1_w0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./CO2w_n2_w0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./CO2w_n3_w0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./CO2w_n4_w0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    # 5 interior nodes inside the washcoat
    # Set for wall ID 1
    [./CO2w_n0_w1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./CO2w_n1_w1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./CO2w_n2_w1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./CO2w_n3_w1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./CO2w_n4_w1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    # 5 interior nodes inside the washcoat
    # Set for wall ID 2
    [./CO2w_n0_w2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./CO2w_n1_w2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./CO2w_n2_w2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./CO2w_n3_w2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./CO2w_n4_w2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    # 5 interior nodes inside the washcoat
    # Set for wall ID 3
    [./CO2w_n0_w3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./CO2w_n1_w3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./CO2w_n2_w3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./CO2w_n3_w3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]
    [./CO2w_n4_w3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    # Just like with primary variables (i.e., gas-species in washcoat)
    #   we must also create variables for reaction rates at all nodes
    #   in the microscale domain. This is because each reaction variable
    #   must be coupled with the concentrations that are local within
    #   that microscale domain.

    ## Reaction variable list
    # 5 interior nodes inside the washcoat
    # Set for wall ID 0
    [./r1_n0_w0]
        order = FIRST
        family = MONOMIAL
    [../]
    [./r1_n1_w0]
        order = FIRST
        family = MONOMIAL
    [../]
    [./r1_n2_w0]
        order = FIRST
        family = MONOMIAL
    [../]
    [./r1_n3_w0]
        order = FIRST
        family = MONOMIAL
    [../]
    [./r1_n4_w0]
        order = FIRST
        family = MONOMIAL
    [../]

    # 5 interior nodes inside the washcoat
    # Set for wall ID 1
    [./r1_n0_w1]
        order = FIRST
        family = MONOMIAL
    [../]
    [./r1_n1_w1]
        order = FIRST
        family = MONOMIAL
    [../]
    [./r1_n2_w1]
        order = FIRST
        family = MONOMIAL
    [../]
    [./r1_n3_w1]
        order = FIRST
        family = MONOMIAL
    [../]
    [./r1_n4_w1]
        order = FIRST
        family = MONOMIAL
    [../]

    # 5 interior nodes inside the washcoat
    # Set for wall ID 2
    [./r1_n0_w2]
        order = FIRST
        family = MONOMIAL
    [../]
    [./r1_n1_w2]
        order = FIRST
        family = MONOMIAL
    [../]
    [./r1_n2_w2]
        order = FIRST
        family = MONOMIAL
    [../]
    [./r1_n3_w2]
        order = FIRST
        family = MONOMIAL
    [../]
    [./r1_n4_w2]
        order = FIRST
        family = MONOMIAL
    [../]

    # 5 interior nodes inside the washcoat
    # Set for wall ID 3
    [./r1_n0_w3]
        order = FIRST
        family = MONOMIAL
    [../]
    [./r1_n1_w3]
        order = FIRST
        family = MONOMIAL
    [../]
    [./r1_n2_w3]
        order = FIRST
        family = MONOMIAL
    [../]
    [./r1_n3_w3]
        order = FIRST
        family = MONOMIAL
    [../]
    [./r1_n4_w3]
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

  # dispersion coefficient - calculated in properties
  [./Disp]
    order = FIRST
    family = MONOMIAL
  [../]

  # e_b
  [./pore]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.775
  [../]

  # non_pore = (1 - pore) - auto calculated in properties
  [./non_pore]
      order = FIRST
      family = MONOMIAL
  [../]

  # ew value
  [./micro_pore]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.4
  [../]

  # total_pore = ew* (1 - pore) - auto calculated in properties
  [./total_pore]
      order = FIRST
      family = MONOMIAL
  [../]

  # area to volume ratio for monolith - auto calculated in properties
  [./Ga]
      order = FIRST
      family = MONOMIAL
  [../]

  # hydraulic diameter for monolith - auto calculated in properties
  [./dh]
      order = FIRST
      family = MONOMIAL
  [../]

  # effective thickness of microscale
  #   Calculated in properties, but cannot be directly used
  #     by microscale kernels. This should be called once before
  #     running full simulation to obtain the value, then place
  #     that obtained value in [GlobalParams] above. Make sure
  #     to give this value in the proper units. In our case, we
  #     are using diffusion and mass-transfer rates on a cm
  #     basis, so this number must be given in cm in [GlobalParams]
  [./wt]
      order = FIRST
      family = MONOMIAL
  [../]

  # Mass transfer coefficient - auto calculated in properties
  [./km]
      order = FIRST
      family = MONOMIAL
  [../]

  # Pore diffusion - auto calculated in properties
  [./Dp]
      order = FIRST
      family = MONOMIAL
  [../]

  # Effective pore diffusion - auto calculated in properties
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
    # Another difference to bare in mind is that since we are separating
    #   out the diffusion into individual walls, we must also separate
    #   out the mass transfer into individual walls.
    [./O2w_trans_w0]
        type = FilmMassTransfer
        variable = O2
        coupled = O2w_n4_w0   # couples at outer most node of microscale for wall 0

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]
    [./O2w_trans_w1]
        type = FilmMassTransfer
        variable = O2
        coupled = O2w_n4_w1   # couples at outer most node of microscale for wall 1

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]
    [./O2w_trans_w2]
        type = FilmMassTransfer
        variable = O2
        coupled = O2w_n4_w2   # couples at outer most node of microscale for wall 2

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]
    [./O2w_trans_w3]
        type = FilmMassTransfer
        variable = O2
        coupled = O2w_n4_w3   # couples at outer most node of microscale for wall 3

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]

    # =============== Washcoat phase O2 (wall 0) ===============
    # Exterior node
    [./O2w_n4_w0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_n4_w0
        nodal_time_var = total_pore
        node_id = 4
    [../]
    [./O2w_n4_w0_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = O2w_n4_w0
        node_id = 4
        macro_variable = O2     #Couple with the macroscale variable here
        lower_neighbor = O2w_n3_w0
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    [./O2w_n4_w0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_n4_w0
        node_id = 4
        coupled_list = 'r1_n4_w0'
        weights = '-0.5'
        scale = non_pore
    [../]

    # Interior node 3
    [./O2w_n3_w0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_n3_w0
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./O2w_n3_w0_diff]
        type = MicroscaleVariableDiffusion
        variable = O2w_n3_w0
        node_id = 3
        upper_neighbor = O2w_n4_w0
        lower_neighbor = O2w_n2_w0
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./O2w_n3_w0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_n3_w0
        node_id = 3
        coupled_list = 'r1_n3_w0'
        weights = '-0.5'
        scale = non_pore
    [../]

    # Interior node 2
    [./O2w_n2_w0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_n2_w0
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./O2w_n2_w0_diff]
        type = MicroscaleVariableDiffusion
        variable = O2w_n2_w0
        node_id = 2
        upper_neighbor = O2w_n3_w0
        lower_neighbor = O2w_n1_w0
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./O2w_n2_w0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_n2_w0
        node_id = 2
        coupled_list = 'r1_n2_w0'
        weights = '-0.5'
        scale = non_pore
    [../]

    # Interior node 1
    [./O2w_n1_w0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_n1_w0
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./O2w_n1_w0_diff]
        type = MicroscaleVariableDiffusion
        variable = O2w_n1_w0
        node_id = 1
        upper_neighbor = O2w_n2_w0
        lower_neighbor = O2w_n0_w0
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./O2w_n1_w0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_n1_w0
        node_id = 1
        coupled_list = 'r1_n1_w0'
        weights = '-0.5'
        scale = non_pore
    [../]

    # Interior node 0 : BC
    [./O2w_n0_w0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_n0_w0
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./O2w_n0_w0_diff]
        type = MicroscaleVariableDiffusionInnerBC
        variable = O2w_n0_w0
        node_id = 0
        upper_neighbor = O2w_n1_w0
        current_diff = Deff
        upper_diff = Deff
    [../]
    [./O2w_n0_w0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_n0_w0
        node_id = 0
        coupled_list = 'r1_n0_w0'
        weights = '-0.5'
        scale = non_pore
    [../]

    # =============== Washcoat phase O2 (wall 1) ===============
    # Exterior node
    [./O2w_n4_w1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_n4_w1
        nodal_time_var = total_pore
        node_id = 4
    [../]
    [./O2w_n4_w1_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = O2w_n4_w1
        node_id = 4
        macro_variable = O2     #Couple with the macroscale variable here
        lower_neighbor = O2w_n3_w1
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    [./O2w_n4_w1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_n4_w1
        node_id = 4
        coupled_list = 'r1_n4_w1'
        weights = '-0.5'
        scale = non_pore
    [../]

    # Interior node 3
    [./O2w_n3_w1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_n3_w1
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./O2w_n3_w1_diff]
        type = MicroscaleVariableDiffusion
        variable = O2w_n3_w1
        node_id = 3
        upper_neighbor = O2w_n4_w1
        lower_neighbor = O2w_n2_w1
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./O2w_n3_w1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_n3_w1
        node_id = 3
        coupled_list = 'r1_n3_w1'
        weights = '-0.5'
        scale = non_pore
    [../]

    # Interior node 2
    [./O2w_n2_w1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_n2_w1
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./O2w_n2_w1_diff]
        type = MicroscaleVariableDiffusion
        variable = O2w_n2_w1
        node_id = 2
        upper_neighbor = O2w_n3_w1
        lower_neighbor = O2w_n1_w1
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./O2w_n2_w1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_n2_w1
        node_id = 2
        coupled_list = 'r1_n2_w1'
        weights = '-0.5'
        scale = non_pore
    [../]

    # Interior node 1
    [./O2w_n1_w1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_n1_w1
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./O2w_n1_w1_diff]
        type = MicroscaleVariableDiffusion
        variable = O2w_n1_w1
        node_id = 1
        upper_neighbor = O2w_n2_w1
        lower_neighbor = O2w_n0_w1
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./O2w_n1_w1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_n1_w1
        node_id = 1
        coupled_list = 'r1_n1_w1'
        weights = '-0.5'
        scale = non_pore
    [../]

    # Interior node 0 : BC
    [./O2w_n0_w1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_n0_w1
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./O2w_n0_w1_diff]
        type = MicroscaleVariableDiffusionInnerBC
        variable = O2w_n0_w1
        node_id = 0
        upper_neighbor = O2w_n1_w1
        current_diff = Deff
        upper_diff = Deff
    [../]
    [./O2w_n0_w1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_n0_w1
        node_id = 0
        coupled_list = 'r1_n0_w1'
        weights = '-0.5'
        scale = non_pore
    [../]

    # =============== Washcoat phase O2 (wall 2) ===============
    # Exterior node
    [./O2w_n4_w2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_n4_w2
        nodal_time_var = total_pore
        node_id = 4
    [../]
    [./O2w_n4_w2_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = O2w_n4_w2
        node_id = 4
        macro_variable = O2     #Couple with the macroscale variable here
        lower_neighbor = O2w_n3_w2
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    [./O2w_n4_w2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_n4_w2
        node_id = 4
        coupled_list = 'r1_n4_w2'
        weights = '-0.5'
        scale = non_pore
    [../]

    # Interior node 3
    [./O2w_n3_w2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_n3_w2
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./O2w_n3_w2_diff]
        type = MicroscaleVariableDiffusion
        variable = O2w_n3_w2
        node_id = 3
        upper_neighbor = O2w_n4_w2
        lower_neighbor = O2w_n2_w2
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./O2w_n3_w2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_n3_w2
        node_id = 3
        coupled_list = 'r1_n3_w2'
        weights = '-0.5'
        scale = non_pore
    [../]

    # Interior node 2
    [./O2w_n2_w2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_n2_w2
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./O2w_n2_w2_diff]
        type = MicroscaleVariableDiffusion
        variable = O2w_n2_w2
        node_id = 2
        upper_neighbor = O2w_n3_w2
        lower_neighbor = O2w_n1_w2
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./O2w_n2_w2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_n2_w2
        node_id = 2
        coupled_list = 'r1_n2_w2'
        weights = '-0.5'
        scale = non_pore
    [../]

    # Interior node 1
    [./O2w_n1_w2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_n1_w2
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./O2w_n1_w2_diff]
        type = MicroscaleVariableDiffusion
        variable = O2w_n1_w2
        node_id = 1
        upper_neighbor = O2w_n2_w2
        lower_neighbor = O2w_n0_w2
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./O2w_n1_w2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_n1_w2
        node_id = 1
        coupled_list = 'r1_n1_w2'
        weights = '-0.5'
        scale = non_pore
    [../]

    # Interior node 0 : BC
    [./O2w_n0_w2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_n0_w2
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./O2w_n0_w2_diff]
        type = MicroscaleVariableDiffusionInnerBC
        variable = O2w_n0_w2
        node_id = 0
        upper_neighbor = O2w_n1_w2
        current_diff = Deff
        upper_diff = Deff
    [../]
    [./O2w_n0_w2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_n0_w2
        node_id = 0
        coupled_list = 'r1_n0_w2'
        weights = '-0.5'
        scale = non_pore
    [../]

    # =============== Washcoat phase O2 (wall 3) ===============
    # Exterior node
    [./O2w_n4_w3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_n4_w3
        nodal_time_var = total_pore
        node_id = 4
    [../]
    [./O2w_n4_w3_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = O2w_n4_w3
        node_id = 4
        macro_variable = O2     #Couple with the macroscale variable here
        lower_neighbor = O2w_n3_w3
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    [./O2w_n4_w3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_n4_w3
        node_id = 4
        coupled_list = 'r1_n4_w3'
        weights = '-0.5'
        scale = non_pore
    [../]

    # Interior node 3
    [./O2w_n3_w3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_n3_w3
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./O2w_n3_w3_diff]
        type = MicroscaleVariableDiffusion
        variable = O2w_n3_w3
        node_id = 3
        upper_neighbor = O2w_n4_w3
        lower_neighbor = O2w_n2_w3
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./O2w_n3_w3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_n3_w3
        node_id = 3
        coupled_list = 'r1_n3_w3'
        weights = '-0.5'
        scale = non_pore
    [../]

    # Interior node 2
    [./O2w_n2_w3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_n2_w3
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./O2w_n2_w3_diff]
        type = MicroscaleVariableDiffusion
        variable = O2w_n2_w3
        node_id = 2
        upper_neighbor = O2w_n3_w3
        lower_neighbor = O2w_n1_w3
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./O2w_n2_w3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_n2_w3
        node_id = 2
        coupled_list = 'r1_n2_w3'
        weights = '-0.5'
        scale = non_pore
    [../]

    # Interior node 1
    [./O2w_n1_w3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_n1_w3
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./O2w_n1_w3_diff]
        type = MicroscaleVariableDiffusion
        variable = O2w_n1_w3
        node_id = 1
        upper_neighbor = O2w_n2_w3
        lower_neighbor = O2w_n0_w3
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./O2w_n1_w3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_n1_w3
        node_id = 1
        coupled_list = 'r1_n1_w3'
        weights = '-0.5'
        scale = non_pore
    [../]

    # Interior node 0 : BC
    [./O2w_n0_w3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_n0_w3
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./O2w_n0_w3_diff]
        type = MicroscaleVariableDiffusionInnerBC
        variable = O2w_n0_w3
        node_id = 0
        upper_neighbor = O2w_n1_w3
        current_diff = Deff
        upper_diff = Deff
    [../]
    [./O2w_n0_w3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_n0_w3
        node_id = 0
        coupled_list = 'r1_n0_w3'
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
    [./COw_trans_w0]
        type = FilmMassTransfer
        variable = CO
        coupled = COw_n4_w0   # couples at outer most node of microscale for wall 0

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]
    [./COw_trans_w1]
        type = FilmMassTransfer
        variable = CO
        coupled = COw_n4_w1   # couples at outer most node of microscale for wall 1

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]
    [./COw_trans_w2]
        type = FilmMassTransfer
        variable = CO
        coupled = COw_n4_w2   # couples at outer most node of microscale for wall 2

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]
    [./COw_trans_w3]
        type = FilmMassTransfer
        variable = CO
        coupled = COw_n4_w3   # couples at outer most node of microscale for wall 3

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]

    # =============== Washcoat phase CO (wall 0) ===============
    # Exterior node
    [./COw_n4_w0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_n4_w0
        nodal_time_var = total_pore
        node_id = 4
    [../]
    [./COw_n4_w0_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = COw_n4_w0
        node_id = 4
        macro_variable = CO     #Couple with the macroscale variable here
        lower_neighbor = COw_n3_w0
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    [./COw_n4_w0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_n4_w0
        coupled_list = 'r1_n4_w0'
        weights = '-1'
        node_id = 4
        scale = non_pore
    [../]

    # Interior node 3
    [./COw_n3_w0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_n3_w0
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./COw_n3_w0_diff]
        type = MicroscaleVariableDiffusion
        variable = COw_n3_w0
        node_id = 3
        upper_neighbor = COw_n4_w0
        lower_neighbor = COw_n2_w0
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./COw_n3_w0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_n3_w0
        node_id = 3
        coupled_list = 'r1_n3_w0'
        weights = '-1'
        scale = non_pore
    [../]

    # Interior node 2
    [./COw_n2_w0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_n2_w0
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./COw_n2_w0_diff]
        type = MicroscaleVariableDiffusion
        variable = COw_n2_w0
        node_id = 2
        upper_neighbor = COw_n3_w0
        lower_neighbor = COw_n1_w0
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./COw_n2_w0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_n2_w0
        node_id = 2
        coupled_list = 'r1_n2_w0'
        weights = '-1'
        scale = non_pore
    [../]

    # Interior node 1
    [./COw_n1_w0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_n1_w0
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./COw_n1_w0_diff]
        type = MicroscaleVariableDiffusion
        variable = COw_n1_w0
        node_id = 1
        upper_neighbor = COw_n2_w0
        lower_neighbor = COw_n0_w0
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./COw_n1_w0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_n1_w0
        node_id = 1
        coupled_list = 'r1_n1_w0'
        weights = '-1'
        scale = non_pore
    [../]

    # Interior node 0 : BC
    [./COw_n0_w0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_n0_w0
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./COw_n0_w0_diff]
        type = MicroscaleVariableDiffusionInnerBC
        variable = COw_n0_w0
        node_id = 0
        upper_neighbor = COw_n1_w0
        current_diff = Deff
        upper_diff = Deff
    [../]
    [./COw_n0_w0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_n0_w0
        node_id = 0
        coupled_list = 'r1_n0_w0'
        weights = '-1'
        scale = non_pore
    [../]

    # =============== Washcoat phase CO (wall 1) ===============
    # Exterior node
    [./COw_n4_w1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_n4_w1
        nodal_time_var = total_pore
        node_id = 4
    [../]
    [./COw_n4_w1_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = COw_n4_w1
        node_id = 4
        macro_variable = CO     #Couple with the macroscale variable here
        lower_neighbor = COw_n3_w1
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    [./COw_n4_w1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_n4_w1
        coupled_list = 'r1_n4_w1'
        weights = '-1'
        node_id = 4
        scale = non_pore
    [../]

    # Interior node 3
    [./COw_n3_w1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_n3_w1
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./COw_n3_w1_diff]
        type = MicroscaleVariableDiffusion
        variable = COw_n3_w1
        node_id = 3
        upper_neighbor = COw_n4_w1
        lower_neighbor = COw_n2_w1
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./COw_n3_w1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_n3_w1
        node_id = 3
        coupled_list = 'r1_n3_w1'
        weights = '-1'
        scale = non_pore
    [../]

    # Interior node 2
    [./COw_n2_w1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_n2_w1
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./COw_n2_w1_diff]
        type = MicroscaleVariableDiffusion
        variable = COw_n2_w1
        node_id = 2
        upper_neighbor = COw_n3_w1
        lower_neighbor = COw_n1_w1
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./COw_n2_w1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_n2_w1
        node_id = 2
        coupled_list = 'r1_n2_w1'
        weights = '-1'
        scale = non_pore
    [../]

    # Interior node 1
    [./COw_n1_w1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_n1_w1
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./COw_n1_w1_diff]
        type = MicroscaleVariableDiffusion
        variable = COw_n1_w1
        node_id = 1
        upper_neighbor = COw_n2_w1
        lower_neighbor = COw_n0_w1
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./COw_n1_w1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_n1_w1
        node_id = 1
        coupled_list = 'r1_n1_w1'
        weights = '-1'
        scale = non_pore
    [../]

    # Interior node 0 : BC
    [./COw_n0_w1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_n0_w1
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./COw_n0_w1_diff]
        type = MicroscaleVariableDiffusionInnerBC
        variable = COw_n0_w1
        node_id = 0
        upper_neighbor = COw_n1_w1
        current_diff = Deff
        upper_diff = Deff
    [../]
    [./COw_n0_w1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_n0_w1
        node_id = 0
        coupled_list = 'r1_n0_w1'
        weights = '-1'
        scale = non_pore
    [../]

    # =============== Washcoat phase CO (wall 2) ===============
    # Exterior node
    [./COw_n4_w2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_n4_w2
        nodal_time_var = total_pore
        node_id = 4
    [../]
    [./COw_n4_w2_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = COw_n4_w2
        node_id = 4
        macro_variable = CO     #Couple with the macroscale variable here
        lower_neighbor = COw_n3_w2
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    [./COw_n4_w2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_n4_w2
        coupled_list = 'r1_n4_w2'
        weights = '-1'
        node_id = 4
        scale = non_pore
    [../]

    # Interior node 3
    [./COw_n3_w2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_n3_w2
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./COw_n3_w2_diff]
        type = MicroscaleVariableDiffusion
        variable = COw_n3_w2
        node_id = 3
        upper_neighbor = COw_n4_w2
        lower_neighbor = COw_n2_w2
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./COw_n3_w2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_n3_w2
        node_id = 3
        coupled_list = 'r1_n3_w2'
        weights = '-1'
        scale = non_pore
    [../]

    # Interior node 2
    [./COw_n2_w2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_n2_w2
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./COw_n2_w2_diff]
        type = MicroscaleVariableDiffusion
        variable = COw_n2_w2
        node_id = 2
        upper_neighbor = COw_n3_w2
        lower_neighbor = COw_n1_w2
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./COw_n2_w2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_n2_w2
        node_id = 2
        coupled_list = 'r1_n2_w2'
        weights = '-1'
        scale = non_pore
    [../]

    # Interior node 1
    [./COw_n1_w2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_n1_w2
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./COw_n1_w2_diff]
        type = MicroscaleVariableDiffusion
        variable = COw_n1_w2
        node_id = 1
        upper_neighbor = COw_n2_w2
        lower_neighbor = COw_n0_w2
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./COw_n1_w2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_n1_w2
        node_id = 1
        coupled_list = 'r1_n1_w2'
        weights = '-1'
        scale = non_pore
    [../]

    # Interior node 0 : BC
    [./COw_n0_w2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_n0_w2
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./COw_n0_w2_diff]
        type = MicroscaleVariableDiffusionInnerBC
        variable = COw_n0_w2
        node_id = 0
        upper_neighbor = COw_n1_w2
        current_diff = Deff
        upper_diff = Deff
    [../]
    [./COw_n0_w2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_n0_w2
        node_id = 0
        coupled_list = 'r1_n0_w2'
        weights = '-1'
        scale = non_pore
    [../]

    # =============== Washcoat phase CO (wall 3) ===============
    # Exterior node
    [./COw_n4_w3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_n4_w3
        nodal_time_var = total_pore
        node_id = 4
    [../]
    [./COw_n4_w3_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = COw_n4_w3
        node_id = 4
        macro_variable = CO     #Couple with the macroscale variable here
        lower_neighbor = COw_n3_w3
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    [./COw_n4_w3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_n4_w3
        coupled_list = 'r1_n4_w3'
        weights = '-1'
        node_id = 4
        scale = non_pore
    [../]

    # Interior node 3
    [./COw_n3_w3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_n3_w3
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./COw_n3_w3_diff]
        type = MicroscaleVariableDiffusion
        variable = COw_n3_w3
        node_id = 3
        upper_neighbor = COw_n4_w3
        lower_neighbor = COw_n2_w3
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./COw_n3_w3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_n3_w3
        node_id = 3
        coupled_list = 'r1_n3_w3'
        weights = '-1'
        scale = non_pore
    [../]

    # Interior node 2
    [./COw_n2_w3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_n2_w3
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./COw_n2_w3_diff]
        type = MicroscaleVariableDiffusion
        variable = COw_n2_w3
        node_id = 2
        upper_neighbor = COw_n3_w3
        lower_neighbor = COw_n1_w3
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./COw_n2_w3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_n2_w3
        node_id = 2
        coupled_list = 'r1_n2_w3'
        weights = '-1'
        scale = non_pore
    [../]

    # Interior node 1
    [./COw_n1_w3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_n1_w3
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./COw_n1_w3_diff]
        type = MicroscaleVariableDiffusion
        variable = COw_n1_w3
        node_id = 1
        upper_neighbor = COw_n2_w3
        lower_neighbor = COw_n0_w3
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./COw_n1_w3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_n1_w3
        node_id = 1
        coupled_list = 'r1_n1_w3'
        weights = '-1'
        scale = non_pore
    [../]

    # Interior node 0 : BC
    [./COw_n0_w3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_n0_w3
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./COw_n0_w3_diff]
        type = MicroscaleVariableDiffusionInnerBC
        variable = COw_n0_w3
        node_id = 0
        upper_neighbor = COw_n1_w3
        current_diff = Deff
        upper_diff = Deff
    [../]
    [./COw_n0_w3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_n0_w3
        node_id = 0
        coupled_list = 'r1_n0_w3'
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
    [./CO2w_trans_w0]
        type = FilmMassTransfer
        variable = CO2
        coupled = CO2w_n4_w0    # couples at outer most node of microscale at wall 0

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]
    [./CO2w_trans_w1]
        type = FilmMassTransfer
        variable = CO2
        coupled = CO2w_n4_w1    # couples at outer most node of microscale at wall 1

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]
    [./CO2w_trans_w2]
        type = FilmMassTransfer
        variable = CO2
        coupled = CO2w_n4_w2    # couples at outer most node of microscale at wall 2

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]
    [./CO2w_trans_w3]
        type = FilmMassTransfer
        variable = CO2
        coupled = CO2w_n4_w3    # couples at outer most node of microscale at wall 3

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]

    # =============== Washcoat phase CO2 (wall 0) ===============
    # Exterior node
    [./CO2w_n4_w0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_n4_w0
        nodal_time_var = total_pore
        node_id = 4
    [../]
    [./CO2w_n4_w0_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = CO2w_n4_w0
        node_id = 4
        macro_variable = CO2     #Couple with the macroscale variable here
        lower_neighbor = CO2w_n3_w0
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    [./CO2w_n4_w0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_n4_w0
        coupled_list = 'r1_n4_w0'
        weights = '1'
        node_id = 4
        scale = non_pore
    [../]

    # Interior node 3
    [./CO2w_n3_w0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_n3_w0
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./CO2w_n3_w0_diff]
        type = MicroscaleVariableDiffusion
        variable = CO2w_n3_w0
        node_id = 3
        upper_neighbor = CO2w_n4_w0
        lower_neighbor = CO2w_n2_w0
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./CO2w_n3_w0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_n3_w0
        node_id = 3
        coupled_list = 'r1_n3_w0'
        weights = '1'
        scale = non_pore
    [../]

    # Interior node 2
    [./CO2w_n2_w0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_n2_w0
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./CO2w_n2_w0_diff]
        type = MicroscaleVariableDiffusion
        variable = CO2w_n2_w0
        node_id = 2
        upper_neighbor = CO2w_n3_w0
        lower_neighbor = CO2w_n1_w0
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./CO2w_n2_w0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_n2_w0
        node_id = 2
        coupled_list = 'r1_n2_w0'
        weights = '1'
        scale = non_pore
    [../]

    # Interior node 1
    [./CO2w_n1_w0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_n1_w0
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./CO2w_n1_w0_diff]
        type = MicroscaleVariableDiffusion
        variable = CO2w_n1_w0
        node_id = 1
        upper_neighbor = CO2w_n2_w0
        lower_neighbor = CO2w_n0_w0
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./CO2w_n1_w0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_n1_w0
        node_id = 1
        coupled_list = 'r1_n1_w0'
        weights = '1'
        scale = non_pore
    [../]

    # Interior node 0 : BC
    [./CO2w_n0_w0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_n0_w0
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./CO2w_n0_w0_diff]
        type = MicroscaleVariableDiffusionInnerBC
        variable = CO2w_n0_w0
        node_id = 0
        upper_neighbor = CO2w_n1_w0
        current_diff = Deff
        upper_diff = Deff
    [../]
    [./CO2w_n0_w0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_n0_w0
        node_id = 0
        coupled_list = 'r1_n0_w0'
        weights = '1'
        scale = non_pore
    [../]

    # =============== Washcoat phase CO2 (wall 1) ===============
    # Exterior node
    [./CO2w_n4_w1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_n4_w1
        nodal_time_var = total_pore
        node_id = 4
    [../]
    [./CO2w_n4_w1_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = CO2w_n4_w1
        node_id = 4
        macro_variable = CO2     #Couple with the macroscale variable here
        lower_neighbor = CO2w_n3_w1
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    [./CO2w_n4_w1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_n4_w1
        coupled_list = 'r1_n4_w1'
        weights = '1'
        node_id = 4
        scale = non_pore
    [../]

    # Interior node 3
    [./CO2w_n3_w1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_n3_w1
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./CO2w_n3_w1_diff]
        type = MicroscaleVariableDiffusion
        variable = CO2w_n3_w1
        node_id = 3
        upper_neighbor = CO2w_n4_w1
        lower_neighbor = CO2w_n2_w1
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./CO2w_n3_w1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_n3_w1
        node_id = 3
        coupled_list = 'r1_n3_w1'
        weights = '1'
        scale = non_pore
    [../]

    # Interior node 2
    [./CO2w_n2_w1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_n2_w1
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./CO2w_n2_w1_diff]
        type = MicroscaleVariableDiffusion
        variable = CO2w_n2_w1
        node_id = 2
        upper_neighbor = CO2w_n3_w1
        lower_neighbor = CO2w_n1_w1
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./CO2w_n2_w1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_n2_w1
        node_id = 2
        coupled_list = 'r1_n2_w1'
        weights = '1'
        scale = non_pore
    [../]

    # Interior node 1
    [./CO2w_n1_w1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_n1_w1
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./CO2w_n1_w1_diff]
        type = MicroscaleVariableDiffusion
        variable = CO2w_n1_w1
        node_id = 1
        upper_neighbor = CO2w_n2_w1
        lower_neighbor = CO2w_n0_w1
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./CO2w_n1_w1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_n1_w1
        node_id = 1
        coupled_list = 'r1_n1_w1'
        weights = '1'
        scale = non_pore
    [../]

    # Interior node 0 : BC
    [./CO2w_n0_w1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_n0_w1
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./CO2w_n0_w1_diff]
        type = MicroscaleVariableDiffusionInnerBC
        variable = CO2w_n0_w1
        node_id = 0
        upper_neighbor = CO2w_n1_w1
        current_diff = Deff
        upper_diff = Deff
    [../]
    [./CO2w_n0_w1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_n0_w1
        node_id = 0
        coupled_list = 'r1_n0_w1'
        weights = '1'
        scale = non_pore
    [../]

    # =============== Washcoat phase CO2 (wall 2) ===============
    # Exterior node
    [./CO2w_n4_w2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_n4_w2
        nodal_time_var = total_pore
        node_id = 4
    [../]
    [./CO2w_n4_w2_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = CO2w_n4_w2
        node_id = 4
        macro_variable = CO2     #Couple with the macroscale variable here
        lower_neighbor = CO2w_n3_w2
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    [./CO2w_n4_w2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_n4_w2
        coupled_list = 'r1_n4_w2'
        weights = '1'
        node_id = 4
        scale = non_pore
    [../]

    # Interior node 3
    [./CO2w_n3_w2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_n3_w2
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./CO2w_n3_w2_diff]
        type = MicroscaleVariableDiffusion
        variable = CO2w_n3_w2
        node_id = 3
        upper_neighbor = CO2w_n4_w2
        lower_neighbor = CO2w_n2_w2
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./CO2w_n3_w2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_n3_w2
        node_id = 3
        coupled_list = 'r1_n3_w2'
        weights = '1'
        scale = non_pore
    [../]

    # Interior node 2
    [./CO2w_n2_w2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_n2_w2
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./CO2w_n2_w2_diff]
        type = MicroscaleVariableDiffusion
        variable = CO2w_n2_w2
        node_id = 2
        upper_neighbor = CO2w_n3_w2
        lower_neighbor = CO2w_n1_w2
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./CO2w_n2_w2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_n2_w2
        node_id = 2
        coupled_list = 'r1_n2_w2'
        weights = '1'
        scale = non_pore
    [../]

    # Interior node 1
    [./CO2w_n1_w2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_n1_w2
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./CO2w_n1_w2_diff]
        type = MicroscaleVariableDiffusion
        variable = CO2w_n1_w2
        node_id = 1
        upper_neighbor = CO2w_n2_w2
        lower_neighbor = CO2w_n0_w2
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./CO2w_n1_w2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_n1_w2
        node_id = 1
        coupled_list = 'r1_n1_w2'
        weights = '1'
        scale = non_pore
    [../]

    # Interior node 0 : BC
    [./CO2w_n0_w2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_n0_w2
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./CO2w_n0_w2_diff]
        type = MicroscaleVariableDiffusionInnerBC
        variable = CO2w_n0_w2
        node_id = 0
        upper_neighbor = CO2w_n1_w2
        current_diff = Deff
        upper_diff = Deff
    [../]
    [./CO2w_n0_w2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_n0_w2
        node_id = 0
        coupled_list = 'r1_n0_w2'
        weights = '1'
        scale = non_pore
    [../]

    # =============== Washcoat phase CO2 (wall 3) ===============
    # Exterior node
    [./CO2w_n4_w3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_n4_w3
        nodal_time_var = total_pore
        node_id = 4
    [../]
    [./CO2w_n4_w3_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = CO2w_n4_w3
        node_id = 4
        macro_variable = CO2     #Couple with the macroscale variable here
        lower_neighbor = CO2w_n3_w3
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    [./CO2w_n4_w3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_n4_w3
        coupled_list = 'r1_n4_w3'
        weights = '1'
        node_id = 4
        scale = non_pore
    [../]

    # Interior node 3
    [./CO2w_n3_w3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_n3_w3
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./CO2w_n3_w3_diff]
        type = MicroscaleVariableDiffusion
        variable = CO2w_n3_w3
        node_id = 3
        upper_neighbor = CO2w_n4_w3
        lower_neighbor = CO2w_n2_w3
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./CO2w_n3_w3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_n3_w3
        node_id = 3
        coupled_list = 'r1_n3_w3'
        weights = '1'
        scale = non_pore
    [../]

    # Interior node 2
    [./CO2w_n2_w3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_n2_w3
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./CO2w_n2_w3_diff]
        type = MicroscaleVariableDiffusion
        variable = CO2w_n2_w3
        node_id = 2
        upper_neighbor = CO2w_n3_w3
        lower_neighbor = CO2w_n1_w3
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./CO2w_n2_w3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_n2_w3
        node_id = 2
        coupled_list = 'r1_n2_w3'
        weights = '1'
        scale = non_pore
    [../]

    # Interior node 1
    [./CO2w_n1_w3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_n1_w3
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./CO2w_n1_w3_diff]
        type = MicroscaleVariableDiffusion
        variable = CO2w_n1_w3
        node_id = 1
        upper_neighbor = CO2w_n2_w3
        lower_neighbor = CO2w_n0_w3
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./CO2w_n1_w3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_n1_w3
        node_id = 1
        coupled_list = 'r1_n1_w3'
        weights = '1'
        scale = non_pore
    [../]

    # Interior node 0 : BC
    [./CO2w_n0_w3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_n0_w3
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./CO2w_n0_w3_diff]
        type = MicroscaleVariableDiffusionInnerBC
        variable = CO2w_n0_w3
        node_id = 0
        upper_neighbor = CO2w_n1_w3
        current_diff = Deff
        upper_diff = Deff
    [../]
    [./CO2w_n0_w3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_n0_w3
        node_id = 0
        coupled_list = 'r1_n0_w3'
        weights = '1'
        scale = non_pore
    [../]

# ------------------- Start Reactions ----------------------
# -------------------------------------------------------------

    ## ======= Wall 0 ============
    ## ======= CO Oxidation ======
    # CO + 0.5 O2 --> CO2   @ node 4
    [./r1_n4_w0_val]
        type = Reaction
        variable = r1_n4_w0
    [../]
    [./r1_n4_w0_rx]
      type = ArrheniusReaction
      variable = r1_n4_w0
      this_variable = r1_n4_w0

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n4_w0 O2w_n4_w0'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    # CO + 0.5 O2 --> CO2   @ node 3
    [./r1_n3_w0_val]
        type = Reaction
        variable = r1_n3_w0
    [../]
    [./r1_n3_w0_rx]
      type = ArrheniusReaction
      variable = r1_n3_w0
      this_variable = r1_n3_w0

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n3_w0 O2w_n3_w0'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    # CO + 0.5 O2 --> CO2   @ node 2
    [./r1_n2_w0_val]
        type = Reaction
        variable = r1_n2_w0
    [../]
    [./r1_n2_w0_rx]
      type = ArrheniusReaction
      variable = r1_n2_w0
      this_variable = r1_n2_w0

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n2_w0 O2w_n2_w0'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    # CO + 0.5 O2 --> CO2   @ node 1
    [./r1_n1_w0_val]
        type = Reaction
        variable = r1_n1_w0
    [../]
    [./r1_n1_w0_rx]
      type = ArrheniusReaction
      variable = r1_n1_w0
      this_variable = r1_n1_w0

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n1_w0 O2w_n1_w0'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    # CO + 0.5 O2 --> CO2   @ node 0
    [./r1_n0_w0_val]
        type = Reaction
        variable = r1_n0_w0
    [../]
    [./r1_n0_w0_rx]
      type = ArrheniusReaction
      variable = r1_n0_w0
      this_variable = r1_n0_w0

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n0_w0 O2w_n0_w0'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    ## ======= Wall 1 ============
    ## ======= CO Oxidation ======
    # CO + 0.5 O2 --> CO2   @ node 4
    [./r1_n4_w1_val]
        type = Reaction
        variable = r1_n4_w1
    [../]
    [./r1_n4_w1_rx]
      type = ArrheniusReaction
      variable = r1_n4_w1
      this_variable = r1_n4_w1

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n4_w1 O2w_n4_w1'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    # CO + 0.5 O2 --> CO2   @ node 3
    [./r1_n3_w1_val]
        type = Reaction
        variable = r1_n3_w1
    [../]
    [./r1_n3_w1_rx]
      type = ArrheniusReaction
      variable = r1_n3_w1
      this_variable = r1_n3_w1

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n3_w1 O2w_n3_w1'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    # CO + 0.5 O2 --> CO2   @ node 2
    [./r1_n2_w1_val]
        type = Reaction
        variable = r1_n2_w1
    [../]
    [./r1_n2_w1_rx]
      type = ArrheniusReaction
      variable = r1_n2_w1
      this_variable = r1_n2_w1

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n2_w1 O2w_n2_w1'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    # CO + 0.5 O2 --> CO2   @ node 1
    [./r1_n1_w1_val]
        type = Reaction
        variable = r1_n1_w1
    [../]
    [./r1_n1_w1_rx]
      type = ArrheniusReaction
      variable = r1_n1_w1
      this_variable = r1_n1_w1

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n1_w1 O2w_n1_w1'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    # CO + 0.5 O2 --> CO2   @ node 0
    [./r1_n0_w1_val]
        type = Reaction
        variable = r1_n0_w1
    [../]
    [./r1_n0_w1_rx]
      type = ArrheniusReaction
      variable = r1_n0_w1
      this_variable = r1_n0_w1

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n0_w1 O2w_n0_w1'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    ## ======= Wall 2 ============
    ## ======= CO Oxidation ======
    # CO + 0.5 O2 --> CO2   @ node 4
    [./r1_n4_w2_val]
        type = Reaction
        variable = r1_n4_w2
    [../]
    [./r1_n4_w2_rx]
      type = ArrheniusReaction
      variable = r1_n4_w2
      this_variable = r1_n4_w2

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n4_w2 O2w_n4_w2'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    # CO + 0.5 O2 --> CO2   @ node 3
    [./r1_n3_w2_val]
        type = Reaction
        variable = r1_n3_w2
    [../]
    [./r1_n3_w2_rx]
      type = ArrheniusReaction
      variable = r1_n3_w2
      this_variable = r1_n3_w2

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n3_w2 O2w_n3_w2'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    # CO + 0.5 O2 --> CO2   @ node 2
    [./r1_n2_w2_val]
        type = Reaction
        variable = r1_n2_w2
    [../]
    [./r1_n2_w2_rx]
      type = ArrheniusReaction
      variable = r1_n2_w2
      this_variable = r1_n2_w2

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n2_w2 O2w_n2_w2'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    # CO + 0.5 O2 --> CO2   @ node 1
    [./r1_n1_w2_val]
        type = Reaction
        variable = r1_n1_w2
    [../]
    [./r1_n1_w2_rx]
      type = ArrheniusReaction
      variable = r1_n1_w2
      this_variable = r1_n1_w2

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n1_w2 O2w_n1_w2'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    # CO + 0.5 O2 --> CO2   @ node 0
    [./r1_n0_w2_val]
        type = Reaction
        variable = r1_n0_w2
    [../]
    [./r1_n0_w2_rx]
      type = ArrheniusReaction
      variable = r1_n0_w2
      this_variable = r1_n0_w2

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n0_w2 O2w_n0_w2'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    ## ======= Wall 3 ============
    ## ======= CO Oxidation ======
    # CO + 0.5 O2 --> CO2   @ node 4
    [./r1_n4_w3_val]
        type = Reaction
        variable = r1_n4_w3
    [../]
    [./r1_n4_w3_rx]
      type = ArrheniusReaction
      variable = r1_n4_w3
      this_variable = r1_n4_w3

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n4_w3 O2w_n4_w3'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    # CO + 0.5 O2 --> CO2   @ node 3
    [./r1_n3_w3_val]
        type = Reaction
        variable = r1_n3_w3
    [../]
    [./r1_n3_w3_rx]
      type = ArrheniusReaction
      variable = r1_n3_w3
      this_variable = r1_n3_w3

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n3_w3 O2w_n3_w3'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    # CO + 0.5 O2 --> CO2   @ node 2
    [./r1_n2_w3_val]
        type = Reaction
        variable = r1_n2_w3
    [../]
    [./r1_n2_w3_rx]
      type = ArrheniusReaction
      variable = r1_n2_w3
      this_variable = r1_n2_w3

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n2_w3 O2w_n2_w3'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    # CO + 0.5 O2 --> CO2   @ node 1
    [./r1_n1_w3_val]
        type = Reaction
        variable = r1_n1_w3
    [../]
    [./r1_n1_w3_rx]
      type = ArrheniusReaction
      variable = r1_n1_w3
      this_variable = r1_n1_w3

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n1_w3 O2w_n1_w3'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    # CO + 0.5 O2 --> CO2   @ node 0
    [./r1_n0_w3_val]
        type = Reaction
        variable = r1_n0_w3
    [../]
    [./r1_n0_w3_rx]
      type = ArrheniusReaction
      variable = r1_n0_w3
      this_variable = r1_n0_w3

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n0_w3 O2w_n0_w3'
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
        # NOTE: velocity must use same shape function type as
        #     all other variables.
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
        cell_density = 93   #cells/cm^2
        channel_vol_ratio = pore
        per_solids_volume = true
        execute_on = 'initial timestep_end'
    [../]

    [./dh_calc]
        type = MonolithHydraulicDiameter
        variable = dh
        cell_density = 93   #cells/cm^2
        channel_vol_ratio = pore
        execute_on = 'initial timestep_end'
    [../]

    [./wt_calc]
        type = MonolithMicroscaleTotalThickness
        variable = wt
        cell_density = 93   #cells/cm^2
        channel_vol_ratio = pore

        # Wall factor is used to set the effective number of walls
        wall_factor = 4
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

        execute_on = 'initial timestep_end'
    [../]

    [./temp_AuxK]
      type = FunctionAux
      variable = temp
      function = data_fun
    [../]

[] #END AuxKernels

# Here, we actually have temperature data to import into
#   the model to use as the temperature gradients instead
#   of adding an energy balance. This is particularly useful
#   for performing data analysis for which you already know
#   the temperature gradients, but want to find reaction rates.
[Functions]
  [./data_fun]
    type = PiecewiseMultilinear
    data_file = temperature_data.txt
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
