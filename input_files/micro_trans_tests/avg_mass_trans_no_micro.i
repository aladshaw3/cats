[GlobalParams]
  dg_scheme = nipg
  sigma = 10
[] #END GlobalParams

[Problem]

    coord_type = RZ
    #NOTE: For RZ coordinates, x ==> R and y ==> Z (and z ==> nothing)

[] #END Problem

[Mesh]

    type = GeneratedMesh
    dim = 2
    nx = 1
    ny = 20
    xmin = 0.0
    xmax = 2.0    #2cm radius
    ymin = 0.0
    ymax = 5.0    #5cm length

[] # END Mesh

[Variables]

    [./C]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./Cw]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]

    [./q]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]

    [./S]
        order = FIRST
        family = LAGRANGE
        initial_condition = 1
    [../]

[] #END Variables

[AuxVariables]

  [./Diff]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.01
  [../]

  [./pore]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.5
  [../]
 
  [./wash_pore]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.25   #   ew * (1 - e)
  [../]
 
  [./S_max]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1
  [../]

  [./vel_x]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

  [./vel_y]
      order = FIRST
      family = MONOMIAL
      initial_condition = 2
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

    [./C_dot]
        type = VariableCoefTimeDerivative
        variable = C
        coupled_coef = pore
    [../]
    [./C_gadv]
        type = GPoreConcAdvection
        variable = C
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./C_gdiff]
        type = GVarPoreDiffusion
        variable = C
        porosity = pore
        Dx = Diff
        Dy = Diff
        Dz = Diff
    [../]
    [./Cw_trans]
        type = FilmMassTransfer
        variable = C
        coupled = Cw
        rate_variable = 0.1
        av_ratio = 500          #(1-pore)*Ao  with Ao = 1000 cm^-1
    [../]

    [./Cw_dot]
        type = VariableCoefTimeDerivative
        variable = Cw
        coupled_coef = wash_pore
    [../]
    [./C_trans]
        type = FilmMassTransfer
        variable = Cw
        coupled = C
        rate_variable = 0.1
        av_ratio = 500           #(1-pore)*Ao  with Ao = 1000 cm^-1
    [../]
    [./transfer_q]
      type = CoupledPorePhaseTransfer
      variable = Cw
      coupled = q
      porosity = pore
    [../]
 
    [./q_dot]
        type = TimeDerivative
        variable = q
    [../]
    [./q_rxn]  #   Cw + S <-- --> q
        type = ConstReaction
        variable = q
        this_variable = q
        forward_rate = 2.0
        reverse_rate = 0.5
        scale = 1.0
        reactants = 'Cw S'
        reactant_stoich = '1 1'
        products = 'q'
        product_stoich = '1'
    [../]
 
    [./mat_bal]
      type = MaterialBalance
      variable = S
      this_variable = S
      coupled_list = 'S q'
      weights = '1 1'
      total_material = S_max
    [../]

[] #END Kernels

[DGKernels]

    [./C_dgadv]
        type = DGPoreConcAdvection
        variable = C
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./C_dgdiff]
        type = DGVarPoreDiffusion
        variable = C
        porosity = pore
        Dx = Diff
        Dy = Diff
        Dz = Diff
    [../]

[] #END DGKernels

[AuxKernels]

[] #END AuxKernels

[BCs]

    [./C_FluxIn]
      type = DGPoreConcFluxBC
      variable = C
      boundary = 'bottom'
      u_input = 1.0
      porosity = pore
      ux = vel_x
      uy = vel_y
      uz = vel_z
    [../]
    [./C_FluxOut]
      type = DGPoreConcFluxBC
      variable = C
      boundary = 'top left right'
      porosity = pore
      ux = vel_x
      uy = vel_y
      uz = vel_z
    [../]

[] #END BCs

[Materials]

[] #END Materials

[Postprocessors]

    [./C_exit]
        type = SideAverageValue
        boundary = 'top'
        variable = C
        execute_on = 'initial timestep_end'
    [../]
 
    [./C_avg]
        type = ElementAverageValue
        variable = C
        execute_on = 'initial timestep_end'
    [../]

    [./q_avg]
        type = ElementAverageValue
        variable = q
        execute_on = 'initial timestep_end'
    [../]

    [./Cw_avg]
        type = ElementAverageValue
        variable = Cw
        execute_on = 'initial timestep_end'
    [../]

[] #END Postprocessors

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
    solve_type = pjfnk   #default to newton, but use pjfnk if newton too slow
  [../]
[] #END Preconditioning

[Executioner]
  type = Transient
  scheme = implicit-euler
  petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -pc_type -sub_pc_type -snes_max_it -sub_pc_factor_shift_type -pc_asm_overlap -snes_atol -snes_rtol'
  petsc_options_value = 'gmres lu ilu 100 NONZERO 2 1E-14 1E-12'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = none
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-4
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0.0
  end_time = 10.0
  dtmax = 0.5

  [./TimeStepper]
     type = ConstantDT
     dt = 0.1
  [../]
 
[] #END Executioner

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
[] #END Outputs
