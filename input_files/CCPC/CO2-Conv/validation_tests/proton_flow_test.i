# Testing Proton flow over membrane with dummy potential
#
# May need 2 different diffusion terms for proton in membrane
#   (1) For the potential grad (use real molecular diff)
#   (2) For the concentration grad (for stabilization)
#
#   The secondary piece is needed since the Deff acts differently
#   for a diffusion only problem, then a diffusion advection problem.
#
#   Net effect is a smoother transition through the membrane and the
#   membrane is still 'relatively' impenetrable without a potential
#   gradient.

[GlobalParams]

[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
  [file]
    type = FileMeshGenerator
    file = FullCell_ValidationMesh_cm.msh

    ### ========= boundary_name ==========
    # "neg_collector_left"
    # "neg_collector_bottom"
    # "neg_collector_top"
    # "neg_collector_interface_neg_electrode"
    # "neg_electrode_bottom"
    # "neg_electrode_top"
    # "neg_electrode_interface_membrane"
    # "membrane_bottom"
    # "membrane_top"
    # "membrane_interface_pos_electrode"
    # "pos_electrode_bottom"
    # "pos_electrode_top"
    # "pos_electrode_interface_pos_collector"
    # "pos_collector_bottom"
    # "pos_collector_top"
    # "pos_collector_right"

    ### ====== block ========
    # "neg_collector"
    # "neg_electrode"
    # "membrane"
    # "pos_electrode"
    # "pos_collector"
  []

[] # END Mesh

[Variables]
  # pressure
  [./pressure]
      order = FIRST
      family = LAGRANGE
      initial_condition = 300 # kPa
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # velocity in x
  [./vel_x]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
    block = 'neg_electrode membrane pos_electrode'
  [../]

  # velocity in y
  [./vel_y]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
    block = 'neg_electrode membrane pos_electrode'
  [../]

  # dummy
  [./dummy]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  ### Other variables for mass and energy can be any order 'MONOMIAL' functions
  [./tracer]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0042 #mol/cm^3
      block = 'neg_electrode membrane pos_electrode'
  [../]

  [./proton]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0012 #mol/cm^3
      block = 'neg_electrode membrane pos_electrode'
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
      family = MONOMIAL
      initial_condition = 33.189
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # = kp / mu   [cm^2/kPa/min]
  #
  #   kp = 1.58E-14 cm^2
  #   mu = 1.667E-8 kPa*min (10^-3 Pa*s)
  [./SchloeglCoeff]
      order = FIRST
      family = MONOMIAL
      initial_condition = 9.4798E-7
      block = 'neg_electrode membrane pos_electrode'
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
      family = MONOMIAL
      initial_condition = 7.8485E-9
  [../]

  [./eps]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.68
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # Should be calculated in Aux system
  [./Dp_tracer]
      order = FIRST
      family = MONOMIAL
      initial_condition = 5E-2
      block = 'neg_electrode membrane pos_electrode'
  [../]

  [./Dp_proton]
      order = FIRST
      family = MONOMIAL
      initial_condition = 5E-2
      block = 'neg_electrode membrane pos_electrode'
  [../]

  [./Dp_proton_ekin]
      order = FIRST
      family = MONOMIAL
      initial_condition = 5E-2
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # velocity in z
  [./vel_z]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
    block = 'neg_electrode membrane pos_electrode'
  [../]

  # other properties
  [./viscosity]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1.667E-8 # kPa*min
    block = 'neg_electrode membrane pos_electrode'
  [../]

  [./Te]
    order = FIRST
    family = MONOMIAL
    initial_condition = 298 # K
    block = 'neg_electrode membrane pos_electrode'
  [../]
[]

[Kernels]
  [./pressure_laplace_electrodes]
    type = VariableLaplacian
    variable = pressure
    coupled_coef = DarcyCoeff
    block = 'neg_electrode pos_electrode'
  [../]
  [./pressure_laplace_membrane]
    type = VariableLaplacian
    variable = pressure
    coupled_coef = SchloeglCoeff
    block = 'membrane'
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
    block = 'neg_electrode pos_electrode'
  [../]
  [./x_schloegl]
    type = VariableVectorCoupledGradient
    variable = vel_x
    coupled = pressure
    ux = SchloeglCoeff
    block = 'membrane'
  [../]
  [./x_schloegl_ele]
    type = VariableVectorCoupledGradient
    variable = vel_x
    coupled = dummy
    ux = SchloeglElecCoeff
    block = 'membrane'
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
    block = 'neg_electrode pos_electrode'
  [../]
  [./y_schloegl]
    type = VariableVectorCoupledGradient
    variable = vel_y
    coupled = pressure
    uy = SchloeglCoeff
    block = 'membrane'
  [../]
  [./y_schloegl_ele]
    type = VariableVectorCoupledGradient
    variable = vel_y
    coupled = dummy
    uy = SchloeglElecCoeff
    block = 'membrane'
  [../]

  [./dummy]
    type = Diffusion
    variable = dummy
  [../]

  ### Conservation of mass for a dilute tracer ###
  [./tracer_dot]
      type = VariableCoefTimeDerivative
      variable = tracer
      coupled_coef = eps
  [../]
  [./tracer_gadv]
      type = GPoreConcAdvection
      variable = tracer
      porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./tracer_gdiff]
      type = GVarPoreDiffusion
      variable = tracer
      porosity = eps
      Dx = Dp_tracer
      Dy = Dp_tracer
      Dz = Dp_tracer
  [../]

  ### Conservation of mass for a proton ###
  [./proton_dot]
      type = VariableCoefTimeDerivative
      variable = proton
      coupled_coef = eps
  [../]
  [./proton_gadv]
      type = GPoreConcAdvection
      variable = proton
      porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      block = 'neg_electrode pos_electrode'
  [../]
  [./proton_gdiff]
      type = GVarPoreDiffusion
      variable = proton
      porosity = eps
      Dx = Dp_proton
      Dy = Dp_proton
      Dz = Dp_proton
  [../]
  [./proton_gnpdiff]
      type = GNernstPlanckDiffusion
      variable = proton
      valence = 1
      porosity = eps
      electric_potential = dummy
      temperature = Te
      Dx = Dp_proton_ekin
      Dy = Dp_proton_ekin
      Dz = Dp_proton_ekin
  [../]
