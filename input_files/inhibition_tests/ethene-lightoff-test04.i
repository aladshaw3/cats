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
    initial_condition = 5329 #ppm
  [../]
 
  [./H2]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1670 #ppm
  [../]
 
  [./HC]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1500 #ppm
  [../]
 
#NOTE: CANNOT name a variable 'NO' because MOOSE interprets this as instructions and not a name
  [./NOx]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1057 #ppm
  [../]
 
  [./N2O]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0 #ppm
  [../]
 
  [./NH3]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0 #ppm
  [../]

#Inhibition variables
  [./R1]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1
    #Need to provide a good initial condition for R1 (otherwise, convergence is poor)
  [../]
  [./R2]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1
   #Need to provide a good initial condition for R1 (otherwise, convergence is poor)
  [../]
  [./R3]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1
   #Need to provide a good initial condition for R1 (otherwise, convergence is poor)
  [../]
  [./R4]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1
   #Need to provide a good initial condition for R1 (otherwise, convergence is poor)
  [../]
  [./R5]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1
   #Need to provide a good initial condition for R1 (otherwise, convergence is poor)
  [../]
  [./R6]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1
   #Need to provide a good initial condition for R1 (otherwise, convergence is poor)
  [../]
  [./R8]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1
   #Need to provide a good initial condition for R1 (otherwise, convergence is poor)
  [../]
  [./R10]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1
   #Need to provide a good initial condition for R1 (otherwise, convergence is poor)
  [../]
  [./R14]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1
   #Need to provide a good initial condition for R1 (otherwise, convergence is poor)
  [../]
 
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
    initial_condition = 134535 #ppm
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
    initial_condition = 1057 #ppm
  [../]
 
  [./NH3_in]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0 #ppm
  [../]
 
  [./HC_in]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1500 #ppm
  [../]
  
  [./CO_in]
    order = FIRST
    family = MONOMIAL
    initial_condition = 5329 #ppm
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
 
#Time coeff = 0.4945 or -0.4945
# Mass Balances
[./CO_time]
   type = CoefTimeDerivative
   variable = CO
   Coefficient = 0.4945
 [../]
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

    forward_pre_exponential = 1.3783E41
    forward_activation_energy = 422622.45
    forward_inhibition = 1

    scale = 1.0
    reactants = 'CO O2'
    reactant_stoich = '1 1'
    products = ''
    product_stoich = ''
  [../]
 [./r4_rxn_CO]
   type = InhibitedArrheniusReaction
   variable = CO
   this_variable = CO
   temperature = temp

   forward_pre_exponential = 58720.44
   forward_activation_energy = 62556.5
   forward_inhibition = 1

   scale = 1.0
   reactants = 'CO NOx'
   reactant_stoich = '1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r5_rxn_CO]
   type = InhibitedArrheniusReaction
   variable = CO
   this_variable = CO
   temperature = temp

   forward_pre_exponential = 70.342
   forward_activation_energy = 39487.3
   forward_inhibition = 1

   scale = 1.0
   reactants = 'CO NOx'
   reactant_stoich = '1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r8_rxn_CO]
   type = InhibitedArrheniusReaction
   variable = CO
   this_variable = CO
   temperature = temp

   forward_pre_exponential = 52.89546
   forward_activation_energy = 91672.78
   forward_inhibition = 1

   scale = 2.5
   reactants = 'CO NOx H2O'
   reactant_stoich = '1 1 1'
   products = ''
   product_stoich = ''
 [../]
 
# Mass Balances
 [./H2_time]
    type = CoefTimeDerivative
    variable = H2
    Coefficient = 0.4945
  [../]
  [./H2_conv]
    type = ConstMassTransfer
    variable = H2
    coupled = H2_in
    transfer_rate = -12.454
  [../]
  [./r2_rxn_H2]
    type = InhibitedArrheniusReaction
    variable = H2
    this_variable = H2
    temperature = temp

    forward_pre_exponential = 31032693
    forward_activation_energy = 88259.46
    forward_inhibition = 1
 
    reverse_pre_exponential = 4.85E9
    reverse_activation_energy = 95089.1
    reverse_inhibition = 1

    scale = 1.0
    reactants = 'H2 O2'
    reactant_stoich = '1 1'
    products = 'H2O'
    product_stoich = '1'
  [../]
 [./r6_rxn_H2]
   type = InhibitedArrheniusReaction
   variable = H2
   this_variable = H2
   temperature = temp

   forward_pre_exponential = 2673.04
   forward_activation_energy = 67254.65
   forward_inhibition = 1

   scale = 2.5
   reactants = 'H2 NOx'
   reactant_stoich = '1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r7_rxn_H2]
   type = InhibitedArrheniusReaction
   variable = H2
   this_variable = H2
   temperature = temp

   forward_pre_exponential = 3.61E11
   forward_activation_energy = 134846.5
   forward_inhibition = 1

   scale = 1
   reactants = 'H2 NOx'
   reactant_stoich = '1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r14_rxn_H2]
   type = InhibitedArrheniusReaction
   variable = H2
   this_variable = H2
   temperature = temp

   forward_pre_exponential = 368.117
   forward_activation_energy = 48408.37
   forward_inhibition = 1

   scale = 1.0
   reactants = 'H2 NOx'
   reactant_stoich = '1 1'
   products = ''
   product_stoich = ''
 [../]
 
