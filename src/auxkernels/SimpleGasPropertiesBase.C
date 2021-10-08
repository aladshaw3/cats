/*!
 *  \file SimpleGasPropertiesBase.h
 *    \brief AuxKernel kernel base to aid in simple gas properties calculations
 *    \details This file is responsible for setting up and storing information
 *              associated with the simplified calculation of system properties.
 *              Calculations here are less rigorous than GasPropertiesBase, but
 *              will allow for more user flexibility and easier interfacing with
 *              the calculation of some simple gas-phase properties.
 *
 *
 *  \author Austin Ladshaw
 *  \date 09/14/2021
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

/****************************************************************/
/*               DO NOT MODIFY THIS HEADER                      */
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*           (c) 2010 Battelle Energy Alliance, LLC             */
/*                   ALL RIGHTS RESERVED                        */
/*                                                              */
/*          Prepared by Battelle Energy Alliance, LLC           */
/*            Under Contract No. DE-AC07-05ID14517              */
/*            With the U. S. Department of Energy               */
/*                                                              */
/*            See COPYRIGHT for full restrictions               */
/****************************************************************/

#include "SimpleGasPropertiesBase.h"

registerMooseObject("catsApp", SimpleGasPropertiesBase);

InputParameters SimpleGasPropertiesBase::validParams()
{
    InputParameters params = AuxKernel::validParams();
    params.addRequiredCoupledVar("pressure","Pressure variable for the domain (kPa)");
    params.addRequiredCoupledVar("temperature","Temperature variable for the domain (K)");
    params.addCoupledVar("micro_porosity",1.0,"Name of the micro porosity variable");
    params.addCoupledVar("macro_porosity",1.0,"Name of the macro porosity variable");

    params.addCoupledVar("characteristic_length",1.0,"Name of the length variable (e.g., hydraulic diameter)");
    params.addParam< std::string >("char_length_unit","m","Length units for characteristic length");

    params.addCoupledVar("velocity",1.0,"Variable for average velocity");
    params.addParam< std::string >("vel_length_unit","m","Length units for velocity");
    params.addParam< std::string >("vel_time_unit","s","Time units for velocity");

    params.addParam< Real >("ref_diffusivity",1.0,"Reference diffusivity value (e.g., molecular gas-phase diffusion constant)");
    params.addParam< std::string >("diff_length_unit","m","Length units for diffusivity");
    params.addParam< std::string >("diff_time_unit","s","Time units for diffusivity");
    params.addParam< Real >("ref_diff_temp",273.0,"Reference temperature value for diffusivity (K)");

    params.addParam< Real >("effective_diffusivity_factor",1.4,"Factor applied to pore diffusivity to estimate effective diffusion: Range (1,2)");

    return params;
}

SimpleGasPropertiesBase::SimpleGasPropertiesBase(const InputParameters & parameters) :
AuxKernel(parameters),
_pressure(coupledValue("pressure")),
_temperature(coupledValue("temperature")),
_micro_pore(coupledValue("micro_porosity")),
_macro_pore(coupledValue("macro_porosity")),
_char_len(coupledValue("characteristic_length")),
_char_len_unit(getParam<std::string >("char_length_unit")),
_velocity(coupledValue("velocity")),
_velocity_length_unit(getParam<std::string >("vel_length_unit")),
_velocity_time_unit(getParam<std::string >("vel_time_unit")),
_ref_diffusivity(getParam< Real >("ref_diffusivity")),
_diff_length_unit(getParam<std::string >("diff_length_unit")),
_diff_time_unit(getParam<std::string >("diff_time_unit")),
_ref_diff_temp(getParam< Real >("ref_diff_temp")),
_eff_diff_factor(getParam< Real >("effective_diffusivity_factor"))
{
    if (_eff_diff_factor < 1.0)
      _eff_diff_factor = 1.0;
    if (_eff_diff_factor > 2.0)
      _eff_diff_factor = 2.0;
}

void SimpleGasPropertiesBase::unsupported_conversion(std::string from, std::string to)
{
    std::cout << "SimpleGasPropertiesBase has encountered an error...\n";
    std::cout << "\t from: " << from << ", to: " << to << " is not a currently supported unit conversion...\n";
    moose::internal::mooseErrorRaw("Given unit is unsupported! Forced Exit...");
}

Real SimpleGasPropertiesBase::length_conversion(Real value, std::string from, std::string to)
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

Real SimpleGasPropertiesBase::time_conversion(Real value, std::string from, std::string to)
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

Real SimpleGasPropertiesBase::mass_conversion(Real value, std::string from, std::string to)
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

Real SimpleGasPropertiesBase::energy_conversion(Real value, std::string from, std::string to)
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

Real SimpleGasPropertiesBase::computeValue()
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
