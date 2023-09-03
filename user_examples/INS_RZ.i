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
# suggest that alpha between .1 and 2 may be optimal for accuracy and
# robustness. The default value is 1, so keep that value as is for
# most cases.

[GlobalParams]
# Below are the parameters for the MOOSE Navier-Stokes methods
    gravity = '0 -9.8 0'          #gravity accel for body force (should be in m/s/s)
    integrate_p_by_parts = true   #how to include the pressure gradient term
    supg = true                   #activates SUPG stabilization
    pspg = true                   #activates PSPG stabilization for pressure term
    alpha = 1                     #stabilization multiplicative correction factor
    laplace = true                #whether or not viscous term is in laplace form
    convective_term = true        #whether or not to include advective/convective term
    transient_term = true         #whether or not to include time derivative in supg correction

 []

[Mesh]
	coord_type = RZ     #Transforms the x-direction to radius and y-direction to length
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
         density = 1.2
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
        type = INSMassRZ
        variable = p
        u = vel_x
        v = vel_y
        w = vel_z
        pressure = p
    [../]

    #Conservation of momentum equ in x (with time derivative)
    [./x_momentum_time]
        type = INSMomentumTimeDerivative
        variable = vel_x
    [../]
    [./x_momentum_space]
        type = INSMomentumLaplaceFormRZ  #INSMomentumTractionFormRZ or INSMomentumLaplaceFormRZ
        variable = vel_x
        u = vel_x
        v = vel_y
        w = vel_z
        pressure = p
        component = 0
    [../]

    #Conservation of momentum equ in y (with time derivative)
    [./y_momentum_time]
        type = INSMomentumTimeDerivative
        variable = vel_y
    [../]
    [./y_momentum_space]
        type = INSMomentumLaplaceFormRZ  #INSMomentumTractionFormRZ or INSMomentumLaplaceFormRZ
        variable = vel_y
        u = vel_x
        v = vel_y
        w = vel_z
        pressure = p
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

# Strong No slip in x direction applies to both the left and right boundary
# We need the vel_x to be zero at both the wall and the axis of symmetry.
# Thus, we apply this condition to the left and right boundaries
     [./x_no_slip]
        type = DirichletBC
        variable = vel_x
        boundary = 'left right'
        value = 0.0
     [../]
# NO penetration across the wall
     [./y_no_penetration]
         type = INSNormalFlowBC
         variable = vel_y
         direction = 1
         boundary = 'bottom'
         u_dot_n = 0
         ux = vel_x
         uy = vel_y
         uz = vel_z
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
                          -pc_asm_overlap

                          -snes_atol
                          -snes_rtol

                          -ksp_ksp_type
                          -ksp_pc_type'

    # snes_max_it = maximum non-linear steps
    petsc_options_value = 'fgmres
                           ksp

                           lu

                           10
                           NONZERO
                           10
                           1E-8
                           1E-10

                           gmres
                           lu'

    line_search = bt
    nl_rel_tol = 1e-8
    nl_abs_tol = 1e-8
    nl_rel_step_tol = 1e-12
    nl_abs_step_tol = 1e-12
    nl_max_its = 10
    l_tol = 1e-6
    l_max_its = 300

    start_time = 0.0
    end_time = 5.0
    dtmax = 0.5

    [./TimeStepper]
        type = ConstantDT
        dt = 0.02
    [../]

[] #END Executioner

[Outputs]
    print_linear_residuals = true
    exodus = true
    csv = true
    interval = 10
[] #END Outputs
