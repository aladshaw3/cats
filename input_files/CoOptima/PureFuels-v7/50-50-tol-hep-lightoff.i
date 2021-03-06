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
    initial_condition = 6850 #ppm
  [../]
 
  [./CO]
    order = FIRST
    family = MONOMIAL
    initial_condition = 5372 #ppm
  [../]
 
  [./H2]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1670 #ppm
  [../]
 
  [./HC_heptane]
    order = FIRST
    family = MONOMIAL
    initial_condition = 214.285 #ppm
  [../]
 
  [./HC_toluene]
     order = FIRST
     family = MONOMIAL
     initial_condition = 214.285 #ppm
  [../]
 
#NOTE: CANNOT name a variable 'NO' because MOOSE interprets this as instructions and not a name
  [./NOx]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1052 #ppm
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
 [./R_NO]
   order = FIRST
   family = MONOMIAL
    [./InitialCondition]
        type = InitialLangmuirInhibition
        temperature = temp
        coupled_list = 'NOx'
        pre_exponentials = '7.6669E-8'
        activation_energies = '-33295.6'
    [../]
 [../]
 
 [./R1]
   order = FIRST
   family = MONOMIAL
    [./InitialCondition]
        type = InitialLangmuirInhibition
        temperature = temp
        coupled_list = 'HC_heptane HC_toluene CO'
        pre_exponentials = '0.008804 0.31953 3.5496E-8'
        activation_energies = '-13050 -21653 -42953'
    [../]
 [../]
 
[./R3]
  order = FIRST
  family = MONOMIAL
   [./InitialCondition]
       type = InitialLangmuirInhibition
       temperature = temp
       coupled_list = 'HC_heptane HC_toluene CO'
        pre_exponentials = '0.007233 0.0022018 3.5496E-8'
        activation_energies = '-8030 -12194 -42953'
   [../]
[../]
 
 [./R4]
   order = FIRST
   family = MONOMIAL
    [./InitialCondition]
        type = InitialInhibitionProducts
        coupled_list = 'R4_COHC R_NO'
        power_list = '1 1'
    [../]
 [../]
[./R4_COHC]
  order = FIRST
  family = MONOMIAL
    [./InitialCondition]
        type = InitialLangmuirInhibition
        temperature = temp
        coupled_list = 'HC_heptane HC_toluene CO'
        pre_exponentials = '0.0002270 0.00015947 3.5496E-8'
        activation_energies = '-25714 -35504 -42953'
    [../]
[../]
 
 [./R5]
   order = FIRST
   family = MONOMIAL
    [./InitialCondition]
        type = InitialInhibitionProducts
        coupled_list = 'R5_COHC R_NO'
        power_list = '1 1'
    [../]
 [../]
[./R5_COHC]
  order = FIRST
  family = MONOMIAL
    [./InitialCondition]
        type = InitialLangmuirInhibition
        temperature = temp
        coupled_list = 'HC_heptane HC_toluene CO'
        pre_exponentials = '0.003939 0.00121 3.5496E-8'
        activation_energies = '-19455 -21602 -42953'
    [../]
[../]
 
 [./R8]
   order = FIRST
   family = MONOMIAL
    [./InitialCondition]
        type = InitialInhibitionProducts
        coupled_list = 'R8_COHC R_NO'
        power_list = '1 1'
    [../]
 [../]
[./R8_COHC]
  order = FIRST
  family = MONOMIAL
    [./InitialCondition]
        type = InitialLangmuirInhibition
        temperature = temp
        coupled_list = 'HC_heptane HC_toluene CO'
        pre_exponentials = '5.25E-6 0.000355 3.5496E-8'
        activation_energies = '-56841 -42820 -42953'
    [../]
[../]
 
 [./R10]
   order = FIRST
   family = MONOMIAL
    [./InitialCondition]
        type = InitialInhibitionProducts
        coupled_list = 'R10_COHC R_NO'
        power_list = '1 1'
    [../]
 [../]
