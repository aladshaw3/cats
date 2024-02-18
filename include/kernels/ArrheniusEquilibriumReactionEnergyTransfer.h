/*!
 *  \file ArrheniusEquilibriumReactionEnergyTransfer.h
 *  \brief Kernel for creating an Arrhenius equilibrium reaction added to an energy phase residual
 *  \details This file creates a standard MOOSE kernel for the coupling a set of non-linear
 * variables to create an Arrhenius reaction acting on an energy balance. This kernel has a list of
 * reactants and a list of products, with corresponding lists for stoichiometric coefficients. The
 * residual for this kernel is as follows Res = - a*kf*prod(C_i, v_i) + a*kr*prod(C_j, v_j) where a
 * = scaling parameter, kf = forward rate, kr = reverse rate, v_i's = stoichiometry, and C_i's =
 * chemical species concentrations kf = Af * T * exp(-Ef/R/T) kr = kf/K       where K = exp(-dH/R/T
 * + dS/R)
 *
 *              For an energy balance, the scaling parameter (a) is the product of a volume
 * fraction, a av_ratio correction (optional), and the enthalpy of the reaction. a = -dH * av_ratio
 * * fv The av_ratio (m^-1) is used as a unit conversion if the reaction rate units are not in
 * mol/m^3 For instance, some surface reactions are given in mol/m^2, so the av_ratio represents the
 * ratio of the reactive surface area to the volume of the pellets/adsorbents.
 *
 *
 *  \author Austin Ladshaw
 *  \date 05/05/2020
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

#include "ArrheniusReactionEnergyTransfer.h"

/// ArrheniusEquilibriumReactionEnergyTransfer class object inherits from ArrheniusReactionEnergyTransfer object
class ArrheniusEquilibriumReactionEnergyTransfer : public ArrheniusReactionEnergyTransfer
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Required constructor for objects in MOOSE
  ArrheniusEquilibriumReactionEnergyTransfer(const InputParameters & parameters);

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

  Real _entropy; ///< Reaction entropy (J/K/mol)

private:
};
