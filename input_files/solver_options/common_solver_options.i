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
#   -sub_pc_type:   asm     gasm    bjacobi     ilu     lu
#    ------------
#       ilu = Incomplete LU factorization
#       lu = Full LU factorization
    petsc_options = '-snes_converged_reason'
    petsc_options_iname ='-ksp_type -ksp_gmres_restart -pc_type -sub_pc_type'
    petsc_options_value = 'bcgs 300 bjacobi ilu'

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
