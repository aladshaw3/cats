/*!
 *  \file GConcentrationAdvection.h
 *	\brief Kernel for use with the corresponding DGConcentrationAdvection object
 *	\details This file creates a standard MOOSE kernel that is to be used in conjunction with DGConcentrationAdvection
 *			for the discontinous Galerkin formulation of momentum advection in MOOSE. In order to complete the DG
 *			formulation of the advective physics, this kernel must be utilized with every variable that also uses
 *			the DGConcentrationAdvection kernel.
 *
 *  \author Austin Ladshaw
 *	\date 07/12/2018
 *	\copyright This kernel was designed and built at the Georgia Institute
 *             of Technology by Austin Ladshaw for PhD research in the area
 *             of radioactive particle transport and settling following a
 *			   nuclear event. It was developed for the US DOD under DTRA
 *			   project No. 14-24-FRCWMD-BAA. Portions Copyright (c) 2018, all
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

#include "GConcentrationAdvection.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", GConcentrationAdvection);

template<>
InputParameters validParams<GConcentrationAdvection>()
{
	InputParameters params = validParams<GAdvection>();
	params.addRequiredCoupledVar("ux","Variable for velocity in x-direction");
	params.addRequiredCoupledVar("uy","Variable for velocity in y-direction");
	params.addRequiredCoupledVar("uz","Variable for velocity in z-direction");
	return params;
}

GConcentrationAdvection::GConcentrationAdvection(const InputParameters & parameters) :
GAdvection(parameters),
_ux(coupledValue("ux")),
_uy(coupledValue("uy")),
_uz(coupledValue("uz")),
_ux_var(coupled("ux")),
_uy_var(coupled("uy")),
_uz_var(coupled("uz"))
{

}

Real GConcentrationAdvection::computeQpResidual()
{
	_velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

	return GAdvection::computeQpResidual();
}

Real GConcentrationAdvection::computeQpJacobian()
{
	_velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

	return GAdvection::computeQpJacobian();
}

Real GConcentrationAdvection::computeQpOffDiagJacobian(unsigned int jvar)
{
	_velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

	if (jvar == _ux_var)
	{
		return -_u[_qp]*(_phi[_j][_qp]*_grad_test[_i][_qp](0));
	}

	if (jvar == _uy_var)
	{
		return -_u[_qp]*(_phi[_j][_qp]*_grad_test[_i][_qp](1));
	}

	if (jvar == _uz_var)
	{
		return -_u[_qp]*(_phi[_j][_qp]*_grad_test[_i][_qp](2));
	}

	return 0.0;
}
