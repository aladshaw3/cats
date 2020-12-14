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
    initial_condition = 6500 #ppm
  [../]
 
  [./CO]
    order = FIRST
    family = MONOMIAL
    initial_condition = 5069 #ppm
  [../]
 
  [./H2]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1670 #ppm
  [../]
 
  [./HC]
    order = FIRST
    family = MONOMIAL
    initial_condition = 428.57 #ppm
  [../]
 
#NOTE: CANNOT name a variable 'NO' because MOOSE interprets this as instructions and not a name
  [./NOx]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1038 #ppm
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
 
#Coupled Inhibition terms
# ---------------- NOTE: May need to create a custom IC kernel for these -------------------
# ----------------- Current ICs are given based on approximate inlet conditions -------------
  [./R1]
    order = FIRST
    family = MONOMIAL
    initial_condition = 7089224
  [../]
 [./R1_COHC]
   order = FIRST
   family = MONOMIAL
   initial_condition = 4262
 [../]
 [./R1_NO]
   order = FIRST
   family = MONOMIAL
   initial_condition = 1663
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
    initial_condition = 134283 #ppm
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
    initial_condition = 1038 #ppm
  [../]
 
  [./NH3_in]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0 #ppm
  [../]
 
  [./HC_in]
    order = FIRST
    family = MONOMIAL
    initial_condition = 428.57 #ppm
  [../]
  
  [./CO_in]
    order = FIRST
    family = MONOMIAL
    initial_condition = 5069 #ppm
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

#forward_pre_exponential = 8.76E26
#forward_activation_energy = 301072.2
#forward_inhibition = 1
 
    forward_pre_exponential = 7.457E28
    forward_activation_energy = 277517.95
    forward_inhibition = R1

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

   forward_pre_exponential = 2.253
   forward_activation_energy = 34410.26
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

   forward_pre_exponential = 209.9159
   forward_activation_energy = 43202.27
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

   forward_pre_exponential = 0.06091
   forward_activation_energy = 65283.03
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

   forward_pre_exponential = 5917464
   forward_activation_energy = 117357
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

    forward_pre_exponential = 1778.56
    forward_activation_energy = 53689.3
    forward_inhibition = 1
 
    reverse_pre_exponential = 804615.7
    reverse_activation_energy = 65974.93
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

    forward_pre_exponential = 7.88E15
    forward_activation_energy = 204098.8
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

   forward_pre_exponential = 3.18E30
   forward_activation_energy = 339190.3
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

   forward_pre_exponential = 1.58E31
   forward_activation_energy = 395428.9
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

   forward_pre_exponential = 1.11E20
   forward_activation_energy = 280507.8
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

    forward_pre_exponential = 2.253
    forward_activation_energy = 34410.26
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

    forward_pre_exponential = 209.9159
    forward_activation_energy = 43202.27
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

    forward_pre_exponential = 0.06091
    forward_activation_energy = 65283.03
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

    forward_pre_exponential = 3.18E30
    forward_activation_energy = 339190.3
   forward_inhibition = 1

#NOTE:  ------------ MUST CHANGE SCALE FOR NOx:   (2x + (y/2) - z):   x=7, y=8, z=0 -----------------
#   ----------------------   scale depends on CxHyOz  for a given HC --------------------------------
   scale = 18.0
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

    forward_pre_exponential = 5917464
    forward_activation_energy = 117357
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

    forward_pre_exponential = 1.58E31
    forward_activation_energy = 395428.9
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

    forward_pre_exponential = 1.11E20
    forward_activation_energy = 280507.8
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

    forward_pre_exponential = 209.9159
    forward_activation_energy = 43202.27
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

    forward_pre_exponential = 5917464
    forward_activation_energy = 117357
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

    forward_pre_exponential = 1.11E20
    forward_activation_energy = 280507.8
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

    forward_pre_exponential = 0.06091
    forward_activation_energy = 65283.03
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

    forward_pre_exponential = 1.58E31
    forward_activation_energy = 395428.9
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

    forward_pre_exponential = 4.42E13
    forward_activation_energy = 224425.4
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
 
 
# ------------------ Start list of inhibition terms --------------------
 [./R1_COHC_eq]
   type = Reaction
   variable = R1_COHC
 [../]
 [./R1_COHC_lang]
   type = LangmuirInhibition
   variable = R1_COHC
   temperature = temp
   coupled_list = 'HC CO'
   pre_exponentials = '718.33 4.494E24'
   activation_energies = '13990.98 246998.65'
 [../]
 
 [./R1_NO_eq]
   type = Reaction
   variable = R1_NO
 [../]
 [./R1_NO_lang]
   type = LangmuirInhibition
   variable = R1_NO
   temperature = temp
   coupled_list = 'NOx'
   pre_exponentials = '6.34E-15'
   activation_energies = '-109334'
 [../]
 
 [./R1_eq]
   type = Reaction
   variable = R1
 [../]
 [./R1_lang]
   type = InhibitionProducts
   variable = R1
   coupled_list = 'R1_COHC R1_NO'
   power_list = '1 1'
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
 
# [./T_R1]
#     type = ElementAverageValue
#     variable = R1
#     execute_on = 'initial timestep_end'
# [../]
# [./T_R1_COHC]
#     type = ElementAverageValue
#     variable = R1_COHC
#     execute_on = 'initial timestep_end'
# [../]
# [./T_R1_NO]
#     type = ElementAverageValue
#     variable = R1_NO
#     execute_on = 'initial timestep_end'
# [../]
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


