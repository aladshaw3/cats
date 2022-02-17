/*!
 *  \file ModifiedButlerVolmerReaction.h
 *  \brief Kernel for creating a Butler-Volmer type of redox reaction
 *  \details This file creates a standard MOOSE kernel for the coupling a set of non-linear variables to
 *            create a Butler-Volmer redox reaction coupled with temperature, electric potential differences,
 *            and sets of 'reduced' and 'oxidized' state variables. Generically, this kernel represents
 *            the following reaction schema:
 *
 *                  R --> O + n*e-
 *
 *            where R = sum of reduced state variables, O = sum of oxidized state variables,
 *            n = number of electrons transferred, and e- represents an electron in the half-cell
 *            redox reaction.
 *
 *            Users would provide parameters for reaction rates and/or equilibrium cell potentials
 *            as well as variables for potential difference between electrode and electrolyte, which
 *            must be its own variable and calculated in another kernel.
 *
 *            Ref: R. O'Hare, S.W. Cha, W. Colella, F.B. Prinz, Fuel Cell Fundamentals, 3rd Ed. Wiley,
 *                  (2016) Ch. 3.
 *
 *
 *  \author Austin Ladshaw
 *  \date 11/22/2021
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

#include "Kernel.h"

/// ModifiedButlerVolmerReaction class object inherits from Kernel object
/** This class object inherits from the Kernel object in the MOOSE framework.
    All public and protected members of this class are required function overrides.
    The kernel interfaces the set of non-linear variables to create a kernel for a
    Butler-Volmer type reaction or chemical redox mechanism. */
class ModifiedButlerVolmerReaction : public Kernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    ModifiedButlerVolmerReaction(const InputParameters & parameters);

protected:
    ///Helper function for the oxidation rate (ka)
    Real oxidation_rate_fun();

    ///Helper function for the reduction rate (kc)
    Real reduction_rate_fun();

    ///Helper function for the oxidation rate (ka) derivative
    Real oxidation_rate_fun_derivative_with_temp();

    ///Helper function for the reduction rate (kc) derivative
    Real reduction_rate_fun_derivative_with_temp();

    /// Helper function for oxidation exponential
    Real oxidation_exp_fun();

    /// Helper function for reduction exponential
    Real reduction_exp_fun();

    /// Helper function for product of reduction state
    Real reduction_state();

    /// Helper function for product of oxidation state
    Real oxidation_state();

    /// Helper function for product of reduction state without the given index term
    Real reduction_state_without(unsigned int k);

    /// Helper function for product of reduction state without the given index term
    Real oxidation_state_without(unsigned int k);

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

    Real _oxidation_rate;                               ///< Rate constant for forward oxidation reaction
    Real _reduction_rate;                               ///< Rate constant for reverse reduction reaction

    Real _reaction_rate;                                ///< (optional) Alternative rate parameter
    Real _equ_pot;                                      ///< (optional) Equilibrium potential (in V or J/C)
    bool useEquilibriumPotential;                       ///< Boolean used to determine whether to use Equilibrium potential or not

    Real _alpha;                                        ///< Electron transfer coefficient (default = 0.5)
    Real _n;                                            ///< Number of electrons transferred (default = 1)

    Real _faraday;                                      ///< Value of Faraday's Constant (default = 96485.3 C/mol)
    Real _gas_const;                                    ///< Value of the Gas law constant (default = 8.314462 J/K/mol)

    Real _scale;                                        ///< Scaling parameter for the reaction
    std::vector<Real> _reduced_stoich;                  ///< Reduced-state Reactant list stoichiometries
    std::vector<Real> _oxidized_stoich;                 ///< Oxidized-state Product list stoichiometries
    std::vector<const VariableValue *> _reduced;        ///< Pointer list to the coupled reduced-state reactants
    std::vector<const VariableValue *> _oxidized;       ///< Pointer list to the coupled oxidized-state products
    std::vector<unsigned int> _reduced_vars;            ///< Indices for the coupled reduced-state reactants
    std::vector<unsigned int> _oxidized_vars;           ///< Indices for the coupled oxidized-state products

    const VariableValue & _temp;                        ///< temperature variable (in K)
    const unsigned int _temp_var;                       ///< Variable identification for the temperature

    const VariableValue & _pot_diff;                    ///< potential difference variable (in V or J/C)
    const unsigned int _pot_diff_var;                   ///< Variable identification for the temperature

private:

};
