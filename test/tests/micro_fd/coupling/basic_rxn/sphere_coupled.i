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
 
 [./v0]
    initial_condition = 0
 [../]
 [./v1]
    initial_condition = 0
 [../]
 [./v2]
    initial_condition = 0
 [../]
 [./v3]
    initial_condition = 0
 [../]
 [./v4]
    initial_condition = 0
 [../]
 [./v5]
    initial_condition = 0
 [../]
 [./v6]
    initial_condition = 0
 [../]
 [./v7]
    initial_condition = 0
 [../]
 [./v8]
    initial_condition = 0
 [../]
 [./v9]
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
 
  [./vTotal]
    initial_condition = 0
  [../]
  [./vAvg]
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
    [./v0_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = u0
        coupled_at_node = v0
        nodal_time_coef = 1.0
        node_id = 0
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
    [./v1_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = u1
        coupled_at_node = v1
        nodal_time_coef = 1.0
        node_id = 1
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
    [./v2_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = u2
        coupled_at_node = v2
        nodal_time_coef = 1.0
        node_id = 2
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
    [./v3_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = u3
        coupled_at_node = v3
        nodal_time_coef = 1.0
        node_id = 3
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
    [./v4_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = u4
        coupled_at_node = v4
        nodal_time_coef = 1.0
        node_id = 4
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
    [./v5_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = u5
        coupled_at_node = v5
        nodal_time_coef = 1.0
        node_id = 5
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
    [./v6_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = u6
        coupled_at_node = v6
        nodal_time_coef = 1.0
        node_id = 6
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
    [./v7_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = u7
        coupled_at_node = v7
        nodal_time_coef = 1.0
        node_id = 7
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
    [./v8_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = u8
        coupled_at_node = v8
        nodal_time_coef = 1.0
        node_id = 8
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
    [./v9_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = u9
        coupled_at_node = v9
        nodal_time_coef = 1.0
        node_id = 9
    [../]
 
    # Chemical reactions at each node
    [./v0_dot]
        type = TimeDerivative
        variable = v0
    [../]
    [./v0_rxn]  #   u <--> v
        type = ConstReaction
        variable = v0
        this_variable = v0
        forward_rate = 1.0
        reverse_rate = 1.0
        scale = 1.0
        reactants = 'u0'
        reactant_stoich = '1'
        products = 'v0'
        product_stoich = '1'
    [../]
 
    [./v1_dot]
        type = TimeDerivative
        variable = v1
    [../]
    [./v1_rxn]  #   u <--> v
        type = ConstReaction
        variable = v1
        this_variable = v1
        forward_rate = 1.0
        reverse_rate = 1.0
        scale = 1.0
        reactants = 'u1'
        reactant_stoich = '1'
        products = 'v1'
        product_stoich = '1'
    [../]
 
    [./v2_dot]
        type = TimeDerivative
        variable = v2
    [../]
    [./v2_rxn]  #   u <--> v
        type = ConstReaction
        variable = v2
        this_variable = v2
        forward_rate = 1.0
        reverse_rate = 1.0
        scale = 1.0
        reactants = 'u2'
        reactant_stoich = '1'
        products = 'v2'
        product_stoich = '1'
    [../]
 
    [./v3_dot]
        type = TimeDerivative
        variable = v3
    [../]
    [./v3_rxn]  #   u <--> v
        type = ConstReaction
        variable = v3
        this_variable = v3
        forward_rate = 1.0
        reverse_rate = 1.0
        scale = 1.0
        reactants = 'u3'
        reactant_stoich = '1'
        products = 'v3'
        product_stoich = '1'
    [../]
 
    [./v4_dot]
        type = TimeDerivative
        variable = v4
    [../]
    [./v4_rxn]  #   u <--> v
        type = ConstReaction
        variable = v4
        this_variable = v4
        forward_rate = 1.0
        reverse_rate = 1.0
        scale = 1.0
        reactants = 'u4'
        reactant_stoich = '1'
        products = 'v4'
        product_stoich = '1'
    [../]
 
    [./v5_dot]
        type = TimeDerivative
        variable = v5
    [../]
    [./v5_rxn]  #   u <--> v
        type = ConstReaction
        variable = v5
        this_variable = v5
        forward_rate = 1.0
        reverse_rate = 1.0
        scale = 1.0
        reactants = 'u5'
        reactant_stoich = '1'
        products = 'v5'
        product_stoich = '1'
    [../]
 
    [./v6_dot]
        type = TimeDerivative
        variable = v6
    [../]
    [./v6_rxn]  #   u <--> v
        type = ConstReaction
        variable = v6
        this_variable = v6
        forward_rate = 1.0
        reverse_rate = 1.0
        scale = 1.0
        reactants = 'u6'
        reactant_stoich = '1'
        products = 'v6'
        product_stoich = '1'
    [../]
 
    [./v7_dot]
        type = TimeDerivative
        variable = v7
    [../]
    [./v7_rxn]  #   u <--> v
        type = ConstReaction
        variable = v7
        this_variable = v7
        forward_rate = 1.0
        reverse_rate = 1.0
        scale = 1.0
        reactants = 'u7'
        reactant_stoich = '1'
        products = 'v7'
        product_stoich = '1'
    [../]
 
    [./v8_dot]
        type = TimeDerivative
        variable = v8
    [../]
    [./v8_rxn]  #   u <--> v
        type = ConstReaction
        variable = v8
        this_variable = v8
        forward_rate = 1.0
        reverse_rate = 1.0
        scale = 1.0
        reactants = 'u8'
        reactant_stoich = '1'
        products = 'v8'
        product_stoich = '1'
    [../]
 
    [./v9_dot]
        type = TimeDerivative
        variable = v9
    [../]
    [./v9_rxn]  #   u <--> v
        type = ConstReaction
        variable = v9
        this_variable = v9
        forward_rate = 1.0
        reverse_rate = 1.0
        scale = 1.0
        reactants = 'u9'
        reactant_stoich = '1'
        products = 'v9'
        product_stoich = '1'
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
 
     [./vtotal]
         type = MicroscaleIntegralTotal
         variable = vTotal
         space_factor = 1.0
         first_node = 0
         micro_vars = 'v0 v1 v2 v3 v4 v5 v6 v7 v8 v9'
         execute_on = 'initial timestep_end'
     [../]
 
    [./vavg]
        type = MicroscaleIntegralAvg
        variable = vAvg
        space_factor = 1.0
        first_node = 0
        micro_vars = 'v0 v1 v2 v3 v4 v5 v6 v7 v8 v9'
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
 
    [./v0]
        type = ElementAverageValue
        variable = v0
        execute_on = 'initial timestep_end'
    [../]
    [./v1]
        type = ElementAverageValue
        variable = v1
        execute_on = 'initial timestep_end'
    [../]
    [./v2]
        type = ElementAverageValue
        variable = v2
        execute_on = 'initial timestep_end'
    [../]
    [./v3]
        type = ElementAverageValue
        variable = v3
        execute_on = 'initial timestep_end'
    [../]
    [./v4]
        type = ElementAverageValue
        variable = v4
        execute_on = 'initial timestep_end'
    [../]
    [./v5]
        type = ElementAverageValue
        variable = v5
        execute_on = 'initial timestep_end'
    [../]
    [./v6]
        type = ElementAverageValue
        variable = v6
        execute_on = 'initial timestep_end'
    [../]
    [./v7]
        type = ElementAverageValue
        variable = v7
        execute_on = 'initial timestep_end'
    [../]
    [./v8]
        type = ElementAverageValue
        variable = v8
        execute_on = 'initial timestep_end'
    [../]
    [./v9]
        type = ElementAverageValue
        variable = v9
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
 
    [./vTotal]
        type = ElementAverageValue
        variable = vTotal
        execute_on = 'initial timestep_end'
    [../]
 
    [./vavg]
        type = ElementAverageValue
        variable = vAvg
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
