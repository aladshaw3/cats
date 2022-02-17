/*!
 *  \file GNSViscousVelocityDivergence.h
 *	\brief Kernel for use with the corresponding DGNSViscousVelocityDivergence object
 *	\details This file creates a standard MOOSE kernel that is to be used in conjunction with the DGNSViscousVelocityDivergence kernel
 *			for the discontinous Galerkin formulation of the 'extra' viscous term in compressible Navier-Stokes.
 *      This extra term is zero in the case where the divergence of velocity is zero (i.e., in the
 *       incompressible case).
 *
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic equations:
 *                    Theory and Implementation, SIAM, Houston, TX, 2008.
 *
 *  \author Austin Ladshaw
 *	\date 10/30/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "GNSViscousVelocityDivergence.h"

registerMooseObject("catsApp", GNSViscousVelocityDivergence);

InputParameters GNSViscousVelocityDivergence::validParams()
{
    InputParameters params = Kernel::validParams();
    params.addRequiredCoupledVar("ux","Variable for velocity in x-direction");
    params.addRequiredCoupledVar("uy","Variable for velocity in y-direction");
    params.addRequiredCoupledVar("uz","Variable for velocity in z-direction");
    params.addRequiredCoupledVar("viscosity","Variable for the viscosity of the domain/subdomain");
    params.addRequiredCoupledVar("this_variable","Name of this variable the kernel acts on");
    return params;
}

GNSViscousVelocityDivergence::GNSViscousVelocityDivergence(const InputParameters & parameters) :
Kernel(parameters),
_ux_grad(coupledGradient("ux")),
_uy_grad(coupledGradient("uy")),
_uz_grad(coupledGradient("uz")),
_ux_var(coupled("ux")),
_uy_var(coupled("uy")),
_uz_var(coupled("uz")),

_viscosity(coupledValue("viscosity")),
_viscosity_var(coupled("viscosity")),

_coupled_main_grad(coupledGradient("this_variable")),
_main_var(coupled("this_variable"))
{
    if (_main_var == _ux_var)
      _dir = 0;
    else if (_main_var == _uy_var)
      _dir = 1;
    else if (_main_var == _uz_var)
      _dir = 2;
    else
    {
      moose::internal::mooseErrorRaw("Supplied 'this_variable' argument does NOT correspond to a velocity component");
    }

    // Set up x-tensor
    _D_this_x(0,0) = 0.0;
  	_D_this_x(0,1) = 0.0;
  	_D_this_x(0,2) = 0.0;

  	_D_this_x(1,0) = 0.0;
  	_D_this_x(1,1) = 0.0;
  	_D_this_x(1,2) = 0.0;

  	_D_this_x(2,0) = 0.0;
  	_D_this_x(2,1) = 0.0;
  	_D_this_x(2,2) = 0.0;

    _D_this_x(_dir,0) = 1.0;

    // Set up y-tensor
    _D_this_y(0,0) = 0.0;
  	_D_this_y(0,1) = 0.0;
  	_D_this_y(0,2) = 0.0;

  	_D_this_y(1,0) = 0.0;
  	_D_this_y(1,1) = 0.0;
  	_D_this_y(1,2) = 0.0;

  	_D_this_y(2,0) = 0.0;
  	_D_this_y(2,1) = 0.0;
  	_D_this_y(2,2) = 0.0;

    _D_this_y(_dir,1) = 1.0;

    // Set up z-tensor
    _D_this_z(0,0) = 0.0;
  	_D_this_z(0,1) = 0.0;
  	_D_this_z(0,2) = 0.0;

  	_D_this_z(1,0) = 0.0;
  	_D_this_z(1,1) = 0.0;
  	_D_this_z(1,2) = 0.0;

  	_D_this_z(2,0) = 0.0;
  	_D_this_z(2,1) = 0.0;
  	_D_this_z(2,2) = 0.0;

    _D_this_z(_dir,2) = 1.0;
}

Real GNSViscousVelocityDivergence::computeQpResidual()
{
	return (1.0/3.0)*_viscosity[_qp]*_D_this_x*_grad_test[_i][_qp]*_ux_grad[_qp]
          + (1.0/3.0)*_viscosity[_qp]*_D_this_y*_grad_test[_i][_qp]*_uy_grad[_qp]
          + (1.0/3.0)*_viscosity[_qp]*_D_this_z*_grad_test[_i][_qp]*_uz_grad[_qp];
}

Real GNSViscousVelocityDivergence::computeQpJacobian()
{
  if (_dir == 0)
  {
    return (1.0/3.0)*_viscosity[_qp]*_D_this_x*_grad_test[_i][_qp]*_grad_phi[_j][_qp];
  }
  if (_dir == 1)
  {
    return (1.0/3.0)*_viscosity[_qp]*_D_this_y*_grad_test[_i][_qp]*_grad_phi[_j][_qp];
  }
  if (_dir == 2)
  {
    return (1.0/3.0)*_viscosity[_qp]*_D_this_z*_grad_test[_i][_qp]*_grad_phi[_j][_qp];
  }
	return 0.0;
}

Real GNSViscousVelocityDivergence::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _ux_var && jvar != _main_var)
	{
		return (1.0/3.0)*_viscosity[_qp]*_D_this_x*_grad_test[_i][_qp]*_grad_phi[_j][_qp];
	}

	if (jvar == _uy_var && jvar != _main_var)
	{
		return (1.0/3.0)*_viscosity[_qp]*_D_this_y*_grad_test[_i][_qp]*_grad_phi[_j][_qp];
	}

	if (jvar == _uz_var && jvar != _main_var)
	{
		return (1.0/3.0)*_viscosity[_qp]*_D_this_z*_grad_test[_i][_qp]*_grad_phi[_j][_qp];
	}

  if (jvar == _viscosity_var)
  {
    return (1.0/3.0)*_phi[_j][_qp]*_D_this_x*_grad_test[_i][_qp]*_ux_grad[_qp]
            + (1.0/3.0)*_phi[_j][_qp]*_D_this_y*_grad_test[_i][_qp]*_uy_grad[_qp]
            + (1.0/3.0)*_phi[_j][_qp]*_D_this_z*_grad_test[_i][_qp]*_uz_grad[_qp];
  }
  return 0.0;
}
