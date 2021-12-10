# Testing Darcy Flow
#
# Key to making the DG work is to either
# do interface kernels to match fluxes at
# the boundaries or to change diffusion
# as a function of location.
#
# Interface:  - Requires new kernels for flux matching
#             - Requires different sets of DG kernels
#               acting on each domain
#
# Updating Dp:  - Use different Time kernels but same transport kernels
#               - Update Dp and vel within each domain individually
#
#               - {NOTE} This also means that the coupled potential to
#                 ion flux across the membrane MUST be the same variable.
#                 (i.e., electric potential in membrane must be same
#                 variable as electric potential in electrolyte).
#
#
# Lastly: To help maximize stability, calculate an effective dispersion
#         coefficient based on mechanical mixing. This will add artificial
#         diffusion and help stablize simulations of ions.

[GlobalParams]

[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
  [file]
    type = FileMeshGenerator
    file = FullCell_ValidationMesh_cm.msh

    ### ========= boundary_name ==========
    # "neg_collector_left"
    # "neg_collector_bottom"
    # "neg_collector_top"
    # "neg_collector_interface_neg_electrode"
    # "neg_electrode_bottom"
    # "neg_electrode_top"
    # "neg_electrode_interface_membrane"
    # "membrane_bottom"
    # "membrane_top"
    # "membrane_interface_pos_electrode"
    # "pos_electrode_bottom"
    # "pos_electrode_top"
    # "pos_electrode_interface_pos_collector"
    # "pos_collector_bottom"
    # "pos_collector_top"
    # "pos_collector_right"

    ### ====== block ========
    # "neg_collector"
    # "neg_electrode"
    # "membrane"
    # "pos_electrode"
    # "pos_collector"
  []

[] # END Mesh

[Variables]
  # pressure
  [./pressure]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # velocity in x
  [./vel_x]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
    block = 'neg_electrode membrane pos_electrode'
  [../]

  # velocity in y
  [./vel_y]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
    block = 'neg_electrode membrane pos_electrode'
  [../]

  # dummy
  [./dummy]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  ### Other variables for mass and energy can be any order 'MONOMIAL' functions
  [./tracer]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0012 #mol/cm^3
      block = 'neg_electrode membrane pos_electrode'
  [../]
[]

[AuxVariables]
  [./DarcyCoeff]
      order = FIRST
      family = LAGRANGE
      initial_condition = 4
  [../]

  [./SchloeglCoeff]
      order = FIRST
      family = LAGRANGE
      initial_condition = 2
  [../]

  [./eps]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.68
  [../]

  [./Dp]
      order = FIRST
      family = MONOMIAL
      initial_condition = 5E-2
  [../]

  # velocity in z
  [./vel_z]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
    block = 'neg_electrode membrane pos_electrode'
  [../]
[]

[Kernels]
  [./pressure_laplace_electrodes]
    type = VariableLaplacian
    variable = pressure
    coupled_coef = DarcyCoeff
    block = 'neg_electrode pos_electrode'
  [../]
  [./pressure_laplace_membrane]
    type = VariableLaplacian
    variable = pressure
    coupled_coef = SchloeglCoeff
    block = 'membrane'
  [../]

  [./v_x_equ]
      type = Reaction
      variable = vel_x
  [../]
  [./x_darcy]
    type = VariableVectorCoupledGradient
    variable = vel_x
    coupled = pressure
    ux = DarcyCoeff
    block = 'neg_electrode pos_electrode'
  [../]
  [./x_schloegl]
    type = VariableVectorCoupledGradient
    variable = vel_x
    coupled = pressure
    ux = SchloeglCoeff
    block = 'membrane'
  [../]
  ## To represent fluid flow across membrane
  [./x_test]
    type = VariableVectorCoupledGradient
    variable = vel_x
    coupled = pressure
    uy = -0.1
    block = 'membrane'
  [../]

  [./v_y_equ]
      type = Reaction
      variable = vel_y
  [../]
  [./y_darcy]
    type = VariableVectorCoupledGradient
    variable = vel_y
    coupled = pressure
    uy = DarcyCoeff
    block = 'neg_electrode pos_electrode'
  [../]
  [./y_schloegl]
    type = VariableVectorCoupledGradient
    variable = vel_y
    coupled = pressure
    ux = SchloeglCoeff
    block = 'membrane'
  [../]

  [./dummy]
    type = Diffusion
    variable = dummy
  [../]

  ### Conservation of mass for a dilute tracer ###
  [./tracer_dot]
      type = VariableCoefTimeDerivative
      variable = tracer
      coupled_coef = eps
      block = 'neg_electrode pos_electrode'
  [../]
  [./tracer_dot_mem]
      type = VariableCoefTimeDerivative
      variable = tracer
      coupled_coef = 1
      block = 'membrane'
  [../]
  [./tracer_gadv]
      type = GPoreConcAdvection
      variable = tracer
      porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./tracer_gdiff]
      type = GVarPoreDiffusion
      variable = tracer
      porosity = eps
      Dx = Dp
      Dy = Dp
      Dz = Dp
  [../]
