# This input file tests various options for the incompressible NS equations in a channel.

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

# NOTE: If you want an approximate steady-state flow profile, use MAXIMUM STABILITY
#       options (alpha = 1.0 and all set to true) and simulate for many time steps.


# Other Notes:
# ------------
#   The Compressible Navier-Stokes module is currently under a MAJOR revision
#   and will be unavailable for 2020. Check back later.

# Below are the parameters for the MOOSE Navier-Stokes methods
#   We put these options under 'GlobalParams' for convenience.
[GlobalParams]

    #gravity accel for body force (should be in m/s^2)
    gravity = '0 0 0'

    #always necessary for incompressible Navier-Stokes
    integrate_p_by_parts = true

    #activates SUPG stabilization (excellent stability, always necessary)
    supg = true

    #activates PSPG stabilization for pressure term (excellent stability, lower accuracy)
    pspg = true

    #stabilization multiplicative correction factor (0.1 < alpha <= 1) [lower value improves accuracy]
    alpha = 0.5

    #whether or not viscous term is in laplace form (should always be true in CATS)
    laplace = true

    #whether or not to include advective/convective term (should aways be true in CATS)
    convective_term = true

    #whether or not to include time derivative in supg correction (should always be true if transient)
    transient_term = true

 []

# The incompressible Navier-Stokes module REQUIRES density and viscosity
#   of the fluid phase to be defined as 'Materials'. To accommodate this
#   restriction, CATS has a custom Material object (INSFluid) that sets
#   the values for density and viscosity according to their variable or
#   auxiliary variable values. You can then either assign these values
#   as a constant, or use an auxiliary kernel to calculate them and
#   have INSFluid transmit those calculated values to the incompressible
#   Navier-Stokes module.
[Materials]
    [./ins_material]
        type = INSFluid
        density = rho
        viscosity = mu
    [../]
[]

# Here we show an example for declaring the density and viscosity as
#   auxiliary variables. Make sure you use the appropriate units.
[AuxVariables]
    [./rho]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1.225  #kg/m^3
    [../]
    [./mu]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1.81E-5   #kg/m/s
    [../]
[]


[Preconditioning]
# The 'active' option is used to denote which preconditioner is actually used
    active = SMP_PJFNK

# SMP is the most efficient option to use
    [./SMP_PJFNK]
        type = SMP
        full = true
    [../]

# FDP should only be used for debugging
    [./FDP_PJFNK]
        type = FDP
        full = true
    [../]
[]

[Executioner]
    type = Transient

# scheme options:   implicit-euler  bdf2
# ---------------
#   Use implicit-euler for stability and bdf2 for accuracy
    scheme = bdf2

# solve_type options:   pjfnk   newton
# ------------------
#   pjfnk = Precondition Jacobian-Free Newton-Krylov
#   newton = Newton's method
#
#   Use pjfnk for most simulation cases. It scales better on multiple cores.
#   For running on a personal computer, newtom may work faster.
    solve_type = pjfnk

# Below are sets of PETSc linear solver options:
# ----------------------------------------------
#
#   -ksp_type options: gcr cgs bcgs gmres
#    ----------------
#       gcr = Generalized Conjugate Residuals
#       cgs = Conjugate Gradients Squared
#       bcgs = Bi-Conjugate Gradients Stabilized
#       gmres = Generalized Minimum Residuals
#
#   NOTE:   If you use gcr or gmres, you need to also provide the following
#                       -ksp_gmres_restart  or  -ksp_gcr_restart
#                (i.e., the number of subspace vectors to store in memory)
#
#   -pc_type:   asm     gasm    bjacobi
#    -------
#       asm = Additive Schwarz Method
#       gasm = Generalized Additive Schwarz Method
#       bjacobi = Block Jacobi method
#
#   -sub_pc_type:   lu
#    ------------
#       lu = Full LU factorization
#
#   NOTE: Unlike the rest of CATS, which works with any 'sub_pc_type', the
#       built-in MOOSE Navier-Stokes module seems to only converge if the
#       'sub_pc_type' is set to 'lu'.
    petsc_options = '-snes_converged_reason'
    petsc_options_iname ='-ksp_type -ksp_gmres_restart -pc_type -sub_pc_type'
    petsc_options_value = 'bcgs 300 bjacobi lu'

# NOTE: Run the command line code suffixed with -log_view to get stats of the solve
#           If the problem is very large (i.e., many DOF) and if significant time
#           is spent in KSPSolve, then GPU acceleration may be viable.

# line_search options:      none    bt      l2      basic
# -------------------
#   none = no line searching
#   bt = backtracking line search
#
#       NOTE: Not sure what the other options are.
    line_search = none

# Below is a list of solver tolerances and maximum iterations that work
# well for most all simulation cases. The 'l_max_its' may need to be
# larger if you simulation domain or degrees of freedom are very large.
    nl_rel_tol = 1e-8
    nl_abs_tol = 1e-6
    nl_rel_step_tol = 1e-10
    nl_abs_step_tol = 1e-10
    nl_max_its = 10
    l_tol = 1e-6
    l_max_its = 300

# Below are parameters you can set for the simulated time and
# maximum time step size
    start_time = 0.0
    end_time = 1.0
    dtmax = 0.5

# The 'TimeStepper' subblock is used to pick a method by which MOOSE
# will choose time steps after a simulation step has completed.
    [./TimeStepper]
# type options:     ConstantDT      SolutionTimeAdaptiveDT
# ------------
#       ConstantDT = each time step will be a given constant (based on 'dt')
#       SolutionTimeAdaptiveDT = the first time step will be 'dt' and each
#                                   subsequent time step will be choosen based
#                                   on the relative success of the previous step.
#
#   Use SolutionTimeAdaptiveDT if you want simulations to accelerate overtime
#       starting from a small initial time step. Very useful to simulate very
#       long time spans.
        type = ConstantDT
        dt = 0.1
    [../]
[]
