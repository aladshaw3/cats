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

  # = kp / mu   [cm^2/kPa/min]
  #
  #   kp = 1.58E-14 cm^2
  #   mu = 1.667E-8 kPa*min (10^-3 Pa*s)
  [./SchloeglCoeff]
      order = FIRST
      family = LAGRANGE
      initial_condition = 9.4798E-7
  [../]

  # = (ko / mu) * (F*C) * f   [(cm^2/kPa/min) * (C/mol * mol/cm^3) * (kPa*cm^3/J)] = [C*cm^2/J/min]
  #
  #   ko = 1.13E-15 cm^2
  #   mu = 1.667E-8 kPa*min (10^-3 Pa*s)
  #
  #   F = 96,485.3 C/mol
  #   C = 0.0012 mol/cm^3 (should be coupled variable)
  #
  #   f = conversion factor necessary to deal with complex units
  #     = 0.001 kPa*cm^3/J
  #       [Will ultimately depend on units defined by all other variables]
  [./SchloeglElecCoeff]
      order = FIRST
      family = LAGRANGE
      initial_condition = 7.8485E-9
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
  [./viscosity]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
  [../]

  [./mass_viscosity]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
  [../]

  [./viscosity_electrolyte]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
  [../]

  [./rho]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
  [../]

  [./MolDiff]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
  [../]

  [./eff_disp]
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

  [./darcy_calc]
      type = KozenyCarmanDarcyCoefficient
      variable = DarcyCoeff
      porosity = eps
      viscosity = viscosity
      particle_diameter = 0.001  #cm
      kozeny_carman_const = 5.55
      execute_on = 'initial timestep_end'
  [../]

  [./schloegl_darcy_calc]
      type = SchloeglDarcyCoefficient
      variable = SchloeglCoeff
      hydraulic_permeability = 1.58E-14 # cm^2
      viscosity = viscosity             # kPa*min
      execute_on = 'initial timestep_end'
  [../]

  [./schloegl_ele_calc]
      type = SchloeglElectrokineticCoefficient
      variable = SchloeglElecCoeff
      electrokinetic_permeability = 1.13E-15  # cm^2
      viscosity = viscosity                   # kPa*min
      ion_conc = 0.0012                       # mol/cm^3
      conversion_factor = 0.001               # kPa*cm^3/J
      execute_on = 'initial timestep_end'
  [../]

  [./viscosity_calc]
      type = SimpleFluidViscosity
      variable = viscosity

      # ========== Standard Input Args ============
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

      # ========== Output Args ============
      output_pressure_unit = "kPa"
      output_time_unit = "min"
      unit_basis = "pressure"

      execute_on = 'initial timestep_end'
  [../]

  [./mass_viscosity_calc]
      type = SimpleFluidViscosity
      variable = mass_viscosity

      # ========== Standard Input Args ============
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

      # ========== Output Args ============
      output_mass_unit = "kg"
      output_length_unit = "cm"
      output_time_unit = "min"
      unit_basis = "mass"

      execute_on = 'initial timestep_end'
  [../]

  [./viscosity_ele_calc]
      type = SimpleFluidElectrolyteViscosity
      variable = viscosity_electrolyte

      # ========== Standard Input Args ============
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

      # ========== Output Args ============
      output_pressure_unit = "kPa"
      output_time_unit = "min"
      unit_basis = "pressure"

      execute_on = 'initial timestep_end'
  [../]

  [./rho_calc]
      type = SimpleFluidDensity
      variable = rho

      # ========== Standard Input Args ============
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

      # ========== Output Args ============
      output_volume_unit = "mL"
      output_mass_unit = "g"

      execute_on = 'initial timestep_end'
  [../]

  [./MolDiff_calc]
      type = SimpleFluidDispersion
      variable = MolDiff

      # ========== Standard Input Args ============
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

      # ========== Output Args ============
      output_length_unit = "cm"
      output_time_unit = "min"
      include_dispersivity_correction = false
      include_porosity_correction = false

      execute_on = 'initial timestep_end'
  [../]

  [./disp_calc]
      type = SimpleFluidDispersion
      variable = eff_disp

      # ========== Standard Input Args ============
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

      # ========== Output Args ============
      output_length_unit = "cm"
      output_time_unit = "min"
      include_dispersivity_correction = true
      include_porosity_correction = true

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

  [./viscosity]
      type = ElementAverageValue
      variable = viscosity
      execute_on = 'initial timestep_end'
  [../]

  [./mass_viscosity]
      type = ElementAverageValue
      variable = mass_viscosity
      execute_on = 'initial timestep_end'
  [../]

  [./viscosity_electrolyte]
      type = ElementAverageValue
      variable = viscosity_electrolyte
      execute_on = 'initial timestep_end'
  [../]

  [./density]
      type = ElementAverageValue
      variable = rho
      execute_on = 'initial timestep_end'
  [../]

  [./MolDiff]
      type = ElementAverageValue
      variable = MolDiff
      execute_on = 'initial timestep_end'
  [../]

  [./eff_disp]
      type = ElementAverageValue
      variable = eff_disp
      execute_on = 'initial timestep_end'
  [../]

  [./DarcyCoeff]
      type = ElementAverageValue
      variable = DarcyCoeff
      execute_on = 'initial timestep_end'
  [../]

  [./SchloeglCoeff]
      type = ElementAverageValue
      variable = SchloeglCoeff
      execute_on = 'initial timestep_end'
  [../]

  [./SchloeglElecCoeff]
      type = ElementAverageValue
      variable = SchloeglElecCoeff
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
