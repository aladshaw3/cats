# Testing of the calculation of fluid properties

[GlobalParams]

[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 5
  ny = 5
  xmin = 0.0
  xmax = 0.0004   # m
  ymin = 0.0
  ymax = 0.0004  # m

[] # END Mesh

[Variables]
  # pressure
  [./pressure]
      order = FIRST
      family = LAGRANGE
      initial_condition = 100 # kPa
  [../]

  # velocity in x
  [./vel_x]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
  [../]

  # velocity in y
  [./vel_y]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
  [../]

[]

[AuxVariables]
  # = (df^2/K/mu) * (eps^3/(1-eps)^2)  [cm^2/kPa/min]
  #
  #   df = 0.001 cm
  #   mu = 1.667E-8 kPa*min (10^-3 Pa*s)
  #   K = 5.55
  #   eps = 0.68
  [./DarcyCoeff]
      order = FIRST
      family = LAGRANGE
      initial_condition = 33.189
  [../]

  [./eps]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.68
  [../]

  # velocity in z
  [./vel_z]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
  [../]


  # Testing fluid prop base
  [./test_prop]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
  [../]
[]

[Kernels]
  [./pressure_laplace_electrodes]
    type = VariableLaplacian
    variable = pressure
    coupled_coef = DarcyCoeff
  [../]

  [./v_x_equ]
      type = Reaction
      variable = vel_x
  [../]
  [./x_darcy]
    type = VariableVectorCoupledGradient
    variable = vel_x
    coupled = pressure
    ux = DarcyCoeff
  [../]

  [./v_y_equ]
      type = Reaction
      variable = vel_y
  [../]
  [./y_darcy]
    type = VariableVectorCoupledGradient
    variable = vel_y
    coupled = pressure
    uy = DarcyCoeff
  [../]

[]

[DGKernels]
[]

[InterfaceKernels]

[] #END InterfaceKernels

[AuxKernels]

  [./test_calc]
      type = SimpleFluidPropertiesBase
      variable = test_prop

      pressure = pressure
      pressure_unit = "kPa"
      temperature = 298 # in K
      macro_porosity = eps

      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "cm"
      vel_time_unit = "min"

      ionic_strength = 0.005
      ionic_strength_volume_unit = "cm^3"

      ref_diffusivity = 2.296E-5
      diff_length_unit = "cm"
      diff_time_unit = "s"
      effective_diffusivity_factor = 1.5

      dispersivity = 0.01
      disp_length_unit = "cm"

      # No args for viscosity or density will make calculations
      # assuming that the solvent is water and use the standard
      # built-in coefficients to calculate properties

      execute_on = 'initial timestep_end'
  [../]
[]

[BCs]
  # exit pressure
  [./press_at_exit]
      type = DirichletBC
      variable = pressure
      boundary = 'top'
      value = 100 # kPa
  [../]

  # inlet pressure grad
  [./press_grad_at_inlet]
      type = NeumannBC
      variable = pressure
      boundary = 'bottom'
      value = 66   # vel in cm/min (0.37 to 1.1 cm/s)
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

  [./vel_y]
      type = ElementAverageValue
      variable = vel_y
      execute_on = 'initial timestep_end'
  [../]

  [./test]
      type = ElementAverageValue
      variable = test_prop
      execute_on = 'initial timestep_end'
  [../]

[]

[Executioner]
  type = Steady
  #scheme = implicit-euler

  # NOTE: Add arg -ksp_view to get info on methods used at linear steps
  petsc_options = '-snes_converged_reason

                    -ksp_gmres_modifiedgramschmidt'

  # NOTE: The sub_pc_type arg not used if pc_type is ksp,
  #       Instead, set the ksp_ksp_type to the pc method
  #       you want. Then, also set the ksp_pc_type to be
  #       the terminal preconditioner.
  #
  # Good terminal precon options: lu, ilu, asm, gasm, pbjacobi
  #                               bjacobi, redundant, telescope
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
