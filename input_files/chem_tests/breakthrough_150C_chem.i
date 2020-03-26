[GlobalParams]
  dg_scheme = nipg
  sigma = 10
[] #END GlobalParams

[Problem]

    coord_type = RZ

[] #END Problem

[Mesh]

    type = GeneratedMesh
    dim = 2
    nx = 1
    ny = 20
    xmin = 0.0
    xmax = 2.0    #2cm radius
    ymin = 0.0
    ymax = 5.0    #5cm length

[] # END Mesh

[Variables]

## ----- NOTE: Cross-Coupled Variables for Mass MUST have same order and family !!! ------- ##
    [./NH3]
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
#initial_condition = 2.578975e-02
    [../]
 
    [./S1]
        order = FIRST
        family = MONOMIAL
#initial_condition = 2.578975e-02
    [../]

    [./S2]
        order = FIRST
        family = MONOMIAL
#initial_condition = 0.03534
    [../]

    [./S3]
        order = FIRST
        family = MONOMIAL
#initial_condition = 0.03963
    [../]

    [./qT]
        order = FIRST
        family = MONOMIAL
#initial_condition = 0
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

  [./w1]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.05016
  [../]

  [./w2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.03534
  [../]

  [./w3]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.03963
  [../]

  [./temp]
      order = FIRST
      family = MONOMIAL
      initial_condition = 423.15
  [../]

  [./Diff]
    order = FIRST
    family = MONOMIAL
    initial_condition = 750.0
  [../]
 
  [./Dz]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0.0
  [../]

  [./pore]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.3309
  [../]

  [./vel_x]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  [./vel_y]
      order = FIRST
      family = LAGRANGE
      initial_condition = 7555.15
  [../]

  [./vel_z]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
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
        Dx = Diff
        Dy = Diff
        Dz = Dz
    [../]
## ------- NOTE: It is more computationally efficient to couple phase transfer 1-by-1 --------- ##
    [./transfer_q1]
        type = CoupledPorePhaseTransfer
        variable = NH3
        coupled = q1
        porosity = pore
    [../]
    [./transfer_q2]
        type = CoupledPorePhaseTransfer
        variable = NH3
        coupled = q2
        porosity = pore
    [../]
    [./transfer_q3]
        type = CoupledPorePhaseTransfer
        variable = NH3
        coupled = q3
        porosity = pore
    [../]

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
 
## ------- NOTE: If kinetic rates are appropriate, then converges very well (too fast = problems) --------- ##
    [./q1_dot]
       type = TimeDerivative
       variable = q1
    [../]
    [./q1_rx]  #   NH3 + S1 <-- --> q1
      type = ConstReaction
      variable = q1
      this_variable = q1
      forward_rate = 157554.199
      reverse_rate = 1.0
      scale = 1.0
      reactants = 'NH3 S1'
      reactant_stoich = '1 1'
      products = 'q1'
      product_stoich = '1'
    [../]
 
    [./q2_dot]
       type = TimeDerivative
       variable = q2
    [../]
    [./q2_rx]  #   NH3 + S2 <-- --> q2
      type = ConstReaction
      variable = q2
      this_variable = q2
      forward_rate = 215414.444
      reverse_rate = 0.010
      scale = 1.0
      reactants = 'NH3 S2'
      reactant_stoich = '1 1'
      products = 'q2'
      product_stoich = '1'
    [../]
 
    [./q3_dot]
       type = TimeDerivative
       variable = q3
    [../]
    [./q3_rx]  #   NH3 + S3 <-- --> q3
      type = ConstReaction
      variable = q3
      this_variable = q3
      forward_rate = 1044803.1090
      reverse_rate = 0.0010
      scale = 1.0
      reactants = 'NH3 S3'
      reactant_stoich = '1 1'
      products = 'q3'
      product_stoich = '1'
    [../]
 
## NOTE: If we do not have kernels for H2O mass transfer, then we do not need a time derivative here ------- ##
    [./qH2O_rx]  #   H2O + S1 <-- --> qH2O
      type = ConstReaction
      variable = qH2O
      this_variable = qH2O
      forward_rate = 790.93684
      reverse_rate = 1.0
      scale = 1.0
      reactants = 'H2O S1'
      reactant_stoich = '1 1'
      products = 'qH2O'
      product_stoich = '1'
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
        Dx = Diff
        Dy = Diff
        Dz = Dz
    [../]

[] #END DGKernels

[AuxKernels]

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
      input_vals = '2.78862977563539E-05 1.40E-05'
      input_times = '2 16'
      time_spans = '0.5 0.5'
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

    [./NH3_exit]
        type = SideAverageValue
        boundary = 'top'
        variable = NH3
        execute_on = 'initial timestep_end'
    [../]
 
    [./NH3_enter]
        type = SideAverageValue
        boundary = 'bottom'
        variable = NH3
        execute_on = 'initial timestep_end'
    [../]
 
    [./S1_avg]
        type = ElementAverageValue
        variable = S1
        execute_on = 'initial timestep_end'
    [../]

    [./S2_avg]
        type = ElementAverageValue
        variable = S2
        execute_on = 'initial timestep_end'
    [../]

    [./S3_avg]
        type = ElementAverageValue
        variable = S3
        execute_on = 'initial timestep_end'
    [../]

    [./q1_avg]
        type = ElementAverageValue
        variable = q1
        execute_on = 'initial timestep_end'
    [../]

    [./q2_avg]
        type = ElementAverageValue
        variable = q2
        execute_on = 'initial timestep_end'
    [../]

    [./q3_avg]
        type = ElementAverageValue
        variable = q3
        execute_on = 'initial timestep_end'
    [../]

    [./qT_avg]
        type = ElementAverageValue
        variable = qT
        execute_on = 'initial timestep_end'
    [../]
    
    [./qWater]
        type = ElementAverageValue
        variable = qH2O
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

  start_time = 0.0
  end_time = 32.0
  dtmax = 0.25

  [./TimeStepper]
     type = SolutionTimeAdaptiveDT
     dt = 0.25
  [../]
[] #END Executioner

[Outputs]
  print_linear_residuals = false
  exodus = true
  csv = true
[] #END Outputs
