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
    initial_condition = 6800 #ppm
  [../]
 
  [./CO]
    order = FIRST
    family = MONOMIAL
    initial_condition = 5273 #ppm
  [../]
 
  [./H2]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1670 #ppm
  [../]
 
  [./HC]
    order = FIRST
    family = MONOMIAL
    initial_condition = 600 #ppm
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
    initial_condition = 134386 #ppm
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
    initial_condition = 600 #ppm
  [../]
  
  [./CO_in]
    order = FIRST
    family = MONOMIAL
    initial_condition = 5273 #ppm
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

    forward_pre_exponential = 6.305E16
    forward_activation_energy = 187127.7
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

   forward_pre_exponential = 1094.8
   forward_activation_energy = 50713.35
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

   forward_pre_exponential = 26.25
   forward_activation_energy = 38367.5
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

   forward_pre_exponential = 2.29
   forward_activation_energy = 79150.6
   forward_inhibition = 1

   scale = 2.5
   reactants = 'CO NOx H2O'
   reactant_stoich = '1 1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r15_rxn_CO]
   type = InhibitedArrheniusReaction
   variable = CO
   this_variable = CO
   temperature = temp

   forward_pre_exponential = 82684.83
   forward_activation_energy = 103792.5
   forward_inhibition = 1

   scale = 1
   reactants = 'N2O CO O2'
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

    forward_pre_exponential = 1.1284E11
    forward_activation_energy = 121696.78
    forward_inhibition = 1
 
    reverse_pre_exponential = 1.1689E14
    reverse_activation_energy = 137611.876
    reverse_inhibition = 1

    scale = 1.0
    reactants = 'H2 O2'
    reactant_stoich = '1 1'
    products = 'H2O'
    product_stoich = '1'
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

    forward_pre_exponential = 4.4595E11
    forward_activation_energy = 152339.79
    forward_inhibition = 1

    scale = 1.0
    reactants = 'HC O2'
    reactant_stoich = '1 1'
    products = ''
    product_stoich = ''
  [../]
 [./r10_rxn_HC]
   type = InhibitedArrheniusReaction
   variable = HC
   this_variable = HC
   temperature = temp

   forward_pre_exponential = 1.08E43
   forward_activation_energy = 484255.12
   forward_inhibition = 1

   scale = 1.0
   reactants = 'HC NOx'
   reactant_stoich = '1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r16_rxn_HC]
   type = InhibitedArrheniusReaction
   variable = HC
   this_variable = HC
   temperature = temp

   forward_pre_exponential = 2.656E45
   forward_activation_energy = 560759.1
   forward_inhibition = 1

   scale = 1.0
   reactants = 'HC NOx O2'
   reactant_stoich = '1 1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r18_rxn_HC]
   type = InhibitedArrheniusReaction
   variable = HC
   this_variable = HC
   temperature = temp

   forward_pre_exponential = 1.308E20
   forward_activation_energy = 269500.3
   forward_inhibition = 1

   scale = 1.0
   reactants = 'HC NOx O2'
   reactant_stoich = '1 1 1'
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

    forward_pre_exponential = 1094.8
    forward_activation_energy = 50713.35
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

    forward_pre_exponential = 26.25
    forward_activation_energy = 38367.5
   forward_inhibition = 1

   scale = 2.0
   reactants = 'CO NOx'
   reactant_stoich = '1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r8_rxn_NO]
   type = InhibitedArrheniusReaction
   variable = NOx
   this_variable = NOx
   temperature = temp

    forward_pre_exponential = 2.29
    forward_activation_energy = 79150.6
    forward_inhibition = 1

   scale = 1.0
   reactants = 'CO NOx H2O'
   reactant_stoich = '1 1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r10_rxn_NO]
   type = InhibitedArrheniusReaction
   variable = NOx
   this_variable = NOx
   temperature = temp

    forward_pre_exponential = 1.08E43
    forward_activation_energy = 484255.12
   forward_inhibition = 1

#NOTE:  ------------ MUST CHANGE SCALE FOR NOx:   (2x + (y/2) - z):   x=7, y=8, z=0 -----------------
#   ----------------------   scale depends on CxHyOz  for a given HC --------------------------------
   scale = 14.0
   reactants = 'HC NOx'
   reactant_stoich = '1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r15_rxn_NO]
   type = InhibitedArrheniusReaction
   variable = NOx
   this_variable = NOx
   temperature = temp

    forward_pre_exponential = 82684.83
    forward_activation_energy = 103792.5
   forward_inhibition = 1

   scale = -2
   reactants = 'N2O CO O2'
   reactant_stoich = '1 1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r16_rxn_NO]
   type = InhibitedArrheniusReaction
   variable = NOx
   this_variable = NOx
   temperature = temp

    forward_pre_exponential = 2.656E45
    forward_activation_energy = 560759.1
   forward_inhibition = 1

   scale = 1.0
   reactants = 'HC NOx O2'
   reactant_stoich = '1 1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r18_rxn_NO]
   type = InhibitedArrheniusReaction
   variable = NOx
   this_variable = NOx
   temperature = temp

    forward_pre_exponential = 1.308E20
    forward_activation_energy = 269500.3
   forward_inhibition = 1

   scale = 2.0
   reactants = 'HC NOx O2'
   reactant_stoich = '1 1 1'
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

    forward_pre_exponential = 26.25
    forward_activation_energy = 38367.5
    forward_inhibition = 1

    scale = -1.0
    reactants = 'CO NOx'
    reactant_stoich = '1 1'
    products = ''
    product_stoich = ''
  [../]
 [./r15_rxn_N2O]
   type = InhibitedArrheniusReaction
   variable = N2O
   this_variable = N2O
   temperature = temp

    forward_pre_exponential = 82684.83
    forward_activation_energy = 103792.5
   forward_inhibition = 1

   scale = 1
   reactants = 'N2O CO O2'
   reactant_stoich = '1 1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r18_rxn_N2O]
   type = InhibitedArrheniusReaction
   variable = N2O
   this_variable = N2O
   temperature = temp

    forward_pre_exponential = 1.308E20
    forward_activation_energy = 269500.3
   forward_inhibition = 1

   scale = -1.0
   reactants = 'HC NOx O2'
   reactant_stoich = '1 1 1'
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
 [./r8_rxn_NH3]
   type = InhibitedArrheniusReaction
   variable = NH3
   this_variable = NH3
   temperature = temp

    forward_pre_exponential = 2.29
    forward_activation_energy = 79150.6
    forward_inhibition = 1

   scale = -1.0
   reactants = 'CO NOx H2O'
   reactant_stoich = '1 1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r16_rxn_NH3]
   type = InhibitedArrheniusReaction
   variable = NH3
   this_variable = NH3
   temperature = temp

    forward_pre_exponential = 2.656E45
    forward_activation_energy = 560759.1
   forward_inhibition = 1

   scale = -1.0
   reactants = 'HC NOx O2'
   reactant_stoich = '1 1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r17_rxn_NH3]
   type = InhibitedArrheniusReaction
   variable = NH3
   this_variable = NH3
   temperature = temp

    forward_pre_exponential = 1.058E40
    forward_activation_energy = 580350.09
   forward_inhibition = 1

   scale = 2.0
   reactants = 'NH3 O2'
   reactant_stoich = '1 1'
   products = ''
   product_stoich = ''
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
        start_time = 120
        end_time = 5160
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
  end_time = 5160
  dtmax = 120

  [./TimeStepper]
     type = ConstantDT
     dt = 120
  [../]
[] #END Executioner

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
  interval = 1
[] #END Outputs


