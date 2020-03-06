# This input file tests various options for the compressible NS equations in a channel.

# Uses the action system MOOSE style of input, which is poorly documented

[Mesh]
   file = 2D-Flow-Converted.unv
   boundary_name = 'inlet outlet top bottom object'
[]



[Modules]
  [./FluidProperties]
    [./ideal_gas]
      type = IdealGasFluidProperties
      gamma = 1.4
      molar_mass = 0.02897024320557491
    [../]
  [../]

  [./NavierStokes]
    [./Variables]
      #         'rho rhou rhov   rhoE'
      scaling = '1.  1.    1.    9.869232667160121e-6'
      family = LAGRANGE
      order = FIRST
    [../]

    [./ICs]
      initial_pressure = 101325.
      initial_temperature = 300.
      initial_velocity = '0 0 0'        			# Mach 0.5: = 0.5*sqrt(gamma*R*T)   [SEE bump.i]
      fluid_properties = ideal_gas
    [../]

    [./Kernels]
      fluid_properties = ideal_gas
    [../]

	#Currently, don't understand what these BCs are doing...
    [./BCs]
      [./inlet]
        type = NSWeakStagnationInletBC
        boundary = 'inlet'
        stagnation_pressure = 103325. 		# Pa, Mach=0.5 at 1 atm    [SEE bump.i]
        stagnation_temperature = 315 				# K, Mach=0.5 at 1 atm    [SEE bump.i]
        sx = 1.
        sy = 0.
        fluid_properties = ideal_gas
      [../]

      [./solid_walls]
        type = NSNoPenetrationBC
        boundary = 'top bottom object'
        fluid_properties = ideal_gas
      [../]

      [./outlet]
        type = NSStaticPressureOutletBC
        boundary = 'outlet'
        specified_pressure = 101325 # Pa
        fluid_properties = ideal_gas
      [../]
    [../]
  [../]
[]



[Materials]
  [./fluid]
    type = Air
    block = 0
    rho = rho
    rhou = rhou
    rhov = rhov
    rhoE = rhoE
    vel_x = vel_x
    vel_y = vel_y
    temperature = temperature
    enthalpy = enthalpy
    dynamic_viscosity = 1.983e-5
    fluid_properties = ideal_gas
  [../]
[]



#[Postprocessors]
#  [./entropy_error]
#    type = NSEntropyError
#    execute_on = 'initial timestep_end'
#    block = 0
#    rho_infty = 1.1768292682926829
#    p_infty = 101325
#    rho = rho
#    pressure = pressure
#    fluid_properties = ideal_gas
#  [../]
#[]



[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
    solve_type = 'NEWTON'
  [../]
[]



[Executioner]
#  type = Transient
#  dt = 5.e-5
#  dtmin = 1.e-5
#  start_time = 0.0
#  num_steps = 10
#  nl_rel_tol = 1e-9
#  nl_max_its = 5
#  l_tol = 1e-4
#  l_max_its = 100

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
  end_time = 0.01
  dtmax = 0.5

  [./TimeStepper]
    type = SolutionTimeAdaptiveDT
#    type = ConstantDT
    dt = 0.00005
 [../]

  # We use trapezoidal quadrature.  This improves stability by
  # mimicking the "group variable" discretization approach.
#  [./Quadrature]
#    type = TRAP
#    order = FIRST
#  [../]
[]



[Outputs]
  print_linear_residuals = false
  exodus = true
[]
