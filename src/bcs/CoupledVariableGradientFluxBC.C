/*!
 *  \file CoupledVariableGradientFluxBC.h
 *	\brief Boundary Condition kernel for flux of material based on another variable gradient
 *  \details A Flux BC which couples the gradient of another variable to the flux of
 *          this variable. Additionally, a variable coefficient may be multiplied by
 *          the other variable gradient to scale the flux accordingly.
 *
 *                Res = -_test[_i][_qp]*_ceof*(_coupled_grad[_qp]*_normals[_qp]);
 *
 *
 *  \author Austin Ladshaw
 *	\date 04/21/2022
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "CoupledVariableGradientFluxBC.h"

registerMooseObject("catsApp", CoupledVariableGradientFluxBC);

InputParameters
CoupledVariableGradientFluxBC::validParams()
{
  InputParameters params = IntegratedBC::validParams();
  params.addRequiredCoupledVar("coupled", "Variable for the coupled gradient at the boundary");
  params.addCoupledVar("coef", 1.0, "Variable for the coupled coefficient");
  return params;
}

CoupledVariableGradientFluxBC::CoupledVariableGradientFluxBC(const InputParameters & parameters)
  : IntegratedBC(parameters),
    _coupled_grad(coupledGradient("coupled")),
    _coupled_var(coupled("coupled")),

    _coef(coupledValue("coef")),
    _coef_var(coupled("coef"))
{
}

Real
CoupledVariableGradientFluxBC::computeQpResidual()
{
  return -_test[_i][_qp] * _coef[_qp] * (_coupled_grad[_qp] * _normals[_qp]);
}

Real
CoupledVariableGradientFluxBC::computeQpJacobian()
{
  return 0.0;
}

Real
CoupledVariableGradientFluxBC::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _coupled_var)
  {
    return -_test[_i][_qp] * _coef[_qp] * (_grad_phi[_j][_qp] * _normals[_qp]);
  }

  if (jvar == _coef_var)
  {
    return -_test[_i][_qp] * _phi[_j][_qp] * (_coupled_grad[_qp] * _normals[_qp]);
  }

  return 0.0;
}
