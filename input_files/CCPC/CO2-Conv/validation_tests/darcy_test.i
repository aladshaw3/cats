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

  # dummy
  [./dummy]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]
[]

[Kernels]
  [./pressure_laplace]
    type = AnisotropicDiffusion
    variable = pressure
    tensor_coeff = '4 0 0
                    0 4 0
                    0 0 4'
  [../]

  [./dummy]
    type = Diffusion
    variable = dummy
  [../]
[]

[DGKernels]
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
        value = 100
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
[]

[Executioner]
  type = Steady
  #scheme = implicit-euler

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
