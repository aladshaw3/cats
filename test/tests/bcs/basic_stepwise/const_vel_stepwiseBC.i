[GlobalParams]
  Dxx = 0.1
  vx = 2
  vy = 0
  vz = 0
  dg_scheme = 'nipg'
  sigma = 10
[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
    type = GeneratedMesh
    dim = 1
	nx = 20
    xmin = 0.0
    xmax = 10.0
[] # END Mesh

[Variables]
	[./u1]
		order = FIRST
		family = MONOMIAL
		initial_condition = 0.0
	[../]
 
    [./u2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1.0
    [../]

[] #END Variables

[AuxVariables]
	[./ux]
		order = FIRST
		family = MONOMIAL
		initial_condition = 2
	[../]

	[./uy]
		order = FIRST
		family = MONOMIAL
		initial_condition = 0
	[../]

	[./uz]
		order = FIRST
		family = MONOMIAL
		initial_condition = 0
	[../]

[] #END AuxVariables

[ICs]


[] #END ICs

[Kernels]
    [./u1_dot]
        type = CoefTimeDerivative
        variable = u1
        Coefficient = 1.0
    [../]
    [./u1_gadv]
        type = GAdvection
        variable = u1
    [../]
    [./u1_gdiff]
      type = GAnisotropicDiffusion
      variable = u1
    [../]
 
    [./u2_dot]
        type = CoefTimeDerivative
        variable = u2
        Coefficient = 1.0
    [../]
    [./u2_gadv]
        type = GAdvection
        variable = u2
    [../]
    [./u2_gdiff]
        type = GAnisotropicDiffusion
        variable = u2
    [../]

[] #END Kernels

[DGKernels]
    [./u1_dgadv]
        type = DGAdvection
        variable = u1
    [../]
    [./u1_dgdiff]
        type = DGAnisotropicDiffusion
        variable = u1
    [../]
 
    [./u2_dgadv]
        type = DGAdvection
        variable = u2
    [../]
    [./u2_dgdiff]
        type = DGAnisotropicDiffusion
        variable = u2
    [../]

[] #END DGKernels

[AuxKernels]


[] #END AuxKernels

[BCs]

	[./u1_Flux]
        type = DGFluxStepwiseBC
        variable = u1
        boundary = 'left right'
        u_input = 1.0
        input_vals = '2 0 1 .5'
        input_times = '10 20 30 40'
        time_spans = '1 0 3 0'
    [../]
 
    [./u2_Flux]
        type = DGFluxLimitedStepwiseBC
        variable = u2
        boundary = 'left right'
        u_input = 0.0
        input_vals = '2 0 1 .5'
        input_times = '5 15 25 35'
        time_spans = '2 0 1 3'
    [../]

[] #END BCs

[Materials]


[] #END Materials

[Postprocessors]
 
    [./u1_enter]
        type = SideAverageValue
        boundary = 'left'
        variable = u1
        execute_on = 'initial timestep_end'
    [../]

    [./u1_exit]
        type = SideAverageValue
        boundary = 'right'
        variable = u1
        execute_on = 'initial timestep_end'
    [../]

    [./u1_avg]
        type = ElementAverageValue
        variable = u1
        execute_on = 'initial timestep_end'
    [../]
 
    [./u2_exit]
        type = SideAverageValue
        boundary = 'right'
        variable = u2
        execute_on = 'initial timestep_end'
    [../]

    [./u2_avg]
        type = ElementAverageValue
        variable = u2
        execute_on = 'initial timestep_end'
    [../]

[] #END Postprocessors

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
  end_time = 50.0
  dtmax = 1.0

    [./TimeStepper]
        type = ConstantDT
        dt = 1.0
    [../]

[] #END Executioner

[Preconditioning]
    [./SMP]
      type = SMP
      full = true
      solve_type = newton   #newton solver works faster when using very good preconditioner
    [../]

[] #END Preconditioning

[Outputs]

    exodus = true
    csv = true
    print_linear_residuals = false

[] #END Outputs
