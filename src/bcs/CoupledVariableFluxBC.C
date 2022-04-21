/*!
 *  \file CoupledVariableFluxBC.h
 *	\brief Boundary Condition kernel for flux of material leaving/entering a domain
 *  \details A Flux BC which is consistent with the boundary terms arising from
 *            any flux of material into or out of a domain. The flux variable
 *            is a vector composed of x, y, z flux components.
 *
 *                Res = _test[_i][_qp]*(_flux*_normals[_qp]);
 *
 *
 *  \author Austin Ladshaw
 *	\date 11/03/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "CoupledVariableFluxBC.h"

registerMooseObject("catsApp", CoupledVariableFluxBC);

InputParameters CoupledVariableFluxBC::validParams()
{
  InputParameters params = IntegratedBC::validParams();
  params.addCoupledVar("fx",0.0,"Variable for flux in x-direction");
  params.addCoupledVar("fy",0.0,"Variable for flux in y-direction");
  params.addCoupledVar("fz",0.0,"Variable for flux in z-direction");
  return params;
}

CoupledVariableFluxBC::CoupledVariableFluxBC(const InputParameters & parameters) :
IntegratedBC(parameters),
_fx(coupledValue("fx")),
_fy(coupledValue("fy")),
_fz(coupledValue("fz")),
_fx_var(coupled("fx")),
_fy_var(coupled("fy")),
_fz_var(coupled("fz"))
{

}

Real CoupledVariableFluxBC::computeQpResidual()
{
	_flux(0)=_fx[_qp];
	_flux(1)=_fy[_qp];
	_flux(2)=_fz[_qp];

	return _test[_i][_qp]*(_flux*_normals[_qp]);
}

Real CoupledVariableFluxBC::computeQpJacobian()
{
	return 0.0;
}

Real CoupledVariableFluxBC::computeQpOffDiagJacobian(unsigned int jvar)
{
  _flux(0)=_fx[_qp];
	_flux(1)=_fy[_qp];
	_flux(2)=_fz[_qp];

	if (jvar == _fx_var)
	{
		return _test[_i][_qp]*(_phi[_j][_qp]*_normals[_qp](0));
	}

	if (jvar == _fy_var)
	{
		return _test[_i][_qp]*(_phi[_j][_qp]*_normals[_qp](1));
	}

	if (jvar == _fz_var)
	{
		return _test[_i][_qp]*(_phi[_j][_qp]*_normals[_qp](2));
	}

	return 0.0;
}
