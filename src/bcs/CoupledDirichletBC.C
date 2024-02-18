/*!
 *  \file CoupledDirichletBC.h
 *	\brief Boundary Condition kernel for a Dirichlet condition based on a coulped variable
 *  \details This kernel creates a standard Dirichlet type BC for a nodal variable wherein
 *        the value at the boundary is another non-linear, nodal variable. This will primarily
 *        be used with Auxilary Variables to create step functions or any other desired
 *        relationship at the boundary. It is to be used ONLY with NODAL variables (i.e.,
 *        you cannot use this with DG variables).
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

#include "CoupledDirichletBC.h"

registerMooseObject("MooseApp", CoupledDirichletBC);

InputParameters
CoupledDirichletBC::validParams()
{
  InputParameters params = NodalBC::validParams();
  params.addCoupledVar("coupled", 0, "The variable whose value we are coupling to.");
  return params;
}

CoupledDirichletBC::CoupledDirichletBC(const InputParameters & parameters)
  : NodalBC(parameters), _coupled(coupledValue("coupled")), _coupled_var(coupled("coupled"))
{
}

// NOTE: There is NO test function or phi function associated with Nodal BCs
Real
CoupledDirichletBC::computeQpResidual()
{
  return _u[_qp] - _coupled[_qp];
}

Real
CoupledDirichletBC::computeQpJacobian()
{
  return 1.;
}

Real
CoupledDirichletBC::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _coupled_var)
    return -1.;
  else
    return 0.;
}
