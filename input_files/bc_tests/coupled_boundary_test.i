[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 10
[]

[Variables]
  [./u]
  [../]
  [./v]
  [../]
[]

[AuxVariables]
  [./v_bc_left]
      initial_condition = 0
  [../]
  [./v_bc_right]
      initial_condition = 1
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

  [./time_v]
    type = TimeDerivative
    variable = v
  [../]
  [./diff_v]
    type = Diffusion
    variable = v
  [../]
  [./rxn_v]
    type = Reaction
    variable = v
  [../]
[]

[AuxKernels]
  [./v_left_side]
      type = AuxPostprocessorValue
      variable = v_bc_left
      postprocessor = v_right
      execute_on = 'initial timestep_end'
  [../]

  [./v_right_side]
      type = LinearChangeInTime
      variable = v_bc_right
      start_time = 0.5
      end_time = 1
      end_value = 2
      execute_on = 'initial timestep_begin'
  [../]

[]

[BCs]
  [./left_u]
    type = DirichletBC
    variable = u
    boundary = left
    value = 0
  [../]
  [./right_u]
    type = NeumannBC
    variable = u
    boundary = right
    value = 1
  [../]

  [./left_v]
    type = CoupledDirichletBC
    variable = v
    boundary = left
    coupled = v_bc_left
  [../]
  [./right_v]
    type = CoupledNeumannBC
    variable = v
    boundary = right
    coupled = v_bc_right
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

  [./v_left]
      type = SideAverageValue
      boundary = 'left'
      variable = v
      execute_on = 'initial timestep_end'
  [../]
  [./v_right]
      type = SideAverageValue
      boundary = 'right'
      variable = v
      execute_on = 'initial timestep_end'
  [../]

  [./v_bc_right]
      type = SideAverageValue
      boundary = 'right'
      variable = v_bc_right
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
  end_time = 2
  dtmax = 0.5

  [./TimeStepper]
		  type = ConstantDT
      dt = 0.5
  [../]
[]

[Outputs]
  exodus = true
[]
