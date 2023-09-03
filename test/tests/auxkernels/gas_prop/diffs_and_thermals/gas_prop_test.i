[GlobalParams]
  
[] #END GlobalParams

[Mesh]
    type = GeneratedMesh
	coord_type = RZ
	#NOTE: For RZ coordinates, x ==> R and y ==> Z (and z ==> nothing)
    dim = 2
    nx = 1
    ny = 10
    xmin = 0.0
    xmax = 0.01    # 2cm radius
    ymin = 0.0
    ymax = 0.05    # 5 cm length
[] # END Mesh

[Variables]

    [./u]
        order = FIRST
        family = LAGRANGE
    [../]

[] #END Variables

[AuxVariables]

    [./P]
        order = FIRST
        family = MONOMIAL
    [../]

  [./pore]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.3309
  [../]

  [./vel_x]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  [./vel_y]
      order = FIRST
      family = LAGRANGE
      initial_condition = 1.26 #m/s
  [../]

  [./vel_z]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]
 
  [./dens]
     order = FIRST
     family = MONOMIAL
#     initial_condition = 0.6158   #kg/m^3
  [../]
 
  [./vis]
     order = FIRST
     family = MONOMIAL
#     initial_condition = 2.93E-5   #kg/m/s
  [../]

    [./cp]      #units: J/kg/K
      order = FIRST
      family = MONOMIAL
   [../]
 
     [./cv]      #units: J/kg/K
       order = FIRST
       family = MONOMIAL
    [../]
   
  [./dia]
     order = FIRST
     family = MONOMIAL
     initial_condition = 0.000777   #m
  [../]
 
    [./macro_dia]
       order = FIRST
       family = MONOMIAL
       initial_condition = 0.02   #m
    [../]
 
    [./temp]
       order = FIRST
       family = MONOMIAL
       initial_condition = 273   #K
    [../]
 
    [./O2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 5.35186739166803E-05  #mol/L
    [../]

    [./H2O]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.001337966847917       #mol/L
    [../]
 
    [./NH3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 2.87293E-05     #mol/L
    [../]
 
    [./P_in]
        order = FIRST
        family = MONOMIAL
        initial_condition = 102300
    [../]
 
# Units --> m^/2
    [./D_NH3]
        order = FIRST
        family = MONOMIAL
    [../]
 
 # Units --> m^/2
    [./Dp_NH3]
        order = FIRST
        family = MONOMIAL
    [../]

 # Units --> m^/2
    [./Dpe_NH3]
        order = FIRST
        family = MONOMIAL
    [../]
 
 # Units --> m^/2
    [./Dz_NH3]
        order = FIRST
        family = MONOMIAL
    [../]
 
 # Units --> m^/2
    [./km_NH3]
        order = FIRST
        family = MONOMIAL
    [../]
 
    [./micro_pore]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.2
    [../]
 
    [./rp]
        order = FIRST
        family = MONOMIAL
        initial_condition = 2.65E-8   #m (micro-pore radius)
    [../]
 
 # Units --> m^/2
    [./kme_NH3]
        order = FIRST
        family = MONOMIAL
    [../]
 
 # Units --> W/m/K
    [./K_g]
        order = FIRST
        family = MONOMIAL
    [../]
 
 # Units --> W/m/K
    [./K_eff]
        order = FIRST
        family = MONOMIAL
    [../]

[] #END AuxVariables

[ICs]

[] #END ICs

[Kernels]
 
    [./uu]
        type = TimeDerivative
        variable = u
    [../]
 
[] #END Kernels

[DGKernels]

[] #END DGKernels

[AuxKernels]
     [./P_ergun]
        type = AuxErgunPressure
        variable = P
        direction = 1
        porosity = pore
        temperature = temp
        # NOTE: Use inlet/outlet pressure for pressure variable in aux pressure kernel
        pressure = P_in
        is_inlet_press = true
        start_point = 0
        end_point = 0.05
        hydraulic_diameter = dia
        ux = vel_x
        uy = vel_y
        uz = vel_z
        gases = 'NH3 H2O O2'
        molar_weights = '17.031 18 32'
        sutherland_temp = '293.17 292.25 298.16'
        sutherland_const = '370 784.72 127'
        sutherland_vis = '0.0000982 0.001043 0.0002018'
        spec_heat = '2.175 1.97 0.919'
        execute_on = 'initial timestep_end'
    [../]
 
    [./vis_calc]
        type = GasViscosity
        variable = vis
        temperature = temp
        pressure = P
        hydraulic_diameter = dia
        ux = vel_x
        uy = vel_y
        uz = vel_z
        gases = 'NH3 H2O O2'
        molar_weights = '17.031 18 32'
        sutherland_temp = '293.17 292.25 298.16'
        sutherland_const = '370 784.72 127'
        sutherland_vis = '0.0000982 0.001043 0.0002018'
        spec_heat = '2.175 1.97 0.919'
        execute_on = 'initial timestep_end'
    [../]
 
    [./dens_calc]
        type = GasDensity
        variable = dens
        temperature = temp
        pressure = P
        hydraulic_diameter = dia
        ux = vel_x
        uy = vel_y
        uz = vel_z
        gases = 'NH3 H2O O2'
        molar_weights = '17.031 18 32'
        sutherland_temp = '293.17 292.25 298.16'
        sutherland_const = '370 784.72 127'
        sutherland_vis = '0.0000982 0.001043 0.0002018'
        spec_heat = '2.175 1.97 0.919'
        execute_on = 'initial timestep_end'
    [../]
 
    [./cp_calc]
        type = GasSpecHeat
        variable = cp
        temperature = temp
        pressure = P
        hydraulic_diameter = dia
        ux = vel_x
        uy = vel_y
        uz = vel_z
        gases = 'NH3 H2O O2'
        molar_weights = '17.031 18 32'
        sutherland_temp = '293.17 292.25 298.16'
        sutherland_const = '370 784.72 127'
        sutherland_vis = '0.0000982 0.001043 0.0002018'
        spec_heat = '2.175 1.97 0.919'
        execute_on = 'initial timestep_end'
    [../]
 
    [./D_NH3_calc]
        type = GasSpeciesDiffusion
        variable = D_NH3
        species_index = 0
        temperature = temp
        pressure = P
        hydraulic_diameter = dia
        ux = vel_x
        uy = vel_y
        uz = vel_z
        gases = 'NH3 H2O O2'
        molar_weights = '17.031 18 32'
        sutherland_temp = '293.17 292.25 298.16'
        sutherland_const = '370 784.72 127'
        sutherland_vis = '0.0000982 0.001043 0.0002018'
        spec_heat = '2.175 1.97 0.919'
        execute_on = 'initial timestep_end'
    [../]
 
    [./Dz_NH3_calc]
        type = GasSpeciesAxialDispersion
        variable = Dz_NH3
        species_index = 0
        macroscale_diameter = macro_dia
        temperature = temp
        pressure = P
        hydraulic_diameter = dia
        ux = vel_x
        uy = vel_y
        uz = vel_z
        gases = 'NH3 H2O O2'
        molar_weights = '17.031 18 32'
        sutherland_temp = '293.17 292.25 298.16'
        sutherland_const = '370 784.72 127'
        sutherland_vis = '0.0000982 0.001043 0.0002018'
        spec_heat = '2.175 1.97 0.919'
        execute_on = 'initial timestep_end'
    [../]
 
#NOTE: This calculation is for actual film mass transfer rate (not the effective rate)
    [./km_NH3_calc]
        type = GasSpeciesMassTransCoef
        variable = km_NH3
        species_index = 0
        temperature = temp
        pressure = P
        hydraulic_diameter = dia
        ux = vel_x
        uy = vel_y
        uz = vel_z
        gases = 'NH3 H2O O2'
        molar_weights = '17.031 18 32'
        sutherland_temp = '293.17 292.25 298.16'
        sutherland_const = '370 784.72 127'
        sutherland_vis = '0.0000982 0.001043 0.0002018'
        spec_heat = '2.175 1.97 0.919'
        execute_on = 'initial timestep_end'
    [../]
 
    #NOTE: This calculation is for effective film mass transfer rate (not the effective rate)
    [./kme_NH3_calc]
        type = GasSpeciesEffectiveTransferCoef
        variable = kme_NH3
        species_index = 0
        micro_porosity = micro_pore
        temperature = temp
        pressure = P
        hydraulic_diameter = dia
        ux = vel_x
        uy = vel_y
        uz = vel_z
        gases = 'NH3 H2O O2'
        molar_weights = '17.031 18 32'
        sutherland_temp = '293.17 292.25 298.16'
        sutherland_const = '370 784.72 127'
        sutherland_vis = '0.0000982 0.001043 0.0002018'
        spec_heat = '2.175 1.97 0.919'
        execute_on = 'initial timestep_end'
    [../]
 
    [./Kg_calc]
        type = GasThermalConductivity
        variable = K_g
        temperature = temp
        pressure = P
        hydraulic_diameter = dia
        ux = vel_x
        uy = vel_y
        uz = vel_z
        gases = 'NH3 H2O O2'
        molar_weights = '17.031 18 32'
        sutherland_temp = '293.17 292.25 298.16'
        sutherland_const = '370 784.72 127'
        sutherland_vis = '0.0000982 0.001043 0.0002018'
        spec_heat = '2.175 1.97 0.919'
        execute_on = 'initial timestep_end'
    [../]
 
    [./Keff_calc]
        type = GasEffectiveThermalConductivity
        variable = K_eff
        temperature = temp
        pressure = P
        hydraulic_diameter = dia
        solid_conductivity = 11.9
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        gases = 'NH3 H2O O2'
        molar_weights = '17.031 18 32'
        sutherland_temp = '293.17 292.25 298.16'
        sutherland_const = '370 784.72 127'
        sutherland_vis = '0.0000982 0.001043 0.0002018'
        spec_heat = '2.175 1.97 0.919'
        execute_on = 'initial timestep_end'
    [../]
 
    [./cv_calc]
        type = GasVolSpecHeat
        variable = cv
        temperature = temp
        pressure = P
        hydraulic_diameter = dia
        ux = vel_x
        uy = vel_y
        uz = vel_z
        gases = 'NH3 H2O O2'
        molar_weights = '17.031 18 32'
        sutherland_temp = '293.17 292.25 298.16'
        sutherland_const = '370 784.72 127'
        sutherland_vis = '0.0000982 0.001043 0.0002018'
        spec_heat = '2.175 1.97 0.919'
        execute_on = 'initial timestep_end'
    [../]
 
    [./Dp_NH3_calc]
        type = GasSpeciesPoreDiffusion
        variable = Dp_NH3
        species_index = 0
        micro_porosity = micro_pore
        temperature = temp
        pressure = P
        hydraulic_diameter = dia
        ux = vel_x
        uy = vel_y
        uz = vel_z
        gases = 'NH3 H2O O2'
        molar_weights = '17.031 18 32'
        sutherland_temp = '293.17 292.25 298.16'
        sutherland_const = '370 784.72 127'
        sutherland_vis = '0.0000982 0.001043 0.0002018'
        spec_heat = '2.175 1.97 0.919'
        execute_on = 'initial timestep_end'
    [../]
 
    [./Dpe_NH3_calc]
        type = GasSpeciesKnudsenDiffusionCorrection
        variable = Dpe_NH3
        species_index = 0
        micro_porosity = micro_pore
        micro_pore_radius = rp
        temperature = temp
        pressure = P
        hydraulic_diameter = dia
        ux = vel_x
        uy = vel_y
        uz = vel_z
        gases = 'NH3 H2O O2'
        molar_weights = '17.031 18 32'
        sutherland_temp = '293.17 292.25 298.16'
        sutherland_const = '370 784.72 127'
        sutherland_vis = '0.0000982 0.001043 0.0002018'
        spec_heat = '2.175 1.97 0.919'
        execute_on = 'initial timestep_end'
    [../]
 
    [./temp_increase]
        type = LinearChangeInTime
        variable = temp
        start_time = 0
        end_time = 10
        end_value = 1500
        execute_on = 'initial timestep_end'
    [../]
 

[] #END AuxKernels

[BCs]

[] #END BCs

[Materials]

[] #END Materials

[Postprocessors]

    [./P_out]
        type = SideAverageValue
        boundary = 'top'
        variable = P
        execute_on = 'initial timestep_end'
    [../]
 
    [./vis]
        type = ElementAverageValue
        variable = vis
        execute_on = 'initial timestep_end'
    [../]
 
    [./dens]
        type = ElementAverageValue
        variable = dens
        execute_on = 'initial timestep_end'
    [../]
 
    [./cp]
        type = ElementAverageValue
        variable = cp
        execute_on = 'initial timestep_end'
    [../]
 
    [./cv]
        type = ElementAverageValue
        variable = cv
        execute_on = 'initial timestep_end'
    [../]
 
    [./D_NH3]
        type = ElementAverageValue
        variable = D_NH3
        execute_on = 'initial timestep_end'
    [../]
 
    [./Dp_NH3]
        type = ElementAverageValue
        variable = Dp_NH3
        execute_on = 'initial timestep_end'
    [../]
 
    [./Dpe_NH3]
        type = ElementAverageValue
        variable = Dpe_NH3
        execute_on = 'initial timestep_end'
    [../]
 
    [./Dz_NH3]
        type = ElementAverageValue
        variable = Dz_NH3
        execute_on = 'initial timestep_end'
    [../]
 
    [./km_NH3]
        type = ElementAverageValue
        variable = km_NH3
        execute_on = 'initial timestep_end'
    [../]
 
    [./kme_NH3]
        type = ElementAverageValue
        variable = kme_NH3
        execute_on = 'initial timestep_end'
    [../]
 
    [./P_in]
        type = SideAverageValue
        boundary = 'bottom'
        variable = P
        execute_on = 'initial timestep_end'
    [../]
 
    [./K_g]
        type = SideAverageValue
        boundary = 'bottom'
        variable = K_g
        execute_on = 'initial timestep_end'
    [../]
 
    [./K_eff]
        type = SideAverageValue
        boundary = 'bottom'
        variable = K_eff
        execute_on = 'initial timestep_end'
    [../]
 
    [./temp_avg]
        type = ElementAverageValue
        variable = temp
        execute_on = 'initial timestep_end'
    [../]

[] #END Postprocessors

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
    solve_type = pjfnk   #default to newton, but use pjfnk if newton too slow
  [../]
[] #END Preconditioning

[Executioner]
  type = Transient
  scheme = implicit-euler
  petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -pc_type -sub_pc_type -snes_max_it -sub_pc_factor_shift_type -pc_asm_overlap -snes_atol -snes_rtol'
  petsc_options_value = 'gmres lu ilu 100 NONZERO 2 1E-14 1E-12'

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
  end_time = 10
  dtmax = 0.25

  [./TimeStepper]
     type = ConstantDT
     dt = 0.25
  [../]
[] #END Executioner

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
[] #END Outputs
