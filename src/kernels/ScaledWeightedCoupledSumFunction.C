/*!
 *  \file ScaledWeightedCoupledSumFunction.h
 *	\brief Standard kernel for coupling a vector non-linear variables via a weighted summation with
 *scaling \details This file creates a standard MOOSE kernel for the coupling of a vector non-linear
 *variables together to a variable whose value is to be determined by those coupled sums with
 *scaling. This kernel is particularly useful if you have a variable that is a function of several
 *different rate variables (e.g., dq/dt = r1 + 2*r2). In these cases, instead of rewriting each
 *reaction kernel and redefining all parameters, you create a set of rate variables (r1, r2, etc),
 *then coupled those rates to other non-linear variables and kernels.
 *
 *  \note The difference between this kernel and the 'WeightedCoupledSumFunction', which it inherits
 *        from, is that this function is multiplied by a common 'scale' variable. Typically, that
 *'scale' would be used as a unit conversion between mass balances. For instance, in a series of
 *surface reaction that impact some bulk concentration, the 'scale' factor applied to all reactions
 *        would be the surface-to-volume ratio or the solids-to-total_volume ratio.
 *
 *  \note This should be used in conjunction with a TimeDerivative or Reaction kernel inside of the
 *        input file to enfore that the variable is the weighted sum of the coupled variables
 *
 *        Reaction kernel ==>   Res(u) = u*test
 *        Coupled Sum     ==>   Res(u) = -scale*(SUM(i, w_i * vars_i))*test
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

#include "ScaledWeightedCoupledSumFunction.h"

registerMooseObject("catsApp", ScaledWeightedCoupledSumFunction);

InputParameters
ScaledWeightedCoupledSumFunction::validParams()
{
  InputParameters params = WeightedCoupledSumFunction::validParams();
  params.addCoupledVar("scale", 1, "Scaling value or scale variable for weighted sum.");
  return params;
}

ScaledWeightedCoupledSumFunction::ScaledWeightedCoupledSumFunction(
    const InputParameters & parameters)
  : WeightedCoupledSumFunction(parameters),
    _scale(coupledValue("scale")),
    _scale_var(coupled("scale"))
{
}

Real
ScaledWeightedCoupledSumFunction::computeQpResidual()
{
  return WeightedCoupledSumFunction::computeQpResidual() * _scale[_qp];
}

Real
ScaledWeightedCoupledSumFunction::computeQpJacobian()
{
  return 0.0;
}

Real
ScaledWeightedCoupledSumFunction::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _scale_var)
  {
    return WeightedCoupledSumFunction::computeQpResidual() * _phi[_j][_qp];
  }
  else
  {
    return WeightedCoupledSumFunction::computeQpOffDiagJacobian(jvar) * _scale[_qp];
  }
}