[./R10_COHC]
  order = FIRST
  family = MONOMIAL
    [./InitialCondition]
        type = InitialLangmuirInhibition
        temperature = temp
        coupled_list = 'HC_heptane HC_toluene CO'
        pre_exponentials = '0.008581 0.00104 3.5496E-8'
        activation_energies = '-10537 -16137 -42953'
    [../]
[../]
 
 [./R15]
   order = FIRST
   family = MONOMIAL
    [./InitialCondition]
        type = InitialInhibitionProducts
        coupled_list = 'R15_COHC R_NO'
        power_list = '1 1'
    [../]
 [../]
[./R15_COHC]
  order = FIRST
  family = MONOMIAL
    [./InitialCondition]
        type = InitialLangmuirInhibition
        temperature = temp
        coupled_list = 'HC_heptane HC_toluene CO'
        pre_exponentials = '6.87E-7 1.67E-7 3.5496E-8'
        activation_energies = '-79889 -79681 -42953'
    [../]
[../]
 
 [./R16]
   order = FIRST
   family = MONOMIAL
    [./InitialCondition]
        type = InitialInhibitionProducts
        coupled_list = 'R16_COHC R_NO'
        power_list = '1 1'
    [../]
 [../]
[./R16_COHC]
  order = FIRST
  family = MONOMIAL
    [./InitialCondition]
        type = InitialLangmuirInhibition
        temperature = temp
        coupled_list = 'HC_heptane HC_toluene CO'
        pre_exponentials = '0.01153 0.00599 3.5496E-8'
        activation_energies = '-2909 -4350 -42953'
    [../]
[../]
 
 [./R18]
   order = FIRST
   family = MONOMIAL
    [./InitialCondition]
        type = InitialInhibitionProducts
        coupled_list = 'R18_COHC R_NO'
        power_list = '1 1'
    [../]
 [../]
[./R18_COHC]
  order = FIRST
  family = MONOMIAL
    [./InitialCondition]
        type = InitialLangmuirInhibition
        temperature = temp
        coupled_list = 'HC_heptane HC_toluene CO'
        pre_exponentials = '0.00299 0.00368 3.5496E-8'
        activation_energies = '-13356 -3330 -42953'
    [../]
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
    initial_condition = 133926 #ppm
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
    initial_condition = 1052 #ppm
  [../]
 
  [./NH3_in]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0 #ppm
  [../]
 
  [./HC_heptane_in]
    order = FIRST
    family = MONOMIAL
    initial_condition = 214.285 #ppm
  [../]
 
  [./HC_toluene_in]
     order = FIRST
     family = MONOMIAL
     initial_condition = 214.285 #ppm
  [../]
  
  [./CO_in]
    order = FIRST
    family = MONOMIAL
    initial_condition = 5372 #ppm
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
 
    forward_pre_exponential = 1.1519
    forward_activation_energy = 5156
    forward_inhibition = R4

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
 
    forward_pre_exponential = 2.3487
    forward_activation_energy = 5668.9
    forward_inhibition = R5


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
 
    forward_pre_exponential = 7.132E-5
    forward_activation_energy = 3087.5
    forward_inhibition = R8

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
 
    forward_pre_exponential = 108.97
    forward_activation_energy = 31700.6
    forward_inhibition = R15

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

    forward_pre_exponential = 43777
    forward_activation_energy = 62427
    forward_inhibition = 1
 
    reverse_pre_exponential = 1.641E7
    reverse_activation_energy = 74018
    reverse_inhibition = 1

    scale = 1.0
    reactants = 'H2 O2'
    reactant_stoich = '1 1'
    products = 'H2O'
    product_stoich = '1'
  [../]
 
 
 
 
