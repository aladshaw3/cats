## ======= NO Oxidation ======
    [./r5_val]
        type = Reaction
        variable = r5
    [../]
    [./r5_rx]
      type = ArrheniusReaction
      variable = r5
      this_variable = r5

      forward_activation_energy = 46077.62

      forward_pre_exponential = 8693470338.69636


      reverse_activation_energy = 85993.32

      reverse_pre_exponential = 21624646159.5736


      temperature = temp
      scale = 1.0
      reactants = 'S1 NOxw O2w'
      reactant_stoich = '1 1 1'
      products = 'S1 NO2w'
      product_stoich = '1 1'
    [../]

    [./r6_val]
        type = Reaction
        variable = r6
    [../]
    [./r6_rx]
      type = ArrheniusReaction
      variable = r6
      this_variable = r6

      forward_activation_energy = 41243.49

      forward_pre_exponential = 2930191759.3159


      reverse_activation_energy = 75883.94

      reverse_pre_exponential = 2668382121.73993


      temperature = temp
      scale = 1.0
      reactants = 'S2 NOxw O2w'
      reactant_stoich = '1 1 1'
      products = 'S2 NO2w'
      product_stoich = '1 1'
    [../]

## ======= NH3 Oxidation ======
    [./r7_val]
        type = Reaction
        variable = r7
    [../]
    [./r7_rx]
      type = ArrheniusReaction
      variable = r7
      this_variable = r7

      forward_activation_energy = 104631.97

      forward_pre_exponential = 75039256257.0974


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2a O2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r8_val]
        type = Reaction
        variable = r8
    [../]
    [./r8_rx]
      type = ArrheniusReaction
      variable = r8
      this_variable = r8

      forward_activation_energy = 101159.98

      forward_pre_exponential = 34648088533.0477


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2b O2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r9_val]
        type = Reaction
        variable = r9
    [../]
    [./r9_rx]
      type = ArrheniusReaction
      variable = r9
      this_variable = r9

      forward_activation_energy = 87826.79

      forward_pre_exponential = 2140619788.0508


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3 O2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= NH3 Partial Oxidation ======
    [./r10_val]
        type = Reaction
        variable = r10
    [../]
    [./r10_rx]
      type = ArrheniusReaction
      variable = r10
      this_variable = r10

      forward_activation_energy = 264372.573707305

      forward_pre_exponential = 3.00708980881736E+021


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2a O2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r11_val]
        type = Reaction
        variable = r11
    [../]
    [./r11_rx]
      type = ArrheniusReaction
      variable = r11
      this_variable = r11

      forward_activation_energy = 266700.909300748

      forward_pre_exponential = 5.00241449799262E+021


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2b O2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r12_val]
        type = Reaction
        variable = r12
    [../]
    [./r12_rx]
      type = ArrheniusReaction
      variable = r12
      this_variable = r12

      forward_activation_energy = 262542.766347393

      forward_pre_exponential = 1.73648545789896E+021


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3 O2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= NO SCR ======
    [./r13_val]
        type = Reaction
        variable = r13
    [../]
    [./r13_rx]
      type = ArrheniusReaction
      variable = r13
      this_variable = r13

      forward_activation_energy = 61217.0869171797

      forward_pre_exponential = 158934896906195


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q1 NOxw O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r14_val]
        type = Reaction
        variable = r14
    [../]
    [./r14_rx]
      type = ArrheniusReaction
      variable = r14
      this_variable = r14

      forward_activation_energy = 63945.5969171797

      forward_pre_exponential = 276342772543379


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2a NOxw O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r15_val]
        type = Reaction
        variable = r15
    [../]
    [./r15_rx]
      type = ArrheniusReaction
      variable = r15
      this_variable = r15

      forward_activation_energy = 61752.5369171797

      forward_pre_exponential = 196507053031761


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2b NOxw O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r16_val]
        type = Reaction
        variable = r16
    [../]
    [./r16_rx]
      type = ArrheniusReaction
      variable = r16
      this_variable = r16

      forward_activation_energy = 66563.6369171797

      forward_pre_exponential = 5793591205044520


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3 NOxw O2w S1'
      reactant_stoich = '1 1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r17_val]
        type = Reaction
        variable = r17
    [../]
    [./r17_rx]
      type = ArrheniusReaction
      variable = r17
      this_variable = r17

      forward_activation_energy = 48581.6669171797

      forward_pre_exponential = 307766200223700


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3 NOxw O2w S2'
      reactant_stoich = '1 1 1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= N2O from NO SCR ======
    [./r18_val]
        type = Reaction
        variable = r18
    [../]
    [./r18_rx]
      type = ArrheniusReaction
      variable = r18
      this_variable = r18

      forward_activation_energy = 59874.3469171797

      forward_pre_exponential = 2195592975649.08


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2a NOxw O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r19_val]
        type = Reaction
        variable = r19
    [../]
    [./r19_rx]
      type = ArrheniusReaction
      variable = r19
      this_variable = r19

      forward_activation_energy = 50337.6569171797

      forward_pre_exponential = 319376073732.502


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2b NOxw O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r20_val]
        type = Reaction
        variable = r20
    [../]
    [./r20_rx]
      type = ArrheniusReaction
      variable = r20
      this_variable = r20

      forward_activation_energy = 47437.3769171797

      forward_pre_exponential = 6698742339169.11


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3 NOxw O2w S2'
      reactant_stoich = '1 1 1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= NH4NO3 Formation ======
    [./r21_val]
        type = Reaction
        variable = r21
    [../]
    [./r21_rx]
      type = ArrheniusReaction
      variable = r21
      this_variable = r21

      forward_activation_energy = 76839.8477897607

      forward_pre_exponential = 17236611765968.6


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q1 NO2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r22_val]
        type = Reaction
        variable = r22
    [../]
    [./r22_rx]
      type = ArrheniusReaction
      variable = r22
      this_variable = r22

      forward_activation_energy = 55024.8277897608

      forward_pre_exponential = 182324247622.474


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2a NO2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r23_val]
        type = Reaction
        variable = r23
    [../]
    [./r23_rx]
      type = ArrheniusReaction
      variable = r23
      this_variable = r23

      forward_activation_energy = 79750.6177897608

      forward_pre_exponential = 19655425647510.6


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2b NO2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r24_val]
        type = Reaction
        variable = r24
    [../]
    [./r24_rx]
      type = ArrheniusReaction
      variable = r24
      this_variable = r24

      forward_activation_energy = 75152.1977897607

      forward_pre_exponential = 11946993616865


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3 NO2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= NH4NO3 Fast SCR ======
    [./r25_val]
        type = Reaction
        variable = r25
    [../]
    [./r25_rx]
      type = ArrheniusReaction
      variable = r25
      this_variable = r25

      forward_activation_energy = 54890.4477897607

      forward_pre_exponential = 283874273512.345


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q1_NH4NO3 NOxw'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r26_val]
        type = Reaction
        variable = r26
    [../]
    [./r26_rx]
      type = ArrheniusReaction
      variable = r26
      this_variable = r26

      forward_activation_energy = 51030.8677897607

      forward_pre_exponential = 107108380593.753


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2_NH4NO3 NOxw'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r27_val]
        type = Reaction
        variable = r27
    [../]
    [./r27_rx]
      type = ArrheniusReaction
      variable = r27
      this_variable = r27

      forward_activation_energy = 41074.2677897607

      forward_pre_exponential = 12198562400.3861


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3_NH4NO3 NOxw'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= NH4NO3 NO2 SCR ======
    [./r28_val]
        type = Reaction
        variable = r28
    [../]
    [./r28_rx]
      type = ArrheniusReaction
      variable = r28
      this_variable = r28

      forward_activation_energy = 58710.4677897607

      forward_pre_exponential = 3561290756.88185


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q1_NH4NO3'
      reactant_stoich = '1'
      products = ''
      product_stoich = ''
    [../]

    [./r29_val]
        type = Reaction
        variable = r29
    [../]
    [./r29_rx]
      type = ArrheniusReaction
      variable = r29
      this_variable = r29

      forward_activation_energy = 72184.2477897607

      forward_pre_exponential = 58610961120.4933


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2_NH4NO3'
      reactant_stoich = '1'
      products = ''
      product_stoich = ''
    [../]

    [./r30_val]
        type = Reaction
        variable = r30
    [../]
    [./r30_rx]
      type = ArrheniusReaction
      variable = r30
      this_variable = r30

      forward_activation_energy = 57621.8277897607

      forward_pre_exponential = 2870523294.82377


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3_NH4NO3'
      reactant_stoich = '1'
      products = ''
      product_stoich = ''
    [../]

