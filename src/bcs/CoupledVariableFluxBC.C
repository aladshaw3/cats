/*!
 *  \file CoupledVariableFluxBC.h
 *	\brief Boundary Condition kernel for flux of material leaving/entering a domain
 *  \details A Flux BC which is consistent with the boundary terms arising from
 *            any flux of material into or out of a domain. The determination of
 *            whether the domain is an input or output domain is made on the fly
 *            by looking at the sign of the dot product between the flux vector
 *            and the normals of the domain.
 *
 *            [OUTPUT]
 *            if ((_flux)*_normals[_qp] > 0.0)
 *                Res = _test[_i][_qp]*(_flux*_normals[_qp]);
 *            [INPUT]
 *             else
 *                Res = _test[_i][_qp]*(_flux_in*_normals[_qp]); //Default to zero
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

/****************************************************************/
/*               DO NOT MODIFY THIS HEADER                      */
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*           (c) 2010 Battelle Energy Alliance, LLC             */
/*                   ALL RIGHTS RESERVED                        */
/*                                                              */
/*          Prepared by Battelle Energy Alliance, LLC           */
/*            Under Contract No. DE-AC07-05ID14517              */
/*            With the U. S. Department of Energy               */
/*                                                              */
/*            See COPYRIGHT for full restrictions               */
/****************************************************************/

#include "CoupledVariableFluxBC.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", CoupledVariableFluxBC);

InputParameters CoupledVariableFluxBC::validParams()
{
    InputParameters params = IntegratedBC::validParams();
    params.addRequiredCoupledVar("fx","Variable for flux in x-direction");
    params.addRequiredCoupledVar("fy","Variable for flux in y-direction");
    params.addRequiredCoupledVar("fz","Variable for flux in z-direction");
    params.addParam<Real>("fx_in",0,"x-component of inlet flux vector");
    params.addParam<Real>("fy_in",0,"y-component of inlet flux vector");
    params.addParam<Real>("fz_in",0,"z-component of inlet flux vector");
    return params;
}

CoupledVariableFluxBC::CoupledVariableFluxBC(const InputParameters & parameters) :
IntegratedBC(parameters),
_fx(coupledValue("fx")),
_fy(coupledValue("fy")),
_fz(coupledValue("fz")),
_fx_var(coupled("fx")),
_fy_var(coupled("fy")),
_fz_var(coupled("fz")),

_fx_in(getParam<Real>("fx_in")),
_fy_in(getParam<Real>("fy_in")),
_fz_in(getParam<Real>("fz_in"))
{
  _flux_in(0)=_fx_in;
	_flux_in(1)=_fy_in;
	_flux_in(2)=_fz_in;
}

Real CoupledVariableFluxBC::computeQpResidual()
{
	_flux(0)=_fx[_qp];
	_flux(1)=_fy[_qp];
	_flux(2)=_fz[_qp];

	Real r = 0;

	//Output
	if ((_flux)*_normals[_qp] > 0.0)
	{
		r += _test[_i][_qp]*(_flux*_normals[_qp]);
	}
	//Input
	else
	{
		r += _test[_i][_qp]*(_flux_in*_normals[_qp]);
	}

	return r;
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

	Real r = 0;

	if (jvar == _fx_var)
	{
		//Output
		if ((_flux)*_normals[_qp] > 0.0)
		{
			r += _test[_i][_qp]*(_phi[_j][_qp]*_normals[_qp](0));
		}
		//Input
		else
		{
			r += 0;
		}
		return r;
	}

	if (jvar == _fy_var)
	{
		//Output
		if ((_flux)*_normals[_qp] > 0.0)
		{
			r += _test[_i][_qp]*(_phi[_j][_qp]*_normals[_qp](1));
		}
		//Input
		else
		{
			r += 0;
		}
		return r;
	}

	if (jvar == _fz_var)
	{
		//Output
		if ((_flux)*_normals[_qp] > 0.0)
		{
			r += _test[_i][_qp]*(_phi[_j][_qp]*_normals[_qp](2));
		}
		//Input
		else
		{
			r += 0;
		}
		return r;
	}

	return 0.0;
}
