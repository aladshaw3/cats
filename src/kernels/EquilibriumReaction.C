/*!
 *  \file EquilibriumReaction.h
 *  \brief Kernel for creating an equilibrium reaction coupled with temperature
 *  \details This file creates a standard MOOSE kernel for the coupling a set of non-linear
 * variables to create an equilibrium reaction coupled with temperature. This kernel has a list of
 * reactants and a list of products, with corresponding lists for stoichiometric coefficients. The
 * residual for this kernel is as follows Res = - K*prod(C_i, v_i) + prod(C_j, v_j) where a =
 * scaling parameter, kf = forward rate, kr = reverse rate, v_i's = stoichiometry, and C_i's =
 * chemical species concentrations K = exp(-dH/R/T + dS/R)
 *
 *
 *  \author Austin Ladshaw
 *  \date 03/31/2020
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "EquilibriumReaction.h"

registerMooseObject("catsApp", EquilibriumReaction);

InputParameters
EquilibriumReaction::validParams()
{
  InputParameters params = ConstReaction::validParams();
  params.addParam<Real>("enthalpy", 0.0, "Reaction enthalpy (J/mol)");
  params.addParam<Real>("entropy", 0.0, "Reaction entropy (J/K/mol)");
  params.addRequiredCoupledVar("temperature", "Name of the coupled temperature variable (K)");
  return params;
}

EquilibriumReaction::EquilibriumReaction(const InputParameters & parameters)
  : ConstReaction(parameters),
    _enthalpy(getParam<Real>("enthalpy")),
    _entropy(getParam<Real>("entropy")),
    _temp(coupledValue("temperature")),
    _temp_var(coupled("temperature"))
{
  _scale = 1.0;
  _reverse_rate = 1.0;

  if (_reactants.size() == 0)
    moose::internal::mooseErrorRaw("EquilibriumReaction requires at least 1 reactant!");
  if (_products.size() == 0)
    moose::internal::mooseErrorRaw("EquilibriumReaction requires at least 1 product!");
}

void
EquilibriumReaction::calculateEquilibriumConstant()
{
  _forward_rate = std::exp(lnKo(_enthalpy, _entropy, _temp[_qp]));
}

Real
EquilibriumReaction::computeQpResidual()
{
  calculateEquilibriumConstant();
  return ConstReaction::computeQpResidual();
}

Real
EquilibriumReaction::computeQpJacobian()
{
  calculateEquilibriumConstant();
  return ConstReaction::computeQpJacobian();
}

Real
EquilibriumReaction::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _temp_var)
  {
    calculateEquilibriumConstant();
    Real react_prod = 1.0;
    if (_reactants.size() == 0)
      react_prod = 0.0;
    for (unsigned int i = 0; i < _reactants.size(); ++i)
    {
      react_prod = react_prod * std::pow((*_reactants[i])[_qp], _react_stoich[i]);
    }
    return -_scale * react_prod * _forward_rate * (_enthalpy / Rstd / _temp[_qp] / _temp[_qp]) *
           _phi[_j][_qp];
  }
  else
  {
    calculateEquilibriumConstant();
    return ConstReaction::computeQpOffDiagJacobian(jvar);
  }
}
