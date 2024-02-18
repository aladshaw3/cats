/*!
 *  \file SimpleGasViscosity.h
 *    \brief AuxKernel kernel to calculate viscosity of air
 *    \details This file is responsible for calculating the viscosity of air by
 *            assuming an ideal gas of mostly O2 and N2 (i.e., standard air)
 *
 *
 *  \author Austin Ladshaw
 *  \date 10/18/2021
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "SimpleGasViscosity.h"

registerMooseObject("catsApp", SimpleGasViscosity);

InputParameters
SimpleGasViscosity::validParams()
{
  InputParameters params = SimpleGasPropertiesBase::validParams();
  params.addParam<std::string>(
      "output_length_unit", "m", "Length units for gas viscosity on output");
  params.addParam<std::string>("output_mass_unit", "kg", "Mass units for gas viscosity on output");
  params.addParam<std::string>("output_time_unit", "s", "Time units for gas viscosity on output");

  return params;
}

SimpleGasViscosity::SimpleGasViscosity(const InputParameters & parameters)
  : SimpleGasPropertiesBase(parameters),
    _output_length_unit(getParam<std::string>("output_length_unit")),
    _output_mass_unit(getParam<std::string>("output_mass_unit")),
    _output_time_unit(getParam<std::string>("output_time_unit"))
{
}

Real
SimpleGasViscosity::computeValue()
{
  // mu [g/cm/s]
  Real mu = 0.1458 * pow(_temperature[_qp], 1.5) / (110.4 + _temperature[_qp]) / 10000;
  mu = 1 / SimpleGasPropertiesBase::length_conversion(1 / mu, "cm", _output_length_unit);
  mu = 1 / SimpleGasPropertiesBase::time_conversion(1 / mu, "s", _output_time_unit);
  mu = SimpleGasPropertiesBase::mass_conversion(mu, "g", _output_mass_unit);
  return mu;
}
