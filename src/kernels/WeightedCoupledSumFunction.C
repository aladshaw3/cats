/*!
 *  \file WeightedCoupledSumFunction.h
 *	\brief Standard kernel for coupling a vector non-linear variables via a weighted summation
 *	\details This file creates a standard MOOSE kernel for the coupling of a vector non-linear variables
 *			together to a variable whose value is to be determined by those coupled sums. This kernel is
 *      particularly useful if you have a variable that is a function of several different rate
 *      variables (e.g., dq/dt = r1 + 2*r2). In these cases, instead of rewriting each reaction
 *      kernel and redefining all parameters, you create a set of rate variables (r1, r2, etc), then
 *      coupled those rates to other non-linear variables and kernels.
 *
 *  \note This should be used in conjunction with a TimeDerivative or Reaction kernel inside of the
 *        input file to enfore that the variable is the weighted sum of the coupled variables
 *
 *        Reaction kernel ==>   Res(u) = u*test
 *        Coupled Sum     ==>   Res(u) = -(SUM(i, w_i * vars_i))*test
 *
 *  \author Austin Ladshaw
 *	\date 02/17/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "WeightedCoupledSumFunction.h"

registerMooseObject("catsApp", WeightedCoupledSumFunction);

InputParameters WeightedCoupledSumFunction::validParams()
{
    InputParameters params = Kernel::validParams();
    params.addRequiredCoupledVar("coupled_list","List of names of the variables being coupled");
    params.addParam< std::vector<Real> >("weights","List of weight factors in the sum");
    return params;
}

WeightedCoupledSumFunction::WeightedCoupledSumFunction(const InputParameters & parameters)
: Kernel(parameters),
_weight(getParam<std::vector<Real> >("weights"))
{
	unsigned int n = coupledComponents("coupled_list");
	_coupled_vars.resize(n);
	_coupled.resize(n);

  if (_coupled.size() != _weight.size())
  {
    moose::internal::mooseErrorRaw("User is required to provide list of variables of the same length as list of weights.");
  }

	for (unsigned int i = 0; i<_coupled.size(); ++i)
	{
		_coupled_vars[i] = coupled("coupled_list",i);
		_coupled[i] = &coupledValue("coupled_list",i);
	}

}

Real WeightedCoupledSumFunction::computeQpResidual()
{
  Real sum = 0.0;
  for (unsigned int i = 0; i<_coupled.size(); ++i)
    sum += (*_coupled[i])[_qp]*_weight[i];
  return -_test[_i][_qp]*sum;
}

Real WeightedCoupledSumFunction::computeQpJacobian()
{
	return 0.0;
}

Real WeightedCoupledSumFunction::computeQpOffDiagJacobian(unsigned int jvar)
{
  for (unsigned int i = 0; i<_coupled.size(); ++i)
	{
		if (jvar == _coupled_vars[i])
		{
			return -_test[_i][_qp]*_phi[_j][_qp]*_weight[i];
		}
	}

	return 0.0;
}
