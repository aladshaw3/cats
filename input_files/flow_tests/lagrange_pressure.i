[GlobalParams]

[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
  type = GeneratedMesh
  dim = 2
	nx = 10
  ny = 10
  xmin = 0.0
  xmax = 10.0
  ymin = 0.0
  ymax = 10.0
[] # END Mesh

[Variables]
	[./pressure]
		order = FIRST
		family = LAGRANGE
		initial_condition = 0.0
	[../]

  [./vel_x]
		order = FIRST
		family = LAGRANGE
		initial_condition = 0.0
	[../]

  [./vel_y]
		order = FIRST
		family = LAGRANGE
		initial_condition = 0.0
	[../]

[] #END Variables

[AuxVariables]
  [./vel_z]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
  [../]
[] #END AuxVariables

[ICs]


[] #END ICs

[Kernels]
    [./press_diff]
      type = Diffusion
      variable = pressure
    [../]

    [./x_equ]
      type = Reaction
      variable = vel_x
    [../]
    [./x_press]
      type = VectorCoupledGradient
      variable = vel_x
      coupled = pressure
      vx = 1
    [../]

    [./y_equ]
      type = Reaction
      variable = vel_y
    [../]
    [./y_press]
      type = VectorCoupledGradient
      variable = vel_y
      coupled = pressure
      vy = 1
    [../]

[] #END Kernels

[DGKernels]

[] #END DGKernels

[AuxKernels]


[] #END AuxKernels

[BCs]

  # Zero pressure at exit
	[./press_at_exit]
        type = DirichletBC
        variable = pressure
        boundary = 'top'
		    value = 0.0
  [../]

  # 100 kPa pressure at enter
	[./press_at_enter]
        type = DirichletBC
        variable = pressure
        boundary = 'bottom'
		    value = 100.0
  [../]

[] #END BCs

[Materials]


[] #END Materials

[Postprocessors]

    [./pressure_right]
        type = SideAverageValue
        boundary = 'right'
        variable = pressure
        execute_on = 'initial timestep_end'
    [../]

    [./pressure_left]
        type = SideAverageValue
        boundary = 'left'
        variable = pressure
        execute_on = 'initial timestep_end'
    [../]

    [./pressure_top]
        type = SideAverageValue
        boundary = 'top'
        variable = pressure
        execute_on = 'initial timestep_end'
    [../]

    [./pressure_bottom]
        type = SideAverageValue
        boundary = 'bottom'
        variable = pressure
        execute_on = 'initial timestep_end'
    [../]

    [./pressure_avg]
        type = ElementAverageValue
        variable = pressure
        execute_on = 'initial timestep_end'
    [../]

[] #END Postprocessors

[Executioner]
  type = Steady
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
  end_time = 10.0
  dtmax = 0.5

    [./TimeStepper]
		  type = ConstantDT
      dt = 0.2
    [../]

[] #END Executioner

[Preconditioning]
    [./SMP_PJFNK]
      type = SMP
      full = true
      solve_type = pjfnk   #newton solver works faster when using very good preconditioner
    [../]

[] #END Preconditioning

[Outputs]

    exodus = true
    csv = true
    print_linear_residuals = true

[] #END Outputs
