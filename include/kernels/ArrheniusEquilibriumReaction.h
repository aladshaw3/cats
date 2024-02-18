/*!
 *  \file ArrheniusEquilibriumReaction.h
 *  \brief Kernel for creating an Arrhenius/Equilibrium reaction coupled with temperature
 *  \details This file creates a standard MOOSE kernel for the coupling a set of non-linear
 * variables to create an Arrhenius/Equilibrium reaction coupled with temperature. This kernel has a
 * list of reactants and a list of products, with corresponding lists for stoichiometric
 * coefficients. The residual for this kernel is as follows Res = - a*kf*prod(C_i, v_i) +
 * a*kr*prod(C_j, v_j) where a = scaling parameter, kf = forward rate, kr = reverse rate, v_i's =
 * stoichiometry, and C_i's = chemical species concentrations kf = Af * T * exp(-Ef/R/T) kr = kf/K
 * where K = exp(-dH/R/T + dS/R)
 *
 *  \note   This kernel requires both a forward and reverse reaction set of variables and the beta
 * parameters from the typical Arrhenius expression are assumed 0.
 *
 *
 *  \author Austin Ladshaw
 *  \date 04/01/2020
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#pragma once

#include "ArrheniusReaction.h"

/// ArrheniusEquilibriumReaction class object inherits from ArrheniusReaction object
class ArrheniusEquilibriumReaction : public ArrheniusReaction
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Required constructor for objects in MOOSE
  ArrheniusEquilibriumReaction(const InputParameters & parameters);

protected:
  /// Required residual function for standard kernels in MOOSE
  /** This function returns a residual contribution for this object.*/
  virtual Real computeQpResidual();

  /// Required Jacobian function for standard kernels in MOOSE
  /** This function returns a Jacobian contribution for this object. The Jacobian being
   computed is the associated diagonal element in the overall Jacobian matrix for the
   system and is used in preconditioning of the linear sub-problem. */
  virtual Real computeQpJacobian();

  /// Not Required, but aids in the preconditioning step
  /** This function returns the off diagonal Jacobian contribution for this object. By
   returning a non-zero value we will hopefully improve the convergence rate for the
   cross coupling of the variables. */
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  Real _enthalpy; ///< Reaction enthalpy (J/mol)
  Real _entropy;  ///< Reaction entropy (J/K/mol)

private:
};
