[GlobalParams]
  Dxx = 0.0
[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
  type = GeneratedMesh
  dim = 1
	nx = 50
  xmin = 0.0
  xmax = 10.0
[] # END Mesh

[Variables]
	[./dens]
		order = CONSTANT
		family = MONOMIAL
		initial_condition = 0.0  #kg/m^3
	[../]

  [./dens_lag]
		order = FIRST
		family = LAGRANGE
		initial_condition = 0.0  #kg/m^3
	[../]

[] #END Variables

[AuxVariables]
	[./ux]
		order = FIRST
		family = MONOMIAL
		initial_condition = 20
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
    [./dens_dot]
        type = CoefTimeDerivative
        variable = dens
        Coefficient = 1.0
    [../]
    [./dens_gadv]
        type = GConcentrationAdvection
        variable = dens
		    ux = ux
		    uy = uy
		    uz = uz
    [../]
    [./u_gdiff]
      type = GAnisotropicDiffusion
      variable = dens
    [../]

    [./dens_lag_dot]
        type = CoefTimeDerivative
        variable = dens_lag
        Coefficient = 1.0
    [../]
    [./dens_lag_gadv]
        type = GConcentrationAdvection
        variable = dens_lag
		    ux = ux
		    uy = uy
		    uz = uz
    [../]
    [./u_lag_gdiff]
      type = GAnisotropicDiffusion
      variable = dens_lag
    [../]

[] #END Kernels

[DGKernels]
    [./dens_dgadv]
        type = DGConcentrationAdvection
		    variable = dens
		    ux = ux
		    uy = uy
		    uz = uz
    [../]
    [./u_dgdiff]
        type = DGAnisotropicDiffusion
        variable = dens
        dg_scheme = 'nipg'   #options: 'nipg', 'sipg', 'iipg'
        sigma = 1
    [../]

[] #END DGKernels

[AuxKernels]


[] #END AuxKernels

[BCs]

	[./dens_Flux]
        type = DGConcentrationFluxBC
        variable = dens
        boundary = 'left right'
		    u_input = 1.0
		    ux = ux
		    uy = uy
		    uz = uz
  [../]

  [./dens_lag_Flux]
        type = DGConcentrationFluxBC
        variable = dens_lag
        boundary = 'left right'
		    u_input = 1.0
		    ux = ux
		    uy = uy
		    uz = uz
  [../]

[] #END BCs

[Materials]


[] #END Materials

[Postprocessors]

    [./dg_exit]
        type = SideAverageValue
        boundary = 'right'
        variable = dens
        execute_on = 'initial timestep_end'
    [../]

    [./cg_exit]
        type = SideAverageValue
        boundary = 'right'
        variable = dens_lag
        execute_on = 'initial timestep_end'
    [../]

[] #END Postprocessors

[Executioner]
  type = Transient
  scheme = bdf2
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
  end_time = 1.0
  dtmax = 0.5

    [./TimeStepper]
		  #type = SolutionTimeAdaptiveDT
		  type = ConstantDT
      dt = 0.02
    [../]

[] #END Executioner

[Preconditioning]

    [./SMP_PJFNK]
      type = SMP
      full = true
      solve_type = pjfnk
    [../]

[] #END Preconditioning

[Outputs]

    exodus = true
    csv = true
    print_linear_residuals = false

[] #END Outputs