# Mass Balances
 [./HC_time]
    type = CoefTimeDerivative
    variable = HC
    Coefficient = 0.4945
  [../]
  [./HC_conv]
    type = ConstMassTransfer
    variable = HC
    coupled = HC_in
    transfer_rate = -12.454
  [../]
  [./r3_rxn_HC]
    type = InhibitedArrheniusReaction
    variable = HC
    this_variable = HC
    temperature = temp

    forward_pre_exponential = 8.17E15
    forward_activation_energy = 187452.3
    forward_inhibition = 1

    scale = 1.0
    reactants = 'HC O2'
    reactant_stoich = '1 1'
    products = ''
    product_stoich = ''
  [../]
 
# Mass Balances
 [./NO_time]
    type = CoefTimeDerivative
    variable = NOx
    Coefficient = 0.4945
  [../]
  [./NO_conv]
    type = ConstMassTransfer
    variable = NOx
    coupled = NO_in
    transfer_rate = -12.454
  [../]
  [./r4_rxn_NO]
    type = InhibitedArrheniusReaction
    variable = NOx
    this_variable = NOx
    temperature = temp

    forward_pre_exponential = 58720.44
    forward_activation_energy = 62556.5
    forward_inhibition = 1

    scale = 1.0
    reactants = 'CO NOx'
    reactant_stoich = '1 1'
    products = ''
    product_stoich = ''
  [../]
 [./r5_rxn_NO]
   type = InhibitedArrheniusReaction
   variable = NOx
   this_variable = NOx
   temperature = temp

    forward_pre_exponential = 70.342
    forward_activation_energy = 39487.3
   forward_inhibition = 1

   scale = 2.0
   reactants = 'CO NOx'
   reactant_stoich = '1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r6_rxn_NO]
   type = InhibitedArrheniusReaction
   variable = NOx
   this_variable = NOx
   temperature = temp

    forward_pre_exponential = 2673.04
    forward_activation_energy = 67254.65
   forward_inhibition = 1

   scale = 1.0
   reactants = 'H2 NOx'
   reactant_stoich = '1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r7_rxn_NO]
   type = InhibitedArrheniusReaction
   variable = NOx
   this_variable = NOx
   temperature = temp

 forward_pre_exponential = 3.61E11
 forward_activation_energy = 134846.5
   forward_inhibition = 1

   scale = 1
   reactants = 'H2 NOx'
   reactant_stoich = '1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r8_rxn_NO]
   type = InhibitedArrheniusReaction
   variable = NOx
   this_variable = NOx
   temperature = temp

 forward_pre_exponential = 52.89546
 forward_activation_energy = 91672.78
    forward_inhibition = 1

   scale = 1.0
   reactants = 'CO NOx H2O'
   reactant_stoich = '1 1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r14_rxn_NO]
   type = InhibitedArrheniusReaction
   variable = NOx
   this_variable = NOx
   temperature = temp

 forward_pre_exponential = 368.117
 forward_activation_energy = 48408.37
    forward_inhibition = 1

   scale = 2.0
   reactants = 'H2 NOx'
   reactant_stoich = '1 1'
   products = ''
   product_stoich = ''
 [../]
 
# Mass Balances
 [./N2O_time]
    type = CoefTimeDerivative
    variable = N2O
    Coefficient = 0.4945
  [../]
  [./N2O_conv]
    type = ConstMassTransfer
    variable = N2O
    coupled = N2O_in
    transfer_rate = -12.454
  [../]
  [./r5_rxn_N2O]
    type = InhibitedArrheniusReaction
    variable = N2O
    this_variable = N2O
    temperature = temp

 forward_pre_exponential = 70.342
 forward_activation_energy = 39487.3
    forward_inhibition = 1

    scale = -1.0
    reactants = 'CO NOx'
    reactant_stoich = '1 1'
    products = ''
    product_stoich = ''
  [../]
 [./r14_rxn_N2O]
   type = InhibitedArrheniusReaction
   variable = N2O
   this_variable = N2O
   temperature = temp

 forward_pre_exponential = 368.117
 forward_activation_energy = 48408.37
    forward_inhibition = 1

    scale = -1.0
   reactants = 'H2 NOx'
   reactant_stoich = '1 1'
   products = ''
   product_stoich = ''
 [../]
 
