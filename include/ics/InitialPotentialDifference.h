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

#pragma once

#include "InitialCondition.h"

/// InitialPotentialDifference class object inherits from InitialCondition object
/** This class object inherits from the InitialCondition object.
    All public and protected members of this class are required function overrides. */
class InitialPotentialDifference : public InitialCondition
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Required constructor for BC objects in MOOSE
  InitialPotentialDifference(const InputParameters & parameters);

protected:
  /// Required function override for IC objects in MOOSE
  /** This function returns the value of the variable at point p in the mesh.*/
  virtual Real value(const Point & p) override;

  const VariableValue & _electrode_pot;   ///< Variable for the electrode potential (V or J/C)
  const unsigned int _electrode_pot_var;  ///< Variable identification for the electrode potential
  const VariableValue & _electrolyte_pot; ///< Variable for the electrolyte potential (V or J/C)
  const unsigned int
      _electrolyte_pot_var; ///< Variable identification for the electrolyte potential

private:
};
