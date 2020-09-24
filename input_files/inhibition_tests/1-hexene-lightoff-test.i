[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 1
  ny = 1
[]

[Variables]
#O2 concentration (used as a variable for moving through time)
  [./O2]
    order = FIRST
    family = MONOMIAL
    initial_condition = 7100 #ppm
  [../]
 
  [./CO]
    order = FIRST
    family = MONOMIAL
    initial_condition = 5272 #ppm
  [../]

#Inhibition variables
  [./R1]
    order = FIRST
    family = MONOMIAL
    initial_condition = 18136467.09
    #Need to provide a good initial condition for R1 (otherwise, convergence is poor)
  [../]
  [./R2]
    order = FIRST
    family = MONOMIAL
    initial_condition = 34615
   #Need to provide a good initial condition for R1 (otherwise, convergence is poor)
  [../]
  [./R3]
    order = FIRST
    family = MONOMIAL
    initial_condition = 50037782
   #Need to provide a good initial condition for R1 (otherwise, convergence is poor)
  [../]
  [./R4]
    order = FIRST
    family = MONOMIAL
    initial_condition = 9.13E13
   #Need to provide a good initial condition for R1 (otherwise, convergence is poor)
  [../]
#  [./R5]
#    order = FIRST
#    family = MONOMIAL
#    initial_condition = 961362176
#   #Need to provide a good initial condition for R1 (otherwise, convergence is poor)
#  [../]
#  [./R6]
#    order = FIRST
#    family = MONOMIAL
#    initial_condition = 3.1E23
#   #Need to provide a good initial condition for R1 (otherwise, convergence is poor)
#  [../]
#  [./R8]
#    order = FIRST
#    family = MONOMIAL
#    initial_condition = 5.1E27
#   #Need to provide a good initial condition for R1 (otherwise, convergence is poor)
#  [../]
#  [./R10]
#    order = FIRST
#    family = MONOMIAL
#    initial_condition = 2531262
#   #Need to provide a good initial condition for R1 (otherwise, convergence is poor)
#  [../]
#  [./R14]
#    order = FIRST
#    family = MONOMIAL
#    initial_condition = 1.6E51
#   #Need to provide a good initial condition for R1 (otherwise, convergence is poor)
#  [../]
 
#Coupled non-linear temperature
  [./temp]
    order = FIRST
    family = MONOMIAL
    initial_condition = 393.15  #K
  [../]
 
[]
 
[AuxVariables]
  [./temp_ref]
    order = FIRST
    family = MONOMIAL
    initial_condition = 393.15  #K
  [../]
  [./H2O]
    order = FIRST
    family = MONOMIAL
    initial_condition = 133562 #ppm
  [../]
 
#Inlet concentrations
  [./N2O_in]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0 #ppm
  [../]
 
  [./NO_in]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1063 #ppm
  [../]
 
  [./NH3_in]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0 #ppm
  [../]
 
  [./HC_in]
    order = FIRST
    family = MONOMIAL
    initial_condition = 3000 #ppm
  [../]
  
  [./CO_in]
    order = FIRST
    family = MONOMIAL
    initial_condition = 5272 #ppm
  [../]
 
  [./H2_in]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1670 #ppm
  [../]

[]

[Kernels]
  [./O2_time]
    type = CoefTimeDerivative
    variable = O2
    Coefficient = 1
  [../]
 
# Mass Balances
  [./CO_conv]
    type = ConstMassTransfer
    variable = CO
    coupled = CO_in
    transfer_rate = -12.454
  [../]
  [./r1_rxn_CO]
    type = InhibitedArrheniusReaction
    variable = CO
    this_variable = CO
    temperature = temp

    forward_pre_exponential = 1406.8
    forward_activation_energy = 6992.5
    forward_inhibition = R1

    scale = 1.0
    reactants = 'CO O2'
    reactant_stoich = '1 1'
    products = ''
    product_stoich = ''
  [../]

# Inhibitions
  [./R1_eq]
    type = Reaction
    variable = R1
  [../]
  [./R1_inhib]
    type = PairedLangmuirInhibition
    variable = R1
    temperature = temp
 
    coupled_list = 'CO'
    pre_exponentials = '38.1'
    activation_energies = '-737.3'
 
    coupled_i_list = 'CO'
    coupled_j_list = 'NO_in'
    binary_pre_exp = '6.17E-6'
    binary_energies = '-43461'
  [../]
 
# Inhibitions
  [./R2_eq]
    type = Reaction
    variable = R2
  [../]
  [./R2_inhib]
    type = PairedLangmuirInhibition
    variable = R2
    temperature = temp
 
    coupled_list = 'H2_in'
    pre_exponentials = '62.43'
    activation_energies = '23658.4'
 
    coupled_i_list = 'CO CO'
    coupled_j_list = 'NO_in H2_in'
    binary_pre_exp = '7.44E-10 3.42E-95'
    binary_energies = '-50750.6 -690724'
  [../]
 
# Inhibitions
  [./R3_eq]
    type = Reaction
    variable = R3
  [../]
  [./R3_inhib]
    type = PairedLangmuirInhibition
    variable = R3
    temperature = temp

    coupled_list = 'HC_in'
    pre_exponentials = '3.61'
    activation_energies = '-112.1'

    coupled_i_list = 'CO HC_in'
    coupled_j_list = 'HC_in H2_in'
    binary_pre_exp = '1.44E-7 7.23E-9'
    binary_energies = '-54305.4 -64664.5'
  [../]
 
# Inhibitions
  [./R4_eq]
    type = Reaction
    variable = R4
  [../]
  [./R4_inhib]
    type = PairedLangmuirInhibition
    variable = R4
    temperature = temp

    coupled_list = 'H2_in'
    pre_exponentials = '4.03E72'
    activation_energies = '678297.4'

    coupled_i_list = 'CO NO_in'
    coupled_j_list = 'NO_in H2_in'
    binary_pre_exp = '1.21E-55 20.96025'
    binary_energies = '-468622 -1258.98'
  [../]
 
# Inhibitions
#  [./R5_eq]
#    type = Reaction
#    variable = R5
#  [../]
#  [./R5_inhib]
#    type = PairedLangmuirInhibition
#    variable = R5
#    temperature = temp
#
#    coupled_list = 'CO H2_in'
#    pre_exponentials = '116.387 4.46E63'
#    activation_energies = '-2542.54 584321.9'
#
#    coupled_i_list = 'CO NO_in'
#    coupled_j_list = 'HC_in H2_in'
#    binary_pre_exp = '1.633565 2.83E-9'
#    binary_energies = '455.4974 -85675'
#  [../]
 
#NOTE: This kernel is used to set the temperature equal to a reference temperature at each time step
#      The residual for this kernel is k*(T - T_ref)  (with k = 1)
  [./temp_equ]
    type = ConstMassTransfer
    variable = temp
    coupled = temp_ref
  [../]
[]
 
[AuxKernels]
    [./temp_ramp]
        type = LinearChangeInTime
        variable = temp_ref
        start_time = 0
        end_time = 50
        end_value = 793.15
    # Execute always at initial, then at either timestep_begin or timestep_end
        execute_on = 'initial timestep_begin'
    [../]
[]

[BCs]

[]

[Postprocessors]
    [./O2]
        type = ElementAverageValue
        variable = O2
        execute_on = 'initial timestep_end'
    [../]
    [./R1]
        type = ElementAverageValue
        variable = R1
        execute_on = 'initial timestep_end'
    [../]
    [./R2]
        type = ElementAverageValue
        variable = R2
        execute_on = 'initial timestep_end'
    [../]
    [./R3]
        type = ElementAverageValue
        variable = R3
        execute_on = 'initial timestep_end'
    [../]
    [./R4]
        type = ElementAverageValue
        variable = R4
        execute_on = 'initial timestep_end'
    [../]
#    [./R5]
#        type = ElementAverageValue
#        variable = R5
#        execute_on = 'initial timestep_end'
#    [../]
    [./CO]
        type = ElementAverageValue
        variable = CO
        execute_on = 'initial timestep_end'
    [../]
    [./T]
        type = ElementAverageValue
        variable = temp
        execute_on = 'initial timestep_end'
    [../]
[]

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
  petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -ksp_gmres_restart -pc_type -sub_pc_type'
  petsc_options_value = 'gmres 300 asm lu'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = basic
  nl_rel_tol = 1e-14
  nl_abs_tol = 1e-10
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0
  end_time = 50
  dtmax = 1

  [./TimeStepper]
     type = ConstantDT
     dt = 1
  [../]
[] #END Executioner

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
  interval = 1
[] #END Outputs


