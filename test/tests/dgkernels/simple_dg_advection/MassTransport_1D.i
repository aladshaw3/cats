[GlobalParams]

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
		order = FIRST
		family = MONOMIAL
		initial_condition = 0.0  #kg/m^3
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

[] #END Kernels

[DGKernels]

    [./dens_dgadv]
        type = DGConcentrationAdvection
		variable = dens
		ux = ux
		uy = uy
		uz = uz
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
 
[] #END BCs

[Materials]


[] #END Materials

[Postprocessors]

    [./dens_exit]
        type = SideAverageValue
        boundary = 'right'
        variable = dens
        execute_on = 'initial timestep_end'
    [../]

    [./dens_enter]
        type = SideAverageValue
        boundary = 'left'
        variable = dens
        execute_on = 'initial timestep_end'
    [../]

    [./dens_avg]
        type = ElementAverageValue
        variable = dens
        execute_on = 'initial timestep_end'
    [../]

[] #END Postprocessors

[Executioner]

    type = Transient
	scheme = implicit-euler

    # NOTE: The default tolerances are far to strict and cause the program to crawl
    nl_rel_tol = 1e-6
    nl_abs_tol = 1e-6
    nl_rel_step_tol = 1e-10
    nl_abs_step_tol = 1e-10
    l_tol = 1e-6
    l_max_its = 100
    nl_max_its = 10

    solve_type = pjfnk
    line_search = bt    # Options: default shell none basic l2 bt cp
    start_time = 0.0
#	end_time = 10.0
	end_time = 0.5
    dtmax = 0.1
    petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart'
    petsc_options_value = 'hypre boomeramg 100'

    [./TimeStepper]
#		type = SolutionTimeAdaptiveDT
		type = ConstantDT
        dt = 0.05
    [../]

[] #END Executioner

[Preconditioning]
 
	[./smp]
		type = SMP
		full = true
		petsc_options = '-snes_converged_reason'
		petsc_options_iname = '-pc_type -sub_pc_type -pc_hypre_type -ksp_gmres_restart  -snes_max_funcs'
		petsc_options_value = 'lu ilu boomeramg 2000 20000'
	[../]

[] #END Preconditioning

[Outputs]

    exodus = true
    csv = true
    print_linear_residuals = false

[] #END Outputs
