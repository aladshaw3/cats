# This test looks at generic flux based BCs for DG or CG methods and
# how those can be applied at boundaries and sub-domain interfaces.
#
# For example, if I create a block '1' and create a boundary on that
# block as the 'primary' block, then that boundary set ONLY applies
# to that block (even if the set is actually physically shared with
# block '0'). So far, it appears as though you CANNOT assign the
# same set to the other block, because that would duplicate the nodes.

[GlobalParams]
  # Default DG methods
  sigma = 10
  dg_scheme = nipg
  Dxx = 1
  Dyy = 1
  Dzz = 1

[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
    [gen] #block = 0
         type = GeneratedMeshGenerator
         dim = 2
         nx = 10
         ny = 10
         xmin = 0
         xmax = 5
         ymin = 0
         ymax = 5
     []
     #Create a bounding box from the entire domain to span the new subdomain (block = 1)
       [./subdomain1]
         input = gen
         type = SubdomainBoundingBoxGenerator
         bottom_left = '2.5 0 0'
         top_right = '5 5 0'
         block_id = 1
       [../]
     #Designate a new boundary as the side sets that are shared between block 0 and block 1
     #   The new boundary is now labeled and can be used in boundary conditions or InterfaceKernels
       [./interface]
         type = SideSetsBetweenSubdomainsGenerator
         input = subdomain1
         primary_block = '1'
         paired_block = '0'
         new_boundary = 'primary_1_to_paired_0'
       [../]
     #Break up the original boundaries (left right top bottom) to create separate boundaries for each subdomain
     #new boundary names are (old_name)_to_(block_id)
     # For example, two new left side boundary names:   left_to_0 and left_to_1
     #       left_to_0 is the new left side boundary that is a part of block 0
       [./break_boundary]
         input = interface
         type = BreakBoundaryOnSubdomainGenerator
       [../]

[] # END Mesh

[Variables]
  # Positive ion concentration (in mol/volume)
  [./pos_ion]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1e-20
  [../]

  [./neg_ion]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1e-20
      block = 1
  [../]

  [./grad_ion]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1e-20
      block = 1
  [../]

  [./lap]
      order = FIRST
      family = LAGRANGE
      initial_condition = 1e-20
  [../]

[] #END Variables

[AuxVariables]
    [./Dp]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1
    [../]

    [./eps]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1
    [../]

[] #END AuxVariables

[ICs]

[] #END ICs

[Kernels]
    [./lap_diff]
        type = VariableLaplacian
        variable = lap
        coupled_coef = 1
    [../]

    ### Conservation of mass for pos_ion ###
    [./pos_ion_dot]
        type = VariableCoefTimeDerivative
        variable = pos_ion
        coupled_coef = eps
    [../]
    [./pos_ion_gdiff]
        type = GVarPoreDiffusion
        variable = pos_ion
        porosity = eps
        Dx = Dp
        Dy = Dp
        Dz = Dp
    [../]

    ### Conservation of mass for neg_ion ###
    [./neg_ion_dot]
        type = VariableCoefTimeDerivative
        variable = neg_ion
        coupled_coef = eps
    [../]
    [./neg_ion_gdiff]
        type = GVarPoreDiffusion
        variable = neg_ion
        porosity = eps
        Dx = Dp
        Dy = Dp
        Dz = Dp
    [../]


    ### Conservation of mass for grad_ion ###
    [./grad_ion_dot]
        type = VariableCoefTimeDerivative
        variable = grad_ion
        coupled_coef = eps
    [../]
    [./grad_ion_gdiff]
        type = GVarPoreDiffusion
        variable = grad_ion
        porosity = eps
        Dx = Dp
        Dy = Dp
        Dz = Dp
    [../]

[] #END Kernels

# NOTE: All'G' prefixed kernels from above MUST have a
#       corresponding 'DG' kernel down here.
[DGKernels]

  ### Conservation of mass for pos_ion ###
  [./pos_ion_dgdiff]
      type = DGVarPoreDiffusion
      variable = pos_ion
      porosity = eps
      Dx = Dp
      Dy = Dp
      Dz = Dp
  [../]

  ### Conservation of mass for neg_ion ###
  [./neg_ion_dgdiff]
      type = DGVarPoreDiffusion
      variable = neg_ion
      porosity = eps
      Dx = Dp
      Dy = Dp
      Dz = Dp
  [../]

  ### Conservation of mass for grad_ion ###
  [./grad_ion_dgdiff]
      type = DGVarPoreDiffusion
      variable = grad_ion
      porosity = eps
      Dx = Dp
      Dy = Dp
      Dz = Dp
  [../]

[]

[AuxKernels]

[] #END AuxKernels

[BCs]

  [./lap_left]
      type = DirichletBC
      variable = lap
      boundary = 'left'
      value = 0
  [../]

  [./lap_right]
      type = CoupledNeumannBC
      variable = lap
      boundary = 'right'
      coupled = 1
  [../]

  ### Fluxes for Pos Ions ###
  [./pos_ion_FluxIn]
      type = CoupledVariableFluxBC
      variable = pos_ion
      boundary = 'bottom_to_0'
      fx = 0
      fy = 1
      fz = 0
  [../]
  [./pos_ion_FluxOut]
      type = CoupledVariableFluxBC
      variable = pos_ion
      boundary = 'top_to_1'
      fx = 0
      fy = -1
      fz = 0
  [../]

  ### Fluxes for Neg Ions ###
  [./neg_ion_FluxIn]
      type = CoupledVariableFluxBC
      variable = neg_ion
      boundary = 'right_to_1'
      fx = 1
      fy = 0
      fz = 0
  [../]

  # NOTE: For some reason, this does not work if
  #       the var is on block 1 ???

  # OK, so whether or not with works depends ENTIRELY on whether or
  #   not the block that the variable is on is considered the PRIMARY
  #   BLOCK (not the paired block)... I am able to make this work either
  #   way, but I have to identify (for the boundary/interface) which of
  #   the blocks is PRIMARY. The primary block is the ONLY block that
  #   actually contains that side set.

  # Question: How is the primary block determined???
  [./neg_ion_FluxOut]
      type = CoupledVariableFluxBC
      variable = neg_ion
      boundary = 'primary_1_to_paired_0'
      fx = -1
      fy = 0
      fz = 0
  [../]


  ### Fluxes for Grad Ions ###
  [./grad_ion_FluxIn]
      type = CoupledVariableGradientFluxBC
      variable = grad_ion
      boundary = 'primary_1_to_paired_0'
      coupled = lap
      coef = -1
  [../]

[] #END BCs

[Materials]

[] #END Materials

[Postprocessors]
    [./pos_ion_top]
        type = SideAverageValue
        boundary = 'top'
        variable = pos_ion
        execute_on = 'initial timestep_end'
    [../]

    [./pos_ion_bottom]
        type = SideAverageValue
        boundary = 'bottom'
        variable = pos_ion
        execute_on = 'initial timestep_end'
    [../]

    [./pos_ion_avg]
        type = ElementAverageValue
        variable = pos_ion
        execute_on = 'initial timestep_end'
    [../]


[] #END Postprocessors

[Executioner]
  type = Transient
  scheme = implicit-euler
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

  petsc_options_value = 'gmres
                         ksp

                         lu

                         20

                         NONZERO
                         NONZERO
                         NONZERO

                         10

                         1E-10
                         1E-10

                         gmres
                         lu'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = none
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-10
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 20
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0.0
  end_time = 15.0
  dtmax = 0.5

    [./TimeStepper]
		  type = ConstantDT
      dt = 0.5
    [../]

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
