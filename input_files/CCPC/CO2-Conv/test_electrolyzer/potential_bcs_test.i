# Test the pressure driven flow in the domain

[GlobalParams]
    min_conductivity = 2.26E-3
[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
  [file]
    type = FileMeshGenerator
    file = 2D_Electrolyzer_mm.msh

    ### ========= boundary_name ==========
    # "cathode_fluid_channel_left"
    # "cathode_fluid_channel_bottom"
    # "cathode_fluid_channel_top"
    # "cathode_fluid_channel_interface_cathode"
    # "cathode_bottom"
    # "cathode_top"
    # "cathode_interface_membrane"
    # "membrane_bottom"
    # "membrane_top"
    # "membrane_interface_anode"
    # "anode_bottom"
    # "anode_top"
    # "anode_interface_anode_fluid_channel"
    # "anode_fluid_channel_bottom"
    # "anode_fluid_channel_top"
    # "anode_fluid_channel_right"

    ### ====== block ========
    # "cathode_fluid_channel"
    # "cathode"
    # "membrane"
    # "anode"
    # "anode_fluid_channel"
  []

[] # END Mesh

[Variables]
  # electrolyte potential (in V or J/C)
  [./phi_e]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
      scaling = 1
  [../]

  # electrode potential (in V or J/C)
  [./phi_s]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
      block = 'cathode anode'
      scaling = 1
  [../]

  # Variable for potential difference
  [./phi_diff]
      order = FIRST
      family = LAGRANGE
      block = 'cathode anode'
      [./InitialCondition]
          type = InitialPotentialDifference
          electrode_potential = phi_s
          electrolyte_potential = phi_e
      [../]
      scaling = 1
  [../]

  # relative pressure (units = g/mm/s^2 == Pa)
  [./pressure]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.0
  [../]

  # velocity in x
  [./vel_x]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0
  [../]

  # velocity in y
  [./vel_y]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0
  [../]

  [./H2O]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1.2E-6 #mol/mm^3
      scaling = 1e6
  [../]
[]

[AuxVariables]
  # velocity in z
  [./vel_z]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0
  [../]

  # velocity magnitude
  #   NOTE: We MUST set an initial condition here because the
  #         DarcyWeisbachCoefficient requires a non-zero velocity
  #         magnitude in order to estimate the pressure drop.
  [./vel_mag]
      order = FIRST
      family = MONOMIAL
      initial_condition = 40.0  #mm^2/s based on inlet condition
  [../]

  [./D_H2O]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0017  #mm^2/s
  [../]

  [./eps]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.80
  [../]

  [./sol_vol_frac]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.20
  [../]

  [./density]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001 # g/mm^3
  [../]
  [./viscosity]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001 # Pa*s = kg/m/s = g/mm/s
  [../]

  # coefficient for all domains
  [./press_coef]
      order = FIRST
      family = MONOMIAL
  [../]

  # Electrolyte temperature
  [./T_e]
      order = FIRST
      family = MONOMIAL
      initial_condition = 300 #K
  [../]

  # Electrode temperature
  [./T_s]
      order = FIRST
      family = MONOMIAL
      initial_condition = 300 #K
  [../]

  # Solids avg conductivity
  [./sigma_s]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1.476E4 #C/V/s/mm == 1.476E7 S/m
      block = 'cathode anode'
  [../]

  # Electrode avg conductivity
  #       ~2.26 S/M (for 0.1 M ionic strength)
  #       ~10.7 S/M (for 0.5 M ionic strength)
  #       ~20.1 S/M (for 1.0 M ionic strength)
  #       ~35.2 S/M (for 2.0 M ionic strength)
  [./sigma_e]
      order = FIRST
      family = MONOMIAL
      initial_condition = 2.26E-3 #C/V/s/mm == 2.26 S/m (for 0.1 M solution)
  [../]
[]

[Kernels]
  ## =============== Potential Difference ==================
  [./phi_diff_equ]
      type = Reaction
      variable = phi_diff
  [../]
  [./phi_diff_sum]
      type = WeightedCoupledSumFunction
      variable = phi_diff
      coupled_list = 'phi_s phi_e'
      weights = '1 -1'
  [../]

  ### ==================== Electrolyte Potentials ==========================
  # Calculate potential from gradients in system
  [./phi_e_potential_conductivity]
      type = ElectrolytePotentialConductivity
      variable = phi_e
      porosity = eps
      temperature = T_e
      ion_conc = ''
      diffusion = ''
      ion_valence = ''
  [../]
  [./phi_e_J]
      type = ScaledWeightedCoupledSumFunction
      variable = phi_e
      coupled_list = 'phi_diff'
      weights = '1'
      block = 'cathode anode'
  [../]

  ### ==================== Electrode Potentials ==========================
  # Calculate potential from conductivity
  [./phi_s_pot_cond]
      type = ElectrodePotentialConductivity
      variable = phi_s
      solid_frac = sol_vol_frac
      conductivity = sigma_s
      block = 'cathode anode'
  [../]
  [./phi_s_J]
      type = ScaledWeightedCoupledSumFunction
      variable = phi_s
      coupled_list = 'phi_diff'
      weights = '-1'
      block = 'cathode anode'
  [../]

  ## =============== Pressure ========================
  [./pressure_laplace_channels]
      type = VariableLaplacian
      variable = pressure
      coupled_coef = press_coef
      block = 'cathode_fluid_channel anode_fluid_channel'
  [../]
  [./pressure_laplace_darcy]
      type = VariableLaplacian
      variable = pressure
      coupled_coef = press_coef
      block = 'cathode anode'
  [../]
  [./pressure_laplace_mem]
      type = VariableLaplacian
      variable = pressure
      coupled_coef = press_coef
      block = 'membrane'
  [../]

  ## =================== vel in x ==========================
  [./v_x_equ]
      type = Reaction
      variable = vel_x
  [../]
  [./x_channel]
      type = VariableVectorCoupledGradient
      variable = vel_x
      coupled = pressure
      ux = press_coef
      block = 'cathode_fluid_channel anode_fluid_channel'
  [../]
  [./x_darcy]
      type = VariableVectorCoupledGradient
      variable = vel_x
      coupled = pressure
      ux = press_coef
      block = 'cathode anode'
  [../]
  [./x_mem]
      type = VariableVectorCoupledGradient
      variable = vel_x
      coupled = pressure
      ux = press_coef
      block = 'membrane'
  [../]

  ## ================== vel in y =========================
  [./v_y_equ]
      type = Reaction
      variable = vel_y
  [../]
  [./y_channel]
      type = VariableVectorCoupledGradient
      variable = vel_y
      coupled = pressure
      uy = press_coef
      block = 'cathode_fluid_channel anode_fluid_channel'
  [../]
  [./y_darcy]
      type = VariableVectorCoupledGradient
      variable = vel_y
      coupled = pressure
      uy = press_coef
      block = 'cathode anode'
  [../]
  [./y_mem]
      type = VariableVectorCoupledGradient
      variable = vel_y
      coupled = pressure
      uy = press_coef
      block = 'membrane'
  [../]

  ## ===================== H2O balance ====================
  [./H2O_dot]
      type = VariableCoefTimeDerivative
      variable = H2O
      coupled_coef = eps
  [../]
  [./H2O_gadv]
      type = GPoreConcAdvection
      variable = H2O
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./H2O_gdiff]
      type = GVarPoreDiffusion
      variable = H2O
      porosity = eps
      Dx = D_H2O
      Dy = D_H2O
      Dz = D_H2O
  [../]
