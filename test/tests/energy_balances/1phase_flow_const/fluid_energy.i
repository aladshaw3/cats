[GlobalParams]
    dg_scheme = nipg
    sigma = 10
  
[] #END GlobalParams
 
[Mesh]
    type = GeneratedMesh
	#NOTE: For RZ coordinates, x ==> R and y ==> Z (and z ==> nothing)
    coord_type = RZ
    dim = 2
    nx = 5
    ny = 10
    xmin = 0.0
    xmax = 0.0725    # m radius
    ymin = 0.0
    ymax = 0.1346    # m length
[]

[Variables]
    [./Ef]
        order = FIRST
        family = MONOMIAL
        #initial_condition = 298000  #J/m^3
        # Ef = rho*cp*T     (1 kg/m^3) * (1000 J/kg/K) * (298 K)
        [./InitialCondition]
            type = InitialPhaseEnergy
            specific_heat = 1000
            density = 1
            temperature = Tf
        [../]
    [../]
 
    [./Tf]
        order = FIRST
        family = MONOMIAL
        initial_condition = 298  #K
    [../]
 
    # Bulk gas concentration for O2
    [./O2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1e-9    #mol/m^3
    [../]
[]
 
[AuxVariables]
    [./vel_x]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]

    [./vel_y]
        order = FIRST
        family = LAGRANGE
        initial_condition = 1.126 #m/s  - superficial velocity
    [../]

    [./vel_z]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]
 
    [./Ke]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.1          #W/m/K
    [../]
    
    [./D]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.01
    [../]
[]

[Kernels]
     [./Ef_dot]
         type = TimeDerivative
         variable = Ef
     [../]
     [./Ef_gadv]
         type = GConcentrationAdvection
         variable = Ef
         ux = vel_x
         uy = vel_y
         uz = vel_z
     [../]
     [./Ef_gdiff]
         type = GThermalConductivity
         variable = Ef
         temperature = Tf
         Dx = Ke
         Dy = Ke
         Dz = Ke
     [../]
 
    [./Tf_calc]
        type = PhaseTemperature
        variable = Tf
        energy = Ef
        specific_heat = 1000
        density = 1
    [../]
 
    [./O2_dot]
        type = VariableCoefTimeDerivative
        variable = O2
        coupled_coef = 1
    [../]
    [./O2_gadv]
        type = GPoreConcAdvection
        variable = O2
        porosity = 1
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./O2_gdiff]
        type = GVarPoreDiffusion
        variable = O2
        porosity = 1
        Dx = D
        Dy = D
        Dz = D
    [../]
[]
 
[DGKernels]
    [./Ef_dgadv]
        type = DGConcentrationAdvection
        variable = Ef
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./Ef_dgdiff]
        type = DGThermalConductivity
        variable = Ef
        temperature = Tf
        Dx = Ke
        Dy = Ke
        Dz = Ke
    [../]
 
    [./O2_dgadv]
        type = DGPoreConcAdvection
        variable = O2
        porosity = 1
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./O2_dgdiff]
        type = DGVarPoreDiffusion
        variable = O2
        porosity = 1
        Dx = D
        Dy = D
        Dz = D
    [../]
[]

[BCs]
    [./Ef_FluxIn]
        type = DGConcentrationFluxBC
        variable = Ef
        u_input = 348000
        boundary = 'bottom'
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./Ef_FluxOut]
        type = DGConcentrationFluxBC
        variable = Ef
        boundary = 'top'
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
 
    [./Ef_WallFluxIn]
        type = DGWallEnergyFluxBC
        variable = Ef
        boundary = 'right'
        transfer_coef = 50
        wall_temp = 323
        temperature = Tf
	area_frac = 1
    [../]
 
    [./O2_FluxIn]
        type = DGPoreConcFluxBC
        variable = O2
        boundary = 'bottom'
        u_input = 1e-6
        porosity = 1
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./O2_FluxOut]
        type = DGPoreConcFluxBC
        variable = O2
        boundary = 'top'
        porosity = 1
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

[]

[Postprocessors]
    [./Ef_out]
        type = SideAverageValue
        boundary = 'top'
        variable = Ef
        execute_on = 'initial timestep_end'
    [../]
 
    [./Ef_in]
        type = SideAverageValue
        boundary = 'bottom'
        variable = Ef
        execute_on = 'initial timestep_end'
    [../]
 
    [./T_out]
        type = SideAverageValue
        boundary = 'top'
        variable = Tf
        execute_on = 'initial timestep_end'
    [../]
 
    [./T_in]
        type = SideAverageValue
        boundary = 'bottom'
        variable = Tf
        execute_on = 'initial timestep_end'
    [../]
 
    [./O2_out]
        type = SideAverageValue
        boundary = 'top'
        variable = O2
        execute_on = 'initial timestep_end'
    [../]
 
    [./O2_in]
        type = SideAverageValue
        boundary = 'bottom'
        variable = O2
        execute_on = 'initial timestep_end'
    [../]
[]

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
  end_time = 0.5
  dtmax = 0.25

  [./TimeStepper]
     type = ConstantDT
     dt = 0.05
  [../]
[] #END Executioner

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
[] #END Outputs

