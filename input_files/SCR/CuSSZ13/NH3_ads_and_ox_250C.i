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

    [./Z1CuOH_NH3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./Z2Cu_NH3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./ZH_NH3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./ZH_NH3_Z1Cu]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./ZH_NH3_CuO]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]
 
     [./qH2O]
         order = FIRST
         family = MONOMIAL
     [../]
  
     [./Z1CuOH]
         order = FIRST
         family = MONOMIAL
     [../]

     [./Z2Cu]
         order = FIRST
         family = MONOMIAL
     [../]

     [./ZH]
         order = FIRST
         family = MONOMIAL
     [../]

    [./ZH_Z1Cu]
        order = FIRST
        family = MONOMIAL
    [../]

    [./ZH_CuO]
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
      initial_condition = 4.66E-05
  [../]

  [./O2w]
      order = FIRST
      family = MONOMIAL
      initial_condition = 4.66E-05
  [../]

  [./H2O]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001131
  [../]
 
  [./H2Ow]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001131
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

# Lone ZH
  [./w3]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0128515
  [../]

# ZH with Z1Cu
  [./w4]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0069
  [../]

# ZH with CuO
  [./w5]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0065
  [../]

  [./temp]
      order = FIRST
      family = MONOMIAL
      initial_condition = 523.15
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
      initial_condition = 2.5184  #m/s
  [../]

  [./vel_z]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  [./P_in]
      order = FIRST
      family = MONOMIAL
      initial_condition = 109600
  [../]
 
 # NOTE: MUST provide IC for pressure!!!
    [./P]
        order = FIRST
        family = MONOMIAL
        initial_condition = 103500
    [../]

# Hydraulic diameter for the monolith channels
  [./dia]
     order = FIRST
     family = MONOMIAL
     initial_condition = 0.000777   #m
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
#    [./transfer_Z1CuOH_NH3]
#        type = CoupledPorePhaseTransfer
#        variable = NH3w
#        coupled = Z1CuOH_NH3
#        porosity = pore
#    [../]
    [./transfer_Z1CuOH_NH3]     #   NH3w + Z1CuOH <-- --> Z1CuOH_NH3
        type = ArrheniusEquilibriumReaction
        variable = NH3w
        this_variable = NH3w
        forward_activation_energy = 0
        forward_pre_exponential = 4166.67
        enthalpy = -54547.9
        entropy = -29.9943
        temperature = temp
        scale = -0.6691             #-1*(1-eps)
        reactants = 'NH3w Z1CuOH'
        reactant_stoich = '1 1'
        products = 'Z1CuOH_NH3'
        product_stoich = '1'
    [../]
#    [./transfer_Z2Cu_NH3]
#        type = CoupledPorePhaseTransfer
#        variable = NH3w
#        coupled = Z2Cu_NH3
#        porosity = pore
#    [../]
    [./transfer_Z2Cu_NH3]       #   NH3w + Z2Cu <-- --> Z2Cu_NH3
        type = ArrheniusEquilibriumReaction
        variable = NH3w
        this_variable = NH3w
        forward_activation_energy = 0
        forward_pre_exponential = 5833.333
        enthalpy = -78065.1
        entropy = -41.0596
        temperature = temp
        scale = -0.6691             #-1*(1-eps)
        reactants = 'NH3w Z2Cu'
        reactant_stoich = '1 1'
        products = 'Z2Cu_NH3'
        product_stoich = '1'
    [../]
#    [./transfer_ZH_NH3]
#        type = CoupledPorePhaseTransfer
#        variable = NH3w
#        coupled = ZH_NH3
#        porosity = pore
#    [../]
    [./transfer_ZH_NH3]  #   NH3w + ZH <-- --> ZH_NH3
        type = ArrheniusEquilibriumReaction
        variable = NH3w
        this_variable = NH3w
        forward_activation_energy = 0
        forward_pre_exponential = 833333.3
        enthalpy = -91860.8
        entropy = -28.9292
        temperature = temp
        scale = -0.6691             #-1*(1-eps)
        reactants = 'NH3w ZH'
        reactant_stoich = '1 1'
        products = 'ZH_NH3'
        product_stoich = '1'
    [../]