# Mass Balances
 [./HC_heptane_time]
    type = CoefTimeDerivative
    variable = HC_heptane
    Coefficient = 0.4945
  [../]
  [./HC_heptane_conv]
    type = ConstMassTransfer
    variable = HC_heptane
    coupled = HC_heptane_in
    transfer_rate = -12.454
  [../]
  [./r3_rxn_HC_heptane]
    type = InhibitedArrheniusReaction
    variable = HC_heptane
    this_variable = HC_heptane
    temperature = temp
 
    forward_pre_exponential = 4.68E9
    forward_activation_energy = 125544
    forward_inhibition = R3

    scale = 1.0
    reactants = 'HC_heptane O2'
    reactant_stoich = '1 1'
    products = ''
    product_stoich = ''
  [../]
 [./r10_rxn_HC_heptane]
   type = InhibitedArrheniusReaction
   variable = HC_heptane
   this_variable = HC_heptane
   temperature = temp

    forward_pre_exponential = 1.305E30
    forward_activation_energy = 357501
    forward_inhibition = R10
 
   scale = 1.0
   reactants = 'HC_heptane NOx'
   reactant_stoich = '1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r16_rxn_HC_heptane]
   type = InhibitedArrheniusReaction
   variable = HC_heptane
   this_variable = HC_heptane
   temperature = temp
 
    forward_pre_exponential = 3.432E28
    forward_activation_energy = 384372
    forward_inhibition = R16

   scale = 1.0
   reactants = 'HC_heptane NOx O2'
   reactant_stoich = '1 1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r18_rxn_HC_heptane]
   type = InhibitedArrheniusReaction
   variable = HC_heptane
   this_variable = HC_heptane
   temperature = temp
 
    forward_pre_exponential = 0.00151
    forward_activation_energy = 23309
    forward_inhibition = R18

   scale = 1.0
   reactants = 'HC_heptane NOx O2'
   reactant_stoich = '1 1 1'
   products = ''
   product_stoich = ''
 [../]
 
 
# Mass Balances
 [./HC_toluene_time]
    type = CoefTimeDerivative
    variable = HC_toluene
    Coefficient = 0.4945
  [../]
  [./HC_toluene_conv]
    type = ConstMassTransfer
    variable = HC_toluene
    coupled = HC_toluene_in
    transfer_rate = -12.454
  [../]
  [./r3_rxn_HC_toluene]
    type = InhibitedArrheniusReaction
    variable = HC_toluene
    this_variable = HC_toluene
    temperature = temp
 
    forward_pre_exponential = 1.0305E14
    forward_activation_energy = 174867
    forward_inhibition = R3

    scale = 1.0
    reactants = 'HC_toluene O2'
    reactant_stoich = '1 1'
    products = ''
    product_stoich = ''
  [../]
 [./r10_rxn_HC_toluene]
   type = InhibitedArrheniusReaction
   variable = HC_toluene
   this_variable = HC_toluene
   temperature = temp

    forward_pre_exponential = 1.691E28
    forward_activation_energy = 304020
    forward_inhibition = R10
 
   scale = 1.0
   reactants = 'HC_toluene NOx'
   reactant_stoich = '1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r16_rxn_HC_toluene]
   type = InhibitedArrheniusReaction
   variable = HC_toluene
   this_variable = HC_toluene
   temperature = temp
 
    forward_pre_exponential = 4.466E29
    forward_activation_energy = 375869
    forward_inhibition = R16

   scale = 1.0
   reactants = 'HC_toluene NOx O2'
   reactant_stoich = '1 1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r18_rxn_HC_toluene]
   type = InhibitedArrheniusReaction
   variable = HC_toluene
   this_variable = HC_toluene
   temperature = temp
 
    forward_pre_exponential = 3.921E18
    forward_activation_energy = 258462
    forward_inhibition = R18

   scale = 1.0
   reactants = 'HC_toluene NOx O2'
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
 
    forward_pre_exponential = 1.1519
    forward_activation_energy = 5156
    forward_inhibition = R4

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
 
    forward_pre_exponential = 2.3487
    forward_activation_energy = 5668.9
    forward_inhibition = R5

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
 
    forward_pre_exponential = 7.132E-5
    forward_activation_energy = 3087.5
    forward_inhibition = R8

   scale = 1.0
   reactants = 'CO NOx H2O'
   reactant_stoich = '1 1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r10_rxn_NO_ethanol]
   type = InhibitedArrheniusReaction
   variable = NOx
   this_variable = NOx
   temperature = temp
 
    forward_pre_exponential = 1.305E30
    forward_activation_energy = 357501
    forward_inhibition = R10

