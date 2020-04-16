[GlobalParams]
    diffusion_const = 0.1
    transfer_const = 1.0
    micro_length = 1.0
    num_nodes = 10
    coord_id = 2
 
    order = FIRST
    family = MONOMIAL
[] #END GlobalParams

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 1
  ny = 1
[]

[Variables]
  [./u0]
     initial_condition = 0
  [../]
  [./u1]
     initial_condition = 0
  [../]
  [./u2]
     initial_condition = 0
  [../]
  [./u3]
     initial_condition = 0
  [../]
  [./u4]
     initial_condition = 0
  [../]
  [./u5]
     initial_condition = 0
  [../]
  [./u6]
     initial_condition = 0
  [../]
  [./u7]
     initial_condition = 0
  [../]
  [./u8]
     initial_condition = 0
  [../]
  [./u9]
     initial_condition = 0
  [../]
 
[]
 
[AuxVariables]
  [./ub]
     initial_condition = 1
  [../]
  [./uTotal]
    initial_condition = 0
  [../]
  [./uAvg]
    initial_condition = 0
  [../]
[]

[Kernels]
    # inner boundary (no flux)
    [./u0_dot]
        type = MicroscaleCoefTimeDerivative
        variable = u0
        nodal_time_coef = 1.0
        node_id = 0
    [../]
    [./u0_diff_inner]
        type = MicroscaleDiffusionInnerBC
        variable = u0
        node_id = 0
        upper_neighbor = u1
    [../]
 
    # interior nodes ( 1 - 8 )
    [./u1_dot]
        type = MicroscaleCoefTimeDerivative
        variable = u1
        nodal_time_coef = 1.0
        node_id = 1
    [../]
    [./u1_diff]
        type = MicroscaleDiffusion
        variable = u1
        node_id = 1
        upper_neighbor = u2
        lower_neighbor = u0
    [../]
 
    [./u2_dot]
        type = MicroscaleCoefTimeDerivative
        variable = u2
        nodal_time_coef = 1.0
        node_id = 2
    [../]
    [./u2_diff]
        type = MicroscaleDiffusion
        variable = u2
        node_id = 2
        upper_neighbor = u3
        lower_neighbor = u1
    [../]
 
    [./u3_dot]
        type = MicroscaleCoefTimeDerivative
        variable = u3
        nodal_time_coef = 1.0
        node_id = 3
    [../]
    [./u3_diff]
        type = MicroscaleDiffusion
        variable = u3
        node_id = 3
        upper_neighbor = u4
        lower_neighbor = u2
    [../]
 
    [./u4_dot]
        type = MicroscaleCoefTimeDerivative
        variable = u4
        nodal_time_coef = 1.0
        node_id = 4
    [../]
    [./u4_diff]
        type = MicroscaleDiffusion
        variable = u4
        node_id = 4
        upper_neighbor = u5
        lower_neighbor = u3
    [../]
 
    [./u5_dot]
        type = MicroscaleCoefTimeDerivative
        variable = u5
        nodal_time_coef = 1.0
        node_id = 5
    [../]
    [./u5_diff]
        type = MicroscaleDiffusion
        variable = u5
        node_id = 5
        upper_neighbor = u6
        lower_neighbor = u4
    [../]
 
    [./u6_dot]
        type = MicroscaleCoefTimeDerivative
        variable = u6
        nodal_time_coef = 1.0
        node_id = 6
    [../]
    [./u6_diff]
        type = MicroscaleDiffusion
        variable = u6
        node_id = 6
        upper_neighbor = u7
        lower_neighbor = u5
    [../]
 
    [./u7_dot]
        type = MicroscaleCoefTimeDerivative
        variable = u7
        nodal_time_coef = 1.0
        node_id = 7
    [../]
    [./u7_diff]
        type = MicroscaleDiffusion
        variable = u7
        node_id = 7
        upper_neighbor = u8
        lower_neighbor = u6
    [../]
 
    [./u8_dot]
        type = MicroscaleCoefTimeDerivative
        variable = u8
        nodal_time_coef = 1.0
        node_id = 8
    [../]
    [./u8_diff_outer]
        type = MicroscaleDiffusion
        variable = u8
        node_id = 8
        upper_neighbor = u9
        lower_neighbor = u7
    [../]
 
    # outer boundary (mass transfer)
    [./u9_dot]
        type = MicroscaleCoefTimeDerivative
        variable = u9
        nodal_time_coef = 1.0
        node_id = 9
    [../]
    [./u9_diff_outer]
        type = MicroscaleDiffusionOuterBC
        variable = u9
        node_id = 9
        macro_variable = ub
        lower_neighbor = u8
    [../]
  
[]

 [AuxKernels]
  
     [./total]
         type = MicroscaleIntegralTotal
         variable = uTotal
         space_factor = 1.0
         first_node = 0
         micro_vars = 'u0 u1 u2 u3 u4 u5 u6 u7 u8 u9'
         execute_on = 'initial timestep_end'
     [../]
 
    [./avg]
        type = MicroscaleIntegralAvg
        variable = uAvg
        space_factor = 1.0
        first_node = 0
        micro_vars = 'u0 u1 u2 u3 u4 u5 u6 u7 u8 u9'
        execute_on = 'initial timestep_end'
    [../]

 [] #END AuxKernels
 
[BCs]

[]

[Postprocessors]
    [./u0]
        type = ElementAverageValue
        variable = u0
        execute_on = 'initial timestep_end'
    [../]
    [./u1]
        type = ElementAverageValue
        variable = u1
        execute_on = 'initial timestep_end'
    [../]
    [./u2]
        type = ElementAverageValue
        variable = u2
        execute_on = 'initial timestep_end'
    [../]
    [./u3]
        type = ElementAverageValue
        variable = u3
        execute_on = 'initial timestep_end'
    [../]
    [./u4]
        type = ElementAverageValue
        variable = u4
        execute_on = 'initial timestep_end'
    [../]
    [./u5]
        type = ElementAverageValue
        variable = u5
        execute_on = 'initial timestep_end'
    [../]
    [./u6]
        type = ElementAverageValue
        variable = u6
        execute_on = 'initial timestep_end'
    [../]
    [./u7]
        type = ElementAverageValue
        variable = u7
        execute_on = 'initial timestep_end'
    [../]
    [./u8]
        type = ElementAverageValue
        variable = u8
        execute_on = 'initial timestep_end'
    [../]
    [./u9]
        type = ElementAverageValue
        variable = u9
        execute_on = 'initial timestep_end'
    [../]
 
    [./uTotal]
        type = ElementAverageValue
        variable = uTotal
        execute_on = 'initial timestep_end'
    [../]
 
    [./uavg]
        type = ElementAverageValue
        variable = uAvg
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
  line_search = bt
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-4
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0.0
  end_time = 10.0
  dtmax = 0.25

  [./TimeStepper]
     type = ConstantDT
     dt = 0.25
  [../]
[] #END Executioner

[Outputs]
  exodus = true
  csv = true
[]