#    [./transfer_ZH_NH3_Z1Cu]
#        type = CoupledPorePhaseTransfer
#        variable = NH3w
#        coupled = ZH_NH3_Z1Cu
#        porosity = pore
#    [../]
    [./transfer_ZH_NH3_Z1Cu]  #   NH3w + ZH_Z1Cu <-- --> ZH_NH3_Z1Cu
        type = ArrheniusEquilibriumReaction
        variable = NH3w
        this_variable = NH3w
        forward_activation_energy = 0
        forward_pre_exponential = 833333.3
        enthalpy = -91860.8
        entropy = -28.9292
        temperature = temp
        scale = -0.6691             #-1*(1-eps)
        reactants = 'NH3w ZH_Z1Cu'
        reactant_stoich = '1 1'
        products = 'ZH_NH3_Z1Cu'
        product_stoich = '1'
    [../]
#    [./transfer_ZH_NH3_CuO]
#        type = CoupledPorePhaseTransfer
#        variable = NH3w
#        coupled = ZH_NH3_CuO
#        porosity = pore
#    [../]
    [./transfer_ZH_NH3_CuO]  #   NH3w + ZH_CuO <-- --> ZH_NH3_CuO
        type = ArrheniusEquilibriumReaction
        variable = NH3w
        this_variable = NH3w
        forward_activation_energy = 0
        forward_pre_exponential = 833333.3
        enthalpy = -91860.8
        entropy = -28.9292
        temperature = temp
        scale = -0.6691             #-1*(1-eps)
        reactants = 'NH3w ZH_CuO'
        reactant_stoich = '1 1'
        products = 'ZH_NH3_CuO'
        product_stoich = '1'
    [../]

