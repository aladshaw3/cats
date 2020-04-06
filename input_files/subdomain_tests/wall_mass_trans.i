[GlobalParams]
  dg_scheme = nipg
  sigma = 10
[] #END GlobalParams

[Problem]

    coord_type = RZ
    #NOTE: For RZ coordinates, x ==> R and y ==> Z (and z ==> nothing)

[] #END Problem

[Mesh]

#NOTE: The washcoat thickness is a very important parameter for this type of model
#           [thickness must align with the stated average bulk porosity]
 
   [gen] #block = 0
        type = GeneratedMeshGenerator
        dim = 2
        nx = 10
        ny = 40
        xmin = 0.0
        xmax = 0.2    #0.2 radius of single channel
        ymin = 0.0
        ymax = 5.0    #5cm length
    []
    #Create a bounding box from the entire domain to span the new subdomain (block = 1)
      [./subdomain1]
        input = gen
        type = SubdomainBoundingBoxGenerator
        bottom_left = '0.15 0 0'
        top_right = '0.2 5 0'
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

[] # END Mesh

[Variables]

    [./C]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
        block = 0
    [../]

    [./Cw]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
        block = 1
    [../]

    [./q]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
        block = 1
    [../]

    [./S]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1
        block = 1
    [../]

[] #END Variables

[AuxVariables]

  [./Diff]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.01
    block = 0
  [../]
    
  [./Dp]
    order = FIRST
    family = LAGRANGE
 initial_condition = 0.01
    block = 1
  [../]

  [./pore]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.5
      block = '0 1'
  [../]
 
  [./wash_pore]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.25   #   ew * (1 - e)
      block = 1
  [../]
 
  [./S_max]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1
    block = 1
  [../]

  [./vel_x]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
      block = 0
  [../]

  [./vel_y]
      order = FIRST
      family = MONOMIAL
      initial_condition = 2
      block = 0
  [../]

  [./vel_z]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
      block = 0
  [../]

[] #END AuxVariables

[ICs]

[] #END ICs

[Kernels]

    [./C_dot]
        type = VariableCoefTimeDerivative
        variable = C
        coupled_coef = pore
        block = 0
    [../]
    [./C_gadv]
        type = GPoreConcAdvection
        variable = C
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        block = 0
    [../]
    [./C_gdiff]
        type = GVarPoreDiffusion
        variable = C
        porosity = pore
        Dx = Diff
        Dy = Diff
        Dz = Diff
        block = 0
    [../]

    [./Cw_dot]
        type = VariableCoefTimeDerivative
        variable = Cw
        coupled_coef = wash_pore
        block = 1
    [../]
    [./Cw_gdiff]
        type = GVarPoreDiffusion
        variable = Cw
        porosity = wash_pore
        Dx = Dp
        Dy = Dp
        Dz = Dp
        block = 1
    [../]
    [./transfer_q]
      type = CoupledPorePhaseTransfer
      variable = Cw
      coupled = q
      porosity = pore
      block = 1
    [../]
 
    [./q_dot]
        type = TimeDerivative
        variable = q
        block = 1
    [../]
    [./q_rxn]  #   Cw + S <-- --> q
        type = ConstReaction
        variable = q
        this_variable = q
        forward_rate = 2.0
        reverse_rate = 0.5
        scale = 1.0
        reactants = 'Cw S'
        reactant_stoich = '1 1'
        products = 'q'
        product_stoich = '1'
        block = 1
    [../]
 
    [./mat_bal]
        type = MaterialBalance
        variable = S
        this_variable = S
        coupled_list = 'S q'
        weights = '1 1'
        total_material = S_max
        block = 1
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
        block = 0
    [../]
    [./C_dgdiff]
        type = DGVarPoreDiffusion
        variable = C
        porosity = pore
        Dx = Diff
        Dy = Diff
        Dz = Diff
        block = 0
    [../]
 
    [./Cw_dgdiff]
        type = DGVarPoreDiffusion
        variable = Cw
        porosity = wash_pore
        Dx = Dp
        Dy = Dp
        Dz = Dp
        block = 1
    [../]

[] #END DGKernels
 
[InterfaceKernels]
   [./interface]
     type = InterfaceMassTransfer
     variable = C        #variable must be the variable in the master block
     neighbor_var = Cw    #neighbor_var must the the variable in the paired block
     boundary = master0_interface
     transfer_rate = 2
   [../]
[] #END InterfaceKernels

[AuxKernels]

[] #END AuxKernels

[BCs]

    [./C_FluxIn]
      type = DGPoreConcFluxBC
      variable = C
      boundary = 'bottom_to_0'
      u_input = 1.0
      porosity = pore
      ux = vel_x
      uy = vel_y
      uz = vel_z
    [../]
    [./C_FluxOut]
      type = DGPoreConcFluxBC
      variable = C
      boundary = 'top_to_0'
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
        boundary = 'top_to_0'
        variable = C
        execute_on = 'initial timestep_end'
    [../]

    [./q_avg]
        type = ElementAverageValue
        variable = q
        execute_on = 'initial timestep_end'
        block = 1
    [../]

    [./Cw_avg]
        type = ElementAverageValue
        variable = Cw
        execute_on = 'initial timestep_end'
        block = 1
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
  end_time = 10.0
  dtmax = 0.5

  [./TimeStepper]
     type = ConstantDT
     dt = 0.1
  [../]
 
[] #END Executioner

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
[] #END Outputs
