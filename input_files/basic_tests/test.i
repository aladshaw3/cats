[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 10
[]

[Variables]
  [./u]
    [./InitialCondition]
      type = ConstantIC
      value = 0
    [../]
  [../]

[]

[Kernels]
  [./diff]
    type = Diffusion
    variable = u
  [../]

[]

[BCs]
  [./left]
    type = DirichletBC
    variable = u
    boundary = left
    value = 0
  [../]

  [./right]
    type = DirichletBC
    variable = u
    boundary = right
    value = 1
  [../]

[]

[Executioner]
  type = Steady
  solve_type = pjfnk
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
[]

[Outputs]
  exodus = True
[]

