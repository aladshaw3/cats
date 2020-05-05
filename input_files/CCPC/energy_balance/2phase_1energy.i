[GlobalParams]
    dg_scheme = nipg
    sigma = 10
  
[] #END GlobalParams

[Problem]
    #NOTE: For RZ coordinates, x ==> R and y ==> Z (and z ==> nothing)
    coord_type = RZ
[] #END Problem
 
[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = 5
    ny = 10
    xmin = 0.0
    xmax = 0.0725    # m radius
    ymin = 0.0
    ymax = 0.1346    # m length
[]

[Variables]
    [./E]
        order = FIRST
        family = MONOMIAL
        [./InitialCondition]
            type = InitialPhaseEnergy   #Need new IC kernel
            specific_heat = cpg
            volume_frac = eps
            density = rho
            temperature = T
        [../]
    [../]
 
    [./T]
        order = FIRST
        family = MONOMIAL
        initial_condition = 298  #K
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
        initial_condition = 2.5769 #m/s  - superficial velocity
    [../]

    [./vel_z]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]
 
    [./Kg]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.1          #W/m/K
    [../]
 
    [./Ks]
        order = FIRST
        family = MONOMIAL
        initial_condition = 11.9       #W/m/K
    [../]
 
    [./eps]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.4371          #W/m/K
    [../]
 
    [./s_frac]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.5629          #W/m/K
    [../]
 
    [./rho]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1       #kg/m^3
    [../]
 
    [./rho_s]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1599       #kg/m^3
    [../]
 
    [./cpg]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1000       #J/kg/K
    [../]
 
    [./cps]
        order = FIRST
        family = MONOMIAL
        initial_condition = 680       #J/kg/K
    [../]
 
    [./hw]
        order = FIRST
        family = MONOMIAL
        initial_condition = 50       #W/m^2/K
    [../]
 
    [./Tw]
        order = FIRST
        family = MONOMIAL
        initial_condition = 298  #K
    [../]
 
    [./hs]
        order = FIRST
        family = MONOMIAL
        initial_condition = 25       #W/m^2/K
    [../]
 
    [./Ao]
        order = FIRST
        family = MONOMIAL
        initial_condition = 11797       #m^-1
    [../]
 
[]

[Kernels]
     [./E_dot]
         type = VariableCoefTimeDerivative  #This one is fine  dE/dt  =>  E = ( eps*rho*cpg + (1-eps)*rho_s*cps ) * T
         variable = E
         coupled_coef = 1
     [../]
    # Only have gas flux  ==> (vel * eps * rho * cpg * T)  [Partial energy]
     [./E_gadv]
         type = GPoreConcAdvection  #This may need to change as well
         variable = E               #NOT ALL ENERGY FLUXES!!! (only the gaseous portion can flux)
         porosity = 1
         ux = vel_x
         uy = vel_y
         uz = vel_z
     [../]
    # This on is fine, but use volume_frac = 1 and volume averaged conductivity
     [./E_gdiff]
         type = GPhaseThermalConductivity
         variable = E
         temperature = T
         volume_frac = 1
         Dx = Kg #Change these to an average
         Dy = Kg
         Dz = Kg
     [../]
 
    [./T_calc]
        type = PhaseTemperature   #Need new kernel for 2-phases combined into 1 temp
        variable = T
        energy = E
        specific_heat = cpg
        volume_frac = eps
        density = rho
    [../]
 
[]
 
[DGKernels]
    # Only have gas flux  ==> (vel * eps * rho * cpg * T)  [Partial energy]
    [./Ef_dgadv] 
        type = DGPoreConcAdvection
        variable = E        #NOT ALL ENERGY FLUXES!!! (only the gaseous portion can flux)
        porosity = 1
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    # This on is fine, but use volume_frac = 1 and volume averaged conductivity
    [./Ef_dgdiff]
        type = DGPhaseThermalConductivity
        variable = E
        temperature = T
        volume_frac = 1
        Dx = Kg #Change these to an average
        Dy = Kg
        Dz = Kg
    [../]

[]

[BCs]
    # Keep same
    [./E_Flux_OpenBounds]
        type = DGFlowEnergyFluxBC
        variable = E
        boundary = 'bottom top'
        porosity = eps
        specific_heat = cpg
        density = rho
        inlet_temp = 348
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    
    # Keep same, but change area_frac to 1
    [./E_WallFluxIn]
        type = DGWallEnergyFluxBC
        variable = E
        boundary = 'right'
        transfer_coef = hw
        wall_temp = Tw
        temperature = T
        area_frac = 1
    [../]

[]

[Postprocessors]
    [./Ef_out]
        type = SideAverageValue
        boundary = 'top'
        variable = E
        execute_on = 'initial timestep_end'
    [../]
 
    [./Ef_in]
        type = SideAverageValue
        boundary = 'bottom'
        variable = E
        execute_on = 'initial timestep_end'
    [../]
 
    [./T_out]
        type = SideAverageValue
        boundary = 'top'
        variable = T
        execute_on = 'initial timestep_end'
    [../]
 
    [./T_in]
        type = SideAverageValue
        boundary = 'bottom'
        variable = T
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
  end_time = 300
  dtmax = 30

  [./TimeStepper]
     type = ConstantDT
     dt = 30
  [../]
[] #END Executioner

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
[] #END Outputs