[]

[DGKernels]
  ## ===================== H2O balance ====================
  [./H2O_dgadv]
      type = DGPoreConcAdvection
      variable = H2O
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./H2O_dgdiff]
      type = DGVarPoreDiffusion
      variable = H2O
      porosity = eps
      Dx = D_H2O
      Dy = D_H2O
      Dz = D_H2O
  [../]
[]

[InterfaceKernels]
[] #END InterfaceKernels

[AuxKernels]
  [./vel_calc]
      type = VectorMagnitude
      variable = vel_mag
      ux = vel_x
      uy = vel_y
      uz = vel_z
      execute_on = 'timestep_end'
  [../]

  [./eps_calc_one]
      type = ConstantAux
      variable = eps
      value = 0.999

      execute_on = 'initial timestep_end'
      block = 'cathode_fluid_channel membrane anode_fluid_channel'
  [../]
  [./eps_calc_two]
      type = ConstantAux
      variable = eps
      value = 0.80

      execute_on = 'initial timestep_end'
      block = 'cathode anode'
  [../]

  [./Disp_calc_channels]
      type = SimpleFluidDispersion
      variable = D_H2O
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.0017
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = true
      include_porosity_correction = false

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'cathode_fluid_channel anode_fluid_channel'
  [../]

  [./Disp_calc_elec]
      type = SimpleFluidDispersion
      variable = D_H2O
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.0017
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = true
      include_porosity_correction = true

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'cathode anode'
  [../]

  [./Disp_calc_mem]
      type = SimpleFluidDispersion
      variable = D_H2O
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.0017
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = false
      include_porosity_correction = false

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]

  [./dens_calc]
      type = SimpleFluidDensity
      variable = density
      temperature = 298

      output_volume_unit = "mm^3"
      output_mass_unit = "g"

      execute_on = 'initial timestep_end'
  [../]

  [./visc_calc]
      type = SimpleFluidViscosity
      variable = viscosity
      temperature = 298

      output_length_unit = "mm"
      output_mass_unit = "g"
      output_time_unit = "s"

      unit_basis = "mass"

      execute_on = 'initial timestep_end'
  [../]


  [./coef_calc_channels]
      type = DarcyWeisbachCoefficient
      variable = press_coef

      friction_factor = 0.05
      density = density          #g/mm^3
      velocity = vel_mag         #mm/s
      hydraulic_diameter = 1.6   #mm

      execute_on = 'initial timestep_end'
      block = 'cathode_fluid_channel anode_fluid_channel'
  [../]

  [./coef_calc_elec]
      type = KozenyCarmanDarcyCoefficient
      variable = press_coef

      porosity = eps
      viscosity = viscosity   #g/mm/s
      particle_diameter = 0.1 #mm
      kozeny_carman_const = 5.55

      execute_on = 'initial timestep_end'
      block = 'cathode anode'
  [../]

  [./coef_calc_mem]
      type = SchloeglDarcyCoefficient
      variable = press_coef

      hydraulic_permeability = 1.58E-12  #mm^2
      viscosity = viscosity  #g/mm/s

      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]

  [./sigma_e_calc]
      type = ElectrolyteConductivity
      variable = sigma_e
      temperature = T_e
      ion_conc = ''
      diffusion = ''
      ion_valence = ''
      execute_on = 'initial timestep_end'
  [../]

  [./sol_vol_calc]
      type = SolidsVolumeFraction
      variable = sol_vol_frac
      porosity = eps
      execute_on = 'initial timestep_end'
  [../]
