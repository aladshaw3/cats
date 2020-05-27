[GlobalParams]

 []

[Mesh]
  #FileMeshGenerator automatically assigns boundary names from the .unv file
  #   .unv file MUST HAVE specific boundary names in it
    [./mesh_file]
        type = FileMeshGenerator
        file = MonolithChannel_v2_2.msh
    [../]
  #The above file contains the following block and boundary names
  #boundary_name = 'inlet outlet washcoat_walls'
  #block_name = 'washcoat channel'
  
 
# NOTE: Although we created a sideset in the file, that didn't get interpreted as an interface
    [./interface_set]
        type = SideSetsBetweenSubdomainsGenerator
        input = mesh_file
        master_block = 'channel'
        paired_block = 'washcoat'
        new_boundary = 'real_interface'
    [../]
 
 
[]

#Use MONOMIAL for DG and LAGRANGE for non-DG
[Variables]
    [./C]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.0
block = 'channel'      #Problem: MOOSE does not see channel_washcoat_interface as part of channel!
    [../]
    [./Cw]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.0
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
        initial_condition = 0.25
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
 
    # C and Cw are not defined on channel_washcoat_interface
 
# NOTE: This will run if given Cw, but Segfault if given C
#    [./Cw_test]
#        type = DGFluxLimitedBC
#        variable = Cw        #NOT SURE WHAT THIS DOES FOR C... Segfault if C not on washcoat...
#        boundary = 'real_interface'
#        u_input = 1.0
#        vx = 0
#        vy = 0
#        vz = 0
#    [../]
 
     [./C_test]
         type = DGFluxLimitedBC
         variable = C        #NOT SURE WHAT THIS DOES FOR C... Segfault if C not on washcoat...
         boundary = 'real_interface'
         u_input = 1.0
         vx = 0
         vy = 0
         vz = 0
     [../]
[]
 
 [InterfaceKernels]
#This kernel is never getting invoked
#    [./interface_kernel]
#type = InterfaceReaction
#       kb = 1
#       kf = 1
#        type = InterfaceMassTransfer
#        variable = C        #variable must be the variable in the master block
#        neighbor_var = Cw    #neighbor_var must the the variable in the paired block
 
#boundary = 'interface'  #<-- MOOSE Claims the boundary doesn't exist?
 
# NOTE: This side set is not considered to be part of C (i.e., channel)
#        boundary = 'real_interface'
#        transfer_rate = 2
#    [../]
 [] #END InterfaceKernels
 
[Postprocessors]

    [./C_exit]
        type = SideAverageValue
        boundary = 'outlet'
        variable = C
        execute_on = 'initial timestep_end'
    [../]
 
#    [./Cw_wall]
#        type = SideAverageValue
#        boundary = 0
#        variable = Cw
#        execute_on = 'initial timestep_end'
#    [../]
 
    [./Cw_avg]
        type = ElementAverageValue
        variable = Cw
        block = 'washcoat'
        execute_on = 'initial timestep_end'
    [../]
[]

[Materials]

[]

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
    solve_type = pjfnk
  [../]
[]

[Executioner]
  type = Transient
  scheme = implicit-euler
  petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -pc_type -sub_pc_type -snes_max_it -sub_pc_factor_shift_type -pc_asm_overlap -snes_atol -snes_rtol'
  petsc_options_value = 'gmres asm lu 100 NONZERO 2 1E-14 1E-12'

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
  end_time = 10
  dtmax = 0.5

  [./TimeStepper]
#	type = SolutionTimeAdaptiveDT
    type = ConstantDT
    dt = 0.1
  [../]
[]

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
[]

