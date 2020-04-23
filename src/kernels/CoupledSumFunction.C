/*!
 *  \file CoupledSumFunction.h
 *	\brief Standard kernel for coupling a vector non-linear variables via summation function
 *	\details This file creates a standard MOOSE kernel for the coupling of a vector non-linear variables
 *			together to a variable whose value is to be determined by those coupled sums. This kernel is
 *      particularly useful if you have something like a heterogenous sorption problem and you want
 *      track individually the sorbed species on each type of surface site, but also want to couple
 *      to all surface sites through a single total adsorption value.
 *
 *  \note This should be used in conjunction with a TimeDerivative or Reaction kernel inside of the
 *        input file to enfore that the variable is the sum of the coupled variables
 *
 *        Reaction kernel ==>   Res(u) = u*test
 *        Coupled Sum     ==>   Res(u) = -(SUM(vars))*test
 *
 *  \author Austin Ladshaw
 *	\date 03/10/2020
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

#include "CoupledSumFunction.h"


registerMooseObject("catsApp", CoupledSumFunction);

/*
template<>
InputParameters validParams<CoupledSumFunction>()
{
	InputParameters params = validParams<Kernel>();
	params.addRequiredCoupledVar("coupled_list","List of names of the variables being coupled");
	return params;
}
 */

InputParameters CoupledSumFunction::validParams()
{
    InputParameters params = Kernel::validParams();
    params.addRequiredCoupledVar("coupled_list","List of names of the variables being coupled");
    return params;
}

CoupledSumFunction::CoupledSumFunction(const InputParameters & parameters)
: Kernel(parameters)
{
	unsigned int n = coupledComponents("coupled_list");
	_coupled_vars.resize(n);
	_coupled.resize(n);

	for (unsigned int i = 0; i<_coupled.size(); ++i)
	{
		_coupled_vars[i] = coupled("coupled_list",i);
		_coupled[i] = &coupledValue("coupled_list",i);
	}

}

Real CoupledSumFunction::computeQpResidual()
{
  Real sum = 0.0;
  for (unsigned int i = 0; i<_coupled.size(); ++i)
    sum += (*_coupled[i])[_qp];
  return -_test[_i][_qp]*sum;
}

Real CoupledSumFunction::computeQpJacobian()
{
	return 0.0;
}

Real CoupledSumFunction::computeQpOffDiagJacobian(unsigned int jvar)
{
  for (unsigned int i = 0; i<_coupled.size(); ++i)
	{
		if (jvar == _coupled_vars[i])
		{
			return -_test[_i][_qp]*_phi[_j][_qp];
		}
	}

	return 0.0;
}
