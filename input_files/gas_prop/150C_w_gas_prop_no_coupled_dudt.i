# There is some issue with the moose methods that make forming solutions difficult
#       Grid size, solve type, line search ==> impact solution when they shouldn't...

# NOTE: Time step size is an important factor in the above issues; if problems occur, reduce time step

[GlobalParams]
  dg_scheme = nipg
  sigma = 10
  av_ratio = 5145.04 #m^-1
[] #END GlobalParams

[Problem]
    coord_type = RZ
    #NOTE: For RZ coordinates, x ==> R and y ==> Z (and z ==> nothing)
[] #END Problem

[Mesh]
#NOTE: For some reason, changing the grid sizes hurts the solution (start with coarse grid)
    type = GeneratedMesh
    dim = 2
    nx = 1
    ny = 20
    xmin = 0.0
    xmax = 0.01    #1cm radius (in m)
    ymin = 0.0
    ymax = 0.05    #5cm length (in m)
[] # END Mesh

[Variables]

## ----- NOTE: Cross-Coupled Variables for Mass MUST have same order and family !!! ------- ##
    [./NH3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1e-9
    [../]
 
    [./NH3w]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1e-9
    [../]

    [./q1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./q2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./q3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]
 
     [./qH2O]
         order = FIRST
         family = MONOMIAL
     [../]
  
     [./S1]
         order = FIRST
         family = MONOMIAL
     [../]

     [./S2]
         order = FIRST
         family = MONOMIAL
     [../]

     [./S3]
         order = FIRST
         family = MONOMIAL
     [../]

    [./qT]
        order = FIRST
        family = MONOMIAL
    [../]

[] #END Variables

[AuxVariables]

  [./O2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 5.35186739166803E-05
  [../]

  #MOVED water to AuxVariables because we don't want to consider mass transfer right now
  [./H2O]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001337966847917
  [../]
 
  [./H2Ow]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001337966847917
  [../]

  [./w1]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.052619
  [../]

  [./w2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0462515
  [../]

  [./w3]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0262515
  [../]

  [./temp]
      order = FIRST
      family = MONOMIAL
      initial_condition = 423.15
  [../]

  [./Disp]
    order = FIRST
    family = MONOMIAL
  [../]

  [./pore]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.3309
  [../]

  [./total_pore]
# ew =~ 1/5
# total_pore = ew* (1 - pore)
# micro_pore_vol = 0.18 cm^3/g
# assume ew = 0.2
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.13382
  [../]

  [./vel_x]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  [./vel_y]
      order = FIRST
      family = LAGRANGE
      initial_condition = 1.2592  #m/s
  [../]

  [./vel_z]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  [./P_in]
      order = FIRST
      family = MONOMIAL
      initial_condition = 103400
  [../]
 
 # NOTE: MUST provide IC for pressure!!!
    [./P]
        order = FIRST
        family = MONOMIAL
        initial_condition = 101300
    [../]

# Hydraulic diameter for the monolith channels
  [./dia]
     order = FIRST
     family = MONOMIAL
     initial_condition = 0.000777   #m
  [../]
 
   [./dens]
      order = FIRST
      family = MONOMIAL
   [../]
  
   [./vis]
      order = FIRST
      family = MONOMIAL
   [../]
 
    [./micro_pore]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.2
    [../]
 
 # Units --> m^/2
    [./kme_NH3]
        order = FIRST
        family = MONOMIAL
    [../]
 
    [./macro_dia]
       order = FIRST
       family = MONOMIAL
       initial_condition = 0.02   #m
    [../]

[] #END AuxVariables

[ICs]

[] #END ICs

[Kernels]

    [./NH3_dot]
        type = VariableCoefTimeDerivative
        variable = NH3
        coupled_coef = pore
    [../]
    [./NH3_gadv]
        type = GPoreConcAdvection
        variable = NH3
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./NH3_gdiff]
        type = GVarPoreDiffusion
        variable = NH3
        porosity = pore
        Dx = Disp
        Dy = Disp
        Dz = Disp
    [../]
    [./NH3w_trans]
        type = FilmMassTransfer
        variable = NH3
        coupled = NH3w
        rate_variable = kme_NH3
    [../]
 
    [./NH3w_dot]
        type = VariableCoefTimeDerivative
        variable = NH3w
        coupled_coef = total_pore
    [../]
    [./NH3_trans]
        type = FilmMassTransfer
        variable = NH3w
        coupled = NH3
        rate_variable = kme_NH3
    [../]
#    [./transfer_q1]
#        type = CoupledPorePhaseTransfer
#        variable = NH3w
#        coupled = q1
#        porosity = pore
#    [../]
    [./transfer_q1]  #   NH3w + S1 <-- --> q1
      type = ArrheniusEquilibriumReaction
      variable = NH3w
      this_variable = NH3w
      forward_activation_energy = 0
      forward_pre_exponential = 4166.67
      enthalpy = -54547.9
      entropy = -29.9943
      temperature = temp
      scale = -0.6691               #(1-pore)
      reactants = 'NH3w S1'
      reactant_stoich = '1 1'
      products = 'q1'
      product_stoich = '1'
    [../]
#    [./transfer_q2]
#        type = CoupledPorePhaseTransfer
#        variable = NH3w
#        coupled = q2
#        porosity = pore
#    [../]
    [./transfer_q2]  #   NH3w + S2 <-- --> q2
      type = ArrheniusEquilibriumReaction
      variable = NH3w
      this_variable = NH3w
      forward_activation_energy = 0
      forward_pre_exponential = 5833.333
      enthalpy = -78065.1
      entropy = -41.0596
      temperature = temp
      scale = -0.6691               #(1-pore)
      reactants = 'NH3w S2'
      reactant_stoich = '1 1'
      products = 'q2'
      product_stoich = '1'
    [../]
#    [./transfer_q3]
#        type = CoupledPorePhaseTransfer
#        variable = NH3w
#        coupled = q3
#        porosity = pore
#    [../]
    [./transfer_q3]  #   NH3w + S3 <-- --> q3
      type = ArrheniusEquilibriumReaction
      variable = NH3w
      this_variable = NH3w
      forward_activation_energy = 0
      forward_pre_exponential = 833333.3
      enthalpy = -91860.8
      entropy = -28.9292
      temperature = temp
      scale = -0.6691               #(1-pore)
      reactants = 'NH3w S3'
      reactant_stoich = '1 1'
      products = 'q3'
      product_stoich = '1'
    [../]

#   NOTE: According to the Olsson paper, the activation energy for adsorption is 0.0
    [./q1_dot]
        type = TimeDerivative
        variable = q1
    [../]
    [./q1_rx]  #   NH3w + S1 <-- --> q1
      type = ArrheniusEquilibriumReaction
      variable = q1
      this_variable = q1
      forward_activation_energy = 0
      forward_pre_exponential = 4166.67
      enthalpy = -54547.9
      entropy = -29.9943
      temperature = temp
      scale = 1.0
      reactants = 'NH3w S1'
      reactant_stoich = '1 1'
      products = 'q1'
      product_stoich = '1'
    [../]

    [./q2_dot]
        type = TimeDerivative
        variable = q2
    [../]
    [./q2_rx]  #   NH3w + S2 <-- --> q2
      type = ArrheniusEquilibriumReaction
      variable = q2
      this_variable = q2
      forward_activation_energy = 0
      forward_pre_exponential = 5833.333
      enthalpy = -78065.1
      entropy = -41.0596
      temperature = temp
      scale = 1.0
      reactants = 'NH3w S2'
      reactant_stoich = '1 1'
      products = 'q2'
      product_stoich = '1'
    [../]

    [./q3_dot]
        type = TimeDerivative
        variable = q3
    [../]
    [./q3_rx]  #   NH3w + S3 <-- --> q3
      type = ArrheniusEquilibriumReaction
      variable = q3
      this_variable = q3
      forward_activation_energy = 0
      forward_pre_exponential = 833333.3
      enthalpy = -91860.8
      entropy = -28.9292
      temperature = temp
      scale = 1.0
      reactants = 'NH3w S3'
      reactant_stoich = '1 1'
      products = 'q3'
      product_stoich = '1'
    [../]
 
    [./qH2O_rx]  #   H2Ow + S1 <-- --> qH2O
      type = EquilibriumReaction
      variable = qH2O
      this_variable = qH2O
      enthalpy = -32099.1
      entropy = -24.2494
      temperature = temp
      reactants = 'H2Ow S1'
      reactant_stoich = '1 1'
      products = 'qH2O'
      product_stoich = '1'
    [../]
 
# ERRORS observered were actually caused by the MaterialBalance kernel (which allowed negative site densities)
    [./qT_calc]
        type = MaterialBalance
        variable = qT
        this_variable = qT
        coupled_list = 'q1 q2 q3'
        weights = '1 1 1'
        total_material = qT
    [../]
 
    [./S1_bal]
        type = MaterialBalance
        variable = S1
        this_variable = S1
        coupled_list = 'q1 S1 qH2O'
        weights = '1 1 1'
        total_material = w1
    [../]
 
    [./S2_bal]
        type = MaterialBalance
        variable = S2
        this_variable = S2
        coupled_list = 'q2 S2'
        weights = '1 1'
        total_material = w2
    [../]
 
    [./S3_bal]
        type = MaterialBalance
        variable = S3
        this_variable = S3
        coupled_list = 'q3 S3'
        weights = '1 1'
        total_material = w3
    [../]

[] #END Kernels

[DGKernels]

    [./NH3_dgadv]
        type = DGPoreConcAdvection
        variable = NH3
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./NH3_dgdiff]
        type = DGVarPoreDiffusion
        variable = NH3
        porosity = pore
        Dx = Disp
        Dy = Disp
        Dz = Disp
    [../]

[] #END DGKernels

[AuxKernels]
 
    [./temp_increase]
        type = LinearChangeInTime
        variable = temp
        start_time = 13525.5
        end_time = 18318
        end_value = 809.5651714
        execute_on = 'initial timestep_end'
    [../]
 
    [./press_increase]
        type = LinearChangeInTime
        variable = P_in
        start_time = 13525.5
        end_time = 18318
        end_value = 104200
        execute_on = 'initial timestep_end'
    [../]
 
    [./P_ergun]
        type = AuxErgunPressure
        variable = P
        direction = 1
        porosity = pore
        temperature = temp
        # NOTE: Use inlet pressure for pressure variable in aux pressure kernel
        pressure = P_in
        hydraulic_diameter = dia
        ux = vel_x
        uy = vel_y
        uz = vel_z
        gases = 'NH3 H2O O2'
        molar_weights = '17.031 18 32'
        sutherland_temp = '293.17 292.25 298.16'
        sutherland_const = '370 784.72 127'
        sutherland_vis = '0.0000982 0.001043 0.0002018'
        spec_heat = '2.175 1.97 0.919'
        execute_on = 'initial timestep_end'
    [../]
 
    [./vis_calc]
        type = GasViscosity
        variable = vis
        temperature = temp
        pressure = P
        hydraulic_diameter = dia
        ux = vel_x
        uy = vel_y
        uz = vel_z
        gases = 'NH3 H2O O2'
        molar_weights = '17.031 18 32'
        sutherland_temp = '293.17 292.25 298.16'
        sutherland_const = '370 784.72 127'
        sutherland_vis = '0.0000982 0.001043 0.0002018'
        spec_heat = '2.175 1.97 0.919'
        execute_on = 'initial timestep_end'
    [../]
 
    [./dens_calc]
        type = GasDensity
        variable = dens
        temperature = temp
        pressure = P
        hydraulic_diameter = dia
        ux = vel_x
        uy = vel_y
        uz = vel_z
        gases = 'NH3 H2O O2'
        molar_weights = '17.031 18 32'
        sutherland_temp = '293.17 292.25 298.16'
        sutherland_const = '370 784.72 127'
        sutherland_vis = '0.0000982 0.001043 0.0002018'
        spec_heat = '2.175 1.97 0.919'
        execute_on = 'initial timestep_end'
    [../]
 
    [./kme_NH3_calc]
        type = GasSpeciesEffectiveTransferCoef
        variable = kme_NH3
        species_index = 0
        micro_porosity = micro_pore
        temperature = temp
        pressure = P
        hydraulic_diameter = dia
        ux = vel_x
        uy = vel_y
        uz = vel_z
        gases = 'NH3 H2O O2'
        molar_weights = '17.031 18 32'
        sutherland_temp = '293.17 292.25 298.16'
        sutherland_const = '370 784.72 127'
        sutherland_vis = '0.0000982 0.001043 0.0002018'
        spec_heat = '2.175 1.97 0.919'
        execute_on = 'initial timestep_end'
    [../]
 
    [./Dz_NH3_calc]
        type = GasSpeciesAxialDispersion
        variable = Disp
        species_index = 0
        macroscale_diameter = macro_dia
        temperature = temp
        pressure = P
        hydraulic_diameter = dia
        ux = vel_x
        uy = vel_y
        uz = vel_z
        gases = 'NH3 H2O O2'
        molar_weights = '17.031 18 32'
        sutherland_temp = '293.17 292.25 298.16'
        sutherland_const = '370 784.72 127'
        sutherland_vis = '0.0000982 0.001043 0.0002018'
        spec_heat = '2.175 1.97 0.919'
        execute_on = 'initial timestep_end'
    [../]

[] #END AuxKernels

[BCs]

    [./NH3_FluxIn]
      type = DGPoreConcFluxStepwiseBC
      variable = NH3
      boundary = 'bottom'
      u_input = 1E-9
      porosity = pore
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_vals = '2.88105E-05    2.28698E-05    1.70674E-05    1.13344E-05    5.76691E-06    2.87521E-06    1.43838E-06    7.21421E-07    3.67254E-07    3.81105E-09'
      input_times = '125.5    955.5    1465.5    1965.5    2545.5    3305.5    4625.5    6545.5    9295.5    13525.5'
      time_spans = '15    15    15    15    15    15    15    15    15    15'
    [../]
    [./NH3_FluxOut]
      type = DGPoreConcFluxBC
      variable = NH3
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

    [./NH3_out]
        type = SideAverageValue
        boundary = 'top'
        variable = NH3
        execute_on = 'initial timestep_end'
    [../]
 
    [./NH3_bypass]
        type = SideAverageValue
        boundary = 'bottom'
        variable = NH3
        execute_on = 'initial timestep_end'
    [../]

    [./Z1CuOH]
        type = ElementAverageValue
        variable = q1
        execute_on = 'initial timestep_end'
    [../]

    [./Z2Cu]
        type = ElementAverageValue
        variable = q2
        execute_on = 'initial timestep_end'
    [../]

    [./ZH]
        type = ElementAverageValue
        variable = q3
        execute_on = 'initial timestep_end'
    [../]

#    [./S3]
#        type = ElementAverageValue
#        variable = S3
#        execute_on = 'initial timestep_end'
#    [../]

#    [./total]
#        type = ElementAverageValue
#        variable = qT
#        execute_on = 'initial timestep_end'
#    [../]
 
    [./temp_avg]
        type = ElementAverageValue
        variable = temp
        execute_on = 'initial timestep_end'
    [../]
 
    [./P_in]
        type = SideAverageValue
        boundary = 'bottom'
        variable = P
        execute_on = 'initial timestep_end'
    [../]
 
    [./P_out]
        type = SideAverageValue
        boundary = 'top'
        variable = P
        execute_on = 'initial timestep_end'
    [../]

#    [./kme_NH3]
#        type = ElementAverageValue
#        variable = kme_NH3
#        execute_on = 'initial timestep_end'
#    [../]
 
#    [./Dz_NH3]
#        type = ElementAverageValue
#        variable = Disp
#        execute_on = 'initial timestep_end'
#    [../]
[] #END Postprocessors

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
    #NOTE: For some reason, changing the solve_type option hurts the solution
    solve_type = pjfnk   #default to newton, but use pjfnk if newton too slow
  [../]
[] #END Preconditioning

[Executioner]
  type = Transient
  scheme = implicit-euler
  petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -pc_type -sub_pc_type -snes_max_it -sub_pc_factor_shift_type -pc_asm_overlap -snes_atol -snes_rtol'
  petsc_options_value = 'gmres lu ilu 100 NONZERO 2 1E-14 1E-12'

  #NOTE: LEAVE LINE_SEARCH ON (Use bt or l2)
  #NOTE: For some reason, changing the line_search option hurts the solution
  line_search = bt
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-6
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-8
  l_max_its = 300

  start_time = 0.0
  end_time = 18360
  dtmax = 15

  [./TimeStepper]
     type = ConstantDT
     dt = 15
  [../]
[] #END Executioner

[Outputs]
  print_linear_residuals = false
  exodus = true
  csv = true
  time_step_interval = 1   #Number of time steps to wait before writing output
[] #END Outputs
