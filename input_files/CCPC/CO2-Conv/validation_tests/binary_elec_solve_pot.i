[GlobalParams]

[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = 20
    ny = 1
    xmin = 0.0
    xmax = 0.1   # m
    ymin = 0.0
    ymax = 0.01  # m
[] # END Mesh

[Variables]
  # electrolyte potential (in V or J/C)
  [./phi_e]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]
[]

[AuxVariables]
  # Positive ion concentration (in mol/m^3)
  [./pos_ion]
      order = FIRST
      family = MONOMIAL
  [../]
[]

[ICs]
  [./ion_ic]
    type = FunctionIC
    variable = pos_ion
    function = parsed_function
  [../]
[]

[Functions]
  [./parsed_function]
    type = ParsedFunction
    value = '1000 - x*4606.34'
  [../]
[]

[Kernels]
  active = 'phi_e_pot_cond phi_e_ion_cond'
  #active = 'phi_e_lap'

  ### ==================== Electrolyte Potentials ==========================
  # Calculate potential from gradients in system
  [./phi_e_pot_cond]
      type = ElectrolytePotentialConductivity
      variable = phi_e
      porosity = 1
      temperature = 300
      ion_conc = 'pos_ion'
      ion_valence = '2'
      diffusion = '4.5e-8'
      tight_coupling = true
  [../]
  [./phi_e_ion_cond]
      type = ElectrolyteIonConductivity
      variable = phi_e
      porosity = 1
      ion_conc = 'pos_ion'
      ion_valence = '2'
      diffusion = '4.5e-8'
      tight_coupling = true
  [../]

  [./phi_e_lap]
      type = Diffusion
      variable = phi_e
  [../]
[]

[DGKernels]

[]

[BCs]
  active = 'phi_e_left phi_e_right_alt'

  ### BCs for phi_e ###
  [./phi_e_left]
      type = FunctionDirichletBC
      variable = phi_e
      boundary = 'left'
      function = '0'
  [../]
  [./phi_e_right]
      type = FunctionNeumannBC
      variable = phi_e
      boundary = 'right'
      function = '-1.6559e-1'
  [../]
  [./phi_e_right_alt]
      type = FunctionDirichletBC
      variable = phi_e
      boundary = 'right'
      function = '-0.012'
  [../]
[]

[Postprocessors]
    [./pos_ion_left]
        type = SideAverageValue
        boundary = 'left'
        variable = pos_ion
        execute_on = 'initial timestep_end'
    [../]

    [./pos_ion_right]
        type = SideAverageValue
        boundary = 'right'
        variable = pos_ion
        execute_on = 'initial timestep_end'
    [../]

    [./pos_ion_avg]
        type = ElementAverageValue
        variable = pos_ion
        execute_on = 'initial timestep_end'
    [../]

    [./phi_e_left]
        type = SideAverageValue
        boundary = 'left'
        variable = phi_e
        execute_on = 'initial timestep_end'
    [../]

    [./phi_e_right]
        type = SideAverageValue
        boundary = 'right'
        variable = phi_e
        execute_on = 'initial timestep_end'
    [../]

    [./phi_e_avg]
        type = ElementAverageValue
        variable = phi_e
        execute_on = 'initial timestep_end'
    [../]

    [./phi_e_right_minus]
        type = ElementalVariableValue
        elementid = 19
        variable = phi_e
        execute_on = 'initial timestep_end'
    [../]

[] #END Postprocessors

[Executioner]
  type = Steady
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

                         1E-15
                         1E-15

                         gmres
                         lu'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = none
  nl_rel_tol = 1e-15
  nl_abs_tol = 1e-15
  nl_rel_step_tol = 1e-15
  nl_abs_step_tol = 1e-15
  nl_max_its = 20
  l_tol = 1e-6
  l_max_its = 300

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