[]

[DGKernels]
  ### Conservation of mass for a dilute tracer ###
  [./tracer_dgadv]
      type = DGPoreConcAdvection
      variable = tracer
      porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./tracer_dgdiff]
      type = DGVarPoreDiffusion
      variable = tracer
      porosity = eps
      Dx = Dp_tracer
      Dy = Dp_tracer
      Dz = Dp_tracer
  [../]

  ### Conservation of mass for a proton ###
  [./proton_dgadv]
      type = DGPoreConcAdvection
      variable = proton
      porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      block = 'neg_electrode pos_electrode'
  [../]
  [./proton_dgdiff]
      type = DGVarPoreDiffusion
      variable = proton
      porosity = eps
      Dx = Dp_proton
      Dy = Dp_proton
      Dz = Dp_proton
  [../]
  [./proton_dgnpdiff]
      type = DGNernstPlanckDiffusion
      variable = proton
      valence = 1
      porosity = eps
      electric_potential = dummy
      temperature = Te
      Dx = Dp_proton_ekin
      Dy = Dp_proton_ekin
      Dz = Dp_proton_ekin
  [../]
[]

[InterfaceKernels]
[] #END InterfaceKernels

[AuxKernels]

  [./eps_elec]
      type = ConstantAux
      variable = eps
      value = 0.68

      execute_on = 'initial timestep_end'
      block = 'neg_electrode pos_electrode'
  [../]

  [./eps_mem]
      type = ConstantAux
      variable = eps
      value = 0.999

      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]

  [./Disp_calc]
      type = SimpleFluidDispersion
      variable = Dp_tracer

      # ========== Standard Input Args ============
      pressure = pressure
      pressure_unit = "kPa"
      temperature = Te # in K
      macro_porosity = eps

      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "cm"
      vel_time_unit = "min"

      ref_diffusivity = 2.296E-5
      ref_diff_temp = 298
      diff_length_unit = "cm"
      diff_time_unit = "s"
      effective_diffusivity_factor = 0.5

      dispersivity = 0.001
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

      block = 'neg_electrode pos_electrode'
  [../]


  [./Disp_calc_mem]
      type = SimpleFluidDispersion
      variable = Dp_tracer

      # ========== Standard Input Args ============
      pressure = pressure
      pressure_unit = "kPa"
      temperature = Te # in K
      macro_porosity = eps

      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "cm"
      vel_time_unit = "min"

      ref_diffusivity = 5.76E-6
      ref_diff_temp = 298
      diff_length_unit = "cm"
      diff_time_unit = "s"
      effective_diffusivity_factor = 0.5

      dispersivity = 0.001
      disp_length_unit = "cm"

      # No args for viscosity or density will make calculations
      # assuming that the solvent is water and use the standard
      # built-in coefficients to calculate properties

      # ========== Output Args ============
      output_length_unit = "cm"
      output_time_unit = "min"
      include_dispersivity_correction = true
      include_porosity_correction = false

      execute_on = 'initial timestep_end'

      block = 'membrane'
  [../]

  [./Disp_proton_calc]
      type = SimpleFluidDispersion
      variable = Dp_proton

      # ========== Standard Input Args ============
      pressure = pressure
      pressure_unit = "kPa"
      temperature = Te # in K
      macro_porosity = eps

      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "cm"
      vel_time_unit = "min"

      ref_diffusivity = 1.4E-5
      ref_diff_temp = 298
      diff_length_unit = "cm"
      diff_time_unit = "s"
      effective_diffusivity_factor = 0.5

      dispersivity = 0.001
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

      block = 'neg_electrode pos_electrode'
  [../]

  [./Disp_proton_mem]
      type = SimpleFluidDispersion
      variable = Dp_proton

      # ========== Standard Input Args ============
      pressure = pressure
      pressure_unit = "kPa"
      temperature = Te # in K
      macro_porosity = eps

      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "cm"
      vel_time_unit = "min"

      ref_diffusivity = 1.4E-5
      ref_diff_temp = 298
      diff_length_unit = "cm"
      diff_time_unit = "s"
      effective_diffusivity_factor = 0.5

      dispersivity = 0.001
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

      block = 'membrane'
  [../]

  [./Disp_proton_mem_ekin]
      type = SimpleFluidDispersion
      variable = Dp_proton_ekin

      # ========== Standard Input Args ============
      pressure = pressure
      pressure_unit = "kPa"
      temperature = Te # in K
      macro_porosity = eps

      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "cm"
      vel_time_unit = "min"

      ref_diffusivity = 1.4E-5
      ref_diff_temp = 298
      diff_length_unit = "cm"
      diff_time_unit = "s"
      effective_diffusivity_factor = 0.5

      dispersivity = 0.001
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

      block = 'membrane neg_electrode pos_electrode'
  [../]

  [./darcy_calc]
      type = KozenyCarmanDarcyCoefficient
      variable = DarcyCoeff
      porosity = eps
      viscosity = viscosity
      particle_diameter = 0.001  #cm
      kozeny_carman_const = 5.55
      execute_on = 'initial timestep_end'
      block = 'neg_electrode pos_electrode'
  [../]

  [./schloegl_darcy_calc]
      type = SchloeglDarcyCoefficient
      variable = SchloeglCoeff
      hydraulic_permeability = 1.58E-14 # cm^2
      viscosity = viscosity             # kPa*min
      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]

  [./schloegl_ele_calc]
      type = SchloeglElectrokineticCoefficient
      variable = SchloeglElecCoeff
      electrokinetic_permeability = 1.13E-15  # cm^2
      viscosity = viscosity                   # kPa*min
      ion_conc = proton                       # mol/cm^3
      conversion_factor = 0.001               # kPa*cm^3/J
      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]

  [./viscosity_calc]
      type = SimpleFluidViscosity
      variable = viscosity

      # ========== Standard Input Args ============
      pressure = pressure
      pressure_unit = "kPa"
      temperature = Te # in K

      # No args for viscosity or density will make calculations
      # assuming that the solvent is water and use the standard
      # built-in coefficients to calculate properties

      # ========== Output Args ============
      output_pressure_unit = "kPa"
      output_time_unit = "min"
      unit_basis = "pressure"

      execute_on = 'initial timestep_end'
  [../]
