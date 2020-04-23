/*!
 *  \file CoupledCoeffTimeDerivative.h
 *	\brief Standard kernel for coupling time derivatives
 *	\details This file creates a standard MOOSE kernel for the coupling of time derivative
 *			functions between different non-linear variables. It will serve as the basis
 *			for creating future heat and mass transfer kernels.
 *
 *  \author Austin Ladshaw
 *	\date 03/30/2017
 *	\copyright This kernel was designed and built at the Georgia Institute
 *             of Technology by Austin Ladshaw for PhD research in the area
 *             of adsorption and surface science and was developed for use
 *			   by Idaho National Laboratory and Oak Ridge National Laboratory
 *			   engineers and scientists. Portions Copyright (c) 2017, all
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

#include "CoupledCoeffTimeDerivative.h"

registerMooseObject("catsApp", CoupledCoeffTimeDerivative);

/*
template<>
InputParameters validParams<CoupledCoeffTimeDerivative>()
{
	InputParameters params = validParams<Kernel>();
	params.addParam<bool>("gaining",false,"If coupled time derivative is a sink term, then gaining = false");
	params.addParam<Real>("time_coeff",1.0,"Coefficient for the time derivative kernel");
	params.addRequiredCoupledVar("coupled","Name of the variable being coupled");
	return params;
}
 */

InputParameters CoupledCoeffTimeDerivative::validParams()
{
    InputParameters params = Kernel::validParams();
    params.addParam<bool>("gaining",false,"If coupled time derivative is a sink term, then gaining = false");
    params.addParam<Real>("time_coeff",1.0,"Coefficient for the time derivative kernel");
    params.addRequiredCoupledVar("coupled","Name of the variable being coupled");
    return params;
}

CoupledCoeffTimeDerivative::CoupledCoeffTimeDerivative(const InputParameters & parameters)
: Kernel(parameters),
	_gaining(getParam<bool>("gaining")),
	_time_coef(getParam<Real>("time_coeff")),
	_coupled_dot(coupledDot("coupled")),
	_coupled_ddot(coupledDotDu("coupled")),
	_coupled_var(coupled("coupled"))
{
	if (_gaining == true)
		_time_coef = -_time_coef;
}

Real CoupledCoeffTimeDerivative::computeQpResidual()
{
	return _time_coef*_coupled_dot[_qp]*_test[_i][_qp];
}

Real CoupledCoeffTimeDerivative::computeQpJacobian()
{
	return 0.0;
}

Real CoupledCoeffTimeDerivative::computeQpOffDiagJacobian(unsigned int jvar)
{
	if (jvar == _coupled_var)
		return _time_coef*_test[_i][_qp] * _phi[_j][_qp] * _coupled_ddot[_qp];

	return 0.0;
}