#NOTE:  ------------ MUST CHANGE SCALE FOR NOx:   (2x + (y/2) - z):   x=7, y=8, z=0 -----------------
#   ----------------------   scale depends on CxHyOz  for a given HC --------------------------------
   scale = 22.0
   reactants = 'HC_heptane NOx'
   reactant_stoich = '1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r10_rxn_NO_toluene]
   type = InhibitedArrheniusReaction
   variable = NOx
   this_variable = NOx
   temperature = temp
 
    forward_pre_exponential = 1.691E28
    forward_activation_energy = 304020
    forward_inhibition = R10

#NOTE:  ------------ MUST CHANGE SCALE FOR NOx:   (2x + (y/2) - z):   x=7, y=8, z=0 -----------------
#   ----------------------   scale depends on CxHyOz  for a given HC --------------------------------
   scale = 18.0
   reactants = 'HC_toluene NOx'
   reactant_stoich = '1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r15_rxn_NO]
   type = InhibitedArrheniusReaction
   variable = NOx
   this_variable = NOx
   temperature = temp
 
    forward_pre_exponential = 108.97
    forward_activation_energy = 31700.6
    forward_inhibition = R15

   scale = -2
   reactants = 'N2O CO O2'
   reactant_stoich = '1 1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r16_rxn_NO_ethanol]
   type = InhibitedArrheniusReaction
   variable = NOx
   this_variable = NOx
   temperature = temp
 
    forward_pre_exponential = 3.432E28
    forward_activation_energy = 384372
    forward_inhibition = R16

   scale = 1.0
   reactants = 'HC_heptane NOx O2'
   reactant_stoich = '1 1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r16_rxn_NO_toluene]
   type = InhibitedArrheniusReaction
   variable = NOx
   this_variable = NOx
   temperature = temp
 
    forward_pre_exponential = 4.466E29
    forward_activation_energy = 375869
    forward_inhibition = R16

   scale = 1.0
   reactants = 'HC_toluene NOx O2'
   reactant_stoich = '1 1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r18_rxn_NO_ethanol]
   type = InhibitedArrheniusReaction
   variable = NOx
   this_variable = NOx
   temperature = temp
 
    forward_pre_exponential = 0.00151
    forward_activation_energy = 23309
    forward_inhibition = R18

   scale = 2.0
   reactants = 'HC_heptane NOx O2'
   reactant_stoich = '1 1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r18_rxn_NO_toluene]
   type = InhibitedArrheniusReaction
   variable = NOx
   this_variable = NOx
   temperature = temp
 
    forward_pre_exponential = 3.921E18
    forward_activation_energy = 258462
    forward_inhibition = R18

   scale = 2.0
   reactants = 'HC_toluene NOx O2'
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
 
    forward_pre_exponential = 2.3487
    forward_activation_energy = 5668.9
    forward_inhibition = R5

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
 
    forward_pre_exponential = 108.97
    forward_activation_energy = 31700.6
    forward_inhibition = R15

   scale = 1
   reactants = 'N2O CO O2'
   reactant_stoich = '1 1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r18_rxn_N2O_ethanol]
   type = InhibitedArrheniusReaction
   variable = N2O
   this_variable = N2O
   temperature = temp
 
    forward_pre_exponential = 0.00151
    forward_activation_energy = 23309
    forward_inhibition = R18

   scale = -1.0
   reactants = 'HC_heptane NOx O2'
   reactant_stoich = '1 1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r18_rxn_N2O_toluene]
   type = InhibitedArrheniusReaction
   variable = N2O
   this_variable = N2O
   temperature = temp
 
    forward_pre_exponential = 3.921E18
    forward_activation_energy = 258462
    forward_inhibition = R18

   scale = -1.0
   reactants = 'HC_toluene NOx O2'
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
 
    forward_pre_exponential = 7.132E-5
    forward_activation_energy = 3087.5
    forward_inhibition = R8

   scale = -1.0
   reactants = 'CO NOx H2O'
   reactant_stoich = '1 1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r16_rxn_NH3_ethanol]
   type = InhibitedArrheniusReaction
   variable = NH3
   this_variable = NH3
   temperature = temp
 
    forward_pre_exponential = 3.432E28
    forward_activation_energy = 384372
    forward_inhibition = R16

   scale = -1.0
   reactants = 'HC_heptane NOx O2'
   reactant_stoich = '1 1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r16_rxn_NH3_toluene]
   type = InhibitedArrheniusReaction
   variable = NH3
   this_variable = NH3
   temperature = temp
 
    forward_pre_exponential = 4.466E29
    forward_activation_energy = 375869
    forward_inhibition = R16

   scale = -1.0
   reactants = 'HC_toluene NOx O2'
   reactant_stoich = '1 1 1'
   products = ''
   product_stoich = ''
 [../]
 [./r17_rxn_NH3]
   type = InhibitedArrheniusReaction
   variable = NH3
   this_variable = NH3
   temperature = temp
 
    forward_pre_exponential = 2.6414E16
    forward_activation_energy = 276665.1
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
# ============= NO Term =============
 [./R_NO_eq]
   type = Reaction
   variable = R_NO
 [../]
 [./R_NO_lang]
   type = LangmuirInhibition
   variable = R_NO
   temperature = temp
   coupled_list = 'NOx'
   pre_exponentials = '7.6669E-8'
   activation_energies = '-33295.6'
 [../]
 
