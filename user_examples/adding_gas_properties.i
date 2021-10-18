# NOTE: The simulation results when we add the gas properties now change.
#       That change is driven by the fact that our properties are no longer
#       constants, but are instead a function of temperature and pressure.
#       The biggest change comes from the gas thermal conductivity. Previously,
#       we gave a conductivity of 0.1 W/m/K, but that value is only good at
#       certain temperatures. Given the actual column temperature, this value
#       is closer to 0.03 W/m/K, which has a significant impact on the evolution
#       of temperature in the column over time.

[GlobalParams]
    forward_activation_energy = 0   #J/mol
    forward_pre_exponential = 2        #m^3/mol/s
    reverse_activation_energy = 2305   #J/mol
    reverse_pre_exponential = 1     #m^3/mol/s
    enthalpy = -2305    #J/mol

    # Gas Properties arguments
    gases = 'N2 C'
    molar_weights = '28 18'
    sutherland_temp = '300.55 298.16'
    sutherland_const = '111 784.72'
    sutherland_vis = '0.0001781 0.0001043'
    spec_heat = '1.04 1.97'
    is_ideal_gas = false
    execute_on = 'initial timestep_end'
[] #END GlobalParams

[Problem]
    coord_type = RZ
[] #END Problem

[Mesh]
    [./my_mesh]
        type = GeneratedMeshGenerator
        dim = 2
        nx = 5
        ny = 20
        xmin = 0.0
        xmax = 0.05
        ymin = 0.0
        ymax = 0.1
    [../]
[] # END Mesh

[Variables]
    [./Ef]
        order = FIRST
        family = MONOMIAL
        [./InitialCondition]
            type = InitialPhaseEnergy
            specific_heat = cpf
            density = rho
            temperature = Tf
        [../]
    [../]

    [./Es]
        order = FIRST
        family = MONOMIAL
        [./InitialCondition]
            type = InitialPhaseEnergy
            specific_heat = cps
            density = rhop
            temperature = Ts
        [../]
    [../]

    [./Tf]
        order = FIRST
        family = LAGRANGE
        initial_condition = 400
    [../]

    [./Ts]
        order = FIRST
        family = LAGRANGE
        initial_condition = 400
    [../]

    [./C]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./Cp]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]

    [./q]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]

    [./S]
        order = FIRST
        family = LAGRANGE
        initial_condition = 1
    [../]
[] #END Variables

[AuxVariables]
  [./eps]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.5
  [../]

  [./s_frac]
    # Solids fraction: (1 - eps)
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.5
  [../]

  [./vel_x]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  [./vel_y]
      order = FIRST
      family = LAGRANGE
      initial_condition = 3
  [../]

  [./vel_z]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  [./Kf]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0.1
  [../]

  [./Ks]
    order = FIRST
    family = MONOMIAL
    initial_condition = 20
  [../]

  [./h]
    order = FIRST
    family = MONOMIAL
    initial_condition = 600
  [../]

  [./Ao]
    order = FIRST
    family = MONOMIAL
    initial_condition = 5000
  [../]

  [./rho]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1.2
  [../]

  [./cpf]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1100
  [../]

  [./rhop]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1500
  [../]

  [./cps]
    order = FIRST
    family = MONOMIAL
    initial_condition = 900
  [../]

  [./Tw]
      order = FIRST
      family = LAGRANGE
      initial_condition = 300
  [../]

  [./hw]
     order = FIRST
     family = MONOMIAL
     initial_condition = 100
  [../]

   [./D]
     order = FIRST
     family = MONOMIAL
     initial_condition = 2.5E-5
   [../]

   [./k]
     order = FIRST
     family = MONOMIAL
     initial_condition = 1
   [../]

   [./eps_p]
       order = FIRST
       family = MONOMIAL
       initial_condition = 0.25
   [../]

   [./S_max]
     order = FIRST
     family = MONOMIAL
     initial_condition = 1
   [../]

    [./P]
      order = FIRST
      family = MONOMIAL
      initial_condition = 101350
    [../]

    [./mu]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1.81E-5
    [../]

    [./N2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 40
    [../]
[] #END AuxVariables

[Kernels]
# Conservation of energy for fluid
    [./Ef_dot]
        type = VariableCoefTimeDerivative
        variable = Ef
        coupled_coef = eps
    [../]
    [./Ef_gadv]
        type = GPoreConcAdvection
        variable = Ef
        porosity = eps
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./Ef_gdiff]
        type = GPhaseThermalConductivity
        variable = Ef
        temperature = Tf
        volume_frac = eps
        Dx = Kf
        Dy = Kf
        Dz = Kf
    [../]
    [./Ef_trans]
        type = PhaseEnergyTransfer
        variable = Ef
        this_phase_temp = Tf
        other_phase_temp = Ts
        transfer_coef = h
        specific_area = Ao
        volume_frac = s_frac
    [../]

 # Conservation of energy for solid
    [./Es_dot]
        type = TimeDerivative
        variable = Es
    [../]
    [./Es_gdiff]
        type = GPhaseThermalConductivity
        variable = Es
        temperature = Ts
        volume_frac = 1
        Dx = Ks
        Dy = Ks
        Dz = Ks
    [../]
    [./Es_trans]
        type = PhaseEnergyTransfer
        variable = Es
        this_phase_temp = Ts
        other_phase_temp = Tf
        transfer_coef = h
        specific_area = Ao
        volume_frac = 1
    [../]
    [./Es_rxn] #   Cp + S <-- --> q
        type = ArrheniusReactionEnergyTransfer
        variable = Es
        this_variable = Es
        temperature = Ts
        volume_frac = rhop
        reactants = 'Cp S'
        reactant_stoich = '1 1'
        products = 'q'
        product_stoich = '1'
    [../]

