[GlobalParams]
  dg_scheme = nipg
  sigma = 10
  transfer_rate = 5757.541  #min^-1
[] #END GlobalParams

[Problem]
    coord_type = RZ
    #NOTE: For RZ coordinates, x ==> R and y ==> Z (and z ==> nothing)
[] #END Problem

[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = 1
    ny = 20
    xmin = 0.0
    xmax = 2.0    #2cm radius
    ymin = 0.0
    ymax = 5.0    #5cm length
[] # END Mesh

[Variables]

## ----- NOTE: Cross-Coupled Variables for Mass MUST have same order and family !!! ------- ##
    [./NH3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1e-9
    [../]
    
    [./NH3w]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1e-9
    [../]

    [./q1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./q2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./q3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]
 
    [./qH2O]
        order = FIRST
        family = MONOMIAL
    [../]
 
    [./S1]
        order = FIRST
        family = MONOMIAL
    [../]

    [./S2]
        order = FIRST
        family = MONOMIAL
    [../]

    [./S3]
        order = FIRST
        family = MONOMIAL
    [../]

    [./qT]
        order = FIRST
        family = MONOMIAL
    [../]

[] #END Variables

[AuxVariables]

  [./O2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 5.35186739166803E-05
  [../]

  #MOVED water to AuxVariables because we don't want to consider mass transfer right now
  [./H2O]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001337966847917
  [../]
 
  [./H2Ow]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001337966847917
  [../]

  [./w1]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.05016
  [../]

  [./w2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.03534
  [../]

  [./w3]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.03963
  [../]

  [./temp]
      order = FIRST
      family = MONOMIAL
      initial_condition = 448.15
  [../]

  [./Diff]
    order = FIRST
    family = MONOMIAL
    initial_condition = 75.0
  [../]
 
  [./Dz]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0.0
  [../]

  [./pore]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.3309
  [../]
 
  [./total_pore]
  # ew =~ 1/5
  # total_pore = ew* (1 - pore)
  # micro_pore_vol = 0.18 cm^3/g
  # assume ew = 0.2
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.13382
  [../]

  [./vel_x]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  [./vel_y]
      order = FIRST
      family = LAGRANGE
      initial_condition = 7555.15
  [../]

  [./vel_z]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

[] #END AuxVariables

[ICs]

[] #END ICs

[Kernels]

    [./NH3_dot]
        type = VariableCoefTimeDerivative
        variable = NH3
        coupled_coef = pore
    [../]
    [./NH3_gadv]
        type = GPoreConcAdvection
        variable = NH3
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./NH3_gdiff]
        type = GVarPoreDiffusion
        variable = NH3
        porosity = pore
        Dx = Diff
        Dy = Diff
        Dz = Dz
    [../]
     [./NH3w_trans]
         type = ConstMassTransfer
         variable = NH3
         coupled = NH3w
     [../]
  
     [./NH3w_dot]
         type = VariableCoefTimeDerivative
         variable = NH3w
         coupled_coef = total_pore
     [../]
     [./NH3_trans]
         type = ConstMassTransfer
         variable = NH3w
         coupled = NH3
     [../]
     [./transfer_q1]
         type = CoupledPorePhaseTransfer
         variable = NH3w
         coupled = q1
         porosity = pore
     [../]
     [./transfer_q2]
         type = CoupledPorePhaseTransfer
         variable = NH3w
         coupled = q2
         porosity = pore
     [../]
     [./transfer_q3]
         type = CoupledPorePhaseTransfer
         variable = NH3w
         coupled = q3
         porosity = pore
     [../]

 #   NOTE: According to the Olsson paper, the activation energy for adsorption is 0.0
     [./q1_dot]
         type = TimeDerivative
         variable = q1
     [../]
     [./q1_rx]  #   NH3w + S1 <-- --> q1
       type = ArrheniusEquilibriumReaction
       variable = q1
       this_variable = q1
       forward_activation_energy = 6146
       forward_pre_exponential = 1044382
       enthalpy = -60019.5678
       entropy = -42.433
       temperature = temp
       scale = 1.0
       reactants = 'NH3w S1'
       reactant_stoich = '1 1'
       products = 'q1'
       product_stoich = '1'
     [../]

     [./q2_dot]
         type = TimeDerivative
         variable = q2
     [../]
     [./q2_rx]  #   NH3w + S2 <-- --> q2
       type = ArrheniusEquilibriumReaction
       variable = q2
       this_variable = q2
       forward_activation_energy = 7915
       forward_pre_exponential = 754952
       enthalpy = -77077.889
       entropy = -41.858
       temperature = temp
       scale = 1.0
       reactants = 'NH3w S2'
       reactant_stoich = '1 1'
       products = 'q2'
       product_stoich = '1'
     [../]

     [./q3_dot]
         type = TimeDerivative
         variable = q3
     [../]
     [./q3_rx]  #   NH3w + S3 <-- --> q3
       type = ArrheniusEquilibriumReaction
       variable = q3
       this_variable = q3
       forward_activation_energy = 8802
       forward_pre_exponential = 2317009
       enthalpy = -78147.021
       entropy = -12.113
       temperature = temp
       scale = 1.0
       reactants = 'NH3w S3'
       reactant_stoich = '1 1'
       products = 'q3'
       product_stoich = '1'
     [../]
  
     [./qH2O_rx]  #   H2Ow + S1 <-- --> qH2O
       type = EquilibriumReaction
       variable = qH2O
       this_variable = qH2O
       enthalpy = -25656.6
       entropy = -5.24228
       temperature = temp
       reactants = 'H2Ow S1'
       reactant_stoich = '1 1'
       products = 'qH2O'
       product_stoich = '1'
     [../]
  
     [./qT_calc]
         type = MaterialBalance
         variable = qT
         this_variable = qT
         coupled_list = 'q1 q2 q3'
         weights = '1 1 1'
         total_material = qT
     [../]
  
     [./S1_bal]
         type = MaterialBalance
         variable = S1
         this_variable = S1
         coupled_list = 'q1 S1 qH2O'
         weights = '1 1 1'
         total_material = w1
     [../]
  
     [./S2_bal]
         type = MaterialBalance
         variable = S2
         this_variable = S2
         coupled_list = 'q2 S2'
         weights = '1 1'
         total_material = w2
     [../]
  
     [./S3_bal]
         type = MaterialBalance
         variable = S3
         this_variable = S3
         coupled_list = 'q3 S3'
         weights = '1 1'
         total_material = w3
     [../]


[] #END Kernels

[DGKernels]

    [./NH3_dgadv]
        type = DGPoreConcAdvection
        variable = NH3
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./NH3_dgdiff]
        type = DGVarPoreDiffusion
        variable = NH3
        porosity = pore
        Dx = Diff
        Dy = Diff
        Dz = Dz
    [../]

[] #END DGKernels

[AuxKernels]
 
    [./temp_increase]
        type = LinearChangeInTime
        variable = temp
        start_time = 207.925
        end_time = 282.75
        end_value = 809.5651714
        execute_on = 'initial timestep_end'
    [../]

[] #END AuxKernels

[BCs]

    [./NH3_FluxIn]
      type = DGPoreConcFluxStepwiseBC
      variable = NH3
      boundary = 'bottom'
      u_input = 1E-9
      porosity = pore
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_vals = '2.71851E-05    2.15632E-05    1.60997E-05    1.06384E-05    5.43622E-06    2.71679E-06    1.35751E-06    6.78678E-07    3.52792E-07    2.60859E-09'
      input_times = '2.09166667    14.925    22.7583333    30.7583333    42.5916667    54.7583333    72.7583333    102.258333    142.591667    207.925'
      time_spans = '0.25    0.25    0.25    0.25    0.25    0.25    0.25    0.25    0.25    0.25'
    [../]
    [./NH3_FluxOut]
      type = DGPoreConcFluxBC
      variable = NH3
      boundary = 'top'
      porosity = pore
      ux = vel_x
      uy = vel_y
      uz = vel_z
    [../]

[] #END BCs

[Materials]

[] #END Materials

[Postprocessors]

    [./NH3_out]
        type = SideAverageValue
        boundary = 'top'
        variable = NH3
        execute_on = 'initial timestep_end'
    [../]
 
    [./NH3_bypass]
        type = SideAverageValue
        boundary = 'bottom'
        variable = NH3
        execute_on = 'initial timestep_end'
    [../]

    [./Z1CuOH]
        type = ElementAverageValue
        variable = q1
        execute_on = 'initial timestep_end'
    [../]

    [./Z2Cu]
        type = ElementAverageValue
        variable = q2
        execute_on = 'initial timestep_end'
    [../]

    [./ZH]
        type = ElementAverageValue
        variable = q3
        execute_on = 'initial timestep_end'
    [../]

    [./total]
        type = ElementAverageValue
        variable = qT
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
  line_search = bt
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-4
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0.0
  end_time = 283.0
  dtmax = 0.25

  [./TimeStepper]
     type = ConstantDT
     dt = 0.25
  [../]
[] #END Executioner

[Outputs]
  print_linear_residuals = false
  exodus = true
  csv = true
[] #END Outputs
