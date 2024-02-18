/*!
 *  \file PhaseTemperature.h
 *    \brief Kernel to create a residual to solve for the temperature of a given phase based on
 * energy per volume \details This file creates a standard MOOSE kernel that is used to calculate
 * the temperature of a phase from the energy per volume, as well as density, specific heat, and
 * volume fraction of the phase. This kernel is a necessary component when doing energy balances
 * where density and heat capacity change in space-time.
 *
 *  \author Austin Ladshaw
 *    \date 05/04/2020
 *    \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "PhaseTemperature.h"

registerMooseObject("catsApp", PhaseTemperature);

InputParameters
PhaseTemperature::validParams()
{
  InputParameters params = Kernel::validParams();
  params.addRequiredCoupledVar("specific_heat", "Variable for specific heat (J/kg/K)");
  params.addRequiredCoupledVar("density", "Variable for density (kg/m^3)");
  params.addRequiredCoupledVar("energy", "Variable for energy density (J/m^3)");
  return params;
}

PhaseTemperature::PhaseTemperature(const InputParameters & parameters)
  : Kernel(parameters),
    _energy(coupledValue("energy")),
    _energy_var(coupled("energy")),
    _density(coupledValue("density")),
    _density_var(coupled("density")),
    _specheat(coupledValue("specific_heat")),
    _specheat_var(coupled("specific_heat"))
{
}

Real
PhaseTemperature::computeQpResidual()
{
  return _density[_qp] * _specheat[_qp] * _u[_qp] * _test[_i][_qp] - _energy[_qp] * _test[_i][_qp];
}

Real
PhaseTemperature::computeQpJacobian()
{
  return _density[_qp] * _specheat[_qp] * _phi[_j][_qp] * _test[_i][_qp];
}

Real
PhaseTemperature::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _energy_var)
  {
    return -_phi[_j][_qp] * _test[_i][_qp];
  }
  if (jvar == _density_var)
  {
    return _phi[_j][_qp] * _specheat[_qp] * _u[_qp] * _test[_i][_qp];
  }
  if (jvar == _specheat_var)
  {
    return _density[_qp] * _phi[_j][_qp] * _u[_qp] * _test[_i][_qp];
  }

  return 0.0;
}