# =========== Reaction 1 ==========
 [./R1_eq]
   type = Reaction
   variable = R1
 [../]
 [./R1_lang]
   type = LangmuirInhibition
   variable = R1
   temperature = temp
    coupled_list = 'HC_heptane HC_toluene CO'
    pre_exponentials = '0.008804 0.31953 3.5496E-8'
    activation_energies = '-13050 -21653 -42953'
 [../]
 
# =========== Reaction 3 ==========
 [./R3_eq]
   type = Reaction
   variable = R3
 [../]
 [./R3_lang]
   type = LangmuirInhibition
   variable = R3
   temperature = temp
    coupled_list = 'HC_heptane HC_toluene CO'
    pre_exponentials = '0.007233 0.0022018 3.5496E-8'
    activation_energies = '-8030 -12194 -42953'
 [../]
 
# =========== Reaction 4 ==========
 [./R4_COHC_eq]
   type = Reaction
   variable = R4_COHC
 [../]
 [./R4_COHC_lang]
   type = LangmuirInhibition
   variable = R4_COHC
   temperature = temp
    coupled_list = 'HC_heptane HC_toluene CO'
    pre_exponentials = '0.0002270 0.00015947 3.5496E-8'
    activation_energies = '-25714 -35504 -42953'
 [../]
 
 [./R4_eq]
   type = Reaction
   variable = R4
 [../]
 [./R4_lang]
   type = InhibitionProducts
   variable = R4
   coupled_list = 'R4_COHC R_NO'
   power_list = '1 1'
 [../]
 
# =========== Reaction 5 ==========
 [./R5_COHC_eq]
   type = Reaction
   variable = R5_COHC
 [../]
 [./R5_COHC_lang]
   type = LangmuirInhibition
   variable = R5_COHC
   temperature = temp
    coupled_list = 'HC_heptane HC_toluene CO'
    pre_exponentials = '0.003939 0.00121 3.5496E-8'
    activation_energies = '-19455 -21602 -42953'
 [../]
 
 [./R5_eq]
   type = Reaction
   variable = R5
 [../]
 [./R5_lang]
   type = InhibitionProducts
   variable = R5
   coupled_list = 'R5_COHC R_NO'
   power_list = '1 1'
 [../]
 