## ======= NH4NO3 N2O Formation ======
    [./r31_val]
        type = Reaction
        variable = r31
    [../]
    [./r31_rx]
      type = ArrheniusReaction
      variable = r31
      this_variable = r31

      forward_activation_energy = 94874.7977897607

      forward_pre_exponential = 387267055622.786


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q1_NH4NO3'
      reactant_stoich = '1'
      products = ''
      product_stoich = ''
    [../]

    [./r32_val]
        type = Reaction
        variable = r32
    [../]
    [./r32_rx]
      type = ArrheniusReaction
      variable = r32
      this_variable = r32

      forward_activation_energy = 85500.2977897608

      forward_pre_exponential = 68011465102.089


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2_NH4NO3'
      reactant_stoich = '1'
      products = ''
      product_stoich = ''
    [../]

    [./r33_val]
        type = Reaction
        variable = r33
    [../]
    [./r33_rx]
      type = ArrheniusReaction
      variable = r33
      this_variable = r33

      forward_activation_energy = 55310.7177897607

      forward_pre_exponential = 136670657.9473


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3_NH4NO3'
      reactant_stoich = '1'
      products = ''
      product_stoich = ''
    [../]

## ======= CuO Facilitated NH3 Oxidation ======
    [./r34_val]
        type = Reaction
        variable = r34
    [../]
    [./r34_rx]
      type = ArrheniusReaction
      variable = r34
      this_variable = r34

      forward_activation_energy = 337783.27

      forward_pre_exponential = 2.84E+29


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3 CuO O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r35_val]
        type = Reaction
        variable = r35
    [../]
    [./r35_rx]
      type = ArrheniusReaction
      variable = r35
      this_variable = r35

      forward_activation_energy = 161014.79

      forward_pre_exponential = 3654870966252980


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3 CuO O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r36_val]
        type = Reaction
        variable = r36
    [../]
    [./r36_rx]
      type = ArrheniusReaction
      variable = r36
      this_variable = r36

      forward_activation_energy = 180163.64

      forward_pre_exponential = 4.69E+16


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3 CuO O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= N2O Formation from  NH3 Oxidation ======
    [./r37_val]
        type = Reaction
        variable = r37
    [../]
    [./r37_rx]
      type = ArrheniusReaction
      variable = r37
      this_variable = r37

      forward_activation_energy = 288305.85

      forward_pre_exponential = 6.62239E+21


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2a O2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]


    [./r38_val]
        type = Reaction
        variable = r38
    [../]
    [./r38_rx]
      type = ArrheniusReaction
      variable = r38
      this_variable = r38

      forward_activation_energy = 290624.89

      forward_pre_exponential = 1.04801E+22


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2b O2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]


    [./r39_val]
        type = Reaction
        variable = r39
    [../]
    [./r39_rx]
      type = ArrheniusReaction
      variable = r39
      this_variable = r39

      forward_activation_energy = 285451.76

      forward_pre_exponential = 3.23131E+21


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3 O2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]
