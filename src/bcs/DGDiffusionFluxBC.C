/*!
 *  \file DGDiffusionFluxBC.h
 *	\brief Boundary Condition kernel apply diffusion flux at a boundary
 *	\details This file creates a boundary condition kernel to impose a diffusion flux
 *            boundary condition. Users can optionally provide a 'u_input' value for
 *            the value of the variable just outside the boundary. What this effectively
 *            does is impose of pseudo-Dirichlet BC at that boundary. By default, this
 *            value is taken to be zero, thus, material fluxes out of the box according
 *            to the given rate of diffusion.
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
 *	\date 11/12/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "DGDiffusionFluxBC.h"

registerMooseObject("catsApp", DGDiffusionFluxBC);

InputParameters DGDiffusionFluxBC::validParams()
{
    InputParameters params = IntegratedBC::validParams();
    params.addParam<Real>("sigma", 10.0, "sigma");
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
    params.addParam<Real>("u_input", 0.0, "value of u outside the boundary");
    return params;
}

DGDiffusionFluxBC::DGDiffusionFluxBC(const InputParameters & parameters) :
IntegratedBC(parameters),
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
_Dzz(getParam<Real>("Dzz")),
_u_input(getParam<Real>("u_input"))
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

Real
DGDiffusionFluxBC::computeQpResidual()
{
	Real r = 0;

	const unsigned int elem_b_order = static_cast<unsigned int> (_var.order());
	const double h_elem = _current_elem->volume()/_current_side_elem->volume() * 1./std::pow(elem_b_order, 2.);

  r += _test[_i][_qp]*(-_Diffusion*_grad_u[_qp])*_normals[_qp];
	r += _epsilon * (_u[_qp] - _u_input) * _Diffusion * _grad_test[_i][_qp] * _normals[_qp];
	r += _sigma/h_elem * (_u[_qp] - _u_input) * _test[_i][_qp];

	return r;
}

Real
DGDiffusionFluxBC::computeQpJacobian()
{
	Real r = 0;

	const unsigned int elem_b_order = static_cast<unsigned int> (_var.order());
	const double h_elem = _current_elem->volume()/_current_side_elem->volume() * 1./std::pow(elem_b_order, 2.);

  r += _test[_i][_qp]*(-_Diffusion*_grad_phi[_j][_qp])*_normals[_qp];
	r += _epsilon * (_phi[_j][_qp]) * _Diffusion * _grad_test[_i][_qp] * _normals[_qp];
	r += _sigma/h_elem * (_phi[_j][_qp]) * _test[_i][_qp];

	return r;
}