[]

[DGKernels]
  ### Conservation of mass for a dilute tracer ###
  [./tracer_dgadv]
      type = DGPoreConcAdvection
      variable = tracer
      porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./tracer_dgdiff]
      type = DGVarPoreDiffusion
      variable = tracer
      porosity = eps
      Dx = Dp
      Dy = Dp
      Dz = Dp
  [../]
[]

[InterfaceKernels]
[] #END InterfaceKernels

[AuxKernels]

  # Need a way to calculate an effective dispersion from
  # the molecular diffusion
  [./Disp_calc]
      type = ConstantAux
      variable = Dp
      value = 8.4E-1  #cm^2/min

      execute_on = 'initial timestep_end'
      block = 'neg_electrode pos_electrode'
  [../]

  [./Disp_calc_mem]
      type = ConstantAux
      variable = Dp
      value = 8.4E-2  #cm^2/min

      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]
[]

[BCs]
  # exit pressure
  [./press_at_exit]
      type = DirichletBC
      variable = pressure
      boundary = 'pos_electrode_top neg_electrode_top'
      value = 0.0
  [../]

  # inlet pressure grad
  [./press_grad_at_inlet]
      type = NeumannBC
      variable = pressure
      boundary = 'pos_electrode_bottom neg_electrode_bottom'
      value = 66   # vel in cm/min (0.37 to 1.1 cm/s)
  [../]

  ### Fluxes for Conservative Tracer ###
  [./tracer_FluxIn_pos]
      type = DGPoreConcFluxBC
      variable = tracer
      boundary = 'pos_electrode_bottom'
      porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      u_input = 0.0024
  [../]
  [./tracer_FluxIn_neg]
      type = DGPoreConcFluxBC
      variable = tracer
      boundary = 'neg_electrode_bottom'
      porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      u_input = 0.0012
  [../]
  [./tracer_FluxOut]
      type = DGPoreConcFluxBC
      variable = tracer
      boundary = 'pos_electrode_top neg_electrode_top'
      porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]

[]

[Postprocessors]
  [./pressure_inlet]
      type = SideAverageValue
      boundary = 'pos_electrode_bottom neg_electrode_bottom'
      variable = pressure
      execute_on = 'initial timestep_end'
  [../]

  [./pressure_outlet]
      type = SideAverageValue
      boundary = 'pos_electrode_top neg_electrode_top'
      variable = pressure
      execute_on = 'initial timestep_end'
  [../]

  [./vel_y_inlet]
      type = SideAverageValue
      boundary = 'pos_electrode_bottom neg_electrode_bottom'
      variable = vel_y
      execute_on = 'initial timestep_end'
  [../]

  [./vel_y_outlet]
      type = SideAverageValue
      boundary = 'pos_electrode_top neg_electrode_top'
      variable = vel_y
      execute_on = 'initial timestep_end'
  [../]

  [./vel_x_membrane]
      type = ElementAverageValue
      block = 'membrane'
      variable = vel_x
      execute_on = 'initial timestep_end'
  [../]

  [./vel_y_membrane]
      type = ElementAverageValue
      block = 'membrane'
      variable = vel_y
      execute_on = 'initial timestep_end'
  [../]

  [./vel_y_membrane_out]
      type = SideAverageValue
      boundary = 'membrane_top'
      variable = vel_y
      execute_on = 'initial timestep_end'
  [../]

  [./vel_y_membrane_in]
      type = SideAverageValue
      boundary = 'membrane_bottom'
      variable = vel_y
      execute_on = 'initial timestep_end'
  [../]

  [./tracer_inlet]
      type = SideAverageValue
      boundary = 'pos_electrode_bottom neg_electrode_bottom'
      variable = tracer
      execute_on = 'initial timestep_end'
  [../]

  [./tracer_outlet]
      type = SideAverageValue
      boundary = 'pos_electrode_top neg_electrode_top'
      variable = tracer
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

  petsc_options_value = 'fgmres
                         ksp

                         lu

                         20

                         NONZERO
                         NONZERO
                         NONZERO

                         10

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
  l_max_its = 20

  start_time = 0.0
  end_time = 1.0
  dtmax = 0.025

  [./TimeStepper]
		  type = ConstantDT
      dt = 0.025
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
