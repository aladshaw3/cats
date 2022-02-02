# NOTE: Be aware that when doing the reactions in this manner, we are
#       needing to solve for concentrations in a very dilute system.
#       Updating and tightening tolerances may be necessary for accuracy.
#
# ALSO NOTE: Due to how fast some of these kinetics are, the initial time
#             step MUST be sufficiently small. In this test case, an initial
#             step size of 0.01 seconds seems fine.
#
#           Part of this issue can be resolved simply by giving a better
#           'guess' to the initial state of the constraints (i.e., making
#           custom IC kernels for activities).
#
#           Can also be dealt with by using SolutionTimeAdaptiveDT with an
#           initially small dt value.

[GlobalParams]

[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = 1
    ny = 1
    xmin = 0
    xmax = 1
    ymin = 0
    ymax = 1
[] # END Mesh

[Variables]
  # H+ concentration
  [./C_H]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0 # mol/cm^3
  [../]

  # OH- concentration
  [./C_OH]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0 # mol/cm^3
  [../]

  # CO2 concentration
  [./C_CO2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0 # mol/cm^3
  [../]

  # HCO3 concentration
  [./C_HCO3]
      order = FIRST
      family = MONOMIAL
      initial_condition = 2.06E-6 # mol/cm^3
  [../]

  # CO3 concentration
  [./C_CO3]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0 # mol/cm^3
  [../]

  # HCOOH concentration
  [./C_HCOOH]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0 # mol/cm^3
  [../]

  # HCOO concentration
  [./C_HCOO]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1e-7 # mol/cm^3
  [../]

  # H+ activity (unitless)
  [./a_H]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0
  [../]

  # OH- activity (unitless)
  [./a_OH]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0
  [../]

  # CO2 activity (unitless)
  [./a_CO2]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0.00
  [../]

  # HCO3 activity (unitless)
  [./a_HCO3]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0
  [../]

  # CO3 activity (unitless)
  [./a_CO3]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0
  [../]

  # HCOOH activity (unitless)
  [./a_HCOOH]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0
  [../]

  # HCOO activity (unitless)
  [./a_HCOO]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0.00
  [../]

  # rate of water reaction
  # 1/s ==> convert to mol/cm^3/s via scale = C_ref
  [./r_w]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0
  [../]

  # rate of CO2 -> HCO3 reaction
  # 1/s ==> convert to mol/cm^3/s via scale = C_ref
  [./r_1]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0
  [../]

  # rate of HCO3 -> CO3 reaction
  # 1/s ==> convert to mol/cm^3/s via scale = C_ref
  [./r_2]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0
  [../]

  # rate of alt CO2 -> HCO3 reaction
  # 1/s ==> convert to mol/cm^3/s via scale = C_ref
  [./r_3]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0
  [../]

  # rate of alt HCO3 -> CO3 reaction
  # 1/s ==> convert to mol/cm^3/s via scale = C_ref
  [./r_4]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0
  [../]

  # rate of alt HCOOH -> HCOO reaction
  # 1/s ==> convert to mol/cm^3/s via scale = C_ref
  [./r_5]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0
  [../]
[]

[AuxVariables]
  # ideal activity coeff
  [./gamma]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 1
  [../]

  # ref conc
  [./C_ref]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0.001 # mol/cm^3
  [../]
[]

[Kernels]

  ## =============== water reaction ================
  [./r_w_equ]
    type = Reaction
    variable = r_w
  [../]
  [./r_w_rxn]  #   H2O <--> H+ + OH-
    type = ConstReaction
    variable = r_w
    this_variable = r_w

    forward_rate = 1.6E-3
    reverse_rate = 1.6E11

    reactants = '1'
    reactant_stoich = '1'
    products = 'a_H a_OH'
    product_stoich = '1 1'
  [../]

  ## =============== r1 reaction ================
  [./r_1_equ]
    type = Reaction
    variable = r_1
  [../]
  [./r_1_rxn]  #   CO2 + H2O <--> H+ + HCO3-
    type = ConstReaction
    variable = r_1
    this_variable = r_1

    forward_rate = 4.0E-2
    reverse_rate = 9.368E4

    reactants = 'a_CO2'
    reactant_stoich = '1'
    products = 'a_H a_HCO3'
    product_stoich = '1 1'
  [../]

  ## =============== r2 reaction ================
  [./r_2_equ]
    type = Reaction
    variable = r_2
  [../]
  [./r_2_rxn]  #   HCO3- <--> H+ + CO3--
    type = ConstReaction
    variable = r_2
    this_variable = r_2

    forward_rate = 5.6281E1
    reverse_rate = 1.2288E12

    reactants = 'a_HCO3'
    reactant_stoich = '1'
    products = 'a_H a_CO3'
    product_stoich = '1 1'
  [../]

  ## =============== r3 reaction ================
  [./r_3_equ]
    type = Reaction
    variable = r_3
  [../]
  [./r_3_rxn]  #   CO2 + OH- <--> HCO3-
    type = ConstReaction
    variable = r_3
    this_variable = r_3

    forward_rate = 2.1E3
    reverse_rate = 4.918E-5

    reactants = 'a_CO2 a_OH'
    reactant_stoich = '1 1'
    products = 'a_HCO3'
    product_stoich = '1'
  [../]

  ## =============== r4 reaction ================
  [./r_4_equ]
    type = Reaction
    variable = r_4
  [../]
  [./r_4_rxn]  #   HCO3- + OH- <--> CO3-- + H2O
    type = ConstReaction
    variable = r_4
    this_variable = r_4

    forward_rate = 6.5E9
    reverse_rate = 1.337E6

    reactants = 'a_HCO3 a_OH'
    reactant_stoich = '1 1'
    products = 'a_CO3'
    product_stoich = '1'
  [../]

  ## =============== r5 reaction ================
  [./r_5_equ]
    type = Reaction
    variable = r_5
  [../]
  [./r_5_rxn]  #   HCOOH <--> H+ + HCOO-
    type = ConstReaction
    variable = r_5
    this_variable = r_5

    forward_rate = 4.04E5
    reverse_rate = 1.971E9

    reactants = 'a_HCOOH'
    reactant_stoich = '1'
    products = 'a_H a_HCOO'
    product_stoich = '1 1'
  [../]

  ## ============= H+ balance ==============
  [./H_dot]
      type = TimeDerivative
      variable = C_H
  [../]
  [./H_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_H
      coupled_list = 'r_w r_1 r_2 r_5'
      weights = '1 1 1 1'
      scale = C_ref
  [../]

  ## ============= OH- balance ==============
  [./OH_dot]
      type = TimeDerivative
      variable = C_OH
  [../]
  [./OH_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_OH
      coupled_list = 'r_w r_3 r_4'
      weights = '1 -1 -1'
      scale = C_ref
  [../]

  ## ============= CO2 balance ==============
  [./CO2_dot]
      type = TimeDerivative
      variable = C_CO2
  [../]
  [./CO2_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_CO2
      coupled_list = 'r_1 r_3'
      weights = '-1 -1'
      scale = C_ref
  [../]

  ## ============= HCO3 balance ==============
  [./HCO3_dot]
      type = TimeDerivative
      variable = C_HCO3
  [../]
  [./HCO3_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_HCO3
      coupled_list = 'r_1 r_2 r_3 r_4'
      weights = '1 -1 1 -1'
      scale = C_ref
  [../]

  ## ============= CO3 balance ==============
  [./CO3_dot]
      type = TimeDerivative
      variable = C_CO3
  [../]
  [./CO3_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_CO3
      coupled_list = 'r_2 r_4'
      weights = '1 1'
      scale = C_ref
  [../]

  ## ============= HCOOH balance ==============
  [./HCOOH_dot]
      type = TimeDerivative
      variable = C_HCOOH
  [../]
  [./HCOOH_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_HCOOH
      coupled_list = 'r_5'
      weights = '-1'
      scale = C_ref
  [../]

  ## ============= HCOO balance ==============
  [./HCOO_dot]
      type = TimeDerivative
      variable = C_HCOO
  [../]
  [./HCOO_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_HCOO
      coupled_list = 'r_5'
      weights = '1'
      scale = C_ref
  [../]

  ## =============== H+ activity constraint ================
  [./a_H_equ]
    type = Reaction
    variable = a_H
  [../]
  [./a_H_cons]
    type = ActivityConstraint
    variable = a_H
    concentration = C_H
    activity_coeff = gamma
    ref_conc = C_ref
  [../]

  ## =============== OH- activity constraint ================
  [./a_OH_equ]
    type = Reaction
    variable = a_OH
  [../]
  [./a_OH_cons]
    type = ActivityConstraint
    variable = a_OH
    concentration = C_OH
    activity_coeff = gamma
    ref_conc = C_ref
  [../]

  ## =============== CO2 activity constraint ================
  [./a_CO2_equ]
    type = Reaction
    variable = a_CO2
  [../]
  [./a_CO2_cons]
    type = ActivityConstraint
    variable = a_CO2
    concentration = C_CO2
    activity_coeff = gamma
    ref_conc = C_ref
  [../]

  ## =============== HCO3 activity constraint ================
  [./a_HCO3_equ]
    type = Reaction
    variable = a_HCO3
  [../]
  [./a_HCO3_cons]
    type = ActivityConstraint
    variable = a_HCO3
    concentration = C_HCO3
    activity_coeff = gamma
    ref_conc = C_ref
  [../]

  ## =============== CO3 activity constraint ================
  [./a_CO3_equ]
    type = Reaction
    variable = a_CO3
  [../]
  [./a_CO3_cons]
    type = ActivityConstraint
    variable = a_CO3
    concentration = C_CO3
    activity_coeff = gamma
    ref_conc = C_ref
  [../]

  ## =============== HCOOH activity constraint ================
  [./a_HCOOH_equ]
    type = Reaction
    variable = a_HCOOH
  [../]
  [./a_HCOOH_cons]
    type = ActivityConstraint
    variable = a_HCOOH
    concentration = C_HCOOH
    activity_coeff = gamma
    ref_conc = C_ref
  [../]

  ## =============== HCOO activity constraint ================
  [./a_HCOO_equ]
    type = Reaction
    variable = a_HCOO
  [../]
  [./a_HCOO_cons]
    type = ActivityConstraint
    variable = a_HCOO
    concentration = C_HCOO
    activity_coeff = gamma
    ref_conc = C_ref
  [../]
[]

[DGKernels]
[]

[AuxKernels]
[]

[BCs]
[]

[Postprocessors]
  [./C_H]
      type = ElementAverageValue
      variable = C_H
      execute_on = 'initial timestep_end'
  [../]
  [./C_OH]
      type = ElementAverageValue
      variable = C_OH
      execute_on = 'initial timestep_end'
  [../]
  [./C_CO2]
      type = ElementAverageValue
      variable = C_CO2
      execute_on = 'initial timestep_end'
  [../]
  [./C_HCO3]
      type = ElementAverageValue
      variable = C_HCO3
      execute_on = 'initial timestep_end'
  [../]
  [./C_CO3]
      type = ElementAverageValue
      variable = C_CO3
      execute_on = 'initial timestep_end'
  [../]
  [./C_HCOOH]
      type = ElementAverageValue
      variable = C_HCOOH
      execute_on = 'initial timestep_end'
  [../]
  [./C_HCOO]
      type = ElementAverageValue
      variable = C_HCOO
      execute_on = 'initial timestep_end'
  [../]
  [./a_H]
      type = ElementAverageValue
      variable = a_H
      execute_on = 'initial timestep_end'
  [../]
  [./a_OH]
      type = ElementAverageValue
      variable = a_OH
      execute_on = 'initial timestep_end'
  [../]
  [./a_CO2]
      type = ElementAverageValue
      variable = a_CO2
      execute_on = 'initial timestep_end'
  [../]
  [./a_HCO3]
      type = ElementAverageValue
      variable = a_HCO3
      execute_on = 'initial timestep_end'
  [../]
  [./a_CO3]
      type = ElementAverageValue
      variable = a_CO3
      execute_on = 'initial timestep_end'
  [../]
  [./a_HCOOH]
      type = ElementAverageValue
      variable = a_HCOOH
      execute_on = 'initial timestep_end'
  [../]
  [./a_HCOO]
      type = ElementAverageValue
      variable = a_HCOO
      execute_on = 'initial timestep_end'
  [../]
[]

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

  petsc_options_value = 'fgmres
                         ksp

                         ilu

                         20

                         NONZERO
                         NONZERO
                         NONZERO

                         10

                         1E-12
                         1E-12

                         fgmres
                         ilu'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = none
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-10
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 20
  l_tol = 1e-6
  l_max_its = 20

  start_time = 0.0
  end_time = 20
  dtmax = 2

  # NOTE: Maximum step size to start is 0.01
  [./TimeStepper]
     type = SolutionTimeAdaptiveDT
     dt = 0.01
     cutback_factor_at_failure = 0.5
     percent_change = 0.7
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