#   NOTE: According to the Olsson paper, the activation energy for adsorption is 0.0
    [./Z1CuOH_NH3_dot]
        type = TimeDerivative
        variable = Z1CuOH_NH3
    [../]
    [./Z1CuOH_NH3_rx]  #   NH3w + Z1CuOH <-- --> Z1CuOH_NH3
      type = ArrheniusEquilibriumReaction
      variable = Z1CuOH_NH3
      this_variable = Z1CuOH_NH3
      forward_activation_energy = 0
      forward_pre_exponential = 4166.67
      enthalpy = -54547.9
      entropy = -29.9943
      temperature = temp
      scale = 1.0
      reactants = 'NH3w Z1CuOH'
      reactant_stoich = '1 1'
      products = 'Z1CuOH_NH3'
      product_stoich = '1'
    [../]
    [./Z1CuOH_NH3_oxs]   # Z1CuOH_NH3 + 0.75 O2w --> Z1CuOH + 0.5 N2 + 1.5 H2O
        type = ConstReaction
        variable = Z1CuOH_NH3
        this_variable = Z1CuOH_NH3
        forward_rate = 0.015
        reverse_rate = 0
        scale = -1
        reactants = 'Z1CuOH_NH3 O2w'
        reactant_stoich = '1 0.75'
        products = 'Z1CuOH'
        product_stoich = '1'
    [../]

    [./Z2Cu_NH3_dot]
        type = TimeDerivative
        variable = Z2Cu_NH3
    [../]
    [./Z2Cu_NH3_rx]  #   NH3w + Z2Cu <-- --> Z2Cu_NH3
      type = ArrheniusEquilibriumReaction
      variable = Z2Cu_NH3
      this_variable = Z2Cu_NH3
      forward_activation_energy = 0
      forward_pre_exponential = 5833.333
      enthalpy = -78065.1
      entropy = -41.0596
      temperature = temp
      scale = 1.0
      reactants = 'NH3w Z2Cu'
      reactant_stoich = '1 1'
      products = 'Z2Cu_NH3'
      product_stoich = '1'
    [../]
    [./Z2Cu_NH3_oxs]   # Z2Cu_NH3 + 0.75 O2w --> Z2Cu + 0.5 N2 + 1.5 H2O
        type = ConstReaction
        variable = Z2Cu_NH3
        this_variable = Z2Cu_NH3
        forward_rate = 0.015
        reverse_rate = 0
        scale = -1
        reactants = 'Z2Cu_NH3 O2w'
        reactant_stoich = '1 0.75'
        products = 'Z2Cu'
        product_stoich = '1'
    [../]

    [./ZH_NH3_dot]
        type = TimeDerivative
        variable = ZH_NH3
    [../]
    [./ZH_NH3_rx]  #   NH3w + ZH <-- --> ZH_NH3
      type = ArrheniusEquilibriumReaction
      variable = ZH_NH3
      this_variable = ZH_NH3
      forward_activation_energy = 0
      forward_pre_exponential = 833333.3
      enthalpy = -91860.8
      entropy = -28.9292
      temperature = temp
      scale = 1.0
      reactants = 'NH3w ZH'
      reactant_stoich = '1 1'
      products = 'ZH_NH3'
      product_stoich = '1'
    [../]

    [./ZH_NH3_Z1Cu_dot]
        type = TimeDerivative
        variable = ZH_NH3_Z1Cu
    [../]
    [./ZH_NH3_Z1Cu_rx]  #   NH3w + ZH_Z1Cu <-- --> ZH_NH3_Z1Cu
      type = ArrheniusEquilibriumReaction
      variable = ZH_NH3_Z1Cu
      this_variable = ZH_NH3_Z1Cu
      forward_activation_energy = 0
      forward_pre_exponential = 833333.3
      enthalpy = -91860.8
      entropy = -28.9292
      temperature = temp
      scale = 1.0
      reactants = 'NH3w ZH_Z1Cu'
      reactant_stoich = '1 1'
      products = 'ZH_NH3_Z1Cu'
      product_stoich = '1'
    [../]

    [./ZH_NH3_CuO_dot]
        type = TimeDerivative
        variable = ZH_NH3_CuO
    [../]
    [./ZH_NH3_CuO_rx]  #   NH3w + ZH_CuO <-- --> ZH_NH3_CuO
      type = ArrheniusEquilibriumReaction
      variable = ZH_NH3_CuO
      this_variable = ZH_NH3_CuO
      forward_activation_energy = 0
      forward_pre_exponential = 833333.3
      enthalpy = -91860.8
      entropy = -28.9292
      temperature = temp
      scale = 1.0
      reactants = 'NH3w ZH_CuO'
      reactant_stoich = '1 1'
      products = 'ZH_NH3_CuO'
      product_stoich = '1'
    [../]
 
    [./qH2O_rx]  #   H2Ow + Z1CuOH <-- --> qH2O
      type = EquilibriumReaction
      variable = qH2O
      this_variable = qH2O
      enthalpy = -32099.1
      entropy = -24.2494
      temperature = temp
      reactants = 'H2Ow Z1CuOH'
      reactant_stoich = '1 1'
      products = 'qH2O'
      product_stoich = '1'
    [../]
 
