# NOTE: This does not work. We cannot solve the electric potential
#       be forcing a divergence free condition on current variables.
#       (Unless maybe we use something other than LU factorization?).
#
#       Solving with preconditioning fails at SUBPC_ERROR, which usually
#       indicates some issue with LU decomp.

# Alternative:   Formulate a Poisson equation for phi_e

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
      family = MONOMIAL
      initial_condition = 1e-20
  [../]

  # Negative ion concentration (in mol/volume)
  [./neg_ion]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1e-20
  [../]

  # electrolyte potential (in V or J/C)
  [./phi_e]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  # Electrolyte current density in x (C/area/time)
  [./ie_x]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1e-20
  [../]

  # Electrolyte current density in y (C/area/time)
  [./ie_y]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1e-20
  [../]


  # Check for ElectroNeutral Condition
  [./ion_sum]
      order = FIRST
      family = MONOMIAL
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
        initial_condition = 0.5
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
    # Enforce Divergence Free Condition on current
    [./cons_current_flow]
        type = DivergenceFreeCondition
        variable = phi_e
        ux = ie_x
        uy = ie_y
        uz = 0
    [../]

    # Current density in x-dir from potential gradient
    #  -ie_x
    [./ie_x_equ]
        type = Reaction
        variable = ie_x
    [../]
    #  -K*grad(phi_e)_x   where K=f(ions, diff, etc....)
    [./ie_x_phigrad]
        type = ElectrolyteCurrentFromPotentialGradient
        variable = ie_x
        direction = 0         # 0=x
        electric_potential = phi_e
        porosity = eps
        temperature = Te
        ion_conc = 'pos_ion neg_ion'
        ion_valence = '1 -1'
        diffusion = 'Dp Dp'
    [../]
    #  -F*eps*SUM( zj*Dj*grad(ion)_x )
    [./ie_x_iongrad]
        type = ElectrolyteCurrentFromIonGradient
        variable = ie_x
        direction = 0         # 0=x
        porosity = eps
        ion_conc = 'pos_ion neg_ion'
        ion_valence = '1 -1'
        diffusion = 'Dp Dp'
    [../]

    # Current density in y-dir from potential gradient
    #  -ie_y
    [./ie_y_equ]
        type = Reaction
        variable = ie_y
    [../]
    #  -K*grad(phi_e)_y   where K=f(ions, diff, etc....)
    [./ie_y_phigrad]
        type = ElectrolyteCurrentFromPotentialGradient
        variable = ie_y
        direction = 1         # 1=y
        electric_potential = phi_e
        porosity = eps
        temperature = Te
        ion_conc = 'pos_ion neg_ion'
        ion_valence = '1 -1'
        diffusion = 'Dp Dp'
    [../]
    #  -F*eps*SUM( zj*Dj*grad(ion)_y )
    [./ie_y_iongrad]
        type = ElectrolyteCurrentFromIonGradient
        variable = ie_y
        direction = 1         # 1=y
        porosity = eps
        ion_conc = 'pos_ion neg_ion'
        ion_valence = '1 -1'
        diffusion = 'Dp Dp'
    [../]


    ### Conservation of mass for pos_ion ###
    [./pos_ion_dot]
        type = VariableCoefTimeDerivative
        variable = pos_ion
        coupled_coef = eps
    [../]
    [./pos_ion_gdiff]
        type = GVarPoreDiffusion
        variable = pos_ion
        porosity = eps
        Dx = Dp
        Dy = Dp
        Dz = Dp
    [../]
    [./pos_ion_gnpdiff]
        type = GNernstPlanckDiffusion
        variable = pos_ion
        valence = 1
        porosity = eps
        electric_potential = phi_e
        temperature = Te
        Dx = Dp
        Dy = Dp
        Dz = Dp
    [../]
    [./pos_ion_gadv]
        type = GPoreConcAdvection
        variable = pos_ion
        porosity = eps
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    ### Solve for negative ion as function of other ions (forces electroneutrality) ###
    [./neg_ion_equ]
        type = Reaction
        variable = neg_ion
    [../]
    [./neg_ion_fun]
        type = WeightedCoupledSumFunction
        variable = neg_ion
        coupled_list = 'pos_ion'
        weights = '1'
    [../]


    # Check for ElectroNeutral
    [./sum_equ]
        type = Reaction
        variable = ion_sum
    [../]
    [./sum_of_ions]
        type = WeightedCoupledSumFunction
        variable = ion_sum
        coupled_list = 'pos_ion neg_ion'
        weights = '1 -1'
    [../]

[] #END Kernels

# NOTE: All'G' prefixed kernels from above MUST have a
#       corresponding 'DG' kernel down here.
[DGKernels]

  ### Conservation of mass for pos_ion ###
  [./pos_ion_dgdiff]
      type = DGVarPoreDiffusion
      variable = pos_ion
      porosity = eps
      Dx = Dp
      Dy = Dp
      Dz = Dp
  [../]
  [./pos_ion_dgnpdiff]
      type = DGNernstPlanckDiffusion
      variable = pos_ion
      valence = 1
      porosity = eps
      electric_potential = phi_e
      temperature = Te
      Dx = Dp
      Dy = Dp
      Dz = Dp
  [../]
  [./pos_ion_dgadv]
      type = DGPoreConcAdvection
      variable = pos_ion
      porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]

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
      type = DGPoreConcFluxBC
      variable = pos_ion
      boundary = 'bottom'
      porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      u_input = 2e-8
  [../]
  [./pos_ion_FluxOut]
      type = DGPoreConcFluxBC
      variable = pos_ion
      boundary = 'top'
      porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
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


    [./sum_ion_avg]
        type = ElementAverageValue
        variable = ion_sum
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

                         ilu

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