# =========== Reaction 8 ==========
 [./R8_COHC_eq]
   type = Reaction
   variable = R8_COHC
 [../]
 [./R8_COHC_lang]
   type = LangmuirInhibition
   variable = R8_COHC
   temperature = temp
    coupled_list = 'HC_heptane HC_toluene CO'
    pre_exponentials = '5.25E-6 0.000355 3.5496E-8'
    activation_energies = '-56841 -42820 -42953'
 [../]
 
 [./R8_eq]
   type = Reaction
   variable = R8
 [../]
 [./R8_lang]
   type = InhibitionProducts
   variable = R8
   coupled_list = 'R8_COHC R_NO'
   power_list = '1 1'
 [../]
 
# =========== Reaction 10 ==========
 [./R10_COHC_eq]
   type = Reaction
   variable = R10_COHC
 [../]
 [./R10_COHC_lang]
   type = LangmuirInhibition
   variable = R10_COHC
   temperature = temp
    coupled_list = 'HC_heptane HC_toluene CO'
    pre_exponentials = '0.008581 0.00104 3.5496E-8'
    activation_energies = '-10537 -16137 -42953'
 [../]
 
 [./R10_eq]
   type = Reaction
   variable = R10
 [../]
 [./R10_lang]
   type = InhibitionProducts
   variable = R10
   coupled_list = 'R10_COHC R_NO'
   power_list = '1 1'
 [../]
 
# =========== Reaction 15 ==========
 [./R15_COHC_eq]
   type = Reaction
   variable = R15_COHC
 [../]
 [./R15_COHC_lang]
   type = LangmuirInhibition
   variable = R15_COHC
   temperature = temp
    coupled_list = 'HC_heptane HC_toluene CO'
    pre_exponentials = '6.87E-7 1.67E-7 3.5496E-8'
    activation_energies = '-79889 -79681 -42953'
 [../]
 
 [./R15_eq]
   type = Reaction
   variable = R15
 [../]
 [./R15_lang]
   type = InhibitionProducts
   variable = R15
   coupled_list = 'R15_COHC R_NO'
   power_list = '1 1'
 [../]
 
# =========== Reaction 16 ==========
 [./R16_COHC_eq]
   type = Reaction
   variable = R16_COHC
 [../]
 [./R16_COHC_lang]
   type = LangmuirInhibition
   variable = R16_COHC
   temperature = temp
    coupled_list = 'HC_heptane HC_toluene CO'
    pre_exponentials = '0.01153 0.00599 3.5496E-8'
    activation_energies = '-2909 -4350 -42953'
 [../]
 
 [./R16_eq]
   type = Reaction
   variable = R16
 [../]
 [./R16_lang]
   type = InhibitionProducts
   variable = R16
   coupled_list = 'R16_COHC R_NO'
   power_list = '1 1'
 [../]
 
# =========== Reaction 18 ==========
 [./R18_COHC_eq]
   type = Reaction
   variable = R18_COHC
 [../]
 [./R18_COHC_lang]
   type = LangmuirInhibition
   variable = R18_COHC
   temperature = temp
    coupled_list = 'HC_heptane HC_toluene CO'
    pre_exponentials = '0.00299 0.00368 3.5496E-8'
    activation_energies = '-13356 -3330 -42953'
 [../]
 
 [./R18_eq]
   type = Reaction
   variable = R18
 [../]
 [./R18_lang]
   type = InhibitionProducts
   variable = R18
   coupled_list = 'R18_COHC R_NO'
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
    [./HC_heptane]
        type = ElementAverageValue
        variable = HC_heptane
        execute_on = 'initial timestep_end'
    [../]
    [./HC_toluene]
        type = ElementAverageValue
        variable = HC_toluene
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
  nl_abs_tol = 1e-7
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


