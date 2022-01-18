[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 10
[]

[Variables]
  [./u]
  [../]
[]

[AuxVariables]
  [./u_bc_left]
      initial_condition = 0
  [../]
[]

[Kernels]
  [./time_u]
    type = TimeDerivative
    variable = u
  [../]
  [./diff_u]
    type = Diffusion
    variable = u
  [../]
  [./rxn_u]
    type = Reaction
    variable = u
  [../]

[]

[AuxKernels]
    ### NOTE: To properly use this AuxKernel, you MUST specify
    #     execute_on = 'initial timestep_begin'
    #   Failure to properly setup the execute_on arg will result
    #     in errors/delays in updating the values correctly
    [./step_input]
        type = TemporalStepFunction
        variable = u_bc_left
        start_value = 1
        aux_vals = '2 3 1'
        aux_times = '1 2 4'
        execute_on = 'initial timestep_begin'
    [../]
[]

[BCs]
  [./left_u]
    type = CoupledDirichletBC
    variable = u
    boundary = left
    coupled = u_bc_left
  [../]
  [./right_u]
    type = NeumannBC
    variable = u
    boundary = right
    value = 0
  [../]


[]

[Postprocessors]

  [./u_left]
      type = SideAverageValue
      boundary = 'left'
      variable = u
      execute_on = 'initial timestep_end'
  [../]
  [./u_right]
      type = SideAverageValue
      boundary = 'right'
      variable = u
      execute_on = 'initial timestep_end'
  [../]

  [./u_bc_left]
      type = SideAverageValue
      boundary = 'left'
      variable = u_bc_left
      execute_on = 'initial timestep_end'
  [../]

[]

[Executioner]
  type = Transient
  scheme = implicit-euler
  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-10
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10

  start_time = 0
  end_time = 5
  dtmax = 0.5

  [./TimeStepper]
		  type = ConstantDT
      dt = 0.5
  [../]
[]

[Outputs]
  exodus = true
[]
