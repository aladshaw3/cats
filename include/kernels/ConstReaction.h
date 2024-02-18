/*!
 *  \file ConstReaction.h
 *  \brief Kernel for creating a generic reaction with forward and/or reverse components
 *  \details This file creates a standard MOOSE kernel for the coupling a set of non-linear
 * variables to create a generic reaction with constant rate coefficients. This kernel has a list of
 * reactants and a list of products, with corresponding lists for stoichiometric coefficients.
 * Additionally, there is an option "scale" parameter that is useful when constructing an overall
 * reaction rate from a set of these kernels that represent a reaction pathway or mechanism. The
 * residual for this kernel is as follows Res = - a*kf*prod(C_i, v_i) + a*kr*prod(C_j, v_j) where a
 * = scaling parameter, kf = forward rate, kr = reverse rate, v_i's = stoichiometry, and C_i's =
 * chemical species concentrations
 *
 *
 *  \author Austin Ladshaw
 *  \date 03/25/2020
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

#include "Kernel.h"

/// ConstReaction class object inherits from Kernel object
/** This class object inherits from the Kernel object in the MOOSE framework.
    All public and protected members of this class are required function overrides.
    The kernel interfaces the set of non-linear variables to create a kernel for a
    reaction or chemical mechanism. */
class ConstReaction : public Kernel
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Required constructor for objects in MOOSE
  ConstReaction(const InputParameters & parameters);

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

  Real _forward_rate;                            ///< Rate constant for forward reaction
  Real _reverse_rate;                            ///< Rate constant for reverse reaction
  Real _scale;                                   ///< Scaling parameter for the reaction
  std::vector<Real> _react_stoich;               ///< Reactant list stoichiometries
  std::vector<Real> _prod_stoich;                ///< Product list stoichiometries
  std::vector<const VariableValue *> _reactants; ///< Pointer list to the coupled reactants
  std::vector<const VariableValue *> _products;  ///< Pointer list to the coupled products
  std::vector<unsigned int> _react_vars;         ///< Indices for the coupled reactants
  std::vector<unsigned int> _prod_vars;          ///< Indices for the coupled products
  const VariableValue & _coupled_main;           ///< Primary Coupled variable (i.e., diagonal)
  const unsigned int _main_var; ///< Variable identification for the main variable (i.e., diagonal)
  bool inReactList;             ///< Value is true if the main variable is the the reactant list
  bool inProdList;              ///< Value is true if the main variable is the the product list
  int indexReact;               ///< Local index for the main variable in the reactant list
  int indexProd;                ///< Local index for the main variable in the reactant list

private:
};
