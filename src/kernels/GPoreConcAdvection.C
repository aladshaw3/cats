/*!
 *  \file GPoreConcAdvection.h
 *	\brief Kernel for use with the corresponding DGPoreConcAdvection object
 *	\details This file creates a standard MOOSE kernel that is to be used in conjunction with DGPoreConcAdvection
 *			for the discontinous Galerkin formulation of advection in MOOSE. In order to complete the DG
 *			formulation of the advective physics, this kernel must be utilized with every variable that also uses
 *			the DGPoreConcAdvection kernel.
 *
 *  \author Austin Ladshaw
 *	\date 03/09/2020
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "GPoreConcAdvection.h"

registerMooseObject("catsApp", GPoreConcAdvection);

InputParameters GPoreConcAdvection::validParams()
{
    InputParameters params = GConcentrationAdvection::validParams();
    params.addRequiredCoupledVar("porosity","Variable for the porosity of the domain/subdomain");
    return params;
}

GPoreConcAdvection::GPoreConcAdvection(const InputParameters & parameters) :
GConcentrationAdvection(parameters),
_porosity(coupledValue("porosity")),
_porosity_var(coupled("porosity"))
{

}

Real GPoreConcAdvection::computeQpResidual()
{
	_velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

	return GAdvection::computeQpResidual()*_porosity[_qp];
}

Real GPoreConcAdvection::computeQpJacobian()
{
  _velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

	return GAdvection::computeQpJacobian()*_porosity[_qp];
}

Real GPoreConcAdvection::computeQpOffDiagJacobian(unsigned int jvar)
{
	_velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

	if (jvar == _ux_var)
	{
		return -_u[_qp]*(_phi[_j][_qp]*_grad_test[_i][_qp](0))*_porosity[_qp];
	}

	if (jvar == _uy_var)
	{
		return -_u[_qp]*(_phi[_j][_qp]*_grad_test[_i][_qp](1))*_porosity[_qp];
	}

	if (jvar == _uz_var)
	{
		return -_u[_qp]*(_phi[_j][_qp]*_grad_test[_i][_qp](2))*_porosity[_qp];
	}

  if (jvar == _porosity_var)
  {
    return -_u[_qp]*(_velocity*_grad_test[_i][_qp])*_phi[_j][_qp];
  }

	return 0.0;
}
