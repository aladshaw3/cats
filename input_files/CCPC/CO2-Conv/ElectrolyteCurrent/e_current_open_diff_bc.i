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
      initial_condition = 1e-8
  [../]

  # Negative ion concentration (in mol/volume)
  [./neg_ion]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1e-8
  [../]

  # electrolyte potential (in V or J/C)
  [./phi_e]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  # Electrolyte current density in x (C/area/time)
  [./ie_x]
      order = SECOND
      family = MONOMIAL
      initial_condition = 0
  [../]

  # Electrolyte current density in y (C/area/time)
  [./ie_y]
      order = SECOND
      family = MONOMIAL
      initial_condition = 0
  [../]

  # Flux of positive ions in x
  [./pos_ion_flux_x]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

  # Flux of positive ions in y
  [./pos_ion_flux_y]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

  # Flux of negative ions in x
  [./neg_ion_flux_x]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

  # Flux of negative ions in y
  [./neg_ion_flux_y]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

[] #END Variables

[AuxVariables]
    [./Dp]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.5
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

    # Electrolyte current density in z (C/L^2/T)
    [./ie_z]
        order = SECOND
        family = MONOMIAL
        initial_condition = 0
    [../]

[] #END AuxVariables

[ICs]

[] #END ICs

[Kernels]
    # Enforce lapacian = 0
    [./phi_e_diff]
        type = Diffusion
        variable = phi_e
    [../]



    ## ========= Kernels to calculate effective ion flux variable =========
    #
    #     -v = D*grad(u)
    #
    # Pos Ion Flux Var (in x)
    [./pos_x_equ]
        type = CoefReaction
        variable = pos_ion_flux_x
        coefficient = -1
    [../]
    [./pos_x_flux]
        type = VariableVectorCoupledGradient
        variable = pos_ion_flux_x
        coupled = pos_ion
        ux = Dp
        uy = 0
        uz = 0
    [../]

    ## ========= Kernels to calculate effective ion flux variable =========
    # Pos Ion Flux Var (in y)
    [./pos_y_equ]
        type = CoefReaction
        variable = pos_ion_flux_y
        coefficient = -1
    [../]
    [./pos_y_flux]
        type = VariableVectorCoupledGradient
        variable = pos_ion_flux_y
        coupled = pos_ion
        ux = 0
        uy = Dp
        uz = 0
    [../]

    ## ========= Kernels to calculate effective ion flux variable =========
    # Neg Ion Flux Var (in x)
    [./neg_x_equ]
        type = CoefReaction
        variable = neg_ion_flux_x
        coefficient = -1
    [../]
    [./neg_x_flux]
        type = VariableVectorCoupledGradient
        variable = neg_ion_flux_x
        coupled = neg_ion
        ux = Dp
        uy = 0
        uz = 0
    [../]

    ## ========= Kernels to calculate effective ion flux variable =========
    # Neg Ion Flux Var (in y)
    [./neg_y_equ]
        type = CoefReaction
        variable = neg_ion_flux_y
        coefficient = -1
    [../]
    [./neg_y_flux]
        type = VariableVectorCoupledGradient
        variable = neg_ion_flux_y
        coupled = neg_ion
        ux = 0
        uy = Dp
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

    ### Conservation of mass for neg_ion ###
    [./neg_ion_dot]
        type = VariableCoefTimeDerivative
        variable = neg_ion
        coupled_coef = eps
    [../]
    [./neg_ion_gdiff]
        type = GVarPoreDiffusion
        variable = neg_ion
        porosity = eps
        Dx = Dp
        Dy = Dp
        Dz = Dp
    [../]
    [./neg_ion_gnpdiff]
        type = GNernstPlanckDiffusion
        variable = neg_ion
        valence = -1
        porosity = eps
        electric_potential = phi_e
        temperature = Te
        Dx = Dp
        Dy = Dp
        Dz = Dp
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

  ### Conservation of mass for neg_ion ###
  [./neg_ion_dgdiff]
      type = DGVarPoreDiffusion
      variable = neg_ion
      porosity = eps
      Dx = Dp
      Dy = Dp
      Dz = Dp
  [../]
  [./neg_ion_dgnpdiff]
      type = DGNernstPlanckDiffusion
      variable = neg_ion
      valence = -1
      porosity = eps
      electric_potential = phi_e
      temperature = Te
      Dx = Dp
      Dy = Dp
      Dz = Dp
  [../]
[]

[AuxKernels]

[] #END AuxKernels

[BCs]
  ### BCs for phi_e ###
  [./phi_e_left]
      type = FunctionDirichletBC
      variable = phi_e
      boundary = 'left'
      function = '1e-4'
  [../]
  [./phi_e_right]
      type = FunctionDirichletBC
      variable = phi_e
      boundary = 'right'
      function = '-1e-4'
  [../]

  # These allow both ions to leave the box through a flux
  #   that is calculated from the concentration gradients
  # This can be futher enhanced by adding more terms to the
  #   calculation of total ion flux.
  [./neg_ion_BC_out]
      type = CoupledVariableFluxBC
      variable = neg_ion
      boundary = 'left right'
      fx = neg_ion_flux_x
      fy = neg_ion_flux_y
      fz = 0
  [../]
  [./pos_ion_BC_out]
      type = CoupledVariableFluxBC
      variable = pos_ion
      boundary = 'left right'
      fx = pos_ion_flux_x
      fy = pos_ion_flux_y
      fz = 0
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
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-8
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 20
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0.0
  end_time = 10.0
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
