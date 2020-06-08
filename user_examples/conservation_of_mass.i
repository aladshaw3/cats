[Problem]
    coord_type = RZ
[] #END Problem

[Mesh]
    [./my_mesh]
        type = GeneratedMeshGenerator
        dim = 2
        nx = 5
        ny = 20
        xmin = 0.0
        xmax = 0.05
        ymin = 0.0
        ymax = 0.1
    [../]
[] # END Mesh

[Variables]
    [./C]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./Cp]
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
  [./eps]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.5
  [../]
 
  [./vel_x]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  [./vel_y]
      order = FIRST
      family = LAGRANGE
      initial_condition = 3
  [../]

  [./vel_z]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]
 
  [./D]
    order = FIRST
    family = LAGRANGE
    initial_condition = 2.5E-5
  [../]
 
  [./k]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1
  [../]
 
  [./k_eps]
    # Represents (1 - eps)*k
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.5
  [../]
 
  [./eps_p]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.25
  [../]
 
  [./S_max]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1
  [../]
[] #END AuxVariables

[Kernels]
# Conservation of mass for C
    [./C_dot]
        type = VariableCoefTimeDerivative
        variable = C
        coupled_coef = eps
    [../]
    [./C_gadv]
        type = GPoreConcAdvection
        variable = C
        porosity = eps
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./C_gdiff]
        type = GVarPoreDiffusion
        variable = C
        porosity = eps
        Dx = D
        Dy = D
        Dz = D
    [../]
    [./C_trans_Cp]
        type = FilmMassTransfer
        variable = C
        coupled = Cp
        rate_variable = k_eps
        # Area to volume ratio: Ao
        av_ratio = 5000
    [../]

 # Conservation of mass for Cp
    [./Cp_dot]
        type = VariableCoefTimeDerivative
        variable = Cp
        coupled_coef = eps_p
    [../]
    [./Cp_trans_C]
        type = FilmMassTransfer
        variable = Cp
        coupled = C
        rate_variable = k
        # Area to volume ratio: Ao
        av_ratio = 5000
    [../]
    [./ads_q]
      type = CoupledCoeffTimeDerivative
      variable = Cp
      coupled = q
      time_coeff = 1500
    [../]
 
 # Conservation of mass for q
    [./q_dot]
        type = TimeDerivative
        variable = q
    [../]
    [./q_rxn]  #   Cp + S <-- --> q
        type = ConstReaction
        variable = q
        this_variable = q
        forward_rate = 2.0
        reverse_rate = 0.5
        scale = 1.0
        reactants = 'Cp S'
        reactant_stoich = '1 1'
        products = 'q'
        product_stoich = '1'
    [../]
 
 # Conservation of mass for S
    [./S_bal]
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
        porosity = eps
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./C_dgdiff]
        type = DGVarPoreDiffusion
        variable = C
        porosity = eps
        Dx = D
        Dy = D
        Dz = D
    [../]

[] #END DGKernels


[BCs]
    [./C_FluxIn]
      type = DGPoreConcFluxBC
      variable = C
      boundary = 'bottom'
      u_input = 1.0
      porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
    [../]
    [./C_FluxOut]
      type = DGPoreConcFluxBC
      variable = C
      boundary = 'top'
      porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
    [../]
[] #END BCs


[Postprocessors]
    [./C_exit]
        type = SideAverageValue
        boundary = 'top'
        variable = C
        execute_on = 'initial timestep_end'
    [../]
    [./q_avg]
        type = ElementAverageValue
        variable = q
        execute_on = 'initial timestep_end'
    [../]
[] #END Postprocessors

[Preconditioning]
    [./SMP_PJFNK]
        type = SMP
        full = true
    [../]
[] #END Preconditioning

[Executioner]
    type = Transient
    scheme = bdf2
    solve_type = pjfnk
    petsc_options = '-snes_converged_reason'
    petsc_options_iname ='-ksp_type -pc_type -sub_pc_type'
    petsc_options_value = 'bcgs bjacobi lu'

    line_search = none
    nl_rel_tol = 1e-8
    nl_abs_tol = 1e-8
    nl_rel_step_tol = 1e-12
    nl_abs_step_tol = 1e-12
    nl_max_its = 10
    l_tol = 1e-6
    l_max_its = 300

    start_time = 0.0
    end_time = 80.0
    dtmax = 0.5

    [./TimeStepper]
        type = ConstantDT
        dt = 0.2
    [../]
 
[] #END Executioner

[Outputs]
    print_linear_residuals = true
    exodus = true
    csv = true
    interval = 10
[] #END Outputs
