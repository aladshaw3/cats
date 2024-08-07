/*!
 *  \file GasThermalConductivity.h
 *    \brief AuxKernel kernel to compute the gas phase thermal conductivity
 *    \details This file is responsible for calculating the gas thermal conductivity in W/m/K
 *
 *
 *  \author Austin Ladshaw
 *  \date 04/21/2020
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

#include "GasThermalConductivity.h"

registerMooseObject("catsApp", GasThermalConductivity);

InputParameters
GasThermalConductivity::validParams()
{
  InputParameters params = GasPropertiesBase::validParams();
  params.addParam<Real>(
      "heat_cap_ratio", 1.4, "Ratio of heat capacities (Cp/Cv) ==> Assumed = 1.4");

  return params;
}

GasThermalConductivity::GasThermalConductivity(const InputParameters & parameters)
  : GasPropertiesBase(parameters), _Cp_Cv_ratio(getParam<Real>("heat_cap_ratio"))
{
  // Check the bounds of the correction factor (typical values: 1.3 - 1.6)
  if (_Cp_Cv_ratio < 0.56)
  {
    _Cp_Cv_ratio = 0.56;
  }
  if (_Cp_Cv_ratio > 1.67)
  {
    _Cp_Cv_ratio = 1.67;
  }
}

Real
GasThermalConductivity::computeValue()
{
  prepareEgret();
  calculateAllProperties();
  Real Cv = _egret_dat.total_specific_heat * 1000.0 / _Cp_Cv_ratio;
  Real mu = _egret_dat.total_dyn_vis / 1000.0 * 100.0;
  Real f = 0.25 * (9.0 * _Cp_Cv_ratio - 5.0);

  return f * mu * Cv;
}