# Temperature of fluid
    [./Tf_calc]
        type = PhaseTemperature
        variable = Tf
        energy = Ef
        specific_heat = cpf
        density = rho
    [../]

# Temperature of solid
    [./Ts_calc]
        type = PhaseTemperature
        variable = Ts
        energy = Es
        specific_heat = cps
        density = rhop
    [../]

 # Conservation of mass for C
    [./C_dot]
        type = VariableCoefTimeDerivative
        variable = C
        coupled_coef = eps
    [../]
    [./C_gadv]
        type = GPoreConcAdvection
        variable = C
        porosity = eps
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./C_gdiff]
        type = GVarPoreDiffusion
        variable = C
        porosity = eps
        Dx = D
        Dy = D
        Dz = D
    [../]
    [./C_trans_Cp]
        type = FilmMassTransfer
        variable = C
        coupled = Cp
        rate_variable = k
        # Area to volume ratio: Ao*(1 - eps)
        av_ratio = 2500
    [../]

 # Conservation of mass for Cp
    [./Cp_dot]
        type = VariableCoefTimeDerivative
        variable = Cp
        coupled_coef = eps_p
    [../]
    [./Cp_trans_C]
        type = FilmMassTransfer
        variable = Cp
        coupled = C
        rate_variable = k
        # Area to volume ratio: Ao
        av_ratio = 5000
    [../]
    [./ads_q]
      type = CoupledCoeffTimeDerivative
      variable = Cp
      coupled = q
      time_coeff = 1500
    [../]

 # Conservation of mass for q
    [./q_dot]
        type = TimeDerivative
        variable = q
    [../]
    [./q_rxn]  #   Cp + S <-- --> q
        type = ArrheniusReaction
        variable = q
        this_variable = q
        temperature = Ts
        scale = 1.0
        reactants = 'Cp S'
        reactant_stoich = '1 1'
        products = 'q'
        product_stoich = '1'
    [../]

 # Conservation of mass for S
    [./S_bal]
      type = MaterialBalance
      variable = S
      this_variable = S
      coupled_list = 'S q'
      weights = '1 1'
      total_material = S_max
    [../]

[] #END Kernels

[DGKernels]
    [./Ef_dgadv]
        type = DGPoreConcAdvection
        variable = Ef
        porosity = eps
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./Ef_dgdiff]
        type = DGPhaseThermalConductivity
        variable = Ef
        temperature = Tf
        volume_frac = eps
        Dx = Kf
        Dy = Kf
        Dz = Kf
    [../]

    [./Es_dgdiff]
        type = DGPhaseThermalConductivity
        variable = Es
        temperature = Ts
        volume_frac = 1
        Dx = Ks
        Dy = Ks
        Dz = Ks
    [../]

    [./C_dgadv]
        type = DGPoreConcAdvection
        variable = C
        porosity = eps
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./C_dgdiff]
        type = DGVarPoreDiffusion
        variable = C
        porosity = eps
        Dx = D
        Dy = D
        Dz = D
    [../]
[] #END DGKernels


[BCs]

    [./Ef_Flux_OpenBounds]
        type = DGFlowEnergyFluxBC
        variable = Ef
        boundary = 'bottom top'
        porosity = eps
        specific_heat = cpf
        density = rho
        inlet_temp = 400
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    [./Ef_WallFluxIn]
        type = DGWallEnergyFluxBC
        variable = Ef
        boundary = 'right'
        transfer_coef = hw
        wall_temp = Tw
        temperature = Tf
        area_frac = eps
    [../]

    [./Es_WallFluxIn]
        type = DGWallEnergyFluxBC
        variable = Es
        boundary = 'right'
        transfer_coef = hw
        wall_temp = Tw
        temperature = Ts
        area_frac = s_frac
    [../]

    [./C_FluxIn]
      type = DGPoreConcFluxBC
      variable = C
      boundary = 'bottom'
      u_input = 1.0
      porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
    [../]
    [./C_FluxOut]
      type = DGPoreConcFluxBC
      variable = C
      boundary = 'top'
      porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
    [../]

