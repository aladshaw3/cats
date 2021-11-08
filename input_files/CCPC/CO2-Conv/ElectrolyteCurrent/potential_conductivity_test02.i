# File to test pore diffusion with variable BCs

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
[] # END Mesh

[Variables]
  # Positive ion concentration (in mol/volume)
  [./pos_ion]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  # Negative ion concentration (in mol/volume)
  [./neg_ion]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  # electrolyte potential (in V or J/C)
  [./phi_e]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

[] #END Variables

[AuxVariables]
    [./Dp]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.05
    [../]

    [./eps]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1
    [../]

    [./Te]
        order = FIRST
        family = MONOMIAL
        initial_condition = 298
    [../]

    [./vel_x]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./vel_y]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./vel_z]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

[] #END AuxVariables

[ICs]

[] #END ICs

[Kernels]
    # Potential Conductivity Term
    ## NOTE: This will ALWAYS fail to converge if 'ion_conc' values are ever '0'
    #         Simple fix is to add a 'min' value for sum of ions such that
    #         we never get zero in matrix diagonals.
    [./phi_e_pot_cond]
        type = ElectrolytePotentialConductivity
        variable = phi_e
        porosity = eps
        temperature = Te
        ion_conc = 'pos_ion neg_ion'
        ion_valence = '1 -1'
        diffusion = 'Dp Dp'
    [../]
    [./phi_e_ion_cond]
        type = ElectrolyteIonConductivity
        variable = phi_e
        porosity = eps
        ion_conc = 'pos_ion neg_ion'
        ion_valence = '1 -1'
        diffusion = 'Dp Dp'
        tight_coupling = false
    [../]


    ### Conservation of mass for pos_ion ###
    [./pos_ion_gdiff]
        type = Diffusion
        variable = pos_ion
    [../]


    ### Conservation of mass for neg_ion ###
    [./neg_ion_gdiff]
        type = Diffusion
        variable = neg_ion
    [../]

[] #END Kernels

# NOTE: All'G' prefixed kernels from above MUST have a
#       corresponding 'DG' kernel down here.
[DGKernels]

[]

[AuxKernels]

[] #END AuxKernels

[BCs]
  ### BCs for phi_e ###
  #[./phi_e_top]
  #    type = FunctionDirichletBC
  #    variable = phi_e
  #    boundary = 'top'
  #    function = '0'
  #[../]

  ### Fluxes for Ions ###
  [./pos_ion_FluxIn]
      type = FunctionPenaltyDirichletBC
      variable = pos_ion
      boundary = 'bottom'
      function = '1e-8'
      penalty = 300
  [../]
  [./pos_ion_FluxOut]
      type = FunctionPenaltyDirichletBC
      variable = pos_ion
      boundary = 'top'
      function = '0'
      penalty = 300
  [../]

  ### Fluxes for Ions ###
  [./neg_ion_FluxIn]
      type = FunctionPenaltyDirichletBC
      variable = neg_ion
      boundary = 'top'
      function = '1e-8'
      penalty = 300
  [../]
  [./neg_ion_FluxOut]
      type = FunctionPenaltyDirichletBC
      variable = neg_ion
      boundary = 'bottom'
      function = '0'
      penalty = 300
  [../]

[] #END BCs

[Materials]

[] #END Materials

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

    [./neg_ion_left]
        type = SideAverageValue
        boundary = 'left'
        variable = neg_ion
        execute_on = 'initial timestep_end'
    [../]

    [./neg_ion_right]
        type = SideAverageValue
        boundary = 'right'
        variable = neg_ion
        execute_on = 'initial timestep_end'
    [../]

    [./neg_ion_avg]
        type = ElementAverageValue
        variable = neg_ion
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
  petsc_options_value = 'fgmres
                         ksp

                         lu

                         20

                         NONZERO
                         NONZERO
                         NONZERO

                         100

                         1E-10
                         1E-10

                         fgmres
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
