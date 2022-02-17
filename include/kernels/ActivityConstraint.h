/*!
 *  \file ActivityConstraint.h
 *  \brief Kernel for calculating activity of a chemical species based on activity coefficient and concentration
 *  \details This file creates a kernel for the coupling a concentration of a species (C)
 *            with an activity coefficient (gamma) through a reference concentration (Cref)
 *            in order to establish the activity of that species in solution or on a surface.
 *            The activity coefficient (gamma) should be a unitless number. The Cref concentration
 *            is generally either total concentration or a reference concentration for a given
 *            phase (e.g., in electrolyte chemistry, this is generally taken to be 1 M). The
 *            concentration for the species must have same units as Cref such that the calculated
 *            activity (a) is unitless.
 *
 *            To use this kernel, combine the 'Reaction' kernel with this 'ActivityConstraint'
 *            kernel to fully describe the constraint.
 *
 *            Reaction:                     test * -a = 0
 *            ActivityConstraint:           test * -gamma*(C/Cref) = 0
 *
 *                          where gamma = activity coefficient variable (unitless)
 *                                C = concentration variable (amount / volume)
 *                                Cref = given constant or calculated total concentration
 *                                      [Must have same units as C]
 *
 *
 *  \author Austin Ladshaw
 *  \date 02/02/2022
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

/// ActivityConstraint class object inherits from Kernel object
/** This class object inherits from the Kernel object in the MOOSE framework.
    All public and protected members of this class are required function overrides.
    The kernel interfaces the non-linear variable with other information
    to calculate activities in a given phase. */
class ActivityConstraint : public Kernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    ActivityConstraint(const InputParameters & parameters);

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

    const VariableValue & _gamma;          ///< Variable for activity coefficient
    const unsigned int _gamma_var;         ///< Variable identification for activity coefficent
    const VariableValue & _conc;           ///< Variable for concentration of species
    const unsigned int _conc_var;          ///< Variable identification for concentration
    const VariableValue & _ref_conc;       ///< Variable for reference/total concentration
    const unsigned int _ref_conc_var;      ///< Variable identification for reference concentration

private:

};
