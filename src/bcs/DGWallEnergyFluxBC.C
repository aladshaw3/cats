/*!
 *  \file DGWallEnergyFluxBC.h
 *    \brief Boundary Condition kernel to for energy flux caused by a wall heating/cooling
 *    \details This file creates a boundary condition kernel to account for heat loss or
 *          gained from a wall. The user must supply a coupled variable for the
 *          heat transfer coefficient at the wall. The wall temperature is given as a
 *          non-linear variable, but a constant may also be given.
 *
 *    \author Austin Ladshaw
 *    \date 05/04/2020
 *    \copyright This kernel was designed and built at the Georgia Institute
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

#include "DGWallEnergyFluxBC.h"

registerMooseObject("catsApp", DGWallEnergyFluxBC);

InputParameters
DGWallEnergyFluxBC::validParams()
{
  InputParameters params = IntegratedBC::validParams();
  params.addCoupledVar("transfer_coef", 1, "Variable for heat transfer coefficient (W/m^2/K)");
  params.addCoupledVar("wall_temp", 298, "Variable for the wall temperature (K)");
  params.addRequiredCoupledVar("temperature", "Variable for the phase temperature (K)");
  params.addCoupledVar(
      "area_frac", 1, "Variable for contact area fraction (or volume fraction) (-)");
  return params;
}

DGWallEnergyFluxBC::DGWallEnergyFluxBC(const InputParameters & parameters)
  : IntegratedBC(parameters),
    _hw(coupledValue("transfer_coef")),
    _hw_var(coupled("transfer_coef")),
    _temp(coupledValue("temperature")),
    _temp_var(coupled("temperature")),
    _walltemp(coupledValue("wall_temp")),
    _walltemp_var(coupled("wall_temp")),
    _areafrac(coupledValue("area_frac")),
    _areafrac_var(coupled("area_frac"))
{
}

Real
DGWallEnergyFluxBC::computeQpResidual()
{
  return _test[_i][_qp] * _hw[_qp] * _areafrac[_qp] * (_temp[_qp] - _walltemp[_qp]);
}

Real
DGWallEnergyFluxBC::computeQpJacobian()
{
  return 0.0;
}

Real
DGWallEnergyFluxBC::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _hw_var)
  {
    return _test[_i][_qp] * _phi[_j][_qp] * _areafrac[_qp] * (_temp[_qp] - _walltemp[_qp]);
  }
  if (jvar == _temp_var)
  {
    return _test[_i][_qp] * _hw[_qp] * _areafrac[_qp] * _phi[_j][_qp];
  }
  if (jvar == _walltemp_var)
  {
    return -_test[_i][_qp] * _hw[_qp] * _areafrac[_qp] * _phi[_j][_qp];
  }
  if (jvar == _areafrac_var)
  {
    return _test[_i][_qp] * _hw[_qp] * _phi[_j][_qp] * (_temp[_qp] - _walltemp[_qp]);
  }

  return 0.0;
}
