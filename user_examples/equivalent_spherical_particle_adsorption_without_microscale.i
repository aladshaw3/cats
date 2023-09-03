
# This example demonstrates how to create simulations of a packed-bed
#   including without needing the microscale. In other words, we will
#   just use mass-transfer and average interior particle concentration.

[GlobalParams]
  # 'dg_scheme' and 'sigma' are parameters for the DG kernels
  dg_scheme = nipg
  sigma = 10

[] #END GlobalParams

[Mesh]
    type = GeneratedMesh
	coord_type = RZ
    #NOTE: For RZ coordinates, x ==> R and y ==> Z (and z ==> nothing)
    dim = 2
    nx = 3
    ny = 10
    xmin = 0.0
    xmax = 1.0    #2cm diameter (1cm radius)
    ymin = 0.0
    ymax = 5.0    #5cm length
[] # END Mesh

[Variables]

## Gas phase variable lists (mol/L unit basis)
    [./H2O]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    # Interior particle concentration
    [./H2Op]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    # Average adsorption
    [./q]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    # Free sites
    [./S]
        order = FIRST
        family = MONOMIAL
        initial_condition = 11.7
    [../]

    ## Reaction variable list
    # 5 interior nodes inside the particle
    [./r]
        order = FIRST
        family = MONOMIAL
    [../]

[] #END Variables

# Here we are adding aux variables where some calculations
#   for system parameters and properties will be made.
[AuxVariables]

  [./temp]
      order = FIRST
      family = MONOMIAL
      initial_condition = 298  # in K
  [../]

  [./press]
      order = FIRST
      family = MONOMIAL
      initial_condition = 101.35  # in kPa
  [../]

  # dispersion coefficient - calculated in properties
  [./Disp]
    order = FIRST
    family = MONOMIAL
  [../]

  # e_b (bulk porosity) - calculated in properties
  [./pore]
      order = FIRST
      family = MONOMIAL
  [../]

  # non_pore = (1 - e_b) - calculated in properties
  [./non_pore]
      order = FIRST
      family = MONOMIAL
  [../]

  # e_p value (particle porosity)
  [./micro_pore]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.4
  [../]

  # total_pore = e_p* (1 - e_b) - auto calculated in properties
  [./total_pore]
      order = FIRST
      family = MONOMIAL
  [../]

  # area to volume ratio for spherical particles - calculated in properties
  [./Ga]
      order = FIRST
      family = MONOMIAL
  [../]

  # hydraulic diameter for spherical particles
  [./dh]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.12  # in cm
  [../]

  # Mass transfer coefficient - calculated in properties
  [./km]
      order = FIRST
      family = MONOMIAL
  [../]

  # Effective pore diffusion - calculated in properties
  #   This is pore diffusivity as Deff = e_p*(1-e_b)*Dp
  [./Deff]
      order = FIRST
      family = MONOMIAL
  [../]

  # We are assuming an average linear velocity in the axial
  #   direction, so other velocities are set to 0
  [./vel_x]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

  # Effective average linear velocity is calculated from the
  #   reactor size and the gas-hourly space-velocity (which here
  #   is given in per minutes instead of per hour).
  [./vel_y]
      order = FIRST
      family = MONOMIAL
  [../]

  # We are assuming an average linear velocity in the axial
  #   direction, so other velocities are set to 0
  [./vel_z]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

[] #END AuxVariables

[Kernels]
# ------------------- Start Gas Balances ----------------------
# -------------------------------------------------------------
    # =============== Bulk phase H2O ===============
    [./H2O_dot]
        type = VariableCoefTimeDerivative
        variable = H2O
        coupled_coef = pore
    [../]
    [./H2O_gadv]
        type = GPoreConcAdvection
        variable = H2O
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./H2O_gdiff]
        type = GVarPoreDiffusion
        variable = H2O
        porosity = pore
        Dx = Disp
        Dy = Disp
        Dz = Disp
    [../]
    [./H2Op_trans]
        type = FilmMassTransfer
        variable = H2O
        coupled = H2Op

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]

    # =============== Particle pore phase H2O ===============
    [./H2Op_dot]
        type = VariableCoefTimeDerivative
        variable = H2Op
        coupled_coef = total_pore
    [../]
    [./H2O_trans]
        type = FilmMassTransfer
        variable = H2Op
        coupled = H2O

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]
    [./H2Op_rxns]
        type = ScaledWeightedCoupledSumFunction
        variable = H2Op
        coupled_list = 'r'
        # Reaction: H2O + S <--> q
        #   Every time this occurs, 1 mole of H2O is removed
        #   Thus, the 'weight' for r is -1.
        weights = '-1'
        scale = 1
    [../]

