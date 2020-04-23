/*!
 *  \file GAnisotropicDiffusion.h
 *	\brief Kernel for use with the corresponding DGAnisotropicDiffusion object
 *	\details This file creates a standard MOOSE kernel that is to be used in conjunction with the DGAnisotropicDiffusion kernel
 *			for the discontinous Galerkin formulation of advection physics in MOOSE. In order to complete the DG
 *			formulation of the advective physics, this kernel must be utilized with every variable that also uses
 *			the DGAAnisotropicDiffusion kernel.
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

#include "GAnisotropicDiffusion.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", GAnisotropicDiffusion);

/*
template<>
InputParameters validParams<GAnisotropicDiffusion>()
{
	InputParameters params = validParams<Kernel>();
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
 */

InputParameters GAnisotropicDiffusion::validParams()
{
    InputParameters params = Kernel::validParams();
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

GAnisotropicDiffusion::GAnisotropicDiffusion(const InputParameters & parameters) :
Kernel(parameters),
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
}

Real GAnisotropicDiffusion::computeQpResidual()
{
	return _Diffusion*_grad_test[_i][_qp]*_grad_u[_qp];
}

Real GAnisotropicDiffusion::computeQpJacobian()
{
	return _Diffusion*_grad_test[_i][_qp]*_grad_phi[_j][_qp];
}
