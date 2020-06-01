# This input file tests various options for the incompressible NS equations in a channel.

# CONVERGES WELL

# NOTES
# -------
# There are multiple types of stabilization possible in incompressible
# Navier Stokes. The user can specify supg = true to apply streamline
# upwind petrov-galerkin stabilization to the momentum equations. This
# is most useful for high Reynolds numbers, e.g. when inertial effects
# dominate over viscous effects. The user can also specify pspg = true
# to apply pressure stabilized petrov-galerkin stabilization to the mass
# equation. PSPG is a form of Galerkin Least Squares. This stabilization
# allows equal order interpolations to be used for pressure and velocity.
# Finally, the alpha parameter controls the amount of stabilization.
# For PSPG, decreasing alpha leads to increased accuracy but may induce
# spurious oscillations in the pressure field. Some numerical experiments
# suggest that alpha between .1 and 1 may be optimal for accuracy and
# robustness.

# Parameters given below provide the best tested compromise of stability and accuracy

# NOTE: If you want an approximate steady-state flow profile, use MAXIMUM STABILITY options (alpha = 1.0 and all set to true)
#       and simulate for many time steps.


[GlobalParams]
# Below are the parameters for the MOOSE Navier-Stokes methods
    gravity = '0 0 0'                #gravity accel for body force (should be in m/s/s  -> we used cm here)
    integrate_p_by_parts = true    #how to include the pressure gradient term (not sure what it does, but solves when true)
    supg = true                     #activates SUPG stabilization (excellent stability, always necessary)
    pspg = true                    #activates PSPG stabilization for pressure term (excellent stability, lower accuracy)
    alpha = 0.1                     #stabilization multiplicative correction factor (0.1 < alpha <= 1) [lower value improves accuracy]
    laplace = true                #whether or not viscous term is in laplace form
    convective_term = true        #whether or not to include advective/convective term
    transient_term = true            #whether or not to include time derivative in supg correction (sometimes needed)
 []

[Materials]
#NOTE: Every block in the mesh requires a Material

#NEED to make sure all our units agree with each other
  [./const]
    type = GenericConstantMaterial
    block = 'washcoat channel'
    prop_names = 'rho mu'
    #              kg/m^3  kg/m/s
    #prop_values = '1.225  1.81E-5'   #VALUES FOR AIR  (All my dimensions are in cm)

# NOTE: viscosity below was choosen such that we get the correct ratio of density to viscosity
#       In future, always use meters for distance. This means you need to change the dimensions
#       in the mesh files, which were done in cm.
    #               kg/cm^3 kg/cm/time
    prop_values = '1.225e-6  1.81E-11'   #VALUES FOR AIR (Only use their dimensions!!!)
  [../]
[]

[Mesh]
  #FileMeshGenerator automatically assigns boundary names from the .msh file
#   .msh file MUST HAVE specific boundary names in it (use msh format 4.1)
    [./mesh_file]
        type = FileMeshGenerator
        file = 2DChannel_Gap.msh
    [../]
  #The above file contains the following boundary names
  #boundary_name = 'inlet outlet outer_walls inner_walls'
  #block_name = 'washcoat channel'
 
[]
 
# Approximate parabolic velocity at inlet
 [Functions]
   [./inlet_func]
     type = ParsedFunction
     #Parabola that has velocity of zero at z=top and=bot, with maximum at z=middle
     #value = a*z^2 + b*z + c    solve for a, b, and c
     value = '-2623.5*z^2 + 333.19*z - 7.0788'
   [../]
 []

#Use MONOMIAL for DG and LAGRANGE for non-DG
[Variables]
    [./C]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.0
        block = 'channel'
    [../]
    [./Cw]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.0
        block = 'washcoat'
    [../]
 
    [./q]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
        block = 'washcoat'
    [../]

    [./S]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1
        block = 'washcoat'
    [../]

   [./vel_y]
       order = FIRST
       family = LAGRANGE
        initial_condition = 0
       block = 'channel'
   [../]

   [./vel_z]
       order = FIRST
       family = LAGRANGE
       initial_condition = 0
       block = 'channel'
   [../]

    [./p]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
      block = 'channel'
    [../]
[]

[AuxVariables]

    [./vel_x]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
        block = 'channel'
    [../]
 
    [./Diff]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.25
        block = 'channel'
    [../]
 
    [./Dw]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.01
        block = 'washcoat'
    [../]
 
    [./ew]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.20
        block = 'washcoat'
    [../]
 
    [./S_max]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1
      block = 'washcoat'
    [../]