# ------------------- Start Reactions ----------------------
# -------------------------------------------------------------

## ======= H2O adsorption rates ======
#   NOTE: The units on the forward_pre_exponential term
#         are whatever units that make the full model work
#         out. Since r needs units of mol/L/min, and H2O is
#         in mol/L and S is in mol/kg, then this pre_exponential
#         term must have units of kg/mol/min.
#
#   If you want your material balance to be on a different unit
#       basis, then that changes what units your pre_exponential
#       ends up as. If you have existing pre_exponentials in a
#       given unit set, then you need to first perform a unit
#       conversion, or change how your overall mass balance is
#       setup.

    # Reaction: H2O + S <--> q
    [./r_val]
        type = Reaction
        variable = r
    [../]
    [./r_rx]
      type = ArrheniusEquilibriumReaction
      variable = r
      this_variable = r

      forward_activation_energy = 0      #J/mol
      forward_pre_exponential = 2500  #kg/mol/min
      enthalpy = -32000  #J/mol
      entropy = -25      #J/K/mol

      temperature = temp
      scale = 1.0
      reactants = 'H2Op S'
      reactant_stoich = '1 1'
      products = 'q'
      product_stoich = '1'
    [../]

# ------------------- ODEs for Sites and Surface Species ----------------------
# -----------------------------------------------------------------------------
# Our adsorbed amount (q) and remaining surface species (S) can be resolved
#   using ODEs that represent their rates of change.
#
# # Reaction: H2O + S <--> q
#
#   dq/dt = r   && dS/dt = -r
#
#     (i.e., everytime the reaction occurs, we form 1 mole of q
#           and consume 1 mole of S).
#     We can use the WeightedCoupledSumFunction to represent
#       each as a weighted sum of r terms at every node in the microscale.

    # ODEs for q
    [./q_dot]
        type = TimeDerivative
        variable = q
    [../]
    [./q_rate]
        type = WeightedCoupledSumFunction
        variable = q
        coupled_list = 'r'
        weights = '1'
    [../]

    # ODEs for S
    [./S_dot]
        type = TimeDerivative
        variable = S
    [../]
    [./S_rate]
        type = WeightedCoupledSumFunction
        variable = S
        coupled_list = 'r'
        weights = '-1'
    [../]

[] #END Kernels


[DGKernels]

    # =========== H2O DG kernels ===========
    [./H2O_dgadv]
        type = DGPoreConcAdvection
        variable = H2O
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./H2O_dgdiff]
        type = DGVarPoreDiffusion
        variable = H2O
        porosity = pore
        Dx = Disp
        Dy = Disp
        Dz = Disp
    [../]

[] #END DGKernels

