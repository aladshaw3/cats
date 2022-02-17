/*!
 *  \file MaterialBalance.h
 *  \brief Kernel for creating a material balance kernel
 *  \details This file creates a standard MOOSE kernel for the coupling a set of non-linear variables to
 *            resolve a material balance equation. This kernel is usually used with sets of chemical reactions
 *            to close the system of equations for the chemistry in a given system.
 *            The residual is as follows...
 *                      Res = CT - sum(b_i, C_i)
 *                      where CT = total concentration, b_i is a weight parameter, and C_i is a component of CT
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

/// MaterialBalance class object inherits from Kernel object
/** This class object inherits from the Kernel object in the MOOSE framework.
    All public and protected members of this class are required function overrides.
    The kernel interfaces the set of non-linear variables to solve a material balance.  */
class MaterialBalance : public Kernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    MaterialBalance(const InputParameters & parameters);

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

    std::vector<Real> _weights;                         ///< Weight coefficients for the list of coupled variables
    std::vector<const VariableValue *> _coupled;        ///< Pointer list to the coupled variables
    std::vector<unsigned int> _coupled_vars;            ///< Indices for the coupled variables
    const VariableValue & _coupled_total;               ///< Variable for the total material
    const unsigned int _coupled_var_total;              ///< Variable identification for the total material
    const VariableValue & _coupled_main;                ///< Primary Coupled variable (i.e., diagona
    const unsigned int _main_var;                       ///< Variable identification for the main variable (i.e., diagonal)
    bool inList;                                        ///< Value is true if the main variable is the the variable list
    int index;                                          ///< Local index for the main variable if it is in the list

private:

};
