[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 1
  ny = 1
[]

[Variables]
  [./A]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0
  [../]
  [./B]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0
  [../]
  [./C]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0
  [../]
[]
 
[AuxVariables]
  [./CT]
     order = FIRST
     family = MONOMIAL
     initial_condition = 1
  [../]
  [./CT2]
    order = FIRST
    family = MONOMIAL
    initial_condition = 2
  [../]
  [./CT3]
    order = FIRST
    family = MONOMIAL
    initial_condition = 3
  [../]
[]

[Kernels]
  [./mb]
    type = MaterialBalance
    variable = A
    this_variable = A
    weights = '2'
    coupled_list = 'A'
    total_material = CT
  [../]
  [./mb2]
    type = MaterialBalance
    variable = B
    this_variable = B
    weights = '2 1'
    coupled_list = 'A B'
    total_material = CT2
  [../]
  [./mb3]
    type = MaterialBalance
    variable = C
    this_variable = C
    weights = '1 1 1'
    coupled_list = 'CT CT2 CT3'
    total_material = C
  [../]
[]

[BCs]

[]

[Postprocessors]
    [./CT]
        type = ElementAverageValue
        variable = CT
        execute_on = 'initial timestep_end'
    [../]
    [./CT2]
        type = ElementAverageValue
        variable = CT2
        execute_on = 'initial timestep_end'
    [../]
    [./CT3]
        type = ElementAverageValue
        variable = CT3
        execute_on = 'initial timestep_end'
    [../]
    [./A]
        type = ElementAverageValue
        variable = A
        execute_on = 'initial timestep_end'
    [../]
    [./B]
        type = ElementAverageValue
        variable = B
        execute_on = 'initial timestep_end'
    [../]
    [./C]
        type = ElementAverageValue
        variable = C
        execute_on = 'initial timestep_end'
    [../]
[]

[Executioner]
  type = Steady
  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
[]

[Outputs]
  exodus = true
  csv = true
[]
