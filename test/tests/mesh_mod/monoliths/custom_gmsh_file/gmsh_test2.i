[Mesh]
  file = Test_Composite.msh
[]

[Variables]
  [./C]
    block = inner_surf
    order = FIRST
    family = MONOMIAL
    initial_condition = 0.0
  [../]

  [./Cw]
    block = outer_surf
    order = FIRST
    family = MONOMIAL
    initial_condition = 0.0
  [../]
[]

[AuxVariables]
  [./D]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1
  [../]

  [./Dp]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0.2
  [../]
[]

[Kernels]
  #Mass conservation in channel kernels
    [./C_dot]
        type = CoefTimeDerivative
        variable = C
        Coefficient = 1.0
        block = inner_surf
    [../]
    [./C_gdiff]
        type = GVarPoreDiffusion
        variable = C
        porosity = 1
        Dx = D
        Dy = D
        Dz = D
        block = inner_surf
    [../]
 
    #Mass conservation in washcoat kernels
      [./Cw_dot]
          type = VariableCoefTimeDerivative
          variable = Cw
          coupled_coef = 0.2
          block = outer_surf
      [../]
      [./Cw_gdiff]
          type = GVarPoreDiffusion
          variable = Cw
          porosity = 0.2
          Dx = Dp
          Dy = Dp
          Dz = Dp
          block = outer_surf
      [../]
  
[]
 
 [DGKernels]
  
     [./C_dgdiff]
         type = DGVarPoreDiffusion
         variable = C
         porosity = 1
         Dx = D
         Dy = D
         Dz = D
         block = inner_surf
     [../]
  
     [./Cw_dgdiff]
         type = DGVarPoreDiffusion
         variable = Cw
         porosity = 0.2
         Dx = Dp
         Dy = Dp
         Dz = Dp
         block = outer_surf
     [../]

 [] #END DGKernels

[InterfaceKernels]
    [./interface]
        type = InterfaceMassTransfer
        variable = C        #variable must be the variable in the master block
        neighbor_var = Cw    #neighbor_var must the the variable in the paired block
        boundary = inner_bound
        transfer_rate = 1
    [../]
[]

[BCs]
     
         [./Cw_test]
             type = DGFluxLimitedBC
             variable = Cw
             boundary = outer_bound
             u_input = 1.0
             vx = 0
             vy = 0
             vz = 0
         [../]
[]

[Postprocessors]
  
[]

[Preconditioning]
  [./smp]
    type = SMP
    full = true
    solve_type = pjfnk
  [../]
[]

[Executioner]
  type = Transient
  scheme = implicit-euler
  petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -pc_type -sub_pc_type -snes_max_it -sub_pc_factor_shift_type -pc_asm_overlap -snes_atol -snes_rtol'
  petsc_options_value = 'gmres asm lu 100 NONZERO 2 1E-14 1E-12'

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
  end_time = 5
  dtmax = 0.5

  [./TimeStepper]
#    type = SolutionTimeAdaptiveDT
    type = ConstantDT
    dt = 0.1
  [../]
[]

[Outputs]
  exodus = true
  print_linear_residuals = true
[]
