[GlobalParams]
  
[] #END GlobalParams

[Problem]
    coord_type = RZ
    #NOTE: For RZ coordinates, x ==> R and y ==> Z (and z ==> nothing)
[] #END Problem

[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = 1
    ny = 20
    xmin = 0.0
    xmax = 0.01    # 2cm radius
    ymin = 0.0
    ymax = 0.05    # 5 cm length
[] # END Mesh

[Variables]

    [./dP]
        order = FIRST
        family = LAGRANGE
    [../]

[] #END Variables

[AuxVariables]
    [./PT]
        order = FIRST
        family = MONOMIAL
    [../]
 
  [./pore]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.3309
  [../]

  [./vel_x]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  [./vel_y]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.416667 #m/s
  [../]

  [./vel_z]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]
 
  [./dens]
     order = FIRST
     family = MONOMIAL
     initial_condition = 0.6158   #kg/m^3
  [../]
 
  [./vis]
     order = FIRST
     family = MONOMIAL
     initial_condition = 2.93E-5   #kg/m/s
  [../]
 
  [./dia]
     order = FIRST
     family = MONOMIAL
     initial_condition = 0.000777   #m
  [../]

[] #END AuxVariables

[ICs]

[] #END ICs

[Kernels]
 
    [./dP_ergun]
        type = ErgunPressure
        variable = dP
        direction = 1
        porosity = pore
        hydraulic_diameter = dia
        velocity = vel_y
        viscosity = vis
        density = dens
    [../]
 
[] #END Kernels

[DGKernels]

[] #END DGKernels

[AuxKernels]
 # Pressure calculated in Pa
    [./ergun_press_y]
        type = AuxErgunPressure
        variable = PT
        inlet_pressure = 102000
        direction = 1
        porosity = pore
        hydraulic_diameter = dia
        velocity = vel_y
        viscosity = vis
        density = dens
        execute_on = 'initial timestep_end'
    [../]

[] #END AuxKernels

[BCs]

[] #END BCs

[Materials]

[] #END Materials

[Postprocessors]

    [./PT_out]
        type = SideAverageValue
        boundary = 'top'
        variable = PT
        execute_on = 'initial timestep_end'
    [../]
 
    [./dP_avg]
        type = ElementAverageValue
        variable = dP
        execute_on = 'initial timestep_end'
    [../]
 
    [./PT_in]
        type = SideAverageValue
        boundary = 'bottom'
        variable = PT
        execute_on = 'initial timestep_end'
    [../]

[] #END Postprocessors

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
    solve_type = pjfnk   #default to newton, but use pjfnk if newton too slow
  [../]
[] #END Preconditioning

[Executioner]
  type = Steady
#scheme = implicit-euler
  petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -pc_type -sub_pc_type -snes_max_it -sub_pc_factor_shift_type -pc_asm_overlap -snes_atol -snes_rtol'
  petsc_options_value = 'gmres lu ilu 100 NONZERO 2 1E-14 1E-12'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = none
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-4
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

#  start_time = 0.0
#  end_time = 0.25
#  dtmax = 0.25
#
#  [./TimeStepper]
#     type = ConstantDT
#     dt = 0.25
#  [../]
[] #END Executioner

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
[] #END Outputs
