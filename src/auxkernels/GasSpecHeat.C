/*!
 *  \file GasSpecHeat.h
 *    \brief AuxKernel kernel to compute the gas specific heat (Cp)
 *    \details This file is responsible for calculating the gas specific heat (Cp) in J/kg/K
 *
 *
 *  \author Austin Ladshaw
 *  \date 04/20/2020
 *  \copyright This kernel was designed and built at the Georgia Institute
 *             of Technology by Austin Ladshaw for PhD research in the area
 *             of adsorption and surface science and was developed for use
 *               by Idaho National Laboratory and Oak Ridge National Laboratory
 *               engineers and scientists. Portions Copyright (c) 2015, all
 *             rights reserved.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "GasSpecHeat.h"

registerMooseObject("catsApp", GasSpecHeat);

InputParameters
GasSpecHeat::validParams()
{
  InputParameters params = GasPropertiesBase::validParams();
  return params;
}

GasSpecHeat::GasSpecHeat(const InputParameters & parameters) : GasPropertiesBase(parameters) {}

Real
GasSpecHeat::computeValue()
{
  prepareEgret();
  calculateAllProperties();

  return _egret_dat.total_specific_heat * 1000.0;
}
