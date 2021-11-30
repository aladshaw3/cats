# Validation test: Given a known concentration
# profile, solve for the potential and current
# in the electrolyte. Also, solve a transient
# salt motion with DG methods to show that concentration
# does actually move with the correct potential
# profile.

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

  # Electrolyte current density in x (C/m^2/s)
  [./ie_x]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  # salt conc in x (mol/m^3)
  [./salt]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1000
  [../]
[]

[AuxVariables]
  # Positive ion concentration (in mol/m^3)
  [./pos_ion]
      order = FIRST
      family = MONOMIAL
  [../]

  # temperature in K
  [./Te]
      order = FIRST
      family = MONOMIAL
      initial_condition = 300
  [../]
[]

[ICs]
  [./ion_ic]
    type = FunctionIC
    variable = pos_ion
    function = parsed_function
  [../]
[]

# Given linear solution to positive ions, solve
# for phi_e and current...
[Functions]
  [./parsed_function]
    type = ParsedFunction
    value = '1000 - x*4606.34'
  [../]
[]

[Kernels]

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

  # Current density in x-dir from potential gradient
  #  ie_x
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
      porosity = 1
      temperature = 300
      ion_conc = 'pos_ion'
      ion_valence = '2'
      diffusion = '4.5e-8'
  [../]
  #  -F*eps*SUM( zj*Dj*grad(ion)_x )
  [./ie_x_iongrad]
      type = ElectrolyteCurrentFromIonGradient
      variable = ie_x
      direction = 0         # 0=x
      porosity = 1
      ion_conc = 'pos_ion'
      ion_valence = '2'
      diffusion = '4.5e-8'
  [../]

  ### ==================== Conservation of Salt ==========================
  ### Conservation of mass for salt ###
  [./pos_ion_dot]
      type = VariableCoefTimeDerivative
      variable = salt
      coupled_coef = 1
  [../]
  [./salt_gdiff]
      type = GVarPoreDiffusion
      variable = salt
      porosity = 1
      Dx = 4.5e-4
      Dy = 4.5e-4
      Dz = 4.5e-4
  [../]
  [./salt_gnpdiff]
      type = GNernstPlanckDiffusion
      variable = salt
      valence = 2
      porosity = 1
      electric_potential = phi_e
      temperature = Te
      Dx = 4.5e-4
      Dy = 4.5e-4
      Dz = 4.5e-4
  [../]
[]

[DGKernels]

  ### Conservation of mass for salt ###
  [./salt_dgdiff]
      type = DGVarPoreDiffusion
      variable = salt
      porosity = 1
      Dx = 4.5e-4
      Dy = 4.5e-4
      Dz = 4.5e-4
  [../]
  [./salt_dgnpdiff]
      type = DGNernstPlanckDiffusion
      variable = salt
      valence = 2
      porosity = 1
      electric_potential = phi_e
      temperature = Te
      Dx = 4.5e-4
      Dy = 4.5e-4
      Dz = 4.5e-4
  [../]

[]

[BCs]
  active = 'phi_e_left phi_e_right
            i_left i_right
            salt_left salt_right_trans'

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
      function = '-100'
  [../]
  [./phi_e_right_alt]
      type = FunctionDirichletBC
      variable = phi_e
      boundary = 'right'
      function = '-0.012'
  [../]

  ### BCs for ie_x ###
  [./i_left]
      type = FunctionDirichletBC
      variable = ie_x
      boundary = 'left'
      function = '100'
  [../]
  [./i_right]
      type = FunctionDirichletBC
      variable = ie_x
      boundary = 'right'
      function = '100'
  [../]

  ### BCs for salt ###
  [./salt_left]
      type = DGDiffusionFluxBC
      variable = salt
      boundary = 'left'
      Dxx = 4.5e-4
      Dyy = 4.5e-4
      Dzz = 4.5e-4
      u_input = 1000
  [../]
  [./salt_right_trans]
      type = DGDiffusionFluxBC
      variable = salt
      boundary = 'right'
      Dxx = 4.5e-4
      Dyy = 4.5e-4
      Dzz = 4.5e-4
  [../]
  [./salt_right]
      type = CoupledVariableFluxBC
      variable = salt
      boundary = 'right'
      fx = 5.1822e-4
      fy = 0
      fz = 0
  [../]
  [./salt_right_alt]
      type = FunctionPenaltyDirichletBC
      variable = salt
      boundary = 'right'
      function = '539.366'
      penalty = 300
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

    [./salt_left]
        type = SideAverageValue
        boundary = 'left'
        variable = salt
        execute_on = 'initial timestep_end'
    [../]

    [./salt_right]
        type = SideAverageValue
        boundary = 'right'
        variable = salt
        execute_on = 'initial timestep_end'
    [../]

    [./salt_avg]
        type = ElementAverageValue
        variable = salt
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

    [./ie_x_right]
        type = SideAverageValue
        boundary = 'right'
        variable = ie_x
        execute_on = 'initial timestep_end'
    [../]

    [./ie_x_left]
        type = SideAverageValue
        boundary = 'left'
        variable = ie_x
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

                         1E-14
                         1E-14

                         gmres
                         lu'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = none
  nl_rel_tol = 1e-14
  nl_abs_tol = 1e-14
  nl_rel_step_tol = 1e-14
  nl_abs_step_tol = 1e-14
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
