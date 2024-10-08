[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 100
  ny = 100
[]

[Variables]
  [./u]
  [../]
[]

[Kernels]
  [./diff]
    type = Diffusion
    variable = u
  [../]
[]

[BCs]
  [./left]
    type = DirichletBC
    variable = u
    boundary = left
    value = 0
  [../]
  [./right]
    type = DirichletBC
    variable = u
    boundary = right
    value = 1
  [../]
[]


[Preconditioning]
    [./SMP_PJFNK]
      type = SMP
      full = true
      solve_type = pjfnk
    [../]

[] #END Preconditioning


[Executioner]
  type = Steady
  petsc_options = '-snes_converged_reason
                  -ksp_gmres_modifiedgramschmidt
                  -ksp_view'

	petsc_options_iname = '-ksp_type
                        -ksp_gmres_restart        -ksp_gcr_restart

                        -pc_type                           -sub_pc_type
                        -ksp_ksp_type                 -ksp_pc_type

                        -pc_factor_shift_type            -pc_factor_levels
                        -sub_pc_factor_shift_type    -sub_pc_factor_levels
                        -ksp_pc_factor_shift_type     -ksp_pc_factor_levels

                        -pc_asm_blocks             -pc_asm_overlap
                        -sub_pc_asm_blocks     -sub_pc_asm_overlap
                        -ksp_pc_asm_blocks      -ksp_pc_asm_overlap

                        -pc_gasm_subdomains              -pc_gasm_overlap
                        -sub_pc_gasm_subdomains      -sub_pc_gasm_overlap
                        -ksp_pc_gasm_subdomains       -ksp_pc_gasm_overlap

                        -snes_max_it     -snes_atol      -snes_rtol   -snes_stol
                        -ksp_max_it       -ksp_atol         -ksp_rtol'



	petsc_options_value =  'fgmres
                          100       100

                          ksp         ilu
                          gmres       ilu

                          NONZERO    3
                          NONZERO    3
                          NONZERO    3

                          3     50
                          3     50
                          3     50

                          3     50
                          3     50
                          3     50

                          20     1e-8     1e-10   1e-10
                          100   1e-6     1e-6'
[]

[Outputs]
  exodus = true
  print_linear_residuals = true
[]