[]

[BCs]
  # dummy potential bcs
  [./dummy_left]
      type = DirichletBC
      variable = dummy
      boundary = 'neg_collector_left'
      value = 1.0
  [../]
  [./dummy_left_plate]
      type = NeumannBC
      variable = dummy
      boundary = 'neg_collector_interface_neg_electrode'
      value = 0
  [../]
  [./dummy_left_mem]
      type = DirichletBC
      variable = dummy
      boundary = 'neg_electrode_interface_membrane'
      value = 1.02
      #value = 1.0
  [../]
  [./dummy_right_mem]
      type = DirichletBC
      variable = dummy
      boundary = 'membrane_interface_pos_electrode'
      value = 1.08
      #value = 1.0
  [../]
  [./dummy_right_plate]
      type = NeumannBC
      variable = dummy
      boundary = 'pos_electrode_interface_pos_collector'
      value = 0
  [../]
  [./dummy_right]
      type = DirichletBC
      variable = dummy
      boundary = 'pos_collector_right'
      value = 1.1
      #value = 1.0
  [../]

  # exit pressure
  [./press_at_exit]
      type = DirichletBC
      variable = pressure
      boundary = 'pos_electrode_top neg_electrode_top'
      value = 300 # kPa
  [../]

  [./press_at_membrane_bounds]
      type = NeumannBC
      variable = pressure
      boundary = 'membrane_top membrane_bottom'
      value = 0 # kPa
  [../]

  # inlet pressure grad
  [./press_grad_at_inlet]
      type = NeumannBC
      variable = pressure
      boundary = 'pos_electrode_bottom neg_electrode_bottom'
      value = 66   # vel in cm/min (0.37 to 1.1 cm/s)
  [../]

  ### Fluxes for Conservative Tracer ###
  [./tracer_FluxIn_pos]
      type = DGPoreConcFluxBC
      variable = tracer
      boundary = 'pos_electrode_bottom'
      porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      u_input = 0.0084
  [../]
  [./tracer_FluxIn_neg]
      type = DGPoreConcFluxBC
      variable = tracer
      boundary = 'neg_electrode_bottom'
      porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      u_input = 0.0042
  [../]
  [./tracer_FluxOut]
      type = DGPoreConcFluxBC
      variable = tracer
      boundary = 'pos_electrode_top neg_electrode_top'
      porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]


  ### Fluxes for Conservative proton ###
  [./proton_FluxIn_pos]
      type = DGPoreConcFluxBC
      variable = proton
      boundary = 'pos_electrode_bottom'
      porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      u_input = 0.0024
  [../]
  [./proton_FluxIn_neg]
      type = DGPoreConcFluxBC
      variable = proton
      boundary = 'neg_electrode_bottom'
      porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      u_input = 0.0012
  [../]
  [./proton_FluxOut]
      type = DGPoreConcFluxBC
      variable = proton
      boundary = 'pos_electrode_top neg_electrode_top'
      porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]

