/*!
 *  \file SimpleFluidPropertiesBase.h
 *    \brief AuxKernel kernel base to aid in simple fluid properties calculations
 *    \details This file is responsible for setting up and storing information
 *              associated with the simplified calculation of system properties.
 *              Calculations here are based mostly off of emperical relationships
 *              in literature and correlations with common data associated with
 *              fluids. By default, the calculations focus on properties of water
 *              and brine or electrolyte solutions where water is the primary
 *              solvent in the system. However, the methods are generic enough
 *              to apply to other fluids as long as you have the right coefficients.
 *
 *    \note These calculations should be good between 0 to 350 oC
 *
 *              Viscosity Calculations:
 *              -----------------------
 *              [1] D.S. Viswananth, G. Natarajan. Data Book on the Viscosity of
 *                  Liquids. Hemisphere Publishing Corp. (1989)
 *              [2] D.S. Viswananth, S. Dabir, et al. Viscosity of Liquids: Theory,
 *                  Estimation, Experiment, and Data. Springer. (2007)
 *
 *              Density and Diffusivity Calculations:
 *              ------------------------------------
 *              [1] Engineering Toolbox. Water - Density, Specific Weight, and
 *                  Thermal Expansion Coefficients. (2003) https://www.engineeringtoolbox.com/
 *                  water-density-specific-weight-d_595.html [Accessed 13-12-2021]
 *              [2] A.J. Easteal, W.E. Price, L.A. Woolf. Diaphragm cell for high-temperature
 *                  diffusion measurements. J. Chem. Soc.: Faraday Trans. 85 (1989) 1091-1097.
 *
 *              Dispersion Calculations:
 *              ------------------------
 *              [1] A. Freeze and J. Cherry. Groundwater. Prentice-Hall, NJ. (1979). Ch. 9.
 *
 *
 *  \author Austin Ladshaw
 *  \date 12/13/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "SimpleFluidPropertiesBase.h"

registerMooseObject("catsApp", SimpleFluidPropertiesBase);

InputParameters SimpleFluidPropertiesBase::validParams()
{
    InputParameters params = AuxKernel::validParams();
    params.addCoupledVar("pressure",101.35,"Pressure variable for the domain");
    params.addParam< std::string >("pressure_unit","kPa","Pressure units for pressure variable");
    params.addParam< bool >("use_pressure_units",true,"If true, the 'pressure_unit' is used for pressure, else the base SI units are used");
    params.addParam< std::string >("pressure_mass_unit","kg","Mass units for pressure");
    params.addParam< std::string >("pressure_length_unit","m","Length units for pressure");
    params.addParam< std::string >("pressure_time_unit","s","Time units for pressure");

    params.addCoupledVar("temperature",298,"Temperature variable for the domain (K)");
    params.addCoupledVar("macro_porosity",1.0,"Name of the macro porosity variable");

    params.addCoupledVar("ux",0.0,"Variable for linear velocity in x");
    params.addCoupledVar("uy",0.0,"Variable for linear velocity in y");
    params.addCoupledVar("uz",0.0,"Variable for linear velocity in z");
    params.addParam< std::string >("vel_length_unit","m","Length units for velocity");
    params.addParam< std::string >("vel_time_unit","s","Time units for velocity");

    params.addCoupledVar("characteristic_length",1.0,"Name of the length variable (e.g., hydraulic diameter)");
    params.addParam< std::string >("char_length_unit","m","Length units for characteristic length");

    params.addParam< Real >("ref_diffusivity",2.296E-5,"Reference diffusivity value (e.g., molecular fluid-phase diffusion constant)");
    params.addParam< std::string >("diff_length_unit","cm","Length units for diffusivity");
    params.addParam< std::string >("diff_time_unit","s","Time units for diffusivity");
    params.addParam< Real >("ref_diff_temp",298.15,"Reference temperature value for diffusivity (K)");

    params.addParam< Real >("effective_diffusivity_factor",0.5,"Factor applied to pore diffusivity to estimate effective diffusion: Range (0,2)");

    params.addParam< Real >("dispersivity",0.01,"Dispersivity coefficient of the porous media");
    params.addParam< std::string >("disp_length_unit","cm","Length units for dispersivity");

    params.addParam< Real >("viscosity_pre_exponential",0.02939,"Pre-exponential factor for viscosity calculation");
    params.addParam< std::string >("viscosity_pressure_unit","mPa","Pressure units for viscosity");
    params.addParam< std::string >("viscosity_time_unit","s","Time units for viscosity");
    params.addParam< Real >("viscosity_param_B",507.88,"B parameter in the viscosity calculation (K)");
    params.addParam< Real >("viscosity_param_C",149.3,"C parameter in the viscosity calculation (K)");

    params.addCoupledVar("ionic_strength",0,"Ionic strength variable for the domain");
    params.addParam< std::string >("ionic_strength_volume_unit","mL","Volume units for ionic strength");
    params.addParam< Real >("ionic_strength_param_A",0.0062,"A parameter in the ionic strength correction calculation (L/mol)^0.5");
    params.addParam< Real >("ionic_strength_param_B",0.0793,"B parameter in the ionic strength correction calculation (L/mol)^1");
    params.addParam< Real >("ionic_strength_param_C",0.0080,"C parameter in the ionic strength correction calculation (L/mol)^2");

    params.addParam< Real >("density_param_A",-2.9335E-6,"A parameter in the density calculation (K)^-2");
    params.addParam< Real >("density_param_B",0.001529811,"B parameter in the density calculation (K)^-1");
    params.addParam< Real >("density_param_C",0.787973,"C parameter in the density calculation (-)");
    params.addParam< Real >("ref_density",1000,"Reference density value (near 0 oC)");
    params.addParam< std::string >("density_mass_unit","kg","Mass units for density");
    params.addParam< std::string >("density_volume_unit","m^3","Volume units for density");

    return params;
}

SimpleFluidPropertiesBase::SimpleFluidPropertiesBase(const InputParameters & parameters) :
AuxKernel(parameters),
_pressure(coupledValue("pressure")),
_pressure_unit(getParam<std::string >("pressure_unit")),
_use_pressure_unit(getParam<bool >("use_pressure_units")),
_pressure_mass_unit(getParam<std::string >("pressure_mass_unit")),
_pressure_length_unit(getParam<std::string >("pressure_length_unit")),
_pressure_time_unit(getParam<std::string >("pressure_time_unit")),

_temperature(coupledValue("temperature")),
_macro_pore(coupledValue("macro_porosity")),

_vel_x(coupledValue("ux")),
_vel_y(coupledValue("uy")),
_vel_z(coupledValue("uz")),
_velocity_length_unit(getParam<std::string >("vel_length_unit")),
_velocity_time_unit(getParam<std::string >("vel_time_unit")),

_char_len(coupledValue("characteristic_length")),
_char_len_unit(getParam<std::string >("char_length_unit")),

_ref_diffusivity(getParam< Real >("ref_diffusivity")),
_diff_length_unit(getParam<std::string >("diff_length_unit")),
_diff_time_unit(getParam<std::string >("diff_time_unit")),
_ref_diff_temp(getParam< Real >("ref_diff_temp")),
_eff_diff_factor(getParam< Real >("effective_diffusivity_factor")),

_dispersivity(getParam< Real >("dispersivity")),
_disp_length_unit(getParam<std::string >("disp_length_unit")),

_mu_pre_exp(getParam< Real >("viscosity_pre_exponential")),
_mu_pressure_unit(getParam<std::string >("viscosity_pressure_unit")),
_mu_time_unit(getParam<std::string >("viscosity_time_unit")),
_mu_B(getParam< Real >("viscosity_param_B")),
_mu_C(getParam< Real >("viscosity_param_C")),

_ionic_strength(coupledValue("ionic_strength")),
_ion_volume_unit(getParam<std::string >("ionic_strength_volume_unit")),
_mu_I_A(getParam< Real >("ionic_strength_param_A")),
_mu_I_B(getParam< Real >("ionic_strength_param_B")),
_mu_I_C(getParam< Real >("ionic_strength_param_C")),


_rho_A(getParam< Real >("density_param_A")),
_rho_B(getParam< Real >("density_param_B")),
_rho_C(getParam< Real >("density_param_C")),
_rho_ref(getParam< Real >("ref_density")),
_rho_mass_unit(getParam<std::string >("density_mass_unit")),
_rho_volume_unit(getParam<std::string >("density_volume_unit"))
{
    if (_eff_diff_factor < 0)
      _eff_diff_factor = 0;
    if (_eff_diff_factor > 2.0)
      _eff_diff_factor = 2.0;

    if (_ref_diffusivity < 0.0)
      moose::internal::mooseErrorRaw("Param arg 'ref_diffusivity' must be strictly > 0");

    if (_dispersivity < 0.0)
      moose::internal::mooseErrorRaw("Param arg 'dispersivity' must be strictly > 0");

    if (_mu_pre_exp < 0.0)
      moose::internal::mooseErrorRaw("Param arg 'viscosity_pre_exponential' must be strictly > 0");

    if (_mu_C >= 273.15)
      moose::internal::mooseErrorRaw("Param arg 'viscosity_param_C' cannot be 273.15 K or larger");

    if (_rho_ref < 0.0)
      moose::internal::mooseErrorRaw("Param arg 'ref_density' must be strictly > 0");
}

void SimpleFluidPropertiesBase::unsupported_conversion(std::string from, std::string to)
{
    std::cout << "SimpleGasPropertiesBase has encountered an error...\n";
    std::cout << "\t from: " << from << ", to: " << to << " is not a currently supported unit conversion...\n";
    moose::internal::mooseErrorRaw("Given unit is unsupported! Forced Exit...");
}

Real SimpleFluidPropertiesBase::length_conversion(Real value, std::string from, std::string to)
{
    Real new_value = 0;

    if (from == "m" && to == "m")
      new_value = value;
    else if (from == "m" && to == "cm")
      new_value = 100*value;
    else if (from == "m" && to == "mm")
      new_value = 1000*value;
    else if (from == "cm" && to == "m")
      new_value = value/100;
    else if (from == "cm" && to == "mm")
      new_value = value*10;
    else if (from == "cm" && to == "cm")
      new_value = value;
    else if (from == "mm" && to == "m")
      new_value = value/1000;
    else if (from == "mm" && to == "mm")
      new_value = value;
    else if (from == "mm" && to == "cm")
      new_value = value/10;
    else
      unsupported_conversion(from,to);

    return new_value;
}

Real SimpleFluidPropertiesBase::time_conversion(Real value, std::string from, std::string to)
{
    Real new_value = 0;

    if (from == "hr" && to == "hr")
      new_value = value;
    else if (from == "hr" && to == "min")
      new_value = 60*value;
    else if (from == "hr" && to == "s")
      new_value = 3600*value;
    else if (from == "min" && to == "hr")
      new_value = value/60;
    else if (from == "min" && to == "min")
      new_value = value;
    else if (from == "min" && to == "s")
      new_value = value*60;
    else if (from == "s" && to == "hr")
      new_value = value/3600;
    else if (from == "s" && to == "min")
      new_value = value/60;
    else if (from == "s" && to == "s")
      new_value = value;
    else
      unsupported_conversion(from,to);

    return new_value;
}

Real SimpleFluidPropertiesBase::mass_conversion(Real value, std::string from, std::string to)
{
    Real new_value = 0;

    if (from == "kg" && to == "kg")
      new_value = value;
    else if (from == "kg" && to == "g")
      new_value = 1000*value;
    else if (from == "kg" && to == "mg")
      new_value = 1000*1000*value;
    else if (from == "g" && to == "kg")
      new_value = value/1000;
    else if (from == "g" && to == "g")
      new_value = value;
    else if (from == "g" && to == "mg")
      new_value = value*1000;
    else if (from == "mg" && to == "kg")
      new_value = value/1000/1000;
    else if (from == "mg" && to == "g")
      new_value = value/1000;
    else if (from == "mg" && to == "mg")
      new_value = value;
    else
      unsupported_conversion(from,to);

    return new_value;
}

Real SimpleFluidPropertiesBase::energy_conversion(Real value, std::string from, std::string to)
{
    Real new_value = 0;

    if (from == "kJ" && to == "kJ")
      new_value = value;
    else if (from == "kJ" && to == "J")
      new_value = 1000*value;
    else if (from == "J" && to == "kJ")
      new_value = value/1000;
    else if (from == "J" && to == "J")
      new_value = value;
    else
      unsupported_conversion(from,to);

    return new_value;
}

Real SimpleFluidPropertiesBase::pressure_conversion(Real value, std::string from, std::string to)
{
    Real new_value = 0;

    // First convert to Pa units
    if (_use_pressure_unit == false)
    {
      value = mass_conversion(value, _pressure_mass_unit, "kg");
      value = 1/length_conversion(1/value, _pressure_length_unit, "m");
      value = 1/time_conversion(1/value, _pressure_time_unit, "s");
      value = 1/time_conversion(1/value, _pressure_time_unit, "s");
      from = "Pa";
    }

    if (from == "kPa" && to == "kPa")
      new_value = value;
    else if (from == "kPa" && to == "Pa")
      new_value = 1000*value;
    else if (from == "kPa" && to == "mPa")
      new_value = 1000*1000*value;
    else if (from == "Pa" && to == "kPa")
      new_value = value/1000;
    else if (from == "Pa" && to == "Pa")
      new_value = value;
    else if (from == "Pa" && to == "mPa")
      new_value = value*1000;
    else if (from == "mPa" && to == "kPa")
      new_value = value/1000/1000;
    else if (from == "mPa" && to == "Pa")
      new_value = value/1000;
    else if (from == "mPa" && to == "mPa")
      new_value = value;
    else
      unsupported_conversion(from,to);

    return new_value;
}

Real SimpleFluidPropertiesBase::volume_conversion(Real value, std::string from, std::string to)
{
    Real new_value = 0;

    if (from == "m^3")
      from = "kL";
    if (from == "cm^3")
      from = "mL";
    if (from == "mm^3")
      from = "uL";

    if (to == "m^3")
      to = "kL";
    if (to == "cm^3")
      to = "mL";
    if (to == "mm^3")
      to = "uL";

    if (from == "kL" && to == "kL")
      new_value = value;
    else if (from == "kL" && to == "L")
      new_value = 1000*value;
    else if (from == "kL" && to == "mL")
      new_value = 1000*1000*value;
    else if (from == "kL" && to == "uL")
      new_value = 1000*1000*1000*value;
    else if (from == "L" && to == "kL")
      new_value = value/1000;
    else if (from == "L" && to == "L")
      new_value = value;
    else if (from == "L" && to == "mL")
      new_value = value*1000;
    else if (from == "L" && to == "uL")
      new_value = value*1000*1000;
    else if (from == "mL" && to == "kL")
      new_value = value/1000/1000;
    else if (from == "mL" && to == "L")
      new_value = value/1000;
    else if (from == "mL" && to == "mL")
      new_value = value;
    else if (from == "mL" && to == "uL")
      new_value = 1000*value;
    else if (from == "uL" && to == "kL")
      new_value = value/1000/1000/1000;
    else if (from == "uL" && to == "L")
      new_value = value/1000/1000;
    else if (from == "uL" && to == "mL")
      new_value = value/1000;
    else if (from == "uL" && to == "uL")
      new_value = value;
    else
      unsupported_conversion(from,to);

    return new_value;
}

Real SimpleFluidPropertiesBase::fluid_viscosity(Real temperature)
{
    return _mu_pre_exp*std::exp(_mu_B/(temperature - _mu_C));
}

Real SimpleFluidPropertiesBase::fluid_viscosity_with_ionic_strength_correction(Real temperature, Real ionic_strength)
{
    if (ionic_strength > 0.0)
      ionic_strength = 1/volume_conversion(1/ionic_strength, _ion_volume_unit, "L");
    else
      ionic_strength = 0;
    Real coeff = 1.0+_mu_I_A*std::sqrt(ionic_strength)+_mu_I_B*ionic_strength+_mu_I_C*ionic_strength*ionic_strength;
    return fluid_viscosity(temperature)*coeff;
}

Real SimpleFluidPropertiesBase::fluid_density(Real temperature, Real pressure)
{
    pressure = pressure_conversion(pressure, _pressure_unit, "kPa");
    Real alpha = 1.0135 + 4.9582E-7 * pressure;
    Real coeff = _rho_A*temperature*temperature + _rho_B*temperature + _rho_C;
    return alpha*coeff*_rho_ref;
}

Real SimpleFluidPropertiesBase::molecular_diffusion(Real temperature)
{
    return _ref_diffusivity*std::exp(-1991.805*((1/temperature)-(1/_ref_diff_temp)));
}

Real SimpleFluidPropertiesBase::effective_molecular_diffusion(Real temperature, Real porosity)
{
    if (porosity > 1 || porosity < 0)
      moose::internal::mooseErrorRaw("Variable for 'macro_porosity' must be strictly < 1 and > 0 [0 < eps < 1]");
    return molecular_diffusion(temperature)*std::pow(porosity, _eff_diff_factor);
}

Real SimpleFluidPropertiesBase::dispersion(Real temperature)
{
    Real vel_mag = velocity_magnitude(_vel_x[_qp], _vel_y[_qp], _vel_z[_qp]);
    vel_mag = length_conversion(vel_mag, _velocity_length_unit, _diff_length_unit);
    vel_mag = 1/time_conversion(1/vel_mag, _velocity_time_unit, _diff_time_unit);
    Real alpha = _dispersivity;
    alpha = length_conversion(alpha, _disp_length_unit, _diff_length_unit);
    return molecular_diffusion(temperature) + vel_mag*alpha;
}

Real SimpleFluidPropertiesBase::effective_dispersion(Real temperature, Real porosity)
{
    if (porosity > 1 || porosity < 0)
      moose::internal::mooseErrorRaw("Variable for 'macro_porosity' must be strictly < 1 and > 0 [0 < eps < 1]");
    return dispersion(temperature)*std::pow(porosity, _eff_diff_factor);
}

Real SimpleFluidPropertiesBase::velocity_magnitude(Real ux, Real uy, Real uz)
{
    return std::sqrt(ux*ux + uy*uy + uz*uz);
}

Real SimpleFluidPropertiesBase::reynolds_number()
{
    Real rho = fluid_density(_temperature[_qp], _pressure[_qp]);
    rho = mass_conversion(rho, _rho_mass_unit, "kg");
    rho = 1/volume_conversion(1/rho, _rho_volume_unit, "m^3");

    Real vel_mag = velocity_magnitude(_vel_x[_qp], _vel_y[_qp], _vel_z[_qp]);
    vel_mag = length_conversion(vel_mag, _velocity_length_unit, "m");
    vel_mag = 1/time_conversion(1/vel_mag, _velocity_time_unit, "s");

    Real mu = fluid_viscosity(_temperature[_qp]);
    mu = pressure_conversion(mu, _mu_pressure_unit, "mPa");
    mu = time_conversion(mu, _mu_time_unit, "s");
    // 1 mPa*s = 1 g/m/s
    mu = 1/length_conversion(1/mu, "m", "m");
    mu = 1/time_conversion(1/mu, "s", "s");
    mu = mass_conversion(mu, "g", "kg");

    Real L = length_conversion(_char_len[_qp], _char_len_unit, "m");

    return rho*vel_mag*L/mu;
}

Real SimpleFluidPropertiesBase::schmidt_number()
{
    Real Dm = molecular_diffusion(_temperature[_qp]);
    Dm = length_conversion(Dm, _diff_length_unit, "m");
    Dm = length_conversion(Dm, _diff_length_unit, "m");
    Dm = 1/time_conversion(1/Dm, _diff_time_unit, "s");

    Real rho = fluid_density(_temperature[_qp], _pressure[_qp]);
    rho = mass_conversion(rho, _rho_mass_unit, "kg");
    rho = 1/volume_conversion(1/rho, _rho_volume_unit, "m^3");

    Real mu = fluid_viscosity(_temperature[_qp]);
    mu = pressure_conversion(mu, _mu_pressure_unit, "mPa");
    mu = time_conversion(mu, _mu_time_unit, "s");
    // 1 mPa*s = 1 g/m/s
    mu = 1/length_conversion(1/mu, "m", "m");
    mu = 1/time_conversion(1/mu, "s", "s");
    mu = mass_conversion(mu, "g", "kg");

    return mu/rho/Dm;
}

Real SimpleFluidPropertiesBase::computeValue()
{
    //Below is a sample usage for conversions of complex units
    //    Conversions are done unit-by-unit. After each conversion
    //      you use the updated value. For inversion conversions,
    //      pass the inverse of the value, then take the inverse
    //      of the returned value.
    /*
    Real temp = length_conversion(_ref_diffusivity, _diff_length_unit, "cm");
    temp = length_conversion(temp, _diff_length_unit, "cm");
    return 1/time_conversion(1/temp, _diff_time_unit, "min");
    */

    return 0;
}
