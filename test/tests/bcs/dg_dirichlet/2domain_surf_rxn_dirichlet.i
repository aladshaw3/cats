# This input file tests various options for the incompressible NS equations in a channel.

# CONVERGES WELL

# NOTES
# -------
# There are multiple types of stabilization possible in incompressible
# Navier Stokes. The user can specify supg = true to apply streamline
# upwind petrov-galerkin stabilization to the momentum equations. This
# is most useful for high Reynolds numbers, e.g. when inertial effects
# dominate over viscous effects. The user can also specify pspg = true
# to apply pressure stabilized petrov-galerkin stabilization to the mass
# equation. PSPG is a form of Galerkin Least Squares. This stabilization
# allows equal order interpolations to be used for pressure and velocity.
# Finally, the alpha parameter controls the amount of stabilization.
# For PSPG, decreasing alpha leads to increased accuracy but may induce
# spurious oscillations in the pressure field. Some numerical experiments
# suggest that alpha between .1 and 1 may be optimal for accuracy and
# robustness.

# Parameters given below provide the best tested compromise of stability and accuracy

# NOTE: If you want an approximate steady-state flow profile, use MAXIMUM STABILITY options (alpha = 1.0 and all set to true)
#       and simulate for many time steps.

[GlobalParams]
  gravity = '0 0 0'				#gravity accel for body force
  integrate_p_by_parts = true	#how to include the pressure gradient term (not sure what it does, but solves when true)
  supg = true 					#activates SUPG stabilization (excellent stability, always necessary)
  pspg = true					#activates PSPG stabilization for pressure term (excellent stability, lower accuracy)
  alpha = 0.1 					#stabilization multiplicative correction factor (0.1 < alpha <= 1) [lower value improves accuracy]
  laplace = true				#whether or not viscous term is in laplace form
  convective_term = true		#whether or not to include advective/convective term
  transient_term = true			#whether or not to include time derivative in supg correction (sometimes needed)
  Dxx = 0.1
  Dyy = 0.1
  Dzz = 0.0
[]

[Mesh]
  #FileMeshGenerator automatically assigns boundary names from the .unv file
  #   .unv file MUST HAVE specific boundary names in it
  [./obstruct_file]
    type = FileMeshGenerator
    file = 2D-obstruction-Converted.unv
  [../]
  #The above file contains the following block and boundary names
  #boundary_name = 'inlet outlet top bottom object'
  #block_name = 'conduit obstruction'
[]

#Use MONOMIAL for DG and LAGRANGE for non-DG
[Variables]
  [./conc]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0.0
    block = 'conduit obstruction'
  [../]
  [./solid]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
    block = 'obstruction'
  [../]
  [./vel_x]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
    block = 'conduit'
  [../]
  [./vel_y]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
    block = 'conduit'
  [../]
  [./p]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
    block = 'conduit'
  [../]
[]

[AuxVariables]

	[./vel_z]
    order = FIRST
    family = LAGRANGE
		initial_condition = 0
    block = 'conduit'
	[../]

[] #END AuxVariables

