/*!
 *  \file SimpleGasThermalConductivity.h
 *    \brief AuxKernel kernel to calculate thermal conductivity of air
 *    \details This file is responsible for calculating the thermal conductivity
 *            of air assuming an ideal gas made up of primarily O2 and N2. This
 *            kernel uses an emperical formula for thermal conductivity for
 *            standard air that is accurate between -50 and 1600 oC.
 *
 *            Ref: K. Ramanathan, C.S. Sharma, "Kinetic parameters estimation
 *                    for three way catalyst modeling," Ind. Eng. Chem. Res.
 *                    50 (2011) 9960-9979.
 *
 *
 *  \author Austin Ladshaw
 *  \date 10/13/2021
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "SimpleGasThermalConductivity.h"

registerMooseObject("catsApp", SimpleGasThermalConductivity);

InputParameters
SimpleGasThermalConductivity::validParams()
{
  InputParameters params = SimpleGasPropertiesBase::validParams();
  params.addParam<std::string>(
      "output_energy_unit", "kJ", "Energy units for gas thermal conductivity on output");
  params.addParam<std::string>(
      "output_length_unit", "m", "Length units for gas thermal conductivity on output");
  params.addParam<std::string>(
      "output_time_unit", "s", "Time units for gas thermal conductivity on output");
  return params;
}

SimpleGasThermalConductivity::SimpleGasThermalConductivity(const InputParameters & parameters)
  : SimpleGasPropertiesBase(parameters),
    _output_energy_unit(getParam<std::string>("output_energy_unit")),
    _output_length_unit(getParam<std::string>("output_length_unit")),
    _output_time_unit(getParam<std::string>("output_time_unit"))
{
}

Real
SimpleGasThermalConductivity::computeValue()
{
  // Kg [J/s/m/K]
  Real Kg = 2.66E-04 * pow(_temperature[_qp], 0.805);
  Kg = SimpleGasPropertiesBase::energy_conversion(Kg, "J", _output_energy_unit);
  Kg = 1 / SimpleGasPropertiesBase::length_conversion(1 / Kg, "m", _output_length_unit);
  Kg = 1 / SimpleGasPropertiesBase::time_conversion(1 / Kg, "s", _output_time_unit);
  return Kg;
}