# --------------- NOTE: MaterialBalance kernel may cause convergence issues -----------------
#   Error was fixed by only adding positive concentrations to find sum total, but this
#       may make convergence worse as the function is no longer continuous.
    [./qT_calc]
        type = MaterialBalance
        variable = qT
        this_variable = qT
        coupled_list = 'Z1CuOH_NH3 Z2Cu_NH3 ZH_NH3 ZH_NH3_Z1Cu ZH_NH3_CuO'
        weights = '1 1 1 1 1'
        total_material = qT
    [../]
 
    [./Z1CuOH_bal]
        type = MaterialBalance
        variable = Z1CuOH
        this_variable = Z1CuOH
        coupled_list = 'Z1CuOH_NH3 Z1CuOH qH2O'
        weights = '1 1 1'
        total_material = w1
    [../]
 
    [./Z2Cu_bal]
        type = MaterialBalance
        variable = Z2Cu
        this_variable = Z2Cu
        coupled_list = 'Z2Cu_NH3 Z2Cu'
        weights = '1 1'
        total_material = w2
    [../]
 
    [./ZH_bal]
        type = MaterialBalance
        variable = ZH
        this_variable = ZH
        coupled_list = 'ZH_NH3 ZH'
        weights = '1 1'
        total_material = w3
    [../]

    [./ZH_Z1Cu_bal]
        type = MaterialBalance
        variable = ZH_Z1Cu
        this_variable = ZH_Z1Cu
        coupled_list = 'ZH_NH3_Z1Cu ZH_Z1Cu'
        weights = '1 1'
        total_material = w4
    [../]

    [./ZH_CuO_bal]
        type = MaterialBalance
        variable = ZH_CuO
        this_variable = ZH_CuO
        coupled_list = 'ZH_NH3_CuO ZH_CuO'
        weights = '1 1'
        total_material = w5
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
 
    [./w2_decrease]
        type = LinearChangeInTime
        variable = w2
        start_time = 1781
        end_time = 1801
        end_value = 0.0432515
        execute_on = 'initial timestep_end'
    [../]

    [./O2_increase]
        type = LinearChangeInTime
        variable = O2
        start_time = 1781
        end_time = 1801
        end_value = 0.00233
        execute_on = 'initial timestep_end'
    [../]

    [./O2w_increase]
        type = LinearChangeInTime
        variable = O2w
        start_time = 1781
        end_time = 1801
        end_value = 0.00233
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
      input_vals = '6.9905E-06    6.9905E-06'
      input_times = '118.998    1791.0'
      time_spans = '15    15'
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

    [./Z1CuOH_NH3]
        type = ElementAverageValue
        variable = Z1CuOH_NH3
        execute_on = 'initial timestep_end'
    [../]

    [./Z2Cu_NH3]
        type = ElementAverageValue
        variable = Z2Cu_NH3
        execute_on = 'initial timestep_end'
    [../]

    [./Z1CuOH]
        type = ElementAverageValue
        variable = Z1CuOH
        execute_on = 'initial timestep_end'
    [../]

    [./Z2Cu]
        type = ElementAverageValue
        variable = Z2Cu
        execute_on = 'initial timestep_end'
    [../]

    [./ZH_NH3]
        type = ElementAverageValue
        variable = ZH_NH3
        execute_on = 'initial timestep_end'
    [../]

    [./ZH_NH3_Z1Cu]
        type = ElementAverageValue
        variable = ZH_NH3_Z1Cu
        execute_on = 'initial timestep_end'
    [../]

    [./ZH_NH3_CuO]
        type = ElementAverageValue
        variable = ZH_NH3_CuO
        execute_on = 'initial timestep_end'
    [../]

    [./ZH]
        type = ElementAverageValue
        variable = ZH
        execute_on = 'initial timestep_end'
    [../]

    [./ZH_Z1Cu]
        type = ElementAverageValue
        variable = ZH_Z1Cu
        execute_on = 'initial timestep_end'
    [../]

    [./ZH_CuO]
        type = ElementAverageValue
        variable = ZH_CuO
        execute_on = 'initial timestep_end'
    [../]

    [./Total_Ads_NH3]
        type = ElementAverageValue
        variable = qT
        execute_on = 'initial timestep_end'
    [../]

    [./O2_avg]
        type = ElementAverageValue
        variable = O2
        execute_on = 'initial timestep_end'
    [../]

    [./O2w_avg]
        type = ElementAverageValue
        variable = O2w
        execute_on = 'initial timestep_end'
    [../]
 
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

[] #END Postprocessors

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
  [../]
[] #END Preconditioning

[Executioner]
  type = Transient
  scheme = implicit-euler
  solve_type = pjfnk
  petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -ksp_gmres_restart -pc_type -sub_pc_type'
  petsc_options_value = 'gmres 300 asm lu'

  line_search = bt
  nl_rel_tol = 1e-12
  nl_abs_tol = 1e-16
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-8
  l_max_its = 300

  start_time = 0.0
  end_time = 2439.0
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
  interval = 1   #Number of time steps to wait before writing output
[] #END Outputs