#NOTE: For additional refinement, should have separate variables
#       for inner and outer concentrations. Each would have their
#       own set of kernels and boundary conditions. Need to use
#       a film mass transfer BC. Concentration in outer needs to
#       deplete as concentration inner increases.
[Kernels]
  #Mass conservation kernels
  [./conc_dot]
    type = CoefTimeDerivative
    variable = conc
    Coefficient = 1.0
    block = 'conduit obstruction'
  [../]
  [./conc_gadv]
    type = GConcentrationAdvection
    variable = conc
    ux = vel_x
    uy = vel_y
    uz = vel_z
    block = 'conduit'
  [../]
  [./conc_gdiff]
    type = GAnisotropicDiffusion
    variable = conc
    block = 'conduit obstruction'
  [../]
  [./coupled_dot]
    type = CoupledTimeDerivative
    variable = conc
    v = solid
    block = 'obstruction'
  [../]

  #Mass transfer to walls
  [./solid_dot]
    type = CoefTimeDerivative
    variable = solid
    Coefficient = 1.0
    block = 'obstruction'
  [../]
  [./rxn_solid]
    type = CoupledForce   #NOTE: CoupledForce is basically a cross-coupled linear reaction with respect to the coupled variable v
    variable = solid
    v = conc
    coef = 1
    block = 'obstruction'         #block id 1 corresponds to the boundaries from our MeshSideSet
  [../]

  #Continuity Equ
  [./mass]
    type = INSMass
    variable = p
    u = vel_x
    v = vel_y
    pressure = p
    block = 'conduit'
  [../]

  #Conservation of momentum equ in x (with time derivative)
  [./x_momentum_time]
    type = INSMomentumTimeDerivative
    variable = vel_x
    block = 'conduit'
  [../]
  [./x_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_x
    u = vel_x
    v = vel_y
    pressure = p
    component = 0
    block = 'conduit'
  [../]

  #Conservation of momentum equ in y (with time derivative)
  [./y_momentum_time]
    type = INSMomentumTimeDerivative
    variable = vel_y
    block = 'conduit'
  [../]
  [./y_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_y
    u = vel_x
    v = vel_y
    pressure = p
    component = 1
    block = 'conduit'
  [../]
[]

[DGKernels]
    #Mass conservation dgkernels
    [./conc_dgadv]
      type = DGConcentrationAdvection
		  variable = conc
		  ux = vel_x
		  uy = vel_y
		  uz = vel_z
      block = 'conduit'
    [../]
    [./conc_dgdiff]
        type = DGAnisotropicDiffusion
        variable = conc
        dg_scheme = 'nipg'   #options: 'nipg', 'sipg', 'iipg'
        sigma = 10
        block = 'conduit obstruction'
    [../]

[] #END DGKernels

[BCs]
  [./x_no_slip]
    type = DirichletBC
    variable = vel_x
    boundary = 'top bottom object'
    value = 0.0
  [../]
  [./y_no_slip]
    type = DirichletBC
    variable = vel_y
    boundary = 'inlet top bottom object'
    value = 0.0
  [../]
  [./x_inlet]
    type = FunctionDirichletBC
    variable = vel_x
    boundary = 'inlet'
    function = 'inlet_func'
  [../]

  [./conc_FluxIn]
    #type = DGConcentrationFluxLimitedBC   #Emulated Dirichlet BC with coupled velocities
    type = DGFluxLimitedBC                 #Emulated Dirichlet BC without any velocity
    variable = conc
    boundary = 'inlet'
		u_input = 1.0
		#ux = vel_x
		#uy = vel_y
		#uz = vel_z
    dg_scheme = 'nipg'   #options: 'nipg', 'sipg', 'iipg'
    sigma = 10
  [../]

  [./conc_FluxOut]
    type = DGConcentrationFluxBC
    variable = conc
    boundary = 'outlet'
    u_input = 0.0
    ux = vel_x
    uy = vel_y
    uz = vel_z
  [../]
[]

[Materials]
#NOTE: Every block in the mesh requires a Material
  [./const]
    type = GenericConstantMaterial
    block = 'conduit obstruction'
    prop_names = 'rho mu'
    #              kg/m^3  kg/m/s
    #prop_values = '1000.0  0.001'   #VALUES FOR WATER
    prop_values = '1.225  1.81E-5'   #VALUES FOR AIR
  [../]
[]

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
    solve_type = newton   #newton solver works faster when using very good preconditioner
  [../]
[]

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
    type = ConstantDT
    dt = 0.1
  [../]
[]

[Outputs]
  print_linear_residuals = false
  exodus = true
[]

[Functions]
  [./inlet_func]
    type = ParsedFunction
    #Parabola that has velocity of zero at y=top and=bot, with maximum at y=middle
    #value = a*y^2 + b*y + c	solve for a, b, and c
    expression = '-0.25 * y^2 + 1'
  [../]
[]
