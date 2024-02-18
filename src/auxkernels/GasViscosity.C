/*!
 *  \file GasViscosity.h
 *    \brief AuxKernel kernel to compute the gas viscosity
 *    \details This file is responsible for calculating the gas visocity in kg/m/s.
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

#include "GasViscosity.h"

registerMooseObject("catsApp", GasViscosity);

InputParameters
GasViscosity::validParams()
{
  InputParameters params = GasPropertiesBase::validParams();

  return params;
}

GasViscosity::GasViscosity(const InputParameters & parameters) : GasPropertiesBase(parameters) {}

Real
GasViscosity::computeValue()
{
  prepareEgret();
  calculateAllProperties();

  return _egret_dat.total_dyn_vis / 1000.0 * 100.0;
}
