/*!
 *  \file MicroscaleVariableCoefTimeDerivative.h
 *    \brief Microscale time derivative with variable coefficient.
 *    \details This file creates a custom MOOSE kernel for the time derivative at the microscale
 *              of a fictious mesh with a variable time coefficient. This variable time coefficient
 *              can replace the porosity factor of the microscale with an actual auxiliary variable.
 *
 *  \author Austin Ladshaw
 *    \date 05/21/2020
 *    \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "MicroscaleVariableCoefTimeDerivative.h"

registerMooseObject("catsApp", MicroscaleVariableCoefTimeDerivative);

InputParameters
MicroscaleVariableCoefTimeDerivative::validParams()
{
  InputParameters params = MicroscaleCoefTimeDerivative::validParams();
  params.addRequiredCoupledVar("nodal_time_var",
                               "Variable coefficient at the current node for the time derivative");
  return params;
}

MicroscaleVariableCoefTimeDerivative::MicroscaleVariableCoefTimeDerivative(
    const InputParameters & parameters)
  : MicroscaleCoefTimeDerivative(parameters),
    _coupled_coef(coupledValue("nodal_time_var")),
    _coupled_coef_var(coupled("nodal_time_var"))
{
}

Real
MicroscaleVariableCoefTimeDerivative::computeQpResidual()
{
  _nodal_time_coef = _coupled_coef[_qp];
  return MicroscaleCoefTimeDerivative::computeQpResidual();
}

Real
MicroscaleVariableCoefTimeDerivative::computeQpJacobian()
{
  _nodal_time_coef = _coupled_coef[_qp];
  return MicroscaleCoefTimeDerivative::computeQpJacobian();
}

Real
MicroscaleVariableCoefTimeDerivative::computeQpOffDiagJacobian(unsigned int jvar)
{
  _nodal_time_coef = _coupled_coef[_qp];

  if (jvar == _coupled_coef_var)
  {
    return _rd_l * _phi[_j][_qp] * _test[_i][_qp] * _u_dot[_qp];
  }
  return 0.0;
}
