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

      forward_activation_energy = 662745.3031230762

      forward_pre_exponential = 199845586597176


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

      forward_activation_energy = 65473.8131230762

      forward_pre_exponential = 347474875284415


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

      forward_activation_energy = 63280.7531230762

      forward_pre_exponential = 247089015993715


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

      forward_activation_energy = 68091.8531230762

      forward_pre_exponential = 7284892464867087


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

      forward_activation_energy = 50109.8831230762

      forward_pre_exponential = 386986860757146


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

      forward_activation_energy = 61402.5631230762

      forward_pre_exponential = 2760750311532.9


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

      forward_activation_energy = 51865.8731230762

      forward_pre_exponential = 401585177595.36


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

      forward_activation_energy = 48965.5931230762

      forward_pre_exponential = 8423034325964.93


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

      forward_activation_energy = 80131.8431230762

      forward_pre_exponential = 28656926258318.3


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

      forward_activation_energy = 58316.8231230762

      forward_pre_exponential = 303125265577.796


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

      forward_activation_energy = 83042.6131230762

      forward_pre_exponential = 32678352973561.6


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

      forward_activation_energy = 78444.1931230762

      forward_pre_exponential = 19862611036065.2


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

      forward_activation_energy = 58182.4431230762

      forward_pre_exponential = 471958423913.589


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

      forward_activation_energy = 54322.8631230762

      forward_pre_exponential = 178074264594.344


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

      forward_activation_energy = 44366.2631230762

      forward_pre_exponential = 20280859597.6818


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

      forward_activation_energy = 62002.4631230762

      forward_pre_exponential = 5920864726.20386


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

      forward_activation_energy = 75476.2431230762

      forward_pre_exponential = 97444324532.2322


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

      forward_activation_energy = 60913.8231230762

      forward_pre_exponential = 4772421372.56709


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

      forward_activation_energy = 98166.7931230762

      forward_pre_exponential = 643855277704.263


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

      forward_activation_energy = 88792.2931230762

      forward_pre_exponential = 113073240066.752


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

      forward_activation_energy = 58602.7131230762

      forward_pre_exponential = 227223367.309598


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
