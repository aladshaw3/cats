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

[GlobalParams]
# Below are the parameters for the MOOSE Navier-Stokes methods
    gravity = '0 -9.8 0'          #gravity accel for body force (should be in m/s/s)
    integrate_p_by_parts = true   #how to include the pressure gradient term
    supg = true                   #activates SUPG stabilization
    pspg = true                   #activates PSPG stabilization for pressure term
    alpha = 0.1                   #stabilization multiplicative correction factor
    laplace = true                #whether or not viscous term is in laplace form
    convective_term = true        #whether or not to include advective/convective term
    transient_term = true         #whether or not to include time derivative in supg correction

 []

[Problem]
    
[] #END Problem

[Mesh]
    [./my_mesh]
        type = GeneratedMeshGenerator
        dim = 2
        nx = 5
        ny = 20
        xmin = 0
        xmax = 0.05
        ymin = 0.0
        ymax = 0.1
    [../]
[] # END Mesh

 [Materials]
     [./ins_material]
         type = INSFluid
         density = 1.13
         viscosity = 2.25E-5
     [../]
 []
 
[Variables]
 
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
 
    [./p]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]

[] #END Variables

[AuxVariables]
    
    [./vel_z]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]

[] #END AuxVariables

[Kernels]
    #Continuity Equ
    [./mass]
        type = INSMass
        variable = p
        u = vel_x
        v = vel_y
        w = vel_z
        p = p
    [../]

    #Conservation of momentum equ in x (with time derivative)
    [./x_momentum_time]
        type = INSMomentumTimeDerivative
        variable = vel_x
    [../]
    [./x_momentum_space]
        type = INSMomentumLaplaceForm  #INSMomentumTractionForm or INSMomentumLaplaceForm
        variable = vel_x
        u = vel_x
        v = vel_y
        w = vel_z
        p = p
        component = 0
    [../]

    #Conservation of momentum equ in y (with time derivative)
    [./y_momentum_time]
        type = INSMomentumTimeDerivative
        variable = vel_y
    [../]
    [./y_momentum_space]
        type = INSMomentumLaplaceForm  #INSMomentumTractionForm or INSMomentumLaplaceForm
        variable = vel_y
        u = vel_x
        v = vel_y
        w = vel_z
        p = p
        component = 1
    [../]

[] #END Kernels

[DGKernels]

[] #END DGKernels


[BCs]
 # New INS BC: It does not work as well as I want. The BC is imposed too weakly. Requires LARGE pentalty term
     [./y_inlet_const]
         type = INSNormalFlowBC
         variable = vel_y
         direction = 1
         boundary = 'bottom'
         u_dot_n = -3
         # NOTE: The negative value denotes that this is an inlet
         ux = vel_x
         uy = vel_y
         uz = vel_z
         penalty = 1e6  #This term should be larger than the no_slip terms
     [../]

 # No slip in x direction applies to both the left and right boundary
# We need the vel_x to be zero at both the wall and the axis of symmetry.
     [./x_no_slip]
        type = PenaltyDirichletBC
        variable = vel_x
        boundary = 'right'
        value = 0.0
        penalty = 1000
     [../]
 # No slip in y direction applies to only the wall boundary
     [./y_no_slip]
        type = PenaltyDirichletBC
        variable = vel_y
        boundary = 'right'
        value = 0.0
        penalty = 1000
     [../]

 # Add in a symmetric flux term for the open boundary
 # This will mimic a symmetric flow profile in a domain that is actually bounded, but
#   we want the solution to be symmetric across this boundary. We do not include
#   vel_x as this type of boundary because the velocity in x should be zero here for symmetry.
    [./y_center]
       type = NeumannBC
       variable = vel_y
       boundary = 'left'
       value = 0
    [../]
# The open boundary is normal to the x-axis, thus there should be no upward or downward velocity
#   in the x-direction at this boundary. That prevents the increase or decrease in volumetric
#   flux at the open flow boundaries.
    [./x_center]
       type = PenaltyDirichletBC
       variable = vel_x
       boundary = 'left'
       value = 0.0
       penalty = 1000
    [../]
    
[] #END BCs


[Postprocessors]
    [./Q_enter]
        type = VolumetricFlowRate
        boundary = 'bottom'
        vel_x = vel_x
        vel_y = vel_y
        vel_z = vel_z
        execute_on = 'initial timestep_end'
    [../]

    [./Q_exit]
        type = VolumetricFlowRate
        boundary = 'top'
        vel_x = vel_x
        vel_y = vel_y
        vel_z = vel_z
        execute_on = 'initial timestep_end'
    [../]
 
    [./vy_exit]
        type = SideAverageValue
        boundary = 'top'
        variable = vel_y
        execute_on = 'initial timestep_end'
    [../]
    [./vy_enter]
        type = SideAverageValue
        boundary = 'bottom'
        variable = vel_y
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
