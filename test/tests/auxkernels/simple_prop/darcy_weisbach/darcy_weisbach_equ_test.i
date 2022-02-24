
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
    # the units for velocity and density
    # In this case, pressure is in g/cm/min/min
    #   NOTE: In this case we are only calculating relative pressure
    #         differentials in the system (NOT total pressure). This
    #         is generally the best way to do this. 
    [./pressure]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]

    [./vel_x]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./vel_y]
        order = FIRST
        family = MONOMIAL
        initial_condition = 100 #cm/min
    [../]

[] #END Variables

[AuxVariables]

  [./temp]
      order = FIRST
      family = MONOMIAL
      initial_condition = 298.15
  [../]

  [./vel_z]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  # hydraulic diameter
  [./dh]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.077  #cm
  [../]

  # friction factor
  [./fD]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.05
  [../]

  # DarcyWeisbachCoefficient
  [./dw_coeff]
      order = FIRST
      family = MONOMIAL
  [../]

  # inlet velocity
  [./vel_in]
      order = FIRST
      family = MONOMIAL
      initial_condition = 100.0  #cm/min
  [../]

  # velocity magnitude
  [./vel_mag]
      order = FIRST
      family = MONOMIAL
  [../]

  # density (g/cm^3)
  [./dens]
      order = FIRST
      family = MONOMIAL
  [../]

[] #END AuxVariables

[Kernels]
  [./pressure_laplace]
    type = VariableLaplacian
    variable = pressure
    coupled_coef = dw_coeff
  [../]

  [./v_x_equ]
      type = Reaction
      variable = vel_x
  [../]
  [./x_ergun]
    type = VariableVectorCoupledGradient
    variable = vel_x
    coupled = pressure
    ux = dw_coeff
  [../]

  [./v_y_equ]
      type = Reaction
      variable = vel_y
  [../]
  [./y_ergun]
    type = VariableVectorCoupledGradient
    variable = vel_y
    coupled = pressure
    uy = dw_coeff
  [../]
[]

[AuxKernels]
  [./dw_calc]
      type = DarcyWeisbachCoefficient
      variable = dw_coeff

      friction_factor = fD
      density = dens
      velocity = vel_mag
      hydraulic_diameter = dh

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

  [./dens_calc]
      type = SimpleGasDensity
      variable = dens

      pressure = 100  #used as inlet total pressure (or reference pressure)
      pressure_unit = "kPa"
      use_pressure_units = true

      pressure_mass_unit = "g"
      pressure_length_unit = "cm"
      pressure_time_unit = "min"

      temperature = temp

      output_length_unit = "cm"
      output_mass_unit = "g"

      execute_on = 'initial timestep_end'
  [../]

[]

[BCs]
  # exit pressure (reference state relative to atm pressure)
  [./press_at_exit]
      type = CoupledDirichletBC
      variable = pressure
      boundary = 'top'
      coupled = 0   #units of g/cm/min/min
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

  [./dw_coeff]
      type = SideAverageValue
      boundary = 'bottom'
      variable = dw_coeff
      execute_on = 'initial timestep_end'
  [../]

  [./dens]
      type = SideAverageValue
      boundary = 'bottom'
      variable = dens
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
                         lu

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
