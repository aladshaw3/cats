[GlobalParams]
  dg_scheme = nipg
  sigma = 10
[] #END GlobalParams

[Problem]

    coord_type = RZ
    #NOTE: For RZ coordinates, x ==> R and y ==> Z (and z ==> nothing)

[] #END Problem

[Mesh]

    type = GeneratedMesh
    dim = 2
    nx = 3
    ny = 20
    xmin = 0.0
    xmax = 2.0    #2cm radius
    ymin = 0.0
    ymax = 5.0    #5cm length

[] # END Mesh

[Variables]

    [./C1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./C2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1
    [../]

    [./Diff]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0.01
    [../]

    [./pore]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0.5  #NOTE: Should not be zero!!
    [../]

[] #END Variables

[AuxVariables]

  [./vel_x]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

  [./vel_y]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1
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

    [./C1_dot]
        type = VariableCoefTimeDerivative
        variable = C1
        coupled_coef = pore
    [../]
    [./C1_gadv]
        type = GPoreConcAdvection
        variable = C1
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./C1_gdiff]
        type = GVarPoreDiffusion
        variable = C1
        porosity = pore
        Dx = Diff
        Dy = Diff
        Dz = Diff
    [../]

    [./C2_dot]
        type = VariableCoefTimeDerivative
        variable = C2
        coupled_coef = pore
    [../]
    [./C2_gadv]
        type = GPoreConcAdvection
        variable = C2
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./C2_gdiff]
        type = GVarPoreDiffusion
        variable = C2
        porosity = pore
        Dx = Diff
        Dy = Diff
        Dz = Diff
    [../]

    [./lin_diff]
      type = Diffusion
      variable = Diff
    [../]

    [./lin_pore]
      type = Diffusion
      variable = pore
    [../]

[] #END Kernels

[DGKernels]

    [./C1_dgadv]
        type = DGPoreConcAdvection
        variable = C1
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./C1_dgdiff]
        type = DGVarPoreDiffusion
        variable = C1
        porosity = pore
        Dx = Diff
        Dy = Diff
        Dz = Diff
    [../]

    [./C2_dgadv]
        type = DGPoreConcAdvection
        variable = C2
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./C2_dgdiff]
        type = DGVarPoreDiffusion
        variable = C2
        porosity = pore
        Dx = Diff
        Dy = Diff
        Dz = Diff
    [../]

[] #END DGKernels

[AuxKernels]

[] #END AuxKernels

[BCs]

    [./C1_FluxIn]
      type = DGPoreDiffFluxLimitedBC
      variable = C1
      boundary = 'bottom'
      u_input = 1.0
      porosity = pore
      ux = vel_x
      uy = vel_y
      uz = vel_z
      Dx = Diff
      Dy = Diff
      Dz = Diff
    [../]
    [./C1_FluxOut]
      type = DGPoreConcFluxBC
      variable = C1
      boundary = 'top left right'
      porosity = pore
      ux = vel_x
      uy = vel_y
      uz = vel_z
    [../]

    [./C2_FluxIn]
      type = DGPoreDiffFluxLimitedBC
      variable = C2
      boundary = 'bottom'
      u_input = 0.0
      porosity = pore
      ux = vel_x
      uy = vel_y
      uz = vel_z
      Dx = Diff
      Dy = Diff
      Dz = Diff
    [../]
    [./C2_FluxOut]
      type = DGPoreConcFluxBC
      variable = C2
      boundary = 'top left right'
      porosity = pore
      ux = vel_x
      uy = vel_y
      uz = vel_z
    [../]

    [./diff_bot]
      type = DirichletBC
      variable = Diff
      boundary = bottom
      value = 0.001
    [../]
    [./diff_top]
      type = DirichletBC
      variable = Diff
      boundary = top
      value = 0.1
    [../]

    [./pore_bot]
      type = DirichletBC
      variable = pore
      boundary = bottom
      value = 0.75
    [../]
    [./pore_top]
      type = DirichletBC
      variable = pore
      boundary = top
      value = 0.25
    [../]

[] #END BCs

[Materials]

[] #END Materials

[Postprocessors]

    [./C1_exit]
        type = SideAverageValue
        boundary = 'top'
        variable = C1
        execute_on = 'initial timestep_end'
    [../]
    [./C1_avg]
        type = ElementAverageValue
        variable = C1
        execute_on = 'initial timestep_end'
    [../]

    [./C2_exit]
        type = SideAverageValue
        boundary = 'top'
        variable = C2
        execute_on = 'initial timestep_end'
    [../]
    [./C2_avg]
        type = ElementAverageValue
        variable = C2
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
  petsc_options_value = 'gmres asm lu 100 NONZERO 2 1E-14 1E-12'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = none
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-4
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0.0
  end_time = 0.2
  dtmax = 0.5

  [./TimeStepper]
	   #type = SolutionTimeAdaptiveDT
     type = ConstantDT
     dt = 0.1
  [../]
[] #END Executioner

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = false
[] #END Outputs
