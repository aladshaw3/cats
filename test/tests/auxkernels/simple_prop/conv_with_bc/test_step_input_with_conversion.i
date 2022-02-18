[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 10
[]

[Variables]
  [./u]
      initial_condition = 0.
  [../]
[]

[AuxVariables]
  [./u_bc_left]
      initial_condition = 0.
  [../]

  [./u_bc_left_volfrac]
      initial_condition = 0.
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
    [./step_input]
        type = TemporalStepFunction
        variable = u_bc_left_volfrac

        start_value = 1
        aux_vals = '200 3000 100'
        aux_times = '1 2 4'
        execute_on = 'initial timestep_begin nonlinear'
    [../]

    [./convert_to_molar]
        type = SimpleGasVolumeFractionToConcentration
        variable = u_bc_left

        pressure = 101.35
        pressure_unit = "kPa"
        temperature = 300 # K

        volfrac = u_bc_left_volfrac

        output_volume_unit = "L"
        input_volfrac_unit = "ppm"

        execute_on = 'initial timestep_end'
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
