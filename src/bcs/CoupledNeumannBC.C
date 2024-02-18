/*!
 *  \file CoupledNeumannBC.h
 *	\brief Boundary Condition kernel for a Neumann condition based on a coulped variable
 *  \details This kernel creates a standard Neumann type BC for a variable wherein
 *        the slope-value at the boundary is another non-linear, variable. This will primarily
 *        be used with Auxilary Variables to create step functions or any other desired
 *        relationship at the boundary.
 *
 *
 *  \author Austin Ladshaw
 *	\date 01/18/2022
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "CoupledNeumannBC.h"

registerMooseObject("MooseApp", CoupledNeumannBC);

InputParameters
CoupledNeumannBC::validParams()
{
  InputParameters params = IntegratedBC::validParams();
  params.addCoupledVar("coupled", 0, "The variable whose value we are coupling to.");
  return params;
}

CoupledNeumannBC::CoupledNeumannBC(const InputParameters & parameters)
  : IntegratedBC(parameters), _coupled(coupledValue("coupled")), _coupled_var(coupled("coupled"))
{
}

Real
CoupledNeumannBC::computeQpResidual()
{
  return -_test[_i][_qp] * _coupled[_qp];
}

Real
CoupledNeumannBC::computeQpJacobian()
{
  return 0.;
}

Real
CoupledNeumannBC::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _coupled_var)
    return -_test[_i][_qp] * _phi[_j][_qp];
  else
    return 0.;
}
