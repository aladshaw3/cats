# This input file tests various options for the compressible NS equations in a channel.

# Uses the standard MOOSE input file style, which is very verbose
# NOTE: Simulation throws exception from IdealGasProperties object

[GlobalParams]

[]

[Mesh]
  file = 2D-Flow-Converted.unv
  boundary_name = 'inlet outlet top bottom object'
[]


[Variables]
  #density
  [./rho]
    order = FIRST
    family = LAGRANGE
  [../]
  #momentum in x
  [./rhou]
    order = FIRST
    family = LAGRANGE
  [../]
  #momentum in y
  [./rhov]
    order = FIRST
    family = LAGRANGE
  [../]
  #total_energy
  [./rhoE]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[AuxVariables]
  #velocity in x
  [./vel_x]
    order = FIRST
    family = LAGRANGE
  [../]
  #velocity in y
  [./vel_y]
    order = FIRST
    family = LAGRANGE
  [../]
  #pressure
  [./pressure]
    order = FIRST
    family = LAGRANGE
  [../]
  #temperature
  [./temperature]
    order = FIRST
    family = LAGRANGE
  [../]
  #enthalpy
  [./enthalpy]
    order = FIRST
    family = LAGRANGE
  [../]
  #internal_energy
  [./internal_energy]
    order = FIRST
    family = LAGRANGE
  [../]
  #specific_volume
  [./specific_volume]
    order = FIRST
    family = LAGRANGE
  [../]
  #Mach
  [./Mach]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[ICs]
  [./rhoIC]
    type = NSInitialCondition
    variable = rho
    initial_pressure = 101325
    initial_temperature = 300
    initial_velocity = '.1 0 0'
    fluid_properties = ideal_gas
  [../]
  [./rhouIC]
    type = NSInitialCondition
    variable = rhou
    initial_pressure = 101325
    initial_temperature = 300
    initial_velocity = '.1 0 0'
    fluid_properties = ideal_gas
  [../]
  [./rhovIC]
    type = NSInitialCondition
    variable = rhov
    initial_pressure = 101325
    initial_temperature = 300
    initial_velocity = '.1 0 0'
    fluid_properties = ideal_gas
  [../]
  [./rhoEIC]
    type = NSInitialCondition
    variable = rhoE
    initial_pressure = 101325
    initial_temperature = 300
    initial_velocity = '.1 0 0'
    fluid_properties = ideal_gas
  [../]
  [./vel_xIC]
    type = NSInitialCondition
    variable = vel_x
    initial_pressure = 101325
    initial_temperature = 300
    initial_velocity = '.1 0 0'
    fluid_properties = ideal_gas
  [../]
  [./vel_yIC]
    type = NSInitialCondition
    variable = vel_y
    initial_pressure = 101325
    initial_temperature = 300
    initial_velocity = '.1 0 0'
    fluid_properties = ideal_gas
  [../]
  [./pressureIC]
    type = NSInitialCondition
    variable = pressure
    initial_pressure = 101325
    initial_temperature = 300
    initial_velocity = '.1 0 0'
    fluid_properties = ideal_gas
  [../]
  [./temperatureIC]
    type = NSInitialCondition
    variable = temperature
    initial_pressure = 101325
    initial_temperature = 300
    initial_velocity = '.1 0 0'
    fluid_properties = ideal_gas
  [../]
  [./enthalpyIC]
    type = NSInitialCondition
    variable = enthalpy
    initial_pressure = 101325
    initial_temperature = 300
    initial_velocity = '.1 0 0'
    fluid_properties = ideal_gas
  [../]
  [./internal_energyIC]
    type = NSInitialCondition
    variable = internal_energy
    initial_pressure = 101325
    initial_temperature = 300
    initial_velocity = '.1 0 0'
    fluid_properties = ideal_gas
  [../]
  [./specific_volumeIC]
    type = NSInitialCondition
    variable = specific_volume
    initial_pressure = 101325
    initial_temperature = 300
    initial_velocity = '.1 0 0'
    fluid_properties = ideal_gas
  [../]
  [./MachIC]
    type = NSInitialCondition
    variable = Mach
    initial_pressure = 101325
    initial_temperature = 300
    initial_velocity = '.1 0 0'
    fluid_properties = ideal_gas
  [../]
[]

[Modules]
  [./FluidProperties]
    [./ideal_gas]
      type = IdealGasFluidProperties
      #options below are default settings
      gamma = 1.4
      mu = 18.23e-6
      k = 25.68e-3
      molar_mass = 29.0e-3
      T_c = 0
      rho_c = 0
      e_c = 0
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

