[GlobalParams]
  dg_scheme = nipg
  sigma = 10
 
    diffusion_const = 0.03125   #Dp*ew  where Dp ~= ew*ew*Dm   and Dm ~ 0.25 cm^2/s
#Actual transfer rates adjusted from above diffusion (0.25 cm^2/s), the pellet porosity (0.5),
#   and the ratio of the effective rate to actual rate (see avg_mass_trans_no_micro.i for rate)
#
#   Actual rate ~ 4x Effective rate  (based on empirical relationship for km and ke)
#       km ~= kem/ew/ew
 transfer_const = 0.4
 rate_variable = 0.4
    micro_length = 0.003        #Radius of pellet Based on the Ao = 1000 cm^-1
    num_nodes = 10
    coord_id = 2
 
    order = FIRST
    family = MONOMIAL
 
[] #END GlobalParams

[Problem]

    coord_type = RZ
    #NOTE: For RZ coordinates, x ==> R and y ==> Z (and z ==> nothing)

[] #END Problem

[Mesh]

    type = GeneratedMesh
    dim = 2
    nx = 1
    ny = 10
    xmin = 0.0
    xmax = 2.0    #2cm radius
    ymin = 0.0
    ymax = 5.0    #5cm length

[] # END Mesh

[Variables]

    [./C]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./Cw0]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]
 
    [./Cw1]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]
    
    [./Cw2]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]
 
    [./Cw3]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]
 
    [./Cw4]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]
 
    [./Cw5]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]
 
    [./Cw6]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]
 
    [./Cw7]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]
 
    [./Cw8]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]
 
    [./Cw9]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]

    [./q0]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]
 
    [./q1]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]
 
    [./q2]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]
 
    [./q3]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]
 
    [./q4]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]
 
    [./q5]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]
 
    [./q6]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]
 
    [./q7]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]
 
    [./q8]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]
 
    [./q9]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]

    [./S0]
        order = FIRST
        family = LAGRANGE
        initial_condition = 1
    [../]
 
    [./S1]
        order = FIRST
        family = LAGRANGE
        initial_condition = 1
    [../]
 
    [./S2]
        order = FIRST
        family = LAGRANGE
        initial_condition = 1
    [../]
 
    [./S3]
        order = FIRST
        family = LAGRANGE
        initial_condition = 1
    [../]
 
    [./S4]
        order = FIRST
        family = LAGRANGE
        initial_condition = 1
    [../]
 
    [./S5]
        order = FIRST
        family = LAGRANGE
        initial_condition = 1
    [../]
 
    [./S6]
        order = FIRST
        family = LAGRANGE
        initial_condition = 1
    [../]
 
    [./S7]
        order = FIRST
        family = LAGRANGE
        initial_condition = 1
    [../]
 
    [./S8]
        order = FIRST
        family = LAGRANGE
        initial_condition = 1
    [../]
 
    [./S9]
        order = FIRST
        family = LAGRANGE
        initial_condition = 1
    [../]

[] #END Variables

[AuxVariables]
 
  [./CwAvg]
    initial_condition = 0
  [../]
 
  [./qAvg]
    initial_condition = 0
  [../]

  [./Diff]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.01
  [../]

  [./pore]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.5
  [../]
 
  [./wash_pore]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.25   #   ew * (1 - e)
  [../]
 
  [./S_max]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1
  [../]

  [./vel_x]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

  [./vel_y]
      order = FIRST
      family = MONOMIAL
      initial_condition = 2
  [../]

  [./vel_z]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

[] #END AuxVariables

[ICs]

[] #END ICs

[Kernels]

    [./C_dot]
        type = VariableCoefTimeDerivative
        variable = C
        coupled_coef = pore
    [../]
    [./C_gadv]
        type = GPoreConcAdvection
        variable = C
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./C_gdiff]
        type = GVarPoreDiffusion
        variable = C
        porosity = pore
        Dx = Diff
        Dy = Diff
        Dz = Diff
    [../]
    [./Cw_trans]
        type = FilmMassTransfer
        variable = C
        coupled = Cw9
        av_ratio = 500          #(1-pore)*Ao  with Ao = 1000 cm^-1
    [../]
 
