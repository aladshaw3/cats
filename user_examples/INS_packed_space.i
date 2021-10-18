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
    gravity = '0 0 0'             #gravity accel for body force (should be in m/s/s)
    integrate_p_by_parts = true   #how to include the pressure gradient term
    supg = true                   #activates SUPG stabilization
    pspg = true                   #activates PSPG stabilization for pressure term
    alpha = 1                     #stabilization multiplicative correction factor
    laplace = true                #whether or not viscous term is in laplace form
    convective_term = true        #whether or not to include advective/convective term
    transient_term = true         #whether or not to include time derivative in supg correction

 []

[Problem]

[] #END Problem

[Mesh]
    [./my_mesh]
        type = FileMeshGenerator
        file = packed_space.msh
    # Boundaries:   walls inlet outlet
    [../]
[] # END Mesh

 [Materials]
     [./ins_material]
         type = INSFluid
         density = 1.13
         viscosity = 2.25E-2
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
        initial_condition = 0
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
        pressure = p
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
        pressure = p
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
         boundary = 'inlet'
         u_dot_n = -3
         # NOTE: The negative value denotes that this is an inlet
         ux = vel_x
         uy = vel_y
         uz = vel_z
         penalty = 1e6  #This term should be larger than the no_slip terms
     [../]

 # Strict NO slip
     [./x_no_slip]
        type = DirichletBC
        variable = vel_x
        boundary = 'walls'
        value = 0.0
     [../]
     [./y_no_slip]
        type = DirichletBC
        variable = vel_y
        boundary = 'walls'
        value = 0.0
     [../]

[] #END BCs


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

    [./vy_exit]
        type = SideAverageValue
        boundary = 'outlet'
        variable = vel_y
        execute_on = 'initial timestep_end'
    [../]
    [./vy_enter]
        type = SideAverageValue
        boundary = 'inlet'
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
    scheme = implicit-euler
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
        type = SolutionTimeAdaptiveDT
        dt = 0.02
    [../]

[] #END Executioner

[Outputs]
    print_linear_residuals = true
    exodus = true
    csv = true
    interval = 1
[] #END Outputs
