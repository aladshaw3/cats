
[Mesh]
  #FileMeshGenerator automatically assigns boundary names from the .msh file
  #   .msh file MUST HAVE specific boundary names in it (use msh format 4.1)
    [./mesh_file]
        type = FileMeshGenerator
        file = 2DChannel.msh
    [../]
  #The above file contains the following boundary names
  #boundary_name = 'inlet outlet outer_walls inner_walls'
  #block_name = 'washcoat channel'

[]

[Variables]
    [./C]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.0
        block = 'channel'
    [../]

    [./Cw]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.0
        block = 'washcoat'
    [../]
 
    [./q]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
        block = 'washcoat'
    [../]

    [./S]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1
        block = 'washcoat'
    [../]

[]

[AuxVariables]

    [./vel_x]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
        block = 'channel'
    [../]
 
    [./vel_y]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0.02
        block = 'channel'
    [../]

    [./vel_z]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
        block = 'channel'
    [../]

    [./D]
        order = FIRST
        family = MONOMIAL
        initial_condition = 2.5e-5
        block = 'channel'
    [../]
 
    [./Dw]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1e-6
        block = 'washcoat'
    [../]
 
    [./ew]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.20
        block = 'washcoat'
    [../]
 
    [./S_max]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1
      block = 'washcoat'
    [../]

[] #END AuxVariables


[Kernels]
  #Mass conservation in channel kernels
    [./C_dot]
        type = TimeDerivative
        variable = C
        block = 'channel'
    [../]
    [./C_gadv]
        type = GConcentrationAdvection
        variable = C
        ux = vel_x
        uy = vel_y
        uz = vel_z
        block = 'channel'
    [../]
    [./C_gdiff]
        type = GVariableDiffusion
        variable = C
        Dx = D
        Dy = D
        Dz = D
        block = 'channel'
    [../]
 
    #Mass conservation in washcoat kernels
      [./Cw_dot]
          type = VariableCoefTimeDerivative
          variable = Cw
          coupled_coef = ew
          block = 'washcoat'
      [../]
      [./Cw_gdiff]
          type = GVarPoreDiffusion
          variable = Cw
          porosity = ew
          Dx = Dw
          Dy = Dw
          Dz = Dw
          block = 'washcoat'
      [../]
      [./transfer_q]
          type = CoupledCoeffTimeDerivative
          variable = Cw
          coupled = q
          block = 'washcoat'
      [../]
 
    # Adsorption in the washcoat
       [./q_dot]
           type = TimeDerivative
           variable = q
           block = 'washcoat'
       [../]
       [./q_rxn]  #   Cw + S <-- --> q
           type = ConstReaction
           variable = q
           this_variable = q
           forward_rate = 8.0
           reverse_rate = 0.5
           scale = 1.0
           reactants = 'Cw S'
           reactant_stoich = '1 1'
           products = 'q'
           product_stoich = '1'
           block = 'washcoat'
       [../]
    
       [./mat_bal]
           type = MaterialBalance
           variable = S
           this_variable = S
           coupled_list = 'S q'
           weights = '1 1'
           total_material = S_max
           block = 'washcoat'
       [../]

[]

[DGKernels]
 
    [./C_dgadv]
        type = DGConcentrationAdvection
        variable = C
        ux = vel_x
        uy = vel_y
        uz = vel_z
        block = 'channel'
    [../]
    [./C_dgdiff]
        type = DGVariableDiffusion
        variable = C
        Dx = D
        Dy = D
        Dz = D
        block = 'channel'
    [../]
 
    [./Cw_dgdiff]
        type = DGVarPoreDiffusion
        variable = Cw
        porosity = ew
        Dx = Dw
        Dy = Dw
        Dz = Dw
        block = 'washcoat'
    [../]

[] #END DGKernels

[BCs]
    [./C_FluxIn]
        type = DGConcentrationFluxBC
        variable = C
        boundary = 'inlet'
		u_input = 1.0
		ux = vel_x
		uy = vel_y
		uz = vel_z
    [../]

    [./C_FluxOut]
        type = DGConcentrationFluxBC
        variable = C
        boundary = 'outlet'
        u_input = 0.0
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

[]
 
 [InterfaceKernels]
    [./interface_kernel]
        type = InterfaceMassTransfer
        variable = C
        neighbor_var = Cw
        boundary = 'inner_walls'
        transfer_rate = 2
    [../]
 [] #END InterfaceKernels
 
[Postprocessors]

    [./C_exit]
        type = SideAverageValue
        boundary = 'outlet'
        variable = C
        execute_on = 'initial timestep_end'
    [../]
 
    [./C_avg]
        type = ElementAverageValue
        variable = C
        block = 'channel'
        execute_on = 'initial timestep_end'
    [../]
 
    [./Cw_avg]
        type = ElementAverageValue
        variable = Cw
        block = 'washcoat'
        execute_on = 'initial timestep_end'
    [../]
 
    [./q_avg]
        type = ElementAverageValue
        variable = q
        block = 'washcoat'
        execute_on = 'initial timestep_end'
    [../]
 
    [./S_avg]
        type = ElementAverageValue
        variable = S
        block = 'washcoat'
        execute_on = 'initial timestep_end'
    [../]
 
    [./volume_washcoat]
        type = VolumePostprocessor
        block = 'washcoat'
        execute_on = 'initial timestep_end'
    [../]
 
    [./volume_channel]
        type = VolumePostprocessor
        block = 'channel'
        execute_on = 'initial timestep_end'
    [../]

[]

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  scheme = implicit-euler
  solve_type = newton
  petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -pc_type -sub_pc_type'
  petsc_options_value = 'gmres bjacobi lu'

  line_search = none
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-12
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0.0
  end_time = 10
  dtmax = 0.5

# As the mesh becomes more complex, may need to cut time steps
  [./TimeStepper]
    type = ConstantDT
    dt = 0.05
  [../]
[]

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
  interval = 10
[]

