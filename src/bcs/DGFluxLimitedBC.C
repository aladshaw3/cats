/*!
 *  \file DGFluxLimitedBC.h
 *	\brief Boundary Condition kernel to mimic a Dirichlet BC for DG methods
 *	\details This file creates a boundary condition kernel to impose a dirichlet-like boundary
 *			condition in DG methods. True DG methods do not have Dirichlet boundary conditions,
 *			so this kernel seeks to impose a constraint on the inlet of a boundary that is met
 *			if the value of a variable at the inlet boundary is equal to the finite element
 *			solution at that boundary. When the condition is not met, the residuals get penalyzed
 *			until the condition is met.
 *
 *      The DG method for diffusion involves 2 correction parameters:
 *
 *          (1) sigma - penalty term that should be >= 0 [if too large, it may cause errors]
 *          (2) epsilon - integer term with values of either -1, 0, or 1
 *
 *      Different values for epsilon result in slightly different discretizations:
 *
 *          (1) epsilon = -1   ==>   Symmetric Interior Penalty Galerkin (SIPG)
 *                                   Very efficient for symmetric problems, but may only
 *                                   converge if sigma is high.
 *          (2) epsilon = 0    ==>   Incomplete Interior Penalty Galerkin (IIPG)
 *                                   Works well for non-symmetic, well posed problems, but
 *                                   only converges under same sigma values as SIPG.
 *          (3) epsilon = 1    ==>   Non-symmetric Interior Penalty Galerking (NIPG)
 *                                   Most stable and easily convergable method that can
 *                                   work for symmetic and non-symmetric systems. Much
 *                                   less dependent on sigma values for convergence.
 *
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic equations:
 *                    Theory and Implementation, SIAM, Houston, TX, 2008.
 *
 *  \author Austin Ladshaw
 *	\date 11/20/2015
 *	\copyright This kernel was designed and built at the Georgia Institute
 *             of Technology by Austin Ladshaw for PhD research in the area
 *             of adsorption and surface science and was developed for use
 *			   by Idaho National Laboratory and Oak Ridge National Laboratory
 *			   engineers and scientists. Portions Copyright (c) 2015, all
 *             rights reserved.
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

#include "DGFluxLimitedBC.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", DGFluxLimitedBC);

template<>
InputParameters validParams<DGFluxLimitedBC>()
{
	InputParameters params = validParams<IntegratedBC>();
	params.addParam<Real>("sigma", 10.0, "sigma");
	MooseEnum dgscheme("sipg iipg nipg", "nipg");
  params.addParam<MooseEnum>("dg_scheme", dgscheme, "DG scheme options: nipg, iipg, sipg");
	params.addParam<Real>("vx",0, "x-component of velocity vector");
	params.addParam<Real>("vy",0,"y-component of velocity vector");
	params.addParam<Real>("vz",0,"z-component of velocity vector");
	params.addParam<Real>("Dxx",0,"xx-component of diffusion tensor");
	params.addParam<Real>("Dxy",0,"xy-component of diffusion tensor");
	params.addParam<Real>("Dxz",0,"xz-component of diffusion tensor");
	params.addParam<Real>("Dyx",0,"yx-component of diffusion tensor");
	params.addParam<Real>("Dyy",0,"yy-component of diffusion tensor");
	params.addParam<Real>("Dyz",0,"yz-component of diffusion tensor");
	params.addParam<Real>("Dzx",0,"zx-component of diffusion tensor");
	params.addParam<Real>("Dzy",0,"zy-component of diffusion tensor");
	params.addParam<Real>("Dzz",0,"zz-component of diffusion tensor");
	params.addParam<Real>("u_input", 1.0, "input value of u");
	return params;
}

DGFluxLimitedBC::DGFluxLimitedBC(const InputParameters & parameters) :
IntegratedBC(parameters),
_dg_scheme(getParam<MooseEnum>("dg_scheme")),
_sigma(getParam<Real>("sigma")),
_vx(getParam<Real>("vx")),
_vy(getParam<Real>("vy")),
_vz(getParam<Real>("vz")),
_Dxx(getParam<Real>("Dxx")),
_Dxy(getParam<Real>("Dxy")),
_Dxz(getParam<Real>("Dxz")),
_Dyx(getParam<Real>("Dyx")),
_Dyy(getParam<Real>("Dyy")),
_Dyz(getParam<Real>("Dyz")),
_Dzx(getParam<Real>("Dzx")),
_Dzy(getParam<Real>("Dzy")),
_Dzz(getParam<Real>("Dzz")),
_u_input(getParam<Real>("u_input"))
{
	_velocity(0)=_vx;
	_velocity(1)=_vy;
	_velocity(2)=_vz;

	_Diffusion(0,0) = _Dxx;
	_Diffusion(0,1) = _Dxy;
	_Diffusion(0,2) = _Dxz;

	_Diffusion(1,0) = _Dyx;
	_Diffusion(1,1) = _Dyy;
	_Diffusion(1,2) = _Dyz;

	_Diffusion(2,0) = _Dzx;
	_Diffusion(2,1) = _Dzy;
	_Diffusion(2,2) = _Dzz;

	if (_sigma < 0.0)
		_sigma = 0.0;

	switch (_dg_scheme)
	{
		//sipg
		case 0:
			_epsilon = -1.0;
			if (_sigma == 0.0)
				_sigma = 10.0;
			break;

		//iipg
		case 1:
			_epsilon = 0.0;
			if (_sigma == 0.0)
				_sigma = 10.0;
			break;

		//nipg
		case 2:
			_epsilon = 1.0;
			break;

		//nipg
		default:
			_epsilon = 1.0;
			break;
	}
}

Real
DGFluxLimitedBC::computeQpResidual()
{
	Real r = 0;

	const unsigned int elem_b_order = static_cast<unsigned int> (_var.order());
	const double h_elem = _current_elem->volume()/_current_side_elem->volume() * 1./std::pow(elem_b_order, 2.);

	//Output (Standard Flux Out)
	if ((_velocity)*_normals[_qp] > 0.0)
	{
		r += _test[_i][_qp]*(_velocity*_normals[_qp])*_u[_qp];
	}
	//Input (Dirichlet BC)
	else
	{
		r += _test[_i][_qp]*(_velocity*_normals[_qp])*_u_input;
		r -= _test[_i][_qp]*(_velocity*_normals[_qp])*(_u[_qp] - _u_input);
		r += _epsilon * (_u[_qp] - _u_input) * _Diffusion * _grad_test[_i][_qp] * _normals[_qp];
		r += _sigma/h_elem * (_u[_qp] - _u_input) * _test[_i][_qp];
		r -= (_Diffusion * _grad_u[_qp] * _normals[_qp] * _test[_i][_qp]);
	}

	return r;
}

Real
DGFluxLimitedBC::computeQpJacobian()
{
	Real r = 0;

	const unsigned int elem_b_order = static_cast<unsigned int> (_var.order());
	const double h_elem = _current_elem->volume()/_current_side_elem->volume() * 1./std::pow(elem_b_order, 2.);

	//Output (Standard Flux Out)
	if ((_velocity)*_normals[_qp] > 0.0)
	{
		r += _test[_i][_qp]*(_velocity*_normals[_qp])*_phi[_j][_qp];
	}
	//Input (Dirichlet BC)
	else
	{
		r += 0.0;
		r -= _test[_i][_qp]*(_velocity*_normals[_qp])*_phi[_j][_qp];
		r += _epsilon * _phi[_j][_qp] * _Diffusion * _grad_test[_i][_qp] * _normals[_qp];
		r += _sigma/h_elem * _phi[_j][_qp] * _test[_i][_qp];
		r -= (_Diffusion * _grad_phi[_j][_qp] * _normals[_qp] * _test[_i][_qp]);
	}

	return r;
}
