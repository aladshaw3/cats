[GlobalParams]
  dg_scheme = nipg
  sigma = 10
  Coefficient = 0.5
[] #END GlobalParams

[Problem]
    coord_type = RZ
    #NOTE: For RZ coordinates, x ==> R and y ==> Z (and z ==> nothing)
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

    [./qT]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
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
      initial_condition = 0.0476971
  [../]

  [./w2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0507088
  [../]

  [./w3]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0227721
  [../]

  [./temp]
      order = FIRST
      family = MONOMIAL
      initial_condition = 598.15
  [../]

  [./Diff]
    order = FIRST
    family = MONOMIAL
    initial_condition = 75.0
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
    [./transfer_qT]
      type = CoupledPorePhaseTransfer
      variable = NH3
      coupled = qT
      porosity = pore
    [../]

    [./q1_dot]
        type = CoefTimeDerivative
        variable = q1
    [../]
    [./q1_rxn]
      type = Reaction
      variable = q1
    [../]
    [./q1_lang] #site 1
      type = VarSiteDensityExtLangModel
      variable = q1
      coupled_site_density = w1
      main_coupled = NH3
      coupled_list = 'NH3 H2O'
      enthalpies = '-60019.6 -25656.6'
      entropies = '-42.4329 -5.24228'
      coupled_temp = temp
    [../]

    [./q2_dot]
        type = CoefTimeDerivative
        variable = q2
    [../]
    [./q2_rxn]
      type = Reaction
      variable = q2
    [../]
    [./q2_lang] #site 2
      type = VarSiteDensityExtLangModel
      variable = q2
     coupled_site_density = w2
      main_coupled = NH3
      coupled_list = 'NH3'
      enthalpies = '-77077.9'
      entropies = '-41.8576'
      coupled_temp = temp
    [../]

    [./q3_dot]
        type = CoefTimeDerivative
        variable = q3
    [../]
    [./q3_rxn]
      type = Reaction
      variable = q3
    [../]
    [./q3_lang] #site 3
      type = VarSiteDensityExtLangModel
      variable = q3
      coupled_site_density = w3
      main_coupled = NH3
      coupled_list = 'NH3'
      enthalpies = '-78147'
      entropies = '-12.1126'
      coupled_temp = temp
    [../]

    [./qT_res]
      type = Reaction
      variable = qT
    [../]
    [./qT_sum]
      type = CoupledSumFunction
      variable = qT
      coupled_list = 'q1 q2 q3'
    [../]

    #[./H2O_dot]
    #    type = VariableCoefTimeDerivative
    #    variable = H2O
    #    coupled_coef = pore
    #[../]
    #[./H2O_gadv]
    #    type = GPoreConcAdvection
    #    variable = H2O
    #    porosity = pore
    #    ux = vel_x
    #    uy = vel_y
    #    uz = vel_z
    #[../]
    #[./H2O_gdiff]
    #    type = GVarPoreDiffusion
    #    variable = H2O
    #    porosity = pore
    #    Dx = Diff
    #    Dy = Diff
    #    Dz = Dz
    #[../]
    # ------------- NOTE: Ignoring H2O mass transfer for this test  --------------

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

    #[./H2O_dgadv]
    #    type = DGPoreConcAdvection
    #    variable = H2O
    #    porosity = pore
    #    ux = vel_x
    #    uy = vel_y
    #    uz = vel_z
    #[../]
    #[./H2O_dgdiff]
    #    type = DGVarPoreDiffusion
    #    variable = H2O
    #    porosity = pore
    #    Dx = Diff
    #    Dy = Diff
    #    Dz = Dz
    #[../]

[] #END DGKernels

[AuxKernels]
 
    [./temp_increase]
        type = LinearChangeInTime
        variable = temp
        start_time = 223.758333
        end_time = 266.591667
        end_value = 811.2147751
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
      input_vals = '1.94036E-05    1.53733E-05    1.13951E-05    7.52065E-06    3.79703E-06    1.89592E-06    9.40707E-07    4.64979E-07    2.30905E-07    8.97185E-10'
      input_times = '2.09166667    13.425    23.0916667    34.7583333    46.7583333    63.5916667    90.425    122.591667    168.091667    221.758333'
      time_spans = '0.5    0.5    0.5    0.5    0.5    0.5    0.5    0.5    0.5    0.5'
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

    #[./H2O_FluxIn]
    #  type = DGPoreConcFluxBC
    #  variable = H2O
    #  boundary = 'bottom'
    #  u_input = 0.001337966847917
    #  porosity = pore
    #  ux = vel_x
    #  uy = vel_y
    #  uz = vel_z
    #[../]
    #[./H2O_FluxOut]
    #  type = DGPoreConcFluxBC
    #  variable = H2O
    #  boundary = 'top'
    #  porosity = pore
    #  ux = vel_x
    #  uy = vel_y
    #  uz = vel_z
    #[../]

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

    [./total]
        type = ElementAverageValue
        variable = qT
        execute_on = 'initial timestep_end'
    [../]
 
    [./temp_avg]
        type = ElementAverageValue
        variable = temp
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
  end_time = 267.0
  dtmax = 0.25

  [./TimeStepper]
     type = ConstantDT
     dt = 0.25
  [../]
[] #END Executioner

[Outputs]
  print_linear_residuals = false
  exodus = true
  csv = true
[] #END Outputs