[] #END AuxVariables


[Kernels]
  #Mass conservation in channel kernels
    [./C_dot]
        type = CoefTimeDerivative
        variable = C
        Coefficient = 1.0
        block = 'channel'
    [../]
    [./C_gadv]
        type = GPoreConcAdvection
        variable = C
        porosity = 1
        ux = vel_x
        uy = vel_y
        uz = vel_z
        block = 'channel'
    [../]
    [./C_gdiff]
        type = GVarPoreDiffusion
        variable = C
        porosity = 1
        Dx = Diff
        Dy = Diff
        Dz = Diff
        block = 'channel'
    [../]
 
    #Mass conservation in washcoat kernels
      [./Cw_dot]
          type = VariableCoefTimeDerivative
          variable = Cw
          coupled_coef = ew
          block = 'washcoat'
      [../]
      [./Cw_gdiff]
          type = GVarPoreDiffusion
          variable = Cw
          porosity = ew
          Dx = Dw
          Dy = Dw
          Dz = Dw
          block = 'washcoat'
      [../]
      [./transfer_q]
          type = CoupledPorePhaseTransfer
          variable = Cw
          coupled = q
          porosity = 0      #replace porosity with 0 because q is measured as mass per volume washcoat already
          block = 'washcoat'
      [../]
 
    # Adsorption in the washcoat
       [./q_dot]
           type = TimeDerivative
           variable = q
           block = 'washcoat'
       [../]
       [./q_rxn]  #   Cw + S <-- --> q
           type = ConstReaction
           variable = q
           this_variable = q
           forward_rate = 4.0
           reverse_rate = 0.5
           scale = 1.0
           reactants = 'Cw S'
           reactant_stoich = '1 1'
           products = 'q'
           product_stoich = '1'
           block = 'washcoat'
       [../]
    
       [./mat_bal]
           type = MaterialBalance
           variable = S
           this_variable = S
           coupled_list = 'S q'
           weights = '1 1'
           total_material = S_max
           block = 'washcoat'
       [../]


    #Continuity Equ
    [./mass]
      type = INSMass
      variable = p
      u = vel_x
      v = vel_y
      w = vel_z
      p = p
      block = 'channel'
    [../]

    #Conservation of momentum equ in z (with time derivative)
    [./z_momentum_time]
      type = INSMomentumTimeDerivative
      variable = vel_z
      block = 'channel'
    [../]
    [./z_momentum_space]
      type = INSMomentumLaplaceForm
      variable = vel_z
      u = vel_x
      v = vel_y
      w = vel_z
      p = p
      component = 2
      block = 'channel'
    [../]

    #Conservation of momentum equ in y (with time derivative)
    [./y_momentum_time]
      type = INSMomentumTimeDerivative
      variable = vel_y
      block = 'channel'
    [../]
    [./y_momentum_space]
      type = INSMomentumLaplaceForm
      variable = vel_y
      u = vel_x
      v = vel_y
      w = vel_z
      p = p
      component = 1
      block = 'channel'
    [../]

[]

[DGKernels]
 
    [./C_dgadv]
        type = DGPoreConcAdvection
        variable = C
        porosity = 1
        ux = vel_x
        uy = vel_y
        uz = vel_z
        block = 'channel'
    [../]
    [./C_dgdiff]
        type = DGVarPoreDiffusion
        variable = C
        porosity = 1
        Dx = Diff
        Dy = Diff
        Dz = Diff
        block = 'channel'
    [../]
 
    [./Cw_dgdiff]
        type = DGVarPoreDiffusion
        variable = Cw
        porosity = ew
        Dx = Dw
        Dy = Dw
        Dz = Dw
        block = 'washcoat'
    [../]

[] #END DGKernels

[BCs]
    [./C_FluxIn]
        type = DGConcentrationFluxBC
        variable = C
        boundary = 'inlet'
		u_input = 1.0
		ux = vel_x
		uy = vel_y
		uz = vel_z
    [../]

# C and Cw are not defined on channel_washcoat_interface
    [./C_FluxOut]
        type = DGConcentrationFluxBC
        variable = C
        boundary = 'outlet'
        u_input = 0.0
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]


# Alternative way of doing the velocity BCs
    [./y_inlet_const]
      type = DirichletBC
      variable = vel_y
      boundary = 'inlet'
        value = 2
    [../]

