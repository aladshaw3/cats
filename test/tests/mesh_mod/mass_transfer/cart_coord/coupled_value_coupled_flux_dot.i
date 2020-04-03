[Mesh]
#Generate a 2D mesh to entire domain (block = 0)
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    xmax = 2
    ny = 10
    ymax = 2
  []
#Create a bounding box from the entire domain to span the new subdomain (block = 1)
  [./subdomain1]
    input = gen
    type = SubdomainBoundingBoxGenerator
    bottom_left = '0 0 0'
    top_right = '1 1 0'
    block_id = 1
  [../]
#Designate a new boundary as the side sets that are shared between block 0 and block 1
#   The new boundary is now labeled and can be used in boundary conditions or InterfaceKernels
  [./interface]
    type = SideSetsBetweenSubdomainsGenerator
    input = subdomain1
    master_block = '0'
    paired_block = '1'
    new_boundary = 'master0_interface'
  [../]
#Break up the original boundaries (left right top bottom) to create separate boundaries for each subdomain
#new boundary names are (old_name)_to_(block_id)
# For example, two new left side boundary names:   left_to_0 and left_to_1
#       left_to_0 is the new left side bounary that is a part of block 0
  [./break_boundary]
    input = interface
    type = BreakBoundaryOnSubdomainGenerator
  [../]
[]

[Variables]
  [./u]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
    block = 0
  [../]

  [./v]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
    block = 1
  [../]
[]

[Kernels]
  [./dot_u]
    type = TimeDerivative
    variable = u
    block = 0
  [../]
  [./diff_u]
    type = Diffusion
    variable = u
    block = 0
  [../]
  [./dot_v]
    type = TimeDerivative
    variable = v
    block = 1
  [../]
  [./diff_v]
    type = Diffusion
    variable = v
    block = 1
  [../]
[]

#InterfaceKernels define how to communicate variables on different subdomains with each other
[InterfaceKernels]
  [./interface]
    type = InterfaceReaction
    variable = u
    neighbor_var = v
    boundary = master0_interface
    kf = 1
    kb = 1
  [../]
[]

[BCs]
  [./v]
    type = DirichletBC
    variable = v
    boundary = 'left_to_1 bottom_to_1'
    value = 1
  [../]
[]

[Postprocessors]
  [./u_int]
    type = ElementIntegralVariablePostprocessor
    variable = u
    block = 0
  [../]
  [./v_int]
    type = ElementIntegralVariablePostprocessor
    variable = v
    block = 1
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = TRUE
  [../]
[]

[Executioner]
  type = Transient
  solve_type = 'pjfnk'

  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = ' lu       superlu_dist                '
  dt = 0.1
  num_steps = 10
  dtmin = 0.1
  line_search = none
[]

[Outputs]
  exodus = true
  print_linear_residuals = true
[]
