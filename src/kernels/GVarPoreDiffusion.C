/*!
 *  \file GVarPoreDiffusion.h
 *	\brief Kernel for use with the corresponding DGVarPoreDiffusion object
 *	\details This file creates a standard MOOSE kernel that is to be used in conjunction with the DGVarPoreDiffusion kernel
 *			for the discontinous Galerkin formulation of diffusion physics in MOOSE. In order to complete the DG
 *			formulation of the diffusion physics, this kernel must be utilized with every variable that also uses
 *			the DGVariableDiffusion kernel.
 *
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic equations:
 *                    Theory and Implementation, SIAM, Houston, TX, 2008.
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

#include "GVarPoreDiffusion.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", GVarPoreDiffusion);

template<>
InputParameters validParams<GVarPoreDiffusion>()
{
	InputParameters params = validParams<GVariableDiffusion>();
  params.addRequiredCoupledVar("porosity","Variable for the porosity of the domain/subdomain");
	return params;
}

GVarPoreDiffusion::GVarPoreDiffusion(const InputParameters & parameters) :
GVariableDiffusion(parameters),
_porosity(coupledValue("porosity")),
_porosity_var(coupled("porosity"))
{

}

Real GVarPoreDiffusion::computeQpResidual()
{
  _Diffusion(0,0) = _Dx[_qp];
  _Diffusion(0,1) = 0.0;
  _Diffusion(0,2) = 0.0;

  _Diffusion(1,0) = 0.0;
  _Diffusion(1,1) = _Dy[_qp];
  _Diffusion(1,2) = 0.0;

  _Diffusion(2,0) = 0.0;
  _Diffusion(2,1) = 0.0;
  _Diffusion(2,2) = _Dz[_qp];

  return GAnisotropicDiffusion::computeQpResidual()*_porosity[_qp];
}

Real GVarPoreDiffusion::computeQpJacobian()
{
  _Diffusion(0,0) = _Dx[_qp];
  _Diffusion(0,1) = 0.0;
  _Diffusion(0,2) = 0.0;

  _Diffusion(1,0) = 0.0;
  _Diffusion(1,1) = _Dy[_qp];
  _Diffusion(1,2) = 0.0;

  _Diffusion(2,0) = 0.0;
  _Diffusion(2,1) = 0.0;
  _Diffusion(2,2) = _Dz[_qp];

	return GAnisotropicDiffusion::computeQpJacobian()*_porosity[_qp];
}

Real GVarPoreDiffusion::computeQpOffDiagJacobian(unsigned int jvar)
{
  _Diffusion(0,0) = _Dx[_qp];
  _Diffusion(0,1) = 0.0;
  _Diffusion(0,2) = 0.0;

  _Diffusion(1,0) = 0.0;
  _Diffusion(1,1) = _Dy[_qp];
  _Diffusion(1,2) = 0.0;

  _Diffusion(2,0) = 0.0;
  _Diffusion(2,1) = 0.0;
  _Diffusion(2,2) = _Dz[_qp];
  
  if (jvar == _Dx_var)
  {
    return _phi[_j][_qp]*_grad_test[_i][_qp](0)*_grad_u[_qp](0)*_porosity[_qp];
  }
  if (jvar == _Dy_var)
  {
    return _phi[_j][_qp]*_grad_test[_i][_qp](1)*_grad_u[_qp](1)*_porosity[_qp];
  }
  if (jvar == _Dz_var)
  {
    return _phi[_j][_qp]*_grad_test[_i][_qp](2)*_grad_u[_qp](2)*_porosity[_qp];
  }
  if (jvar == _porosity_var)
  {
    return _Diffusion*_grad_test[_i][_qp]*_grad_u[_qp]*_phi[_j][_qp];
  }
  return 0.0;
}
