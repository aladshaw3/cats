[GlobalParams]
  dg_scheme = nipg
  sigma = 10
  Dxx = 1.0
  Dyy = 1.0
[] #END GlobalParams

[Problem]
    coord_type = RZ
    #NOTE: For RZ coordinates, x ==> R and y ==> Z (and z ==> nothing)
[] #END Problem

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
    bottom_left = '1 0 0'
    top_right = '2 2 0'
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
    family = MONOMIAL
    initial_condition = 0
    block = 0
  [../]

  [./v]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0
    block = 1
  [../]
 
 [./q]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1
    block = 0
 [../]
 
 [./s]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0
    block = 0
 [../]
[]

[AuxVariables]
 [./w]
     order = FIRST
     family = MONOMIAL
     initial_condition = 1
 [../]
[]

[Kernels]
  [./dot_u]
    type = TimeDerivative
    variable = u
    block = 0
  [../]
  [./u_gdiff]
    type = GAnisotropicDiffusion
    variable = u
    block = 0
  [../]
  [./transfer_q]
      type = CoupledCoeffTimeDerivative
      variable = u
      coupled = q
      block = 0
  [../]
 
 [./q_dot]
    type = TimeDerivative
    variable = q
    block = 0
 [../]
 [./q_rxn]
    type = ConstReaction
    variable = q
    this_variable = q
    forward_rate = 4
    reverse_rate = 1
    scale = 1.0
    reactants = 'u s'
    reactant_stoich = '1 1'
    products = 'q'
    product_stoich = '1'
    block = 0
 [../]
 
 [./s_bal]
     type = MaterialBalance
     variable = s
     this_variable = s
     coupled_list = 'q s'
     weights = '1 1'
     total_material = w
     block = 0
 [../]
 
  [./dot_v]
    type = TimeDerivative
    variable = v
    block = 1
  [../]
  [./v_gdiff]
    type = GAnisotropicDiffusion
    variable = v
    block = 1
  [../]
[]

[DGKernels]
  [./u_dgdiff]
    type = DGAnisotropicDiffusion
    variable = u
    block = 0
  [../]
  [./v_dgdiff]
    type = DGAnisotropicDiffusion
    variable = v
    block = 1
  [../]

[] #END DGKernels

#InterfaceKernels define how to communicate variables on different subdomains with each other
#   This interface kernel is for a phase transfer via reaction between subdomains
#   (i.e., can be used to represent Henrys Law)
#
#       Reaction:  u <-- --> v
#       Residuals = (kf*u - kb*v)*test
#
#   New Kernel --> InferfaceMassTransfer  :   Residual = test*km*(u - v)
#                   Uses same residuals and jacobians as InterfaceReaction where kf=kb=km
#
#   Then, create CoupledInterfaceMassTransfer where km = variable
#       and add a OffDiagJacobian (similar to DGConcentrationAdvection OffDiag)
[InterfaceKernels]
  [./interface]
    type = InterfaceReaction
    variable = u        #variable must be the variable in the master block
    neighbor_var = v    #neighbor_var must the the variable in the paired block
    boundary = master0_interface
    kf = 1
    kb = 1
  [../]
[]

[BCs]
#  [./v]
#    type = DGFluxLimitedBC
#    variable = v
#    boundary = 'bottom_to_1'
#    value = 1
#  [../]
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
  num_steps = 20
  dtmin = 0.1
  line_search = none
[]

[Outputs]
  exodus = true
  print_linear_residuals = true
[]
