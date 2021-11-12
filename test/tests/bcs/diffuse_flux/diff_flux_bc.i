# This test compares the CG and DG methods for diffusion in a
# box with a diffuse flux BC and imposed Dirichlet BC.

[GlobalParams]
  # Default DG methods
  sigma = 10
  dg_scheme = nipg
  Dxx = 1
  Dyy = 1
  Dzz = 1

[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = 10
    ny = 10
    xmin = 0.0
    xmax = 5.0
    ymin = 0.0
    ymax = 5.0
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
      family = LAGRANGE
      initial_condition = 1e-20
  [../]

[] #END Variables

[AuxVariables]
    [./Dp]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1
    [../]

    [./eps]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1
    [../]

[] #END AuxVariables

[ICs]

[] #END ICs

[Kernels]
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

    ### Conservation of mass for neg_ion ###
    [./neg_ion_dot]
        type = TimeDerivative
        variable = neg_ion
    [../]
    [./neg_ion_gdiff]
        type = Diffusion
        variable = neg_ion
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

[]

[AuxKernels]

[] #END AuxKernels

[BCs]

  ### Fluxes for Ions ###
  [./pos_ion_FluxIn]
      #type = FunctionPenaltyDirichletBC
      #variable = pos_ion
      #boundary = 'bottom'
      #function = 1e-8
      #penalty = 300

      type = DGDiffusionFluxBC
      variable = pos_ion
      boundary = 'bottom'
      Dxx = 1
      Dyy = 1
      Dzz = 1
      u_input = 1e-8
  [../]
  [./pos_ion_FluxOut]
      type = DGDiffusionFluxBC
      variable = pos_ion
      boundary = 'top'
      Dxx = 1
      Dyy = 1
      Dzz = 1
  [../]

  ### Fluxes for Ions ###
  [./neg_ion_FluxIn]
      type = FunctionDirichletBC
      variable = neg_ion
      boundary = 'bottom'
      function = 1e-8
  [../]
  [./neg_ion_FluxOut]
      type = DiffusionFluxBC
      variable = neg_ion
      boundary = 'top'
  [../]

[] #END BCs

[Materials]

[] #END Materials

[Postprocessors]
    [./pos_ion_top]
        type = SideAverageValue
        boundary = 'top'
        variable = pos_ion
        execute_on = 'initial timestep_end'
    [../]

    [./pos_ion_bottom]
        type = SideAverageValue
        boundary = 'bottom'
        variable = pos_ion
        execute_on = 'initial timestep_end'
    [../]

    [./pos_ion_avg]
        type = ElementAverageValue
        variable = pos_ion
        execute_on = 'initial timestep_end'
    [../]

    [./neg_ion_top]
        type = SideAverageValue
        boundary = 'top'
        variable = neg_ion
        execute_on = 'initial timestep_end'
    [../]

    [./neg_ion_bottom]
        type = SideAverageValue
        boundary = 'bottom'
        variable = neg_ion
        execute_on = 'initial timestep_end'
    [../]

    [./neg_ion_avg]
        type = ElementAverageValue
        variable = neg_ion
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
  end_time = 5.0
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