# inner BC
    [./Cw0_dot]
        type = MicroscaleCoefTimeDerivative
        variable = Cw0
        nodal_time_coef = 0.5
        node_id = 0
    [../]
    [./Cw0_diff_inner]
        type = MicroscaleDiffusionInnerBC
        variable = Cw0
        node_id = 0
        upper_neighbor = Cw1
    [../]
    [./q0_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = Cw0
        coupled_at_node = q0
        nodal_time_coef = 1.0
        node_id = 0
    [../]
 
    [./Cw1_dot]
        type = MicroscaleCoefTimeDerivative
        variable = Cw1
        nodal_time_coef = 0.5
        node_id = 1
    [../]
    [./Cw1_diff]
        type = MicroscaleDiffusion
        variable = Cw1
        node_id = 1
        upper_neighbor = Cw2
        lower_neighbor = Cw0
    [../]
    [./q1_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = Cw1
        coupled_at_node = q1
        nodal_time_coef = 1.0
        node_id = 1
    [../]
 
    [./Cw2_dot]
        type = MicroscaleCoefTimeDerivative
        variable = Cw2
        nodal_time_coef = 0.5
        node_id = 2
    [../]
    [./Cw2_diff]
        type = MicroscaleDiffusion
        variable = Cw2
        node_id = 2
        upper_neighbor = Cw3
        lower_neighbor = Cw1
    [../]
    [./q2_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = Cw2
        coupled_at_node = q2
        nodal_time_coef = 1.0
        node_id = 2
    [../]
 
    [./Cw3_dot]
        type = MicroscaleCoefTimeDerivative
        variable = Cw3
        nodal_time_coef = 0.5
        node_id = 3
    [../]
    [./Cw3_diff]
        type = MicroscaleDiffusion
        variable = Cw3
        node_id = 3
        upper_neighbor = Cw4
        lower_neighbor = Cw2
    [../]
    [./q3_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = Cw3
        coupled_at_node = q3
        nodal_time_coef = 1.0
        node_id = 3
    [../]
 
    [./Cw4_dot]
        type = MicroscaleCoefTimeDerivative
        variable = Cw4
        nodal_time_coef = 0.5
        node_id = 4
    [../]
    [./Cw4_diff]
        type = MicroscaleDiffusion
        variable = Cw4
        node_id = 4
        upper_neighbor = Cw5
        lower_neighbor = Cw3
    [../]
    [./q4_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = Cw4
        coupled_at_node = q4
        nodal_time_coef = 1.0
        node_id = 4
    [../]
 
    [./Cw5_dot]
        type = MicroscaleCoefTimeDerivative
        variable = Cw5
        nodal_time_coef = 0.5
        node_id = 5
    [../]
    [./Cw5_diff]
        type = MicroscaleDiffusion
        variable = Cw5
        node_id = 5
        upper_neighbor = Cw6
        lower_neighbor = Cw4
    [../]
    [./q5_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = Cw5
        coupled_at_node = q5
        nodal_time_coef = 1.0
        node_id = 5
    [../]
 
    [./Cw6_dot]
        type = MicroscaleCoefTimeDerivative
        variable = Cw6
        nodal_time_coef = 0.5
        node_id = 6
    [../]
    [./Cw6_diff]
        type = MicroscaleDiffusion
        variable = Cw6
        node_id = 6
        upper_neighbor = Cw7
        lower_neighbor = Cw5
    [../]
    [./q6_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = Cw6
        coupled_at_node = q6
        nodal_time_coef = 1.0
        node_id = 6
    [../]
 
    [./Cw7_dot]
        type = MicroscaleCoefTimeDerivative
        variable = Cw7
        nodal_time_coef = 0.5
        node_id = 7
    [../]
    [./Cw7_diff]
        type = MicroscaleDiffusion
        variable = Cw7
        node_id = 7
        upper_neighbor = Cw8
        lower_neighbor = Cw6
    [../]
    [./q7_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = Cw7
        coupled_at_node = q7
        nodal_time_coef = 1.0
        node_id = 7
    [../]
 
    [./Cw8_dot]
        type = MicroscaleCoefTimeDerivative
        variable = Cw8
        nodal_time_coef = 0.5
        node_id = 8
    [../]
    [./Cw8_diff]
        type = MicroscaleDiffusion
        variable = Cw8
        node_id = 8
        upper_neighbor = Cw9
        lower_neighbor = Cw7
    [../]
    [./q8_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = Cw8
        coupled_at_node = q8
        nodal_time_coef = 1.0
        node_id = 8
    [../]

 
# outer BC
    [./Cw9_dot]
        type = MicroscaleCoefTimeDerivative
        variable = Cw9
        nodal_time_coef = 0.5
        node_id = 9
    [../]
    [./Cw9_diff_outer]
        type = MicroscaleDiffusionOuterBC
        variable = Cw9
        node_id = 9
        macro_variable = C
        lower_neighbor = Cw8
    [../]
    [./q9_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = Cw9
        coupled_at_node = q9
        nodal_time_coef = 1.0
        node_id = 9
    [../]
 
    [./q0_dot]
        type = TimeDerivative
        variable = q0
    [../]
    [./q0_rxn]  #   Cw0 + S0 <-- --> q0
        type = ConstReaction
        variable = q0
        this_variable = q0
        forward_rate = 2.0
        reverse_rate = 0.5
        scale = 1.0
        reactants = 'Cw0 S0'
        reactant_stoich = '1 1'
        products = 'q0'
        product_stoich = '1'
    [../]
    [./mat_bal0]
      type = MaterialBalance
      variable = S0
      this_variable = S0
      coupled_list = 'S0 q0'
      weights = '1 1'
      total_material = S_max
    [../]
 
    [./q1_dot]
        type = TimeDerivative
        variable = q1
    [../]
    [./q1_rxn]  #   Cw1 + S1 <-- --> q1
        type = ConstReaction
        variable = q1
        this_variable = q1
        forward_rate = 2.0
        reverse_rate = 0.5
        scale = 1.0
        reactants = 'Cw1 S1'
        reactant_stoich = '1 1'
        products = 'q1'
        product_stoich = '1'
    [../]
    [./mat_bal1]
      type = MaterialBalance
      variable = S1
      this_variable = S1
      coupled_list = 'S1 q1'
      weights = '1 1'
      total_material = S_max
    [../]
 
    [./q2_dot]
        type = TimeDerivative
        variable = q2
    [../]
    [./q2_rxn]  #   Cw2 + S2 <-- --> q2
        type = ConstReaction
        variable = q2
        this_variable = q2
        forward_rate = 2.0
        reverse_rate = 0.5
        scale = 1.0
        reactants = 'Cw2 S2'
        reactant_stoich = '1 1'
        products = 'q2'
        product_stoich = '1'
    [../]
    [./mat_bal2]
      type = MaterialBalance
      variable = S2
      this_variable = S2
      coupled_list = 'S2 q2'
      weights = '1 1'
      total_material = S_max
    [../]
 
    [./q3_dot]
        type = TimeDerivative
        variable = q3
    [../]
    [./q3_rxn]  #   Cw3 + S3 <-- --> q3
        type = ConstReaction
        variable = q3
        this_variable = q3
        forward_rate = 2.0
        reverse_rate = 0.5
        scale = 1.0
        reactants = 'Cw3 S3'
        reactant_stoich = '1 1'
        products = 'q3'
        product_stoich = '1'
    [../]
    [./mat_bal3]
      type = MaterialBalance
      variable = S3
      this_variable = S3
      coupled_list = 'S3 q3'
      weights = '1 1'
      total_material = S_max
    [../]
 
    [./q4_dot]
        type = TimeDerivative
        variable = q4
    [../]
    [./q4_rxn]  #   Cw4 + S4 <-- --> q4
        type = ConstReaction
        variable = q4
        this_variable = q4
        forward_rate = 2.0
        reverse_rate = 0.5
        scale = 1.0
        reactants = 'Cw4 S4'
        reactant_stoich = '1 1'
        products = 'q4'
        product_stoich = '1'
    [../]
    [./mat_bal4]
      type = MaterialBalance
      variable = S4
      this_variable = S4
      coupled_list = 'S4 q4'
      weights = '1 1'
      total_material = S_max
    [../]
 
    [./q5_dot]
        type = TimeDerivative
        variable = q5
    [../]
    [./q5_rxn]  #   Cw5 + S5 <-- --> q5
        type = ConstReaction
        variable = q5
        this_variable = q5
        forward_rate = 2.0
        reverse_rate = 0.5
        scale = 1.0
        reactants = 'Cw5 S5'
        reactant_stoich = '1 1'
        products = 'q5'
        product_stoich = '1'
    [../]
    [./mat_bal5]
      type = MaterialBalance
      variable = S5
      this_variable = S5
      coupled_list = 'S5 q5'
      weights = '1 1'
      total_material = S_max
    [../]
 
    [./q6_dot]
        type = TimeDerivative
        variable = q6
    [../]
    [./q6_rxn]  #   Cw6 + S6 <-- --> q6
        type = ConstReaction
        variable = q6
        this_variable = q6
        forward_rate = 2.0
        reverse_rate = 0.5
        scale = 1.0
        reactants = 'Cw6 S6'
        reactant_stoich = '1 1'
        products = 'q6'
        product_stoich = '1'
    [../]
    [./mat_bal6]
      type = MaterialBalance
      variable = S6
      this_variable = S6
      coupled_list = 'S6 q6'
      weights = '1 1'
      total_material = S_max
    [../]
 
    [./q7_dot]
        type = TimeDerivative
        variable = q7
    [../]
    [./q7_rxn]  #   Cw7 + S7 <-- --> q7
        type = ConstReaction
        variable = q7
        this_variable = q7
        forward_rate = 2.0
        reverse_rate = 0.5
        scale = 1.0
        reactants = 'Cw7 S7'
        reactant_stoich = '1 1'
        products = 'q7'
        product_stoich = '1'
    [../]
    [./mat_bal7]
      type = MaterialBalance
      variable = S7
      this_variable = S7
      coupled_list = 'S7 q7'
      weights = '1 1'
      total_material = S_max
    [../]
 
    [./q8_dot]
        type = TimeDerivative
        variable = q8
    [../]
    [./q8_rxn]  #   Cw8 + S8 <-- --> q8
        type = ConstReaction
        variable = q8
        this_variable = q8
        forward_rate = 2.0
        reverse_rate = 0.5
        scale = 1.0
        reactants = 'Cw8 S8'
        reactant_stoich = '1 1'
        products = 'q8'
        product_stoich = '1'
    [../]
    [./mat_bal8]
      type = MaterialBalance
      variable = S8
      this_variable = S8
      coupled_list = 'S8 q8'
      weights = '1 1'
      total_material = S_max
    [../]
 
    [./q9_dot]
        type = TimeDerivative
        variable = q9
    [../]
    [./q9_rxn]  #   Cw9 + S9 <-- --> q9
        type = ConstReaction
        variable = q9
        this_variable = q9
        forward_rate = 2.0
        reverse_rate = 0.5
        scale = 1.0
        reactants = 'Cw9 S9'
        reactant_stoich = '1 1'
        products = 'q9'
        product_stoich = '1'
    [../]
    [./mat_bal9]
      type = MaterialBalance
      variable = S9
      this_variable = S9
      coupled_list = 'S9 q9'
      weights = '1 1'
      total_material = S_max
    [../]

[] #END Kernels

[DGKernels]

    [./C_dgadv]
        type = DGPoreConcAdvection
        variable = C
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./C_dgdiff]
        type = DGVarPoreDiffusion
        variable = C
        porosity = pore
        Dx = Diff
        Dy = Diff
        Dz = Diff
    [../]

[] #END DGKernels

[AuxKernels]
 
    [./Cw_avg]
        type = MicroscaleIntegralAvg
        variable = CwAvg
        space_factor = 1.0
        first_node = 0
        micro_vars = 'Cw0 Cw1 Cw2 Cw3 Cw4 Cw5 Cw6 Cw7 Cw8 Cw9'
        execute_on = 'initial timestep_end'
    [../]
 
    [./q_avg]
        type = MicroscaleIntegralAvg
        variable = qAvg
        space_factor = 1.0
        first_node = 0
        micro_vars = 'q0 q1 q2 q3 q4 q5 q6 q7 q8 q9'
        execute_on = 'initial timestep_end'
    [../]

[] #END AuxKernels

[BCs]

    [./C_FluxIn]
      type = DGPoreConcFluxBC
      variable = C
      boundary = 'bottom'
      u_input = 1.0
      porosity = pore
      ux = vel_x
      uy = vel_y
      uz = vel_z
    [../]
    [./C_FluxOut]
      type = DGPoreConcFluxBC
      variable = C
      boundary = 'top left right'
      porosity = pore
      ux = vel_x
      uy = vel_y
      uz = vel_z
    [../]

[] #END BCs

[Materials]

[] #END Materials

[Postprocessors]

    [./C_exit]
        type = SideAverageValue
        boundary = 'top'
        variable = C
        execute_on = 'initial timestep_end'
    [../]

    [./q_avg]
        type = ElementAverageValue
        variable = qAvg
        execute_on = 'initial timestep_end'
    [../]

    [./Cw_avg]
        type = ElementAverageValue
        variable = CwAvg
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
  end_time = 5.0
  dtmax = 0.5

  [./TimeStepper]
     type = ConstantDT
     dt = 0.5
  [../]
 
[] #END Executioner

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
[] #END Outputs