# The AuxKernels are where all the properties are calculated that
#   get used in the other kernels above.
[AuxKernels]

    # The system is assumed isothermal, but after we adsorb water,
    #   we are going to raise the temperature to perform a Temperature
    #   Programmed Desorption (TPD). To simulate this, we can use
    #   the following aux kernel to linearly raise the temperature
    #   at a specified start and end time up to a specified level.
    [./temp_increase]
        type = LinearChangeInTime
        variable = temp
        start_time = 350   # time at which we start ramping (in min)
        end_time = 850    # time at which we reach 500 K (in min)
        end_value = 500   # final temp in K
        execute_on = 'initial timestep_end'
    [../]

    # If we do not know our fixed-bed porosity, we can estimate this
    #   value from our average particle size, the average mass of a
    #   particle, and the bulk packing density of the bed. This kernel
    #   will also check your estimated porosity and report a warning
    #   if the value calculated is unreasonable and automatically revert
    #   to a theoretical max or min value. This reversion of the value
    #   to a max or min can be overriden. Pay close attention to any
    #   messages that this kernel prints.
    [./pore_calc]
        type = VoidsVolumeFraction
        variable = pore
        particle_diameter = 0.12    #cm
        particle_mass = 0.0015      #g
        packing_density = 0.8       #g/cm^3
        execute_on = 'initial timestep_end'
    [../]

    # There are other ways to calculate average linear velocity, but
    #   in this demo, we will calculate it using the 'space_velocity'
    #   parameter, which is the standard volume of gas per material
    #   volume per unit time. Then, the velocity is also adjusted
    #   to match an equivalent volume of gas at the specified
    #   temperature and pressure.
    #
    # NOTE: This is most commonly used in catalysis, where it is
    #   volumes of material per hour. In the case of fixed-beds,
    #   it may make more sense to calculate this using the AuxAvgLinearVelocity
    #   auxiliary kernel, where you provide a true volumetric flow rate, reactor
    #   size, and porosity. However, that kernel does not currently update with
    #   temperature.
    [./velocity]
        # NOTE: velocity must use same shape function type as
        #     all other variables.
        type = GasVelocityCylindricalReactor
        variable = vel_y
        # 'space_velocity' is volume of gas per volumes of solids per time
        porosity = pore
        space_velocity = 50   # volumes of gas per volume of solids per min
        inlet_temperature = temp
        ref_pressure = 101.35
        ref_temperature = 273.15
        radius = 1  #cm
        length = 5  #cm
        execute_on = 'initial timestep_end'
    [../]

    [./Ga_calc]
        type = SphericalAreaVolumeRatio
        variable = Ga
        particle_diameter = 0.12 #in cm
        porosity = pore
        per_solids_volume = true
        execute_on = 'initial timestep_end'
    [../]

    [./non_pore_calc]
        type = SolidsVolumeFraction
        variable = non_pore
        porosity = pore
        execute_on = 'initial timestep_end'
    [../]

    [./total_pore_calc]
        type = MicroscalePoreVolumePerTotalVolume
        variable = total_pore
        porosity = pore
        microscale_porosity = micro_pore
        execute_on = 'initial timestep_end'
    [../]

    [./km_calc]
        type = SimpleGasSphericalMassTransCoef
        variable = km

        pressure = press
        temperature = temp
        micro_porosity = micro_pore
        macro_porosity = pore

        # characteristic_length is particle diameter for this case
        characteristic_length = dh
        char_length_unit = "cm"

        velocity = vel_y
        vel_length_unit = "cm"
        vel_time_unit = "min"

        # molecular diffusivity of H2O in air
        #   at a reference temperature of 20 C (293 K)
        # Often these values can be looked up in data tables
        ref_diffusivity = 0.242
        diff_length_unit = "cm"
        diff_time_unit = "s"
        ref_diff_temp = 293

        # Our model uses 'cm' as the base length
        #   and 'min' as the base time, so these args
        #   will ensure we get those units for km
        output_length_unit = "cm"
        output_time_unit = "min"

        execute_on = 'initial timestep_end'
    [../]

    [./Deff_calc]
        type = SimpleGasEffectivePoreDiffusivity
        variable = Deff

        pressure = press
        temperature = temp
        micro_porosity = micro_pore
        macro_porosity = pore
        characteristic_length = dh
        char_length_unit = "cm"

        velocity = vel_y
        vel_length_unit = "cm"
        vel_time_unit = "min"

        # molecular diffusivity of H2O in air
        #   at a reference temperature of 20 C (293 K)
        # Often these values can be looked up in data tables
        ref_diffusivity = 0.242
        diff_length_unit = "cm"
        diff_time_unit = "s"
        ref_diff_temp = 293

        output_length_unit = "cm"
        output_time_unit = "min"
        # NOTE: Because we are using this inside
        #     our Microscale kernels, we actually DO NOT
        #     want this on the per solids volume basis.
        #     This is because we want this to lump everything
        #     into a single term, instead of adding additional
        #     conversion terms (as we did with the FilmMassTransfer
        #     kernel).
        per_solids_volume = false

        execute_on = 'initial timestep_end'
    [../]

    [./Disp_calc]
        type = SimpleGasDispersion
        variable = Disp

        pressure = press
        temperature = temp
        micro_porosity = micro_pore
        macro_porosity = pore

        # NOTE: For this calculation, use bed diameter as char_length
        characteristic_length = 2
        char_length_unit = "cm"

        velocity = vel_y
        vel_length_unit = "cm"
        vel_time_unit = "min"

        # molecular diffusivity of H2O in air
        #   at a reference temperature of 20 C (293 K)
        # Often these values can be looked up in data tables
        ref_diffusivity = 0.242
        diff_length_unit = "cm"
        diff_time_unit = "s"
        ref_diff_temp = 293

        output_length_unit = "cm"
        output_time_unit = "min"

        execute_on = 'initial timestep_end'
    [../]

