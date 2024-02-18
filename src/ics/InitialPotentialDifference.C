/*!
 *  \file InitialPotentialDifference.h
 *    \brief Initial Condition kernel for the potential energy difference constraint/variable
 *    \details This file creates an initial condition for evaluating the initial condition for
 *              the potential difference between the electrode and electrolyte in a mixed-phase,
 *              volume-average domain. This kernel should be used in conjunction with initial
 *              conditions for the Butler-Volmer rate variable and current density variables.
 *              The sole purpose is to improve convergence behavior of the highly non-linear
 *              electrochemistry problem by establishing a 'close-enough' approximation to
 *              the starting state of the non-linear problem.
 *
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

#include "InitialPotentialDifference.h"

registerMooseObject("catsApp", InitialPotentialDifference);

InputParameters
InitialPotentialDifference::validParams()
{
  InputParameters params = InitialCondition::validParams();
  params.addRequiredCoupledVar("electrode_potential",
                               "Variable for the electrode potential (V or J/C)");
  params.addRequiredCoupledVar("electrolyte_potential",
                               "Variable for the electrolyte potential (V or J/C)");
  return params;
}

InitialPotentialDifference::InitialPotentialDifference(const InputParameters & parameters)
  : InitialCondition(parameters),
    _electrode_pot(coupledValue("electrode_potential")),
    _electrode_pot_var(coupled("electrode_potential")),
    _electrolyte_pot(coupledValue("electrolyte_potential")),
    _electrolyte_pot_var(coupled("electrolyte_potential"))
{
}

Real
InitialPotentialDifference::value(const Point & /*p*/)
{
  return _electrode_pot[_qp] - _electrolyte_pot[_qp];
}
