/*!
 *  \file SimpleGasPoreDiffusivity.h
 *    \brief AuxKernel kernel to calculate pore diffusion coefficients in microscale
 *    \details This file is responsible for calculating the pore diffusivity
 *              for the microscale given some simple properties. Calculation is based
 *              diffusivities that are corrected via an Arrhenius like
 *              expression from a reference diffusivity and reference temperature.
 *              User provides input units for specific parameters and provides
 *              desired unit basis of the calculation of diffusivity.
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

#include "SimpleGasPoreDiffusivity.h"

registerMooseObject("catsApp", SimpleGasPoreDiffusivity);

InputParameters
SimpleGasPoreDiffusivity::validParams()
{
  InputParameters params = SimpleGasPropertiesBase::validParams();
  params.addParam<std::string>(
      "output_length_unit", "m", "Length units for mass transfer on output");
  params.addParam<std::string>("output_time_unit", "s", "Time units for mass transfer on output");

  return params;
}

SimpleGasPoreDiffusivity::SimpleGasPoreDiffusivity(const InputParameters & parameters)
  : SimpleGasPropertiesBase(parameters),
    _output_length_unit(getParam<std::string>("output_length_unit")),
    _output_time_unit(getParam<std::string>("output_time_unit"))
{
}

Real
SimpleGasPoreDiffusivity::computeValue()
{
  // Put diffusivity into cm^2/s
  Real Dm = _ref_diffusivity * exp(-887.5 * ((1 / _temperature[_qp]) - (1 / _ref_diff_temp)));
  Dm = SimpleGasPropertiesBase::length_conversion(Dm, _diff_length_unit, "cm");
  Dm = SimpleGasPropertiesBase::length_conversion(Dm, _diff_length_unit, "cm");
  Dm = 1 / SimpleGasPropertiesBase::time_conversion(1 / Dm, _diff_time_unit, "s");

  Real Deff = pow(_micro_pore[_qp], _eff_diff_factor) * Dm;
  // ends up in cm^2/s
  Deff = SimpleGasPropertiesBase::length_conversion(Deff, "cm", _output_length_unit);
  Deff = SimpleGasPropertiesBase::length_conversion(Deff, "cm", _output_length_unit);
  Deff = 1 / SimpleGasPropertiesBase::time_conversion(1 / Deff, "s", _output_time_unit);
  return Deff;
}