[] #END AuxKernels

[BCs]
    # NOTE: Here we are using a stepwise inlet
    #       for BCs to represent switching of
    #       a valve from off, to on, to off again.
    # ============== H2O BCs ================
    [./H2O_FluxIn]
      type = DGPoreConcFluxStepwiseBC
      variable = H2O
      boundary = 'bottom'   #bottom boundary is the feed side
      u_input = 1E-15       #initial inlet value
      porosity = pore
      ux = vel_x
      uy = vel_y
      uz = vel_z
      # At time 0, there is no H2O flowing, then at 5 min, a valve is
      #   opened and we start flowing H2O. At 50 min, the valve is shut off.
      input_vals = '0.001    1e-15'
      input_times = '5    350'
      # Time spans are the time it takes to reach a specific inlet value
      #   based on valve delays. It also smooths the inlet term to stabilize
      #   the FE methods.
      time_spans = '0.25    0.25'
    [../]
    [./H2O_FluxOut]
      type = DGPoreConcFluxBC
      variable = H2O
      boundary = 'top'    #top boundary is the exit side
      porosity = pore
      ux = vel_x
      uy = vel_y
      uz = vel_z
    [../]

[] #END BCs

[Postprocessors]

    [./H2O_out]
        type = SideAverageValue
        boundary = 'top'
        variable = H2O
        execute_on = 'initial timestep_end'
    [../]

    [./H2O_bypass]
        type = SideAverageValue
        boundary = 'bottom'
        variable = H2O
        execute_on = 'initial timestep_end'
    [../]

    [./temp_avg]
        type = ElementAverageValue
        variable = temp
        execute_on = 'initial timestep_end'
    [../]

    [./q_avg]
        type = ElementAverageValue
        variable = q
        execute_on = 'initial timestep_end'
    [../]

    [./S_avg]
        type = ElementAverageValue
        variable = S
        execute_on = 'initial timestep_end'
    [../]

    [./H2Op_avg]
        type = ElementAverageValue
        variable = H2Op
        execute_on = 'initial timestep_end'
    [../]

    # In addition to outputting our model simulated results
    #   to the csv file. Here, we can also output all of the
    #   values that were automatically calculated by the auxilary
    #   kernel system. This is useful for picking out the
    #   MonolithMicroscaleTotalThickness value, as well as
    #   checking the calculated values used in the model.
    [./vel_in]
        type = SideAverageValue
        boundary = 'bottom'
        variable = vel_y
        execute_on = 'initial timestep_end'
    [../]

    [./Ga]
        type = ElementAverageValue
        variable = Ga
        execute_on = 'initial timestep_end'
    [../]

    [./non_pore]
        type = ElementAverageValue
        variable = non_pore
        execute_on = 'initial timestep_end'
    [../]

    [./pore]
        type = ElementAverageValue
        variable = pore
        execute_on = 'initial timestep_end'
    [../]

    [./total_pore]
        type = ElementAverageValue
        variable = total_pore
        execute_on = 'initial timestep_end'
    [../]

    [./km]
        type = ElementAverageValue
        variable = km
        execute_on = 'initial timestep_end'
    [../]

    [./Deff]
        type = ElementAverageValue
        variable = Deff
        execute_on = 'initial timestep_end'
    [../]

    [./Disp]
        type = ElementAverageValue
        variable = Disp
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
  type = Transient
  scheme = implicit-euler
  petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -pc_type -sub_pc_type -snes_max_it -sub_pc_factor_shift_type -pc_asm_overlap -snes_atol -snes_rtol'
  petsc_options_value = 'gmres lu ilu 100 NONZERO 2 1E-14 1E-12'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = bt
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-4
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0
  end_time = 850.0
  dtmax = 2.5

  [./TimeStepper]
     type = ConstantDT
     dt = 2.5
  [../]
[] #END Executioner

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
[] #END Outputs
