[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 1
  ny = 1
[]

[Variables]
  [./q_chem]
    order = FIRST
    family = MONOMIAL
  [../]
  [./q_chem_D]
    order = FIRST
    family = MONOMIAL
  [../]
  [./q_chem_tot]
    order = FIRST
    family = MONOMIAL
  [../]
  [./q_lang]
    order = FIRST
    family = MONOMIAL
  [../]
  [./S]
    order = FIRST
    family = MONOMIAL
  [../]
[]
 
[AuxVariables]
  [./C]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0.5
  [../]
  [./D]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0.15
  [../]
  [./S_max]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1
  [../]
[]

[Kernels]
  [./mat_bal]
    type = MaterialBalance
    variable = S
    this_variable = S
    coupled_list = 'S q_chem q_chem_D'
    weights = '1 1 1'
    total_material = S_max
  [../]
 
  [./mat_bal_tot]
    type = MaterialBalance
    variable = q_chem_tot
    this_variable = q_chem_tot
    coupled_list = 'q_chem q_chem_D'
    weights = '1 1'
    total_material = q_chem_tot
  [../]

  [./q_chem_lang]  #   C + S <-- --> q
    type = ConstReaction
    variable = q_chem
    this_variable = q_chem
    forward_rate = 2.0
    reverse_rate = 0.5
    scale = 1.0
    reactants = 'C S'
    reactant_stoich = '1 1'
    products = 'q_chem'
    product_stoich = '1'
  [../]
  [./q_chem_D_lang]  #   D + S <-- --> q_D
    type = ConstReaction
    variable = q_chem_D
    this_variable = q_chem_D
    forward_rate = 2.0
    reverse_rate = 1.0
    scale = 1.0
    reactants = 'D S'
    reactant_stoich = '1 1'
    products = 'q_chem_D'
    product_stoich = '1'
  [../]
 
  [./qlang_rxn]
    type = Reaction
    variable = q_lang
  [../]
  [./q_lang_lang]
    type = ExtendedLangmuirFunction
    variable = q_lang
    site_density = 1.0
    main_coupled = C
    coupled_list = 'C D'
    langmuir_coeff = '4.0 2.0'
  [../]
[]

[BCs]

[]

[Postprocessors]
    [./q_chem]
        type = ElementAverageValue
        variable = q_chem
        execute_on = 'initial timestep_end'
    [../]
    [./q_chem_D]
        type = ElementAverageValue
        variable = q_chem_D
        execute_on = 'initial timestep_end'
    [../]
    [./q_chem_tot]
        type = ElementAverageValue
        variable = q_chem_tot
        execute_on = 'initial timestep_end'
    [../]
    [./q_lang]
        type = ElementAverageValue
        variable = q_lang
        execute_on = 'initial timestep_end'
    [../]
    [./C]
       type = ElementAverageValue
       variable = C
       execute_on = 'initial timestep_end'
    [../]
    [./S]
       type = ElementAverageValue
       variable = S
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
  type = Steady
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

[] #END Executioner

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
[] #END Outputs

