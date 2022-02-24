[Mesh]
#Generate a 2D mesh to entire domain (block = 0)
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    xmax = 2
    ny = 10
    ymax = 2
  []
#Create a bounding box from the entire domain to span the new subdomain (block = 1)
  [./subdomain1]
    input = gen
    type = SubdomainBoundingBoxGenerator
    bottom_left = '0 0 0'
    top_right = '1 1 0'
    block_id = 1
  [../]
#Designate a new boundary as the side sets that are shared between block 0 and block 1
#   The new boundary is now labeled and can be used in boundary conditions or InterfaceKernels
  [./interface]
    type = SideSetsBetweenSubdomainsGenerator
    input = subdomain1
    primary_block = '0'
    paired_block = '1'
    new_boundary = 'master0_interface'
  [../]
#Break up the original boundaries (left right top bottom) to create separate boundaries for each subdomain
#new boundary names are (old_name)_to_(block_id)
# For example, two new left side boundary names:   left_to_0 and left_to_1
#       left_to_0 is the new left side bounary that is a part of block 0
  [./break_boundary]
    input = interface
    type = BreakBoundaryOnSubdomainGenerator
  [../]
[]

[Variables]
  [./u]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
    block = 0
  [../]

  [./v]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
    block = 1
  [../]
[]

[AuxVariables]
  [./km_flat_gas]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1
  [../]
  [./km_flat_fluid]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1
  [../]

  [./km_mono_gas]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1
  [../]
  [./km_mono_fluid]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1
  [../]

  [./km_sph_gas]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1
  [../]
  [./km_sph_fluid]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1
  [../]
[]

[Kernels]
  [./dot_u]
    type = TimeDerivative
    variable = u
    block = 0
  [../]
  [./diff_u]
    type = Diffusion
    variable = u
    block = 0
  [../]
  [./dot_v]
    type = TimeDerivative
    variable = v
    block = 1
  [../]
  [./diff_v]
    type = Diffusion
    variable = v
    block = 1
  [../]
[]

