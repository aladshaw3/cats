/*!
 *  \file InitialButlerVolmerCurrentDensity.h
 *    \brief Initial Condition kernel for a Butler-Volmer current density variable
 *    \details This file creates an initial condition kernel for evalulation of the
 *              initial state of the Butler-Volmer current density induced by a
 *              kinetics expression. Each current density variable will need an
 *              instance of this kernel. All the parameters should match those
 *              in the full system kernel for the given current density variable.
 *              The purpose of this kernel is to properly initialize the highly
 *              non-linear electrochemistry problem.
 *
 *  \author Austin Ladshaw
 *  \date 12/09/2021
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "InitialButlerVolmerCurrentDensity.h"

registerMooseObject("catsApp", InitialButlerVolmerCurrentDensity);

InputParameters
InitialButlerVolmerCurrentDensity::validParams()
{
  InputParameters params = InitialCondition::validParams();
  params.addRequiredCoupledVar(
      "rate_var",
      "Variable for reaction rate that exchanges electrons (moles / electrode area / time)");
  params.addCoupledVar(
      "specific_area",
      1.0,
      "Specific area for transfer [surface area of electrode / total volume] (m^-1)");

  params.addParam<Real>(
      "faraday_const", 96485.3, "Value of Faraday's constant (default = 96485.3 C/mol)");
  params.addParam<Real>(
      "number_of_electrons", 1.0, "Number of electrons transferred the redox reaction");
  return params;
}

InitialButlerVolmerCurrentDensity::InitialButlerVolmerCurrentDensity(
    const InputParameters & parameters)
  : InitialCondition(parameters),
    _rate(coupledValue("rate_var")),
    _rate_var(coupled("rate_var")),
    _specarea(coupledValue("specific_area")),
    _specarea_var(coupled("specific_area")),
    _n(getParam<Real>("number_of_electrons")),
    _faraday(getParam<Real>("faraday_const"))
{
}

Real
InitialButlerVolmerCurrentDensity::value(const Point & /*p*/)
{
  return _n * _specarea[_qp] * _faraday * (-_rate[_qp]);
}