#    [./y_inlet_const]
#      type = INSNormalFlowBC
#      variable = vel_y
#      boundary = 'inlet'
#      u_dot_n = -2
#      direction = 1
#      ux = vel_x
#      uy = vel_y
#      uz = vel_z
#    [../]

    [./z_no_slip]
      type = PenaltyDirichletBC
      variable = vel_z
      boundary = 'inner_walls'
      value = 0.0
        penalty = 10000
    [../]
    [./y_no_slip]
      type = PenaltyDirichletBC
      variable = vel_y
      boundary = 'inner_walls'
      value = 0.0
        penalty = 10000
    [../]

#    [./z_no_slip]
#      type = DirichletBC
#      variable = vel_z
#      boundary = 'inner_walls'
#      value = 0.0
#    [../]
#    [./y_no_slip]
#      type = DirichletBC
#      variable = vel_y
#      boundary = 'inner_walls'
#      value = 0.0
#    [../]

# If we know that the edges have a no-slip condition, do we need to create a FunctionBC to account for that
#    [./y_inlet]
#      type = FunctionDirichletBC
#      variable = vel_y
#      boundary = 'inlet'
#      function = 'inlet_func'
#    [../]

# NOTE: This works, but the average inlet velocity is NOT 2, because of the no-slip condition
#    [./y_inlet_const]
#      type = DirichletBC
#      variable = vel_y
#      boundary = 'inlet'
#        value = 2.6666667
#    [../]

# NOTE: This is better that just DirichletBC, but is still not giving the right average
#    [./y_inlet_slope_const]
#      type = PenaltyDirichletBC
#      variable = vel_y
#      boundary = 'inlet'
#        value = 2.3
#      penalty = 1
#    [../]

[]
 
 [InterfaceKernels]
#This kernel is never getting invoked
    [./interface_kernel]
        type = InterfaceMassTransfer
        variable = C        #variable must be the variable in the master block
        neighbor_var = Cw    #neighbor_var must the the variable in the paired block
        boundary = 'inner_walls'
        transfer_rate = 2
    [../]
 [] #END InterfaceKernels
 
[Postprocessors]
 
    [./vy_enter]
        type = SideAverageValue
        boundary = 'inlet'
        variable = vel_y
        execute_on = 'initial timestep_end'
    [../]
 
    [./vy_exit]
        type = SideAverageValue
        boundary = 'outlet'
        variable = vel_y
        execute_on = 'initial timestep_end'
    [../]

    [./C_exit]
        type = SideAverageValue
        boundary = 'outlet'
        variable = C
        execute_on = 'initial timestep_end'
    [../]
 
    [./C_avg]
        type = ElementAverageValue
        variable = C
        block = 'channel'
        execute_on = 'initial timestep_end'
    [../]
 
    [./Cw_avg]
        type = ElementAverageValue
        variable = Cw
        block = 'washcoat'
        execute_on = 'initial timestep_end'
    [../]
 
    [./q_avg]
        type = ElementAverageValue
        variable = q
        block = 'washcoat'
        execute_on = 'initial timestep_end'
    [../]
 
    [./S_avg]
        type = ElementAverageValue
        variable = S
        block = 'washcoat'
        execute_on = 'initial timestep_end'
    [../]
 
    [./ew_avg]
        type = ElementAverageValue
        variable = ew
        block = 'washcoat'
        execute_on = 'initial timestep_end'
    [../]
 
    [./volume_washcoat]
        type = VolumePostprocessor
        block = 'washcoat'
        execute_on = 'initial timestep_end'
    [../]
 
    [./volume_channel]
        type = VolumePostprocessor
        block = 'channel'
        execute_on = 'initial timestep_end'
    [../]
 
    [./xsec_area_channel]
        type = AreaPostprocessor
        boundary = 'outlet'
        execute_on = 'initial timestep_end'
    [../]

[]

[Materials]

[]

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
    solve_type = pjfnk
  [../]
[]

[Executioner]
  type = Transient
  scheme = implicit-euler
  petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -pc_type -sub_pc_type -snes_max_it -sub_pc_factor_shift_type -pc_asm_overlap -snes_atol -snes_rtol'
  petsc_options_value = 'gmres asm lu 100 NONZERO 2 1E-14 1E-12'

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
  end_time = 10
  dtmax = 0.5

  [./TimeStepper]
#	type = SolutionTimeAdaptiveDT
    type = ConstantDT
    dt = 0.10
  [../]
[]

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
[]

