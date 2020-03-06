/*!
 *  \file DGAnisotropicDiffusion.h
 *	\brief Discontinous Galerkin kernel for anisotropic diffusion
 *	\details This file creates a discontinous Galerkin kernel for anisotropic diffusion in a given domain. It is a generic
 *			diffusion kernel that is meant to be inherited from to make a more specific kernel for a given problem. The
 *			physical parameter in this kernel's formulation is a diffusion tensor. That tensor can be built piecewise by
 *			the respective components of the tensor at a given quadrature point.
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
 *	\note Any DG kernel under DGOSPREY will have a cooresponding G kernel (usually of same name) that must be included
 *		with the DG kernel in the input file. This is because the DG finite element method breaks into several different
 *		residual pieces, only a handful of which are handled by the DG kernel system and the other parts must be handled
 *		by the standard Galerkin system. This my be due to some legacy code in MOOSE. I am not sure if it is possible to
 *		lump all of these actions into a single DG kernel.
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

#include "DGAnisotropicDiffusion.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", DGAnisotropicDiffusion);

template<>
InputParameters validParams<DGAnisotropicDiffusion>()
{
	InputParameters params = validParams<DGKernel>();
	params.addParam<Real>("sigma", 10.0, "sigma penalty value (>=0 for NIPG, but >0 for others)");
	MooseEnum dgscheme("sipg iipg nipg", "nipg");
  params.addParam<MooseEnum>("dg_scheme", dgscheme, "DG scheme options: nipg, iipg, sipg");
	params.addParam<Real>("Dxx",0,"xx-component of diffusion tensor");
	params.addParam<Real>("Dxy",0,"xy-component of diffusion tensor");
	params.addParam<Real>("Dxz",0,"xz-component of diffusion tensor");
	params.addParam<Real>("Dyx",0,"yx-component of diffusion tensor");
	params.addParam<Real>("Dyy",0,"yy-component of diffusion tensor");
	params.addParam<Real>("Dyz",0,"yz-component of diffusion tensor");
	params.addParam<Real>("Dzx",0,"zx-component of diffusion tensor");
	params.addParam<Real>("Dzy",0,"zy-component of diffusion tensor");
	params.addParam<Real>("Dzz",0,"zz-component of diffusion tensor");
	return params;
}

DGAnisotropicDiffusion::DGAnisotropicDiffusion(const InputParameters & parameters) :
DGKernel(parameters),
_dg_scheme(getParam<MooseEnum>("dg_scheme")),
_sigma(getParam<Real>("sigma")),
_Dxx(getParam<Real>("Dxx")),
_Dxy(getParam<Real>("Dxy")),
_Dxz(getParam<Real>("Dxz")),
_Dyx(getParam<Real>("Dyx")),
_Dyy(getParam<Real>("Dyy")),
_Dyz(getParam<Real>("Dyz")),
_Dzx(getParam<Real>("Dzx")),
_Dzy(getParam<Real>("Dzy")),
_Dzz(getParam<Real>("Dzz"))
{
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

Real DGAnisotropicDiffusion::computeQpResidual(Moose::DGResidualType type)
{
	Real r = 0;

	const unsigned int elem_b_order = static_cast<unsigned int> (_var.order());
	const double h_elem = _current_elem->volume()/_current_side_elem->volume() * 1./std::pow(elem_b_order, 2.);

	switch (type)
	{
		case Moose::Element:
			r -= 0.5 * (_Diffusion * _grad_u[_qp] * _normals[_qp] +
						_Diffusion * _grad_u_neighbor[_qp] * _normals[_qp]) *
			_test[_i][_qp];
			r += _epsilon * 0.5 * (_u[_qp] - _u_neighbor[_qp]) * _Diffusion * _grad_test[_i][_qp] *
			_normals[_qp];
			r += _sigma / h_elem * (_u[_qp] - _u_neighbor[_qp]) * _test[_i][_qp];
			break;

		case Moose::Neighbor:
			r += 0.5 * (_Diffusion * _grad_u[_qp] * _normals[_qp] +
						_Diffusion * _grad_u_neighbor[_qp] * _normals[_qp]) *
			_test_neighbor[_i][_qp];
			r += _epsilon * 0.5 * (_u[_qp] - _u_neighbor[_qp]) * _Diffusion *
			_grad_test_neighbor[_i][_qp] * _normals[_qp];
			r -= _sigma / h_elem * (_u[_qp] - _u_neighbor[_qp]) * _test_neighbor[_i][_qp];
			break;
	}

	return r;
}

Real DGAnisotropicDiffusion::computeQpJacobian(Moose::DGJacobianType type)
{
	Real r = 0;

	const unsigned int elem_b_order = static_cast<unsigned int> (_var.order());
	const double h_elem = _current_elem->volume()/_current_side_elem->volume() * 1./std::pow(elem_b_order, 2.);

	switch (type)
	{

		case Moose::ElementElement:
			r -= 0.5 * _Diffusion * _grad_phi[_j][_qp] * _normals[_qp] * _test[_i][_qp];
			r += _epsilon * 0.5 * _phi[_j][_qp] * _Diffusion * _grad_test[_i][_qp] * _normals[_qp];
			r += _sigma / h_elem * _phi[_j][_qp] * _test[_i][_qp];
			break;

		case Moose::ElementNeighbor:
			r -= 0.5 * _Diffusion * _grad_phi_neighbor[_j][_qp] * _normals[_qp] * _test[_i][_qp];
			r += _epsilon * 0.5 * -_phi_neighbor[_j][_qp] * _Diffusion * _grad_test[_i][_qp] *
			_normals[_qp];
			r += _sigma / h_elem * -_phi_neighbor[_j][_qp] * _test[_i][_qp];
			break;

		case Moose::NeighborElement:
			r += 0.5 * _Diffusion * _grad_phi[_j][_qp] * _normals[_qp] * _test_neighbor[_i][_qp];
			r += _epsilon * 0.5 * _phi[_j][_qp] * _Diffusion * _grad_test_neighbor[_i][_qp] *
			_normals[_qp];
			r -= _sigma / h_elem * _phi[_j][_qp] * _test_neighbor[_i][_qp];
			break;

		case Moose::NeighborNeighbor:
			r += 0.5 * _Diffusion * _grad_phi_neighbor[_j][_qp] * _normals[_qp] *
			_test_neighbor[_i][_qp];
			r += _epsilon * 0.5 * -_phi_neighbor[_j][_qp] * _Diffusion *
			_grad_test_neighbor[_i][_qp] * _normals[_qp];
			r -= _sigma / h_elem * -_phi_neighbor[_j][_qp] * _test_neighbor[_i][_qp];
			break;
	}

	return r;
}
