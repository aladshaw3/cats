/*!
 *  \file InitialModifiedButlerVolmerReaction.h
 *    \brief Initial Condition kernel for a Butler-Volmer reaction rate variable
 *    \details This file creates an initial condition kernel for evalulation of the
 *              initial state of the reaction rate of the modified Butler-Volmer
 *              kinetics expression. Each reaction rate variable will need an
 *              instance of this kernel. All the parameters should match those
 *              in the full system kernel for the given reaction rate variable.
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

#pragma once

#include "InitialCondition.h"

/// InitialModifiedButlerVolmerReaction class object inherits from InitialCondition object
/** This class object inherits from the InitialCondition object.
    All public and protected members of this class are required function overrides. */
class InitialModifiedButlerVolmerReaction : public InitialCondition
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Required constructor for BC objects in MOOSE
  InitialModifiedButlerVolmerReaction(const InputParameters & parameters);

protected:
  ///Helper function for the oxidation rate (ka)
  Real oxidation_rate_fun();

  ///Helper function for the reduction rate (kc)
  Real reduction_rate_fun();

  /// Helper function for oxidation exponential
  Real oxidation_exp_fun();

  /// Helper function for reduction exponential
  Real reduction_exp_fun();

  /// Helper function for product of reduction state
  Real reduction_state();

  /// Helper function for product of oxidation state
  Real oxidation_state();

  /// Required function override for IC objects in MOOSE
  /** This function returns the value of the variable at point p in the mesh.*/
  virtual Real value(const Point & p) override;

  Real _oxidation_rate; ///< Rate constant for forward oxidation reaction
  Real _reduction_rate; ///< Rate constant for reverse reduction reaction

  Real _reaction_rate; ///< (optional) Alternative rate parameter
  Real _equ_pot;       ///< (optional) Equilibrium potential (in V or J/C)
  bool
      useEquilibriumPotential; ///< Boolean used to determine whether to use Equilibrium potential or not

  Real _alpha; ///< Electron transfer coefficient (default = 0.5)
  Real _n;     ///< Number of electrons transferred (default = 1)

  Real _faraday;   ///< Value of Faraday's Constant (default = 96485.3 C/mol)
  Real _gas_const; ///< Value of the Gas law constant (default = 8.314462 J/K/mol)

  Real _scale;                        ///< Scaling parameter for the reaction
  std::vector<Real> _reduced_stoich;  ///< Reduced-state Reactant list stoichiometries
  std::vector<Real> _oxidized_stoich; ///< Oxidized-state Product list stoichiometries
  std::vector<const VariableValue *>
      _reduced; ///< Pointer list to the coupled reduced-state reactants
  std::vector<const VariableValue *>
      _oxidized;                            ///< Pointer list to the coupled oxidized-state products
  std::vector<unsigned int> _reduced_vars;  ///< Indices for the coupled reduced-state reactants
  std::vector<unsigned int> _oxidized_vars; ///< Indices for the coupled oxidized-state products

  const VariableValue & _temp;  ///< temperature variable (in K)
  const unsigned int _temp_var; ///< Variable identification for the temperature

  const VariableValue & _pot_diff;  ///< potential difference variable (in V or J/C)
  const unsigned int _pot_diff_var; ///< Variable identification for the temperature

private:
};
