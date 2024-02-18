/*!
 *  \file InhibitedArrheniusReaction.h
 *  \brief Kernel for creating an Arrhenius reaction coupled with an inhibition term
 *  \details This file creates a standard MOOSE kernel for the coupling a set of non-linear
 * variables to create an Arrhenius reaction coupled with temperature and an inhibition term. This
 * kernel has a list of reactants and a list of products, with corresponding lists for
 * stoichiometric coefficients. Additionally, it includes coupling for forward and reverse
 * inhibition terms. Those inhibition terms are coded as non-linear variables and can be defined
 * through other inhibition function kernels. The residual for this kernel is as follows Res = -
 * a*kf/Rf*prod(C_i, v_i) + a*kr/Rr*prod(C_j, v_j) where a = scaling parameter, kf = forward rate,
 * kr = reverse rate, v_i's = stoichiometry, and C_i's = chemical species concentrations kf = Af *
 * T^Bf * exp(-Ef/R/T) kr = Ar * T^Br * exp(-Er/R/T) Rf = forward inhibition term (unitless) Rr =
 * reverse inhibition term (unitless)
 *
 *
 *  \author Austin Ladshaw
 *  \date 09/18/2020
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

#ifndef Rstd
#define Rstd 8.3144621 ///< Gas Constant in J/K/mol (or) L*kPa/K/mol (Standard Units)
#endif

/// InhibitedArrheniusReaction class object inherits from ArrheniusReaction object
/** This class object inherits from the Kernel object in the MOOSE framework.
    All public and protected members of this class are required function overrides.
    The kernel interfaces the set of non-linear variables to create a kernel for an
    Arrhenius reaction. */
class InhibitedArrheniusReaction : public ArrheniusReaction
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Required constructor for objects in MOOSE
  InhibitedArrheniusReaction(const InputParameters & parameters);

protected:
  ///  Function to compute the rate constants
  void calculateInhibitedRateConstants();

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

  const VariableValue & _forward_inhibition; ///< Coupled forward inhibition variable (-)
  const unsigned int _Rf_var;                ///< Variable identification for Rf
  const VariableValue & _reverse_inhibition; ///< Coupled reverse inhibition variable (-)
  const unsigned int _Rr_var;                ///< Variable identification for Rr

private:
};
