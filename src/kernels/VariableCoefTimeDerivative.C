/*!
 *  \file VariableCoefTimeDerivative.h
 *	\brief Kernel to create a time derivative that is linearly dependent on another variable
 *	\details This file creates a standard MOOSE kernel that is to be used to coupled another
 *          MOOSE variable with the current variable. An example of usage would be to couple
 *          a concentration time derivative with a variable for porosity if that porosity
 *          where a non-linear or linear function of space-time.
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

#include "VariableCoefTimeDerivative.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", VariableCoefTimeDerivative);

/*
template<>
InputParameters validParams<VariableCoefTimeDerivative>()
{
	InputParameters params = validParams<CoefTimeDerivative>();
	params.addRequiredCoupledVar("coupled_coef","Variable coefficient for the time derivative");
	return params;
}
 */

InputParameters VariableCoefTimeDerivative::validParams()
{
    InputParameters params = CoefTimeDerivative::validParams();
    params.addRequiredCoupledVar("coupled_coef","Variable coefficient for the time derivative");
    return params;
}

VariableCoefTimeDerivative::VariableCoefTimeDerivative(const InputParameters & parameters) :
CoefTimeDerivative(parameters),
_coupled(coupledValue("coupled_coef")),
_coupled_var(coupled("coupled_coef"))
{

}

Real VariableCoefTimeDerivative::computeQpResidual()
{
  _coef = _coupled[_qp];
  return CoefTimeDerivative::computeQpResidual();
}

Real VariableCoefTimeDerivative::computeQpJacobian()
{
  _coef = _coupled[_qp];
  return CoefTimeDerivative::computeQpJacobian();
}

Real VariableCoefTimeDerivative::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _coupled_var)
	{
		return _phi[_j][_qp]*_test[_i][_qp] * _u_dot[_qp];
	}
	return 0.0;
}
