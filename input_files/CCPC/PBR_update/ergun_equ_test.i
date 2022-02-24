
[GlobalParams]

[] #END GlobalParams

[Problem]
    coord_type = RZ
    #NOTE: For RZ coordinates, x ==> R and y ==> Z (and z ==> nothing)
[] #END Problem

[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = 3
    ny = 10
    xmin = 0.0
    xmax = 1.0    #2cm diameter
    ymin = 0.0
    ymax = 5.0    #5cm length
[] # END Mesh

[Variables]

    # units of pressure calculated are based on
    # the units for viscosity and density
    # In this case, pressure is in kg/cm/min/min
    [./pressure]
        order = FIRST
        family = LAGRANGE
        initial_condition = 3648600  # equals 101.35 kPa
    [../]

    [./vel_x]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./vel_y]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1.015E4 #cm/min
    [../]

[] #END Variables

[AuxVariables]

  [./temp]
      order = FIRST
      family = MONOMIAL
      initial_condition = 423.15
  [../]

  # e_b
  [./pore]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.43
  [../]

  [./vel_z]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  # particle diameter
  [./dp]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.077  #cm
  [../]

  # ErgunCoefficient
  [./ergun_coeff]
      order = FIRST
      family = MONOMIAL
  [../]

  # inlet velocity
  [./vel_in]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1.015E4  #cm/min
  [../]

  # velocity magnitude
  [./vel_mag]
      order = FIRST
      family = MONOMIAL
  [../]

  # density (kg/cm^3)
  [./dens]
      order = FIRST
      family = MONOMIAL
  [../]

  # viscosity (kg/cm/min)
  [./vis]
      order = FIRST
      family = MONOMIAL
  [../]

[] #END AuxVariables

[Kernels]
  [./pressure_laplace]
    type = VariableLaplacian
    variable = pressure
    coupled_coef = ergun_coeff
  [../]

  [./v_x_equ]
      type = Reaction
      variable = vel_x
  [../]
  [./x_ergun]
    type = VariableVectorCoupledGradient
    variable = vel_x
    coupled = pressure
    ux = ergun_coeff
  [../]

  [./v_y_equ]
      type = Reaction
      variable = vel_y
  [../]
  [./y_ergun]
    type = VariableVectorCoupledGradient
    variable = vel_y
    coupled = pressure
    uy = ergun_coeff
  [../]
[]

[AuxKernels]
  [./ergun_calc]
      type = ErgunCoefficient
      variable = ergun_coeff

      porosity = pore
      viscosity = vis
      density = dens
      velocity = vel_mag
      particle_diameter = dp

      execute_on = 'initial timestep_end'
  [../]

  [./vel_calc]
      type = VectorMagnitude
      variable = vel_mag

      ux = vel_x
      uy = vel_y
      uz = vel_z

      execute_on = 'initial timestep_end'
  [../]

  [./velocity_inlet]
      type = GasVelocityCylindricalReactor
      variable = vel_in
      porosity = pore
      space_velocity = 1000   #volumes per min
      inlet_temperature = temp
      inlet_pressure = 101.35 #kPa
      ref_pressure = 101.35
      ref_temperature = 273.15
      radius = 1  #cm
      length = 5  #cm
      execute_on = 'initial timestep_end'
  [../]

  [./dens_calc]
      type = SimpleGasDensity
      variable = dens

      pressure = pressure
      use_pressure_units = false
      pressure_mass_unit = "kg"
      pressure_length_unit = "cm"
      pressure_time_unit = "min"

      temperature = temp

      output_length_unit = "cm"
      output_mass_unit = "kg"

      execute_on = 'initial timestep_end'
  [../]

  [./vis_calc]
      type = SimpleGasViscosity
      variable = vis

      pressure = pressure
      use_pressure_units = false
      pressure_mass_unit = "kg"
      pressure_length_unit = "cm"
      pressure_time_unit = "min"

      temperature = temp

      output_length_unit = "cm"
      output_mass_unit = "kg"
      output_time_unit = "min"

      execute_on = 'initial timestep_end'
  [../]
[]

[BCs]
  # exit pressure
  [./press_at_exit]
      type = CoupledDirichletBC
      variable = pressure
      boundary = 'top'
      coupled = 3648600   #units of kg/cm/min/min
  [../]

  # inlet pressure grad
  [./press_grad_at_inlet]
      type = CoupledNeumannBC
      variable = pressure
      boundary = 'bottom'
      coupled = vel_in
  [../]
[]

[Postprocessors]
  [./pressure_inlet]
      type = SideAverageValue
      boundary = 'bottom'
      variable = pressure
      execute_on = 'initial timestep_end'
  [../]

  [./pressure_outlet]
      type = SideAverageValue
      boundary = 'top'
      variable = pressure
      execute_on = 'initial timestep_end'
  [../]

  [./vel_y_inlet]
      type = SideAverageValue
      boundary = 'bottom'
      variable = vel_y
      execute_on = 'initial timestep_end'
  [../]

  [./vel_in_inlet]
      type = SideAverageValue
      boundary = 'bottom'
      variable = vel_in
      execute_on = 'initial timestep_end'
  [../]

  [./vel_mag_inlet]
      type = SideAverageValue
      boundary = 'bottom'
      variable = vel_mag
      execute_on = 'initial timestep_end'
  [../]

  [./vel_y_outlet]
      type = SideAverageValue
      boundary = 'top'
      variable = vel_y
      execute_on = 'initial timestep_end'
  [../]

  [./ergun_coeff]
      type = SideAverageValue
      boundary = 'bottom'
      variable = ergun_coeff
      execute_on = 'initial timestep_end'
  [../]
[]

[Executioner]
  type = Steady

  # NOTE: Add arg -ksp_view to get info on methods used at linear steps
  petsc_options = '-snes_converged_reason

                    -ksp_gmres_modifiedgramschmidt'

  petsc_options_iname ='-ksp_type
                        -pc_type

                        -sub_pc_type

                        -snes_max_it

                        -sub_pc_factor_shift_type
                        -pc_factor_shift_type
                        -ksp_pc_factor_shift_type

                        -pc_asm_overlap

                        -snes_atol
                        -snes_rtol

                        -ksp_ksp_type
                        -ksp_pc_type'

  petsc_options_value = 'fgmres
                         ksp

                         lu

                         20

                         NONZERO
                         NONZERO
                         NONZERO

                         10

                         1E-10
                         1E-10

                         fgmres
                         lu'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = none
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-10
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 20
  l_tol = 1e-6
  l_max_its = 20

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
    print_linear_residuals = true

[] #END Outputs
