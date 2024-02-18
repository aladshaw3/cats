/*!
 *  \file SimpleFluidDensity.h
 *    \brief AuxKernel kernel to calculate density of a fluid (default = water)
 *    \details This file is responsible for calculating the density of a fluid by
 *            using an emperical relationship that is based on a polynomial fitting
 *            of data with temperature and pressure. The default configuration of
 *            this calculation is for the density of water between 0 and 350 oC.
 *            Pressure range that this is valid for is between 1 and 200 bar.
 *            User's may update the parameter information for other fluids and
 *            temperature/pressure ranges as needed.
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

#include "SimpleFluidDensity.h"

registerMooseObject("catsApp", SimpleFluidDensity);

InputParameters
SimpleFluidDensity::validParams()
{
  InputParameters params = SimpleFluidPropertiesBase::validParams();
  params.addParam<std::string>(
      "output_volume_unit", "L", "Volume units for fluid density on output");
  params.addParam<std::string>("output_mass_unit", "kg", "Mass units for fluid density on output");

  return params;
}

SimpleFluidDensity::SimpleFluidDensity(const InputParameters & parameters)
  : SimpleFluidPropertiesBase(parameters),
    _output_volume_unit(getParam<std::string>("output_volume_unit")),
    _output_mass_unit(getParam<std::string>("output_mass_unit"))
{
}

Real
SimpleFluidDensity::computeValue()
{
  Real rho = SimpleFluidPropertiesBase::fluid_density(_temperature[_qp], _pressure[_qp]);
  rho = SimpleFluidPropertiesBase::mass_conversion(rho, _rho_mass_unit, _output_mass_unit);
  rho = 1 / SimpleFluidPropertiesBase::volume_conversion(
                1 / rho, _rho_volume_unit, _output_volume_unit);
  return rho;
}
