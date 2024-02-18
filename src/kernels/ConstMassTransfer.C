/*!
 *  \file ConstMassTransfer.h
 *  \brief Kernel for creating an exchange of mass (or energy) between non-linear variables
 *  \details This file creates a kernel for the coupling a pair of non-linear variables in
 *            the same domain as a form of mass/energy transfer. The variables are
 *            coupled linearly in a via a constant transfer coefficient as shown below:
 *                  Res = test * km * (u - v)
 *                          where u = this variable
 *                          and v = coupled variable
 *
 *
 *  \author Austin Ladshaw
 *  \date 04/06/2020
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "ConstMassTransfer.h"

registerMooseObject("catsApp", ConstMassTransfer);

InputParameters
ConstMassTransfer::validParams()
{
  InputParameters params = Kernel::validParams();
  params.addParam<Real>("transfer_rate", 1.0, "Mass/energy transfer coefficient");
  params.addRequiredCoupledVar("coupled", "Name of the coupled variable");
  return params;
}

ConstMassTransfer::ConstMassTransfer(const InputParameters & parameters)
  : Kernel(parameters),
    _trans_rate(getParam<Real>("transfer_rate")),
    _coupled(coupledValue("coupled")),
    _coupled_var(coupled("coupled"))
{
}

Real
ConstMassTransfer::computeQpResidual()
{
  return _test[_i][_qp] * _trans_rate * (_u[_qp] - _coupled[_qp]);
}

Real
ConstMassTransfer::computeQpJacobian()
{
  return _test[_i][_qp] * _trans_rate * _phi[_j][_qp];
}

Real
ConstMassTransfer::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _coupled_var)
  {
    return -_test[_i][_qp] * _trans_rate * _phi[_j][_qp];
  }
  return 0.0;
}