[] #END BCs

[AuxKernels]
     [./P_ergun]
         type = AuxErgunPressure
         variable = P
        # Pressure drop will apply in direction of flow, which in this case is the y-direction
         direction = 1
         porosity = eps
         temperature = Tf
         # NOTE: Use inlet/outlet pressure for pressure variable in aux pressure kernel
         pressure = 101350
         is_inlet_press = true
         start_point = 0
         end_point = 0.1
         # Particle size in m  (recall, Ao = 5000 = 3/r for this demo)
         hydraulic_diameter = 0.0012
         ux = vel_x
         uy = vel_y
         uz = vel_z
     [../]

     [./dens_calc]
         type = GasDensity
         variable = rho
         temperature = Tf
         pressure = P
         hydraulic_diameter = 0.0012
         ux = vel_x
         uy = vel_y
         uz = vel_z
     [../]

     [./Kf_calc]
         type = GasThermalConductivity
         variable = Kf
         temperature = Tf
         pressure = P
         hydraulic_diameter = 0.0012
         ux = vel_x
         uy = vel_y
         uz = vel_z
     [../]

     [./vis_calc]
         type = GasViscosity
         variable = mu
         temperature = Tf
         pressure = P
         hydraulic_diameter = 0.0012
         ux = vel_x
         uy = vel_y
         uz = vel_z
     [../]

     [./cp_calc]
         type = GasSpecHeat
         variable = cpf
         temperature = Tf
         pressure = P
         hydraulic_diameter = 0.0012
         ux = vel_x
         uy = vel_y
         uz = vel_z
     [../]

     [./k_calc]
         type = GasSpeciesMassTransCoef
         variable = k
         species_index = 1
         temperature = Tf
         pressure = P
         hydraulic_diameter = 0.0012
         ux = vel_x
         uy = vel_y
         uz = vel_z
     [../]

    [./D_calc]
        type = GasSpeciesAxialDispersion
        variable = D
        species_index = 1
        # Bed diameter (in m)
        macroscale_diameter = 0.1
        temperature = Tf
        pressure = P
        hydraulic_diameter = 0.0012
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

[] #END AuxKernels

[Postprocessors]
    [./T_exit]
        type = SideAverageValue
        boundary = 'top'
        variable = Tf
        execute_on = 'initial timestep_end'
    [../]
    [./Ts_avg]
        type = ElementAverageValue
        variable = Ts
        execute_on = 'initial timestep_end'
    [../]

    [./C_exit]
        type = SideAverageValue
        boundary = 'top'
        variable = C
        execute_on = 'initial timestep_end'
    [../]
    [./q_avg]
        type = ElementAverageValue
        variable = q
        execute_on = 'initial timestep_end'
    [../]

    [./P_exit]
        type = SideAverageValue
        boundary = 'top'
        variable = P
        execute_on = 'initial timestep_end'
    [../]
    [./P_enter]
        type = SideAverageValue
        boundary = 'bottom'
        variable = P
        execute_on = 'initial timestep_end'
    [../]

    [./rho]
        type = ElementAverageValue
        variable = rho
        execute_on = 'initial timestep_end'
    [../]
    [./k]
        type = ElementAverageValue
        variable = k
        execute_on = 'initial timestep_end'
    [../]
    [./D]
        type = ElementAverageValue
        variable = D
        execute_on = 'initial timestep_end'
    [../]
    [./cpf]
        type = ElementAverageValue
        variable = cpf
        execute_on = 'initial timestep_end'
    [../]
    [./mu]
        type = ElementAverageValue
        variable = mu
        execute_on = 'initial timestep_end'
    [../]
    [./Kf]
        type = ElementAverageValue
        variable = Kf
        execute_on = 'initial timestep_end'
    [../]
[] #END Postprocessors

[Preconditioning]
    [./SMP_PJFNK]
        type = SMP
        full = true
    [../]
[] #END Preconditioning

[Executioner]
    type = Transient
    scheme = bdf2
    solve_type = pjfnk
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
                          -pc_asm_overlap

                          -snes_atol
                          -snes_rtol

                          -ksp_ksp_type
                          -ksp_pc_type'

    # snes_max_it = maximum non-linear steps
    petsc_options_value = 'fgmres
                           ksp

                           lu

                           10
                           NONZERO
                           10
                           1E-8
                           1E-10

                           gmres
                           lu'

    line_search = none
    nl_rel_tol = 1e-8
    nl_abs_tol = 1e-8
    nl_rel_step_tol = 1e-12
    nl_abs_step_tol = 1e-12
    nl_max_its = 10
    l_tol = 1e-6
    l_max_its = 300

    start_time = 0.0
    end_time = 80.0
    dtmax = 0.5

    [./TimeStepper]
        type = ConstantDT
        dt = 0.2
    [../]

[] #END Executioner

[Outputs]
    print_linear_residuals = true
    exodus = true
    csv = true
    interval = 10
[] #END Outputs
