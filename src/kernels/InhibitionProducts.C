/*!
 *  \file InhibitionProducts.h
 *  \brief Kernel for creating a function which computes the product of a list of inhibition
 * variables \details This file creates a standard MOOSE kernel for the coupling a set of non-linear
 * inhibition variables to create a generic function whose resolution is the products of those
 * variables raised to specific powers. The intent of this is to create more complex inhibition
 * terms for heterogenous reactions. The residual for this kernel is as follows Res = - prod(R_i,
 * p_i) where R_i is the i-th inhibition term and p_i is the power for that term
 *
 *  \note This should be used in conjunction with a Reaction kernel inside of the
 *        input file to enfore that the inhibition variable value equals this function. The reason
 * it is done in this fashion is so that it will be more modular in how the inhibition variable R
 * could be represented if multiple instances of these objects are necessary to define its behavior
 *
 *        Reaction kernel ==>     Res(R) = R*test
 *        Inhibition Products ==> Res(R) = -InhibitionProducts*test
 *
 *  \author Austin Ladshaw
 *  \date 09/22/2020
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "InhibitionProducts.h"

registerMooseObject("catsApp", InhibitionProducts);

InputParameters
InhibitionProducts::validParams()
{
  InputParameters params = Kernel::validParams();
  params.addRequiredParam<std::vector<Real>>("power_list",
                                             "List of powers for coupled inhibition terms");
  params.addRequiredCoupledVar("coupled_list", "List of names of the inhibition variables");
  return params;
}

InhibitionProducts::InhibitionProducts(const InputParameters & parameters)
  : Kernel(parameters), _power(getParam<std::vector<Real>>("power_list"))
{
  unsigned int r = coupledComponents("coupled_list");
  _inhibition_vars.resize(r);
  _inhibition.resize(r);

  if (_inhibition.size() != _power.size())
  {
    moose::internal::mooseErrorRaw("User is required to provide (at minimum) a list of power "
                                   "factors equal to the number of coupled inhibition terms.");
  }

  for (unsigned int i = 0; i < _inhibition.size(); ++i)
  {
    _inhibition_vars[i] = coupled("coupled_list", i);
    _inhibition[i] = &coupledValue("coupled_list", i);
  }
}

Real
InhibitionProducts::computeQpResidual()
{
  Real res = 0.0;
  Real prod = 1.0;
  if (_inhibition.size() == 0)
    prod = 0.0;
  for (unsigned int i = 0; i < _inhibition.size(); ++i)
  {
    prod = prod * std::pow((*_inhibition[i])[_qp], _power[i]);
  }
  res = -prod * _test[_i][_qp];
  return res;
}

Real
InhibitionProducts::computeQpJacobian()
{
  // The total inhibition term should not be a function of itself
  return 0.0;
}

Real
InhibitionProducts::computeQpOffDiagJacobian(unsigned int jvar)
{
  Real prod = 1.0;
  if (_inhibition.size() == 0)
    prod = 0.0;
  bool exists = false;
  for (unsigned int i = 0; i < _inhibition.size(); ++i)
  {
    if (jvar != _inhibition_vars[i])
    {
      prod = prod * std::pow((*_inhibition[i])[_qp], _power[i]);
    }
    else
    {
      exists = true;
      prod = prod * std::pow((*_inhibition[i])[_qp], _power[i] - 1.0) * _power[i] * _phi[_j][_qp];
    }
  }

  if (exists == true)
    return -prod * _test[_i][_qp];
  else
    return 0.0;
}
