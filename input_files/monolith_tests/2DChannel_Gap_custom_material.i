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


# Other Notes:
# ------------
#   The Compressible Navier-Stokes module is currently under a MAJOR revision
#   and will be unavailable for 2020. Check back later.

[GlobalParams]
# Below are the parameters for the MOOSE Navier-Stokes methods
    gravity = '0 0 0'                #gravity accel for body force (should be in m/s/s  -> we used cm here)
    integrate_p_by_parts = true    #how to include the pressure gradient term (not sure what it does, but solves when true)
    supg = true                     #activates SUPG stabilization (excellent stability, always necessary)
    pspg = true                    #activates PSPG stabilization for pressure term (excellent stability, lower accuracy)
    alpha = 0.5                     #stabilization multiplicative correction factor (0.1 < alpha <= 1) [lower value improves accuracy]
    laplace = true                #whether or not viscous term is in laplace form
    convective_term = true        #whether or not to include advective/convective term
    transient_term = true            #whether or not to include time derivative in supg correction (sometimes needed)

 []

[Materials]
    [./ins_material]
        type = INSFluid
#block = 'washcoat channel'
        density = rho
        viscosity = mu
    [../]
[]

[Mesh]
  #FileMeshGenerator automatically assigns boundary names from the .msh file
#   .msh file MUST HAVE specific boundary names in it (use msh format 4.1)
    [./mesh_file]
        type = FileMeshGenerator
        file = 2DChannel_Gap_lead.msh
    [../]
  #The above file contains the following boundary names
  #boundary_name = 'inlet outlet outer_walls inner_walls'
  #block_name = 'washcoat channel'

# The above mesh has a bumb going into the channel and a gap inside the channel

[]

# Approximate parabolic velocity at inlet
 [Functions]
   [./inlet_func]
     type = ParsedFunction
     #Parabola that has velocity of zero at z=top and=bot, with maximum at z=middle
     #value = a*z^2 + b*z + c    solve for a, b, and c
     value = '-2623.5*z^2 + 333.19*z - 7.0788'
   [../]

    [./dens_func]
        type = ParsedFunction
        value = '1.225e-6 - 0.225e-6*(y/5)'
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

# NOTE: This is NOT the actual pressure in the system. It is only dynamic pressure...
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

# NOTE: We are REQUIRED to have rho for both washcoat and channel due to the materials system
    [./rho]
        order = FIRST
        family = MONOMIAL
        #initial_condition = 1.225e-6  #kg/cm^3  (should be kg/m^3)
        [./InitialCondition]
            type = FunctionIC
            function = dens_func
        [../]
#block = 'washcoat channel'
    [../]
# NOTE: We are REQUIRED to have rho for both washcoat and channel due to the materials system
    [./mu]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1.81E-11   #Units are choosen to maintain correct rho/mu ratio (unrealistic)
#block = 'washcoat channel'
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
      pressure = p
      block = 'channel'
    [../]

    #Conservation of momentum equ in z (with time derivative)
    [./z_momentum_time]
      type = INSMomentumTimeDerivative
      variable = vel_z
      block = 'channel'
    [../]
    [./z_momentum_space]
      type = INSMomentumTractionForm  #INSMomentumTractionForm or INSMomentumLaplaceForm
      variable = vel_z
      u = vel_x
      v = vel_y
      w = vel_z
      pressure = p
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
      type = INSMomentumTractionForm  #INSMomentumTractionForm or INSMomentumLaplaceForm
      variable = vel_y
      u = vel_x
      v = vel_y
      w = vel_z
      pressure = p
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

# New INS BC: It does not work as well as I want. The BC is imposed too weakly. Requires LARGE pentalty term
    [./y_inlet_const]
        type = INSNormalFlowBC
        variable = vel_y
        direction = 1
        boundary = 'inlet'
        u_dot_n = -1.15        #This is the average velocity at the inlet which is wider than the channel
        # Avg velocity = Q/A
        # NOTE: The negative value denotes that this is an inlet
        ux = vel_x
        uy = vel_y
        uz = vel_z
        penalty = 1e6  #This term should be larger than the no_slip terms
    [../]

# This is a weaker form of a Dirichlet BC that may be more appropriate
    [./z_no_slip]
      type = PenaltyDirichletBC
      variable = vel_z
      boundary = 'inner_walls'
      value = 0.0
        penalty = 1000
    [../]
    [./y_no_slip]
      type = PenaltyDirichletBC
      variable = vel_y
      boundary = 'inner_walls'
      value = 0.0
        penalty = 1000
    [../]

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

   [./Q_enter]
       type = VolumetricFlowRate
       boundary = 'inlet'
       vel_x = vel_x
       vel_y = vel_y
       vel_z = vel_z
       execute_on = 'initial timestep_end'
   [../]

   [./Q_exit]
       type = VolumetricFlowRate
       boundary = 'outlet'
       vel_x = vel_x
       vel_y = vel_y
       vel_z = vel_z
       execute_on = 'initial timestep_end'
   [../]

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

    [./xsec_area_lead]
        type = AreaPostprocessor
        boundary = 'inlet'
        execute_on = 'initial timestep_end'
    [../]

[]

[Materials]

[]

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
  [../]

#  [./FDP_PJFNK]
#    type = FDP
#    full = true
#  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = pjfnk
  petsc_options = '-snes_converged_reason'
#petsc_options_iname ='-ksp_type -ksp_gmres_restart -pc_type -sub_pc_type'
#petsc_options_value = 'gmres 300 asm lu'
#petsc_options_value = 'bcgs 300 bjacobi lu'

petsc_options_iname ='-ksp_type -ksp_gmres_restart -pc_type -sub_pc_type'
petsc_options_value = 'gmres 300 lu lu'

# NOTE: gcr also has a -ksp_gcr_restart option (should override)
#-ksp_type options: gcr cgs bcgs gmres

#-pc_type options: asm bjacobi gasm
#-sub_pc_type:  lu   (NOTE: This is the only option that was found to work efficiently)

# -snes_max_it:  Max nonlinear iterations (do not need! because given below as a MOOSE option)

# NOTE: Run the command line code suffixed with -log_view to get stats of the solve
#           If the problem is very large (i.e., many DOF) and if significant time
#           is spent in KSPSolve, then GPU acceleration may be viable.

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = none
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-6
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0.0
end_time = 1.0
  dtmax = 0.5

# As the mesh becomes more complex, may need to cut time steps
  [./TimeStepper]
#	type = SolutionTimeAdaptiveDT
    type = ConstantDT
    dt = 0.1
  [../]
[]

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
[]