[]

[BCs]
  # exit pressure
  [./press_at_exit]
      type = DirichletBC
      variable = pressure
      boundary = 'cathode_fluid_channel_top anode_fluid_channel_top'
      value = 0
  [../]

  # inlet pressure grad
  [./press_grad_at_inlet]
      type = NeumannBC
      variable = pressure
      boundary = 'cathode_fluid_channel_bottom anode_fluid_channel_bottom'
      value = 40   # vel in mm/s
  [../]

  # zero pressure grad at non-exits
  [./press_grad_at_non_exits]
      type = NeumannBC
      variable = pressure
      boundary = 'cathode_bottom cathode_top anode_bottom anode_top membrane_bottom membrane_top'
      value = 0
  [../]

  # Ground state
  [./phi_s_ground_side]
      type = CoupledDirichletBC
      variable = phi_s
      boundary = 'cathode_fluid_channel_interface_cathode'
      #
      ## edge value was defined at 0 V
      coupled = 0 # in V
  [../]
  [./phi_e_ground_side]
      type = CoupledDirichletBC
      variable = phi_e
      boundary = 'cathode_fluid_channel_left'
      #
      ## edge value was defined at 0 V
      coupled = 0 # in V
  [../]

  # Applied Voltage
  [./phi_s_applied_side]
      type = CoupledDirichletBC
      variable = phi_s
      boundary = 'anode_interface_anode_fluid_channel'
      #
      ## edge value was defined at 0 V
      coupled = 1 # in V
  [../]
  [./phi_e_applied_side]
      type = CoupledDirichletBC
      variable = phi_e
      boundary = 'anode_fluid_channel_right'
      #
      ## edge value was defined at 0 V
      coupled = 0 # in V
  [../]

  ## =============== H2O fluxes ================
  [./H2O_FluxIn_pos]
      type = DGPoreConcFluxBC
      variable = H2O
      boundary = 'cathode_fluid_channel_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      u_input = 2.4E-6
  [../]
  [./H2O_FluxIn_neg]
      type = DGPoreConcFluxBC
      variable = H2O
      boundary = 'anode_fluid_channel_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      u_input = 1.2E-6
  [../]
  [./H2O_FluxOut]
      type = DGPoreConcFluxBC
      variable = H2O
      boundary = 'cathode_fluid_channel_top anode_fluid_channel_top'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
[]

[Postprocessors]
  [./pressure_inlet]
      type = SideAverageValue
      boundary = 'cathode_fluid_channel_bottom anode_fluid_channel_bottom'
      variable = pressure
      execute_on = 'initial timestep_end'
  [../]

  [./pressure_outlet]
      type = SideAverageValue
      boundary = 'cathode_fluid_channel_top anode_fluid_channel_top'
      variable = pressure
      execute_on = 'initial timestep_end'
  [../]

  [./vel_y_inlet]
      type = SideAverageValue
      boundary = 'cathode_fluid_channel_bottom anode_fluid_channel_bottom'
      variable = vel_y
      execute_on = 'initial timestep_end'
  [../]

  [./vel_y_outlet]
      type = SideAverageValue
      boundary = 'cathode_fluid_channel_top anode_fluid_channel_top'
      variable = vel_y
      execute_on = 'initial timestep_end'
  [../]

  [./H2O_inlet]
      type = SideAverageValue
      boundary = 'cathode_fluid_channel_bottom anode_fluid_channel_bottom'
      variable = H2O
      execute_on = 'initial timestep_end'
  [../]

  [./H2O_outlet]
      type = SideAverageValue
      boundary = 'cathode_fluid_channel_top anode_fluid_channel_top'
      variable = H2O
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
  line_search = l2
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-10
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 20
  l_tol = 1e-6
  l_max_its = 20

  start_time = 0.0
  end_time = 0.5
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