[]

[Postprocessors]
  [./pressure_inlet]
      type = SideAverageValue
      boundary = 'pos_electrode_bottom neg_electrode_bottom'
      variable = pressure
      execute_on = 'initial timestep_end'
  [../]

  [./pressure_outlet]
      type = SideAverageValue
      boundary = 'pos_electrode_top neg_electrode_top'
      variable = pressure
      execute_on = 'initial timestep_end'
  [../]

  [./vel_y_inlet]
      type = SideAverageValue
      boundary = 'pos_electrode_bottom neg_electrode_bottom'
      variable = vel_y
      execute_on = 'initial timestep_end'
  [../]

  [./vel_y_outlet]
      type = SideAverageValue
      boundary = 'pos_electrode_top neg_electrode_top'
      variable = vel_y
      execute_on = 'initial timestep_end'
  [../]

  [./vel_x_membrane]
      type = ElementAverageValue
      block = 'membrane'
      variable = vel_x
      execute_on = 'initial timestep_end'
  [../]

  [./tracer_inlet]
      type = SideAverageValue
      boundary = 'pos_electrode_bottom neg_electrode_bottom'
      variable = tracer
      execute_on = 'initial timestep_end'
  [../]

  [./tracer_outlet]
      type = SideAverageValue
      boundary = 'pos_electrode_top neg_electrode_top'
      variable = tracer
      execute_on = 'initial timestep_end'
  [../]

  [./proton_inlet]
      type = SideAverageValue
      boundary = 'pos_electrode_bottom neg_electrode_bottom'
      variable = proton
      execute_on = 'initial timestep_end'
  [../]

  [./proton_outlet]
      type = SideAverageValue
      boundary = 'pos_electrode_top neg_electrode_top'
      variable = proton
      execute_on = 'initial timestep_end'
  [../]

[]

[Executioner]
  type = Transient
  scheme = implicit-euler

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

  start_time = 0.0
  end_time = 1.0
  dtmax = 0.025

  [./TimeStepper]
		  type = ConstantDT
      dt = 0.025
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
    print_linear_residuals = true

[] #END Outputs
