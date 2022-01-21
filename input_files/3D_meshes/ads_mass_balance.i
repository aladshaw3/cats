[GlobalParams]

 []

[Mesh]
  #FileMeshGenerator automatically assigns boundary names from the .msh file
#   .msh file MUST HAVE specific boundary names in it (use msh format 4.1)
    [./mesh_file]
        type = FileMeshGenerator
        file = Monolith_Composite_Updated.msh
    [../]
  #The above file contains the following boundary names
  #boundary_name = 'inlet outlet washcoat_walls interface wash_in wash_out'
  #block_name = 'washcoat channel'

  # 5cm length x 0.127 cm full channel dia

[]

#Use MONOMIAL for DG and LAGRANGE for non-DG
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
        initial_condition = 2
        block = 'channel'
    [../]

	[./vel_z]
        order = FIRST
        family = LAGRANGE
		    initial_condition = 0
        block = 'channel'
	[../]

    [./Diff]
        order = FIRST
        family = MONOMIAL
        initial_condition = 2.5
        block = 'channel'
    [../]

    [./Dw]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.01
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
        type = CoefTimeDerivative
        variable = C
        Coefficient = 1.0
        block = 'channel'
    [../]
    [./C_gadv]
        type = GPoreConcAdvection
        variable = C
        porosity = 1
        ux = vel_x
        uy = vel_y
        uz = vel_z
        block = 'channel'
    [../]
    [./C_gdiff]
        type = GVarPoreDiffusion
        variable = C
        porosity = 1
        Dx = Diff
        Dy = Diff
        Dz = Diff
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
          type = CoupledPorePhaseTransfer
          variable = Cw
          coupled = q
          porosity = 0      #replace porosity with 0 because q is measured as mass per volume washcoat already
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
           forward_rate = 4.0
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
        type = DGPoreConcAdvection
        variable = C
        porosity = 1
        ux = vel_x
        uy = vel_y
        uz = vel_z
        block = 'channel'
    [../]
    [./C_dgdiff]
        type = DGVarPoreDiffusion
        variable = C
        porosity = 1
        Dx = Diff
        Dy = Diff
        Dz = Diff
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

# C and Cw are not defined on channel_washcoat_interface
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
#This kernel is never getting invoked
    [./interface_kernel]
        type = InterfaceMassTransfer
        variable = C        #variable must be the variable in the master block
        neighbor_var = Cw    #neighbor_var must the the variable in the paired block
        boundary = 'interface'
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

    [./ew_avg]
        type = ElementAverageValue
        variable = ew
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

    [./xsec_area_channel]
        type = AreaPostprocessor
        boundary = 'outlet'
        execute_on = 'initial timestep_end'
    [../]

    [./xsec_area_washcoat]
        type = AreaPostprocessor
        boundary = 'wash_out'
        execute_on = 'initial timestep_end'
    [../]
[]

[Materials]

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
  solve_type = pjfnk
  petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -ksp_gmres_restart -pc_type -sub_pc_type'
  petsc_options_value = 'gmres 300 lu lu'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = none
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-6
  nl_rel_step_tol = 1e-12
  nl_abs_step_tol = 1e-12
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0.0
  end_time = 15
  dtmax = 0.5

  [./TimeStepper]
#	type = SolutionTimeAdaptiveDT
    type = ConstantDT
    dt = 0.15
  [../]
[]

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
[]