[Kernels]
  #Mass Equ
  [./mass]
    type = NSSUPGMass
    variable = rho
    rho = rho
    rhou = rhou
    rhov = rhov
    rhoE = rhoE
    vel_x = vel_x
    vel_y = vel_y
    temperature = temperature
    enthalpy = enthalpy
    fluid_properties = ideal_gas
  [../]

  #Conservation of momentum equ in x
  [./x_momentum]
    type = NSSUPGMomentum
    variable = rhou
    component = 0
    rho = rho
    rhou = rhou
    rhov = rhov
    rhoE = rhoE
    vel_x = vel_x
    vel_y = vel_y
    temperature = temperature
    enthalpy = enthalpy
    fluid_properties = ideal_gas
  [../]

  #Conservation of momentum equ in y
  [./y_momentum]
    type = NSSUPGMomentum
    variable = rhov
    component = 1
    rho = rho
    rhou = rhou
    rhov = rhov
    rhoE = rhoE
    vel_x = vel_x
    vel_y = vel_y
    temperature = temperature
    enthalpy = enthalpy
    fluid_properties = ideal_gas
  [../]

  #Conservation of total energy
  [./energy]
    type = NSSUPGEnergy
    variable = rhoE
    rho = rho
    rhou = rhou
    rhov = rhov
    rhoE = rhoE
    vel_x = vel_x
    vel_y = vel_y
    temperature = temperature
    enthalpy = enthalpy
    fluid_properties = ideal_gas
  [../]
[]

[AuxKernels]
  [./spec_vol]
    type = SpecificVolumeAux
    variable = specific_volume
    rho = rho
  [../]
  [./int_energy]
    type = NSInternalEnergyAux
    variable = internal_energy
    rho = rho
    vel_x = vel_x
    vel_y = vel_y
    rhoE = rhoE
  [../]
  [./temp]
    type = NSTemperatureAux
    variable = temperature
    specific_volume = specific_volume
    internal_energy = internal_energy
    fluid_properties = ideal_gas
  [../]
  [./dH]
    type = NSEnthalpyAux
    variable = enthalpy
    rho = rho
    rhoE = rhoE
    pressure = pressure
  [../]
  [./velocity_x]
    type = NSVelocityAux
    variable = vel_x
    rho = rho
    momentum = rhou
    fluid_properties = ideal_gas
  [../]
  [./velocity_y]
    type = NSVelocityAux
    variable = vel_y
    rho = rho
    momentum = rhov
    fluid_properties = ideal_gas
  [../]
  [./press]
    type = NSPressureAux
    variable = pressure
    specific_volume = specific_volume
    internal_energy = internal_energy
    fluid_properties = ideal_gas
  [../]
  [./mach]
    type = NSMachAux
    variable = Mach
    vel_x = vel_x
    vel_y = vel_y
    specific_volume = specific_volume
    internal_energy = internal_energy
    fluid_properties = ideal_gas
  [../]
[]

[BCs]
  [./rho_inlet]
    type = DirichletBC
    variable = rho
    boundary = 'inlet'
    value = 1.178038049    # For now, rho = p * _molar_mass / (_R * T)
    						# p = initial, T = initial, _molar_mass = molar_mass, _R = 8.3144598
  [../]
  # All others are natural BCs (outflow)

  [./rhou_inlet]
    type = NSImposedVelocityBC
    variable = rhou
    boundary = 'inlet'
    rho = rho
    desired_velocity = 1
  [../]
  [./rhou_noSlip]
    type = NSImposedVelocityBC
    variable = rhou
    boundary = 'object'
    rho = rho
    desired_velocity = 0
  [../]
  # All others are natural BCs (outflow)

  [./rhov_inlet_and_noSlip]
    type = NSImposedVelocityBC
    variable = rhov
    boundary = 'inlet object'
    rho = rho
    desired_velocity = 0
  [../]
  # All others are natural BCs (outflow)


  [./rhoE_inlet]
    type = NSInflowThermalBC
    variable = rhoE
    boundary = 'inlet'
    specified_rho = 1.178038049
    specified_temperature = 300
    specified_velocity_magnitude = 1
    fluid_properties = ideal_gas
  [../]
  # All others are natural BCs (outflow) [unsure about this]

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
  end_time = 100.0
  dtmax = 0.5

  [./TimeStepper]
	type = SolutionTimeAdaptiveDT
#    type = ConstantDT
    dt = 0.01
  [../]
[]

[Outputs]
  print_linear_residuals = false
  exodus = true
[]

#[Functions]
#  [./inlet_func]
#    type = ParsedFunction
#    #Parabola that has momentum of zero at y=top and=bot, with maximum at y=middle
#    #value = a*y^2 + b*y + c	solve for a, b, and c
#    value = '1.178038049*(-0.25 * y^2 + 1)'    #rho*velocity = inlet momentum
#  [../]
#  [./energy_func]
#    type = ParsedFunction
#    value = '1.178038049*((-0.25 * y^2 + 1)^2/2 + 300*0.718e3)'    #rho*(c_v*T + |u|^2/2) = inlet energy
#  [../]
#[]
