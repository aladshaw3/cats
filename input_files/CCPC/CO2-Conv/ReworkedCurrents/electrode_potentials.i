
[GlobalParams]
  # Default DG methods
  sigma = 10
  dg_scheme = nipg

[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = 10
    ny = 20
    xmin = 0.0
    xmax = 5.0
    ymin = 0.0
    ymax = 10.0
    elem_type = TRI3
[] # END Mesh

[Variables]
  # electrode potential (in V or J/C)
  [./phi_s]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  # electrode current density in x (C/area/time)
  [./is_x]
      order = FIRST
      family = LAGRANGE
      initial_condition = 1e-20
  [../]

  # electrode current density in y (C/area/time)
  [./is_y]
      order = FIRST
      family = LAGRANGE
      initial_condition = 1e-20
  [../]

[] #END Variables

[AuxVariables]
    [./eps]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.4
    [../]

    [./solid_frac]
        order = FIRST
        family = MONOMIAL
    [../]

    [./sigma_s]
        order = FIRST
        family = MONOMIAL
        initial_condition = 50
    [../]

[] #END AuxVariables

[ICs]

[] #END ICs

[Kernels]
    # Calculate potential from conductivity
    [./phi_s_pot_cond]
        type = ElectrodePotentialConductivity
        variable = phi_s
        solid_frac = solid_frac
        conductivity = sigma_s
    [../]

    # Current density in x-dir from potential gradient
    #  is_x
    [./is_x_equ]
        type = Reaction
        variable = is_x
    [../]
    #  -sigma*(1-eps)*grad(phi_s)_x
    [./is_x_phigrad]
        type = ElectrodeCurrentFromPotentialGradient
        variable = is_x
        direction = 0         # 0=x
        electric_potential = phi_s
        solid_frac = solid_frac
        conductivity = sigma_s
    [../]

    # Current density in y-dir from potential gradient
    #  is_y
    [./is_y_equ]
        type = Reaction
        variable = is_y
    [../]
    #  -sigma*(1-eps)*grad(phi_s)_y
    [./is_y_phigrad]
        type = ElectrodeCurrentFromPotentialGradient
        variable = is_y
        direction = 1         # 1=y
        electric_potential = phi_s
        solid_frac = solid_frac
        conductivity = sigma_s
    [../]

[] #END Kernels

# NOTE: All'G' prefixed kernels from above MUST have a
#       corresponding 'DG' kernel down here.
[DGKernels]

[]

[AuxKernels]

    [./non_pore_calc]
        type = SolidsVolumeFraction
        variable = solid_frac
        porosity = eps
        execute_on = 'initial timestep_end'
    [../]

[] #END AuxKernels

[BCs]
  ### BCs for phi_e ###
  [./phi_s_right]
      type = FunctionPenaltyDirichletBC
      variable = phi_s
      boundary = 'left'
      function = '0'
      penalty = 300
  [../]
  [./phi_s_left]
      type = FunctionNeumannBC
      variable = phi_s
      boundary = 'right'
      function = '2e-6*t'
  [../]

[] #END BCs

[Materials]

[] #END Materials

[Postprocessors]
    [./phi_s_left]
        type = SideAverageValue
        boundary = 'left'
        variable = phi_s
        execute_on = 'initial timestep_end'
    [../]

    [./phi_s_right]
        type = SideAverageValue
        boundary = 'right'
        variable = phi_s
        execute_on = 'initial timestep_end'
    [../]

    [./phi_s_avg]
        type = ElementAverageValue
        variable = phi_s
        execute_on = 'initial timestep_end'
    [../]

[] #END Postprocessors

[Executioner]
  type = Transient
  scheme = implicit-euler
  # NOTE: Add arg -ksp_view to get info on methods used at linear steps
  petsc_options = '-snes_converged_reason

                    -ksp_gmres_modifiedgramschmidt'

  # NOTE: The sub_pc_type arg not used if pc_type is ksp,
  #       Instead, set the ksp_ksp_type to the pc method
  #       you want. Then, also set the ksp_pc_type to be
  #       the terminal preconditioner.
  #
  # Good terminal precon options: lu, ilu, asm, gasm, pbjacobi
  #                               bjacobi, redundant, telescope
  petsc_options_iname ='-ksp_type
                        -pc_type

                        -sub_pc_type

                        -snes_max_it

                        -sub_pc_factor_shift_type
                        -pc_factor_shift_type
                        -ksp_pc_factor_shift_type

                        -pc_asm_overlap

                        -snes_atol
                        -snes_rtol

                        -ksp_ksp_type
                        -ksp_pc_type'

  # snes_max_it = maximum non-linear steps


  ######## NOTE: Best convergence results with asm pc and lu sub-pc ##############
  ##      Issue may be caused by the terminal pc of the ksp pc method
  #       using MUMPS as the linear solver (which is an inefficient method)

  petsc_options_value = 'gmres
                         ksp

                         lu

                         20

                         NONZERO
                         NONZERO
                         NONZERO

                         10

                         1E-10
                         1E-10

                         gmres
                         lu'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = none
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-10
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 20
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0.0
  end_time = 15.0
  dtmax = 0.5

    [./TimeStepper]
		  type = ConstantDT
      dt = 0.5
    [../]

[] #END Executioner

[Preconditioning]
    [./SMP_PJFNK]
      type = SMP
      full = true
      solve_type = pjfnk
    [../]

[] #END Preconditioning

[Outputs]

    exodus = true
    csv = true
    print_linear_residuals = true

[] #END Outputs