# Mass Balances
 [./NH3_time]
    type = CoefTimeDerivative
    variable = NH3
    Coefficient = 0.4945
  [../]
  [./NH3_conv]
    type = ConstMassTransfer
    variable = NH3
    coupled = NH3_in
    transfer_rate = -12.454
  [../]
  [./r6_rxn_NH3]
    type = InhibitedArrheniusReaction
    variable = NH3
    this_variable = NH3
    temperature = temp

 forward_pre_exponential = 2673.04
 forward_activation_energy = 67254.65
    forward_inhibition = 1

    scale = -1.0
    reactants = 'H2 NOx'
    reactant_stoich = '1 1'
    products = ''
    product_stoich = ''
  [../]
 [./r8_rxn_NH3]
   type = InhibitedArrheniusReaction
   variable = NH3
   this_variable = NH3
   temperature = temp

 forward_pre_exponential = 52.89546
 forward_activation_energy = 91672.78
    forward_inhibition = 1

   scale = -1.0
   reactants = 'CO NOx H2O'
   reactant_stoich = '1 1 1'
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
    pre_exponentials = '0'
    activation_energies = '0'
 
    coupled_i_list = 'CO'
    coupled_j_list = 'NOx'
    binary_pre_exp = '0'
    binary_energies = '0'
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
 
    coupled_list = 'CO'
    pre_exponentials = '0'
    activation_energies = '0'
 
    coupled_i_list = 'CO CO'
    coupled_j_list = 'NOx HC'
    binary_pre_exp = '0 0'
    binary_energies = '0 0'
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

    coupled_list = 'HC'
    pre_exponentials = '0'
    activation_energies = '0'

    coupled_i_list = 'CO HC'
    coupled_j_list = 'HC NOx'
    binary_pre_exp = '0 0'
    binary_energies = '0 0'
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

    coupled_list = 'HC'
    pre_exponentials = '0'
    activation_energies = '0'

    coupled_i_list = 'CO NOx'
    coupled_j_list = 'NOx HC'
    binary_pre_exp = '0 0'
    binary_energies = '0 0'
  [../]
 
# Inhibitions
  [./R5_eq]
    type = Reaction
    variable = R5
  [../]
  [./R5_inhib]
    type = PairedLangmuirInhibition
    variable = R5
    temperature = temp

    coupled_list = 'CO'
    pre_exponentials = '0'
    activation_energies = '0'

    coupled_i_list = 'CO NOx'
    coupled_j_list = 'HC HC'
    binary_pre_exp = '0 0'
    binary_energies = '0 0'
  [../]
 
# Inhibitions
  [./R6_eq]
    type = Reaction
    variable = R6
  [../]
  [./R6_inhib]
    type = PairedLangmuirInhibition
    variable = R6
    temperature = temp

    coupled_list = 'HC'
    pre_exponentials = '0'
    activation_energies = '0'

    coupled_i_list = 'CO HC'
    coupled_j_list = 'HC NOx'
    binary_pre_exp = '0 0'
    binary_energies = '0 0'
  [../]
 
# Inhibitions
  [./R8_eq]
    type = Reaction
    variable = R8
  [../]
  [./R8_inhib]
    type = PairedLangmuirInhibition
    variable = R8
    temperature = temp

    coupled_list = 'HC'
    pre_exponentials = '0'
    activation_energies = '0'

    coupled_i_list = 'CO'
    coupled_j_list = 'NOx'
    binary_pre_exp = '0'
    binary_energies = '0'
  [../]
 
# Inhibitions
  [./R10_eq]
    type = Reaction
    variable = R10
  [../]
  [./R10_inhib]
    type = PairedLangmuirInhibition
    variable = R10
    temperature = temp

    coupled_list = 'HC'
    pre_exponentials = '0'
    activation_energies = '0'

    coupled_i_list = 'HC'
    coupled_j_list = 'NOx'
    binary_pre_exp = '0'
    binary_energies = '0'
  [../]
 
# Inhibitions
  [./R14_eq]
    type = Reaction
    variable = R14
  [../]
  [./R14_inhib]
    type = PairedLangmuirInhibition
    variable = R14
    temperature = temp

    coupled_list = ''
    pre_exponentials = ''
    activation_energies = ''

    coupled_i_list = 'CO HC'
    coupled_j_list = 'HC NOx'
    binary_pre_exp = '0 0'
    binary_energies = '0 0'
  [../]
 
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
        start_time = 1
        end_time = 43
        end_value = 813.15
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
    [./CO]
        type = ElementAverageValue
        variable = CO
        execute_on = 'initial timestep_end'
    [../]
    [./H2]
        type = ElementAverageValue
        variable = H2
        execute_on = 'initial timestep_end'
    [../]
    [./HC]
        type = ElementAverageValue
        variable = HC
        execute_on = 'initial timestep_end'
    [../]
    [./NO]
        type = ElementAverageValue
        variable = NOx
        execute_on = 'initial timestep_end'
    [../]
    [./N2O]
        type = ElementAverageValue
        variable = N2O
        execute_on = 'initial timestep_end'
    [../]
    [./NH3]
        type = ElementAverageValue
        variable = NH3
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
#NOTE: The NEWTON solver is much better for steady-state problems
  solve_type = pjfnk
  petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -ksp_gmres_restart -pc_type -sub_pc_type'
  petsc_options_value = 'gmres 300 asm lu'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = none
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-6
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 20
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0
  end_time = 43
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
  time_step_interval = 1
[] #END Outputs


