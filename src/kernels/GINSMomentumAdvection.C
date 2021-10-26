/*!
 *  \file GINSMomentumAdvection.h
 *	\brief Kernel for use with the corresponding DGINSMomentumAdvection object
 *	\details This file creates a standard MOOSE kernel that is to be used in conjunction
 *            with DGINSMomentumAdvection for the discontinous Galerkin formulation of
 *            the momentum advection term in the Incompressible Navier-Stokes equation.
 *
 *  \author Austin Ladshaw
 *	\date 10/26/2021
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

#include "GINSMomentumAdvection.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", GINSMomentumAdvection);

InputParameters GINSMomentumAdvection::validParams()
{
    InputParameters params = GConcentrationAdvection::validParams();
    params.addRequiredCoupledVar("density","Variable for the density of the domain/subdomain");
    params.addRequiredCoupledVar("this_variable","Name of this variable the kernel acts on");
    return params;
}

GINSMomentumAdvection::GINSMomentumAdvection(const InputParameters & parameters) :
GConcentrationAdvection(parameters),
_density(coupledValue("density")),
_density_var(coupled("density")),
_coupled_main(coupledValue("this_variable")),
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
}

Real GINSMomentumAdvection::computeQpResidual()
{
	_velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

	return GAdvection::computeQpResidual()*_density[_qp];
}

Real GINSMomentumAdvection::computeQpJacobian()
{
  _velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

	return GAdvection::computeQpJacobian()*_density[_qp] + (-_u[_qp]*(_phi[_j][_qp]*_grad_test[_i][_qp](_dir))*_density[_qp]);
}

Real GINSMomentumAdvection::computeQpOffDiagJacobian(unsigned int jvar)
{
	_velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

	if (jvar == _ux_var && jvar != _main_var)
	{
		return -_u[_qp]*(_phi[_j][_qp]*_grad_test[_i][_qp](0))*_density[_qp];
	}

	if (jvar == _uy_var && jvar != _main_var)
	{
		return -_u[_qp]*(_phi[_j][_qp]*_grad_test[_i][_qp](1))*_density[_qp];
	}

	if (jvar == _uz_var && jvar != _main_var)
	{
		return -_u[_qp]*(_phi[_j][_qp]*_grad_test[_i][_qp](2))*_density[_qp];
	}

  if (jvar == _density_var)
  {
    return -_u[_qp]*(_velocity*_grad_test[_i][_qp])*_phi[_j][_qp];
  }

	return 0.0;
}