[AuxKernels]

    [./km_flat_gas_calc]
        type = SimpleGasFlatSurfaceMassTransCoef
        variable = km_flat_gas

        pressure = 101.35 #kPa
        pressure_unit = "kPa"

        temperature = 300 # K

        macro_porosity = 0.5
        characteristic_length = 0.05
        char_length_unit = "cm"

        velocity = 100
        vel_length_unit = "cm"
        vel_time_unit = "min"

        ref_diffusivity = 0.561
        diff_length_unit = "cm"
        diff_time_unit = "s"
        ref_diff_temp = 473

        output_length_unit = "cm"
        output_time_unit = "min"

        execute_on = 'initial timestep_end'
    [../]

    [./km_mono_gas_calc]
        type = SimpleGasMonolithMassTransCoef
        variable = km_mono_gas

        pressure = 101.35 #kPa
        pressure_unit = "kPa"

        temperature = 300 # K

        macro_porosity = 0.5
        characteristic_length = 0.05
        char_length_unit = "cm"

        velocity = 100
        vel_length_unit = "cm"
        vel_time_unit = "min"

        ref_diffusivity = 0.561
        diff_length_unit = "cm"
        diff_time_unit = "s"
        ref_diff_temp = 473

        output_length_unit = "cm"
        output_time_unit = "min"

        execute_on = 'initial timestep_end'
    [../]

    [./km_sph_gas_calc]
        type = SimpleGasSphericalMassTransCoef
        variable = km_sph_gas

        pressure = 101.35 #kPa
        pressure_unit = "kPa"

        temperature = 300 # K

        macro_porosity = 0.5
        characteristic_length = 0.05
        char_length_unit = "cm"

        velocity = 100
        vel_length_unit = "cm"
        vel_time_unit = "min"

        ref_diffusivity = 0.561
        diff_length_unit = "cm"
        diff_time_unit = "s"
        ref_diff_temp = 473

        output_length_unit = "cm"
        output_time_unit = "min"

        execute_on = 'initial timestep_end'
    [../]

    [./km_flat_fluid_calc]
        type = SimpleFluidFlatSurfaceMassTransCoef
        variable = km_flat_fluid

        pressure = 101.35 #kPa
        pressure_unit = "kPa"

        temperature = 300 # K

        macro_porosity = 0.5
        characteristic_length = 0.05
        char_length_unit = "cm"

        ux = 100
        uy = 0
        uz = 0
        vel_length_unit = "cm"
        vel_time_unit = "min"

        ref_diffusivity = 2.296E-5
        diff_length_unit = "cm"
        diff_time_unit = "s"
        ref_diff_temp = 298

        output_length_unit = "cm"
        output_time_unit = "min"

        execute_on = 'initial timestep_end'
    [../]

    [./km_mono_fluid_calc]
        type = SimpleFluidMonolithMassTransCoef
        variable = km_mono_fluid

        pressure = 101.35 #kPa
        pressure_unit = "kPa"

        temperature = 300 # K

        macro_porosity = 0.5
        characteristic_length = 0.05
        char_length_unit = "cm"

        ux = 100
        uy = 0
        uz = 0
        vel_length_unit = "cm"
        vel_time_unit = "min"

        ref_diffusivity = 2.296E-5
        diff_length_unit = "cm"
        diff_time_unit = "s"
        ref_diff_temp = 298

        output_length_unit = "cm"
        output_time_unit = "min"

        execute_on = 'initial timestep_end'
    [../]

    [./km_sph_fluid_calc]
        type = SimpleFluidSphericalMassTransCoef
        variable = km_sph_fluid

        pressure = 101.35 #kPa
        pressure_unit = "kPa"

        temperature = 300 # K

        macro_porosity = 0.5
        characteristic_length = 0.05
        char_length_unit = "cm"

        ux = 100
        uy = 0
        uz = 0
        vel_length_unit = "cm"
        vel_time_unit = "min"

        ref_diffusivity = 2.296E-5
        diff_length_unit = "cm"
        diff_time_unit = "s"
        ref_diff_temp = 298

        output_length_unit = "cm"
        output_time_unit = "min"

        execute_on = 'initial timestep_end'
    [../]
[]

#InterfaceKernels define how to communicate variables on different subdomains with each other
[InterfaceKernels]
  [./interface]
    type = InterfaceMassTransfer
    variable = u
    neighbor_var = v
    boundary = master0_interface
    transfer_rate = km_flat_fluid
    area_frac = 1
  [../]
[]

[BCs]
  [./v]
    type = DirichletBC
    variable = v
    boundary = 'left_to_1 bottom_to_1'
    value = 1
  [../]
[]

[Postprocessors]
  [./u_avg]
    type = ElementAverageValue
    variable = u
    block = 0
  [../]
  [./v_avg]
    type = ElementAverageValue
    variable = v
    block = 1
  [../]

  [./km_flat_gas]
    type = ElementAverageValue
    variable = km_flat_gas
  [../]

  [./km_flat_fluid]
    type = ElementAverageValue
    variable = km_flat_fluid
  [../]

  [./km_mono_gas]
    type = ElementAverageValue
    variable = km_mono_gas
  [../]

  [./km_mono_fluid]
    type = ElementAverageValue
    variable = km_mono_fluid
  [../]

  [./km_sph_gas]
    type = ElementAverageValue
    variable = km_sph_gas
  [../]

  [./km_sph_fluid]
    type = ElementAverageValue
    variable = km_sph_fluid
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = TRUE
  [../]
[]

[Executioner]
  type = Transient
  solve_type = 'pjfnk'

  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = ' lu       superlu_dist                '
  dt = 0.1
  num_steps = 10
  dtmin = 0.1
  line_search = none
[]

[Outputs]
  exodus = true
  print_linear_residuals = true
[]
