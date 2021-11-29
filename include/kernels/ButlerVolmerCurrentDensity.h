/*!
 *  \file ButlerVolmerCurrentDensity.h
 *  \brief Kernel for calculating current density from a Bulter-Volmer reaction rate variable
 *  \details This file creates a kernel for the coupling the reaction rate calculated from
 *            a Butler-Volmer relationship with a variable for specific electrode surface
 *            area and the number of electrons transferred in that reaction. This kernel
 *            should be used in conjuction with the 'Reaction' kernel to fully describe
 *            the equations being solved.
 *
 *            Reaction:                     test * -J = 0
 *            ButlerVolmerCurrentDensity:   test * n*As*F*(-r) = 0
 *
 *                          where J = current density (C / (total volume) / time)
 *                                n = number of electrons transferred in reaction 'r'
 *                                As = specific surface area (total electrode surface area / total volume)
 *                                      [total volume would include void volume]
 *                                F = Faraday's constant (default = 96,485.3 C/mol)
 *                                r = reaction rate variable (moles / electrode surface area / time)
 *
 *
 *  \author Austin Ladshaw
 *  \date 11/29/2021
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

/****************************************************************/
/*               DO NOT MODIFY THIS HEADER                      */
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*           (c) 2010 Battelle Energy Alliance, LLC             */
/*                   ALL RIGHTS RESERVED                        */
/*                                                              */
/*          Prepared by Battelle Energy Alliance, LLC           */
/*            Under Contract No. DE-AC07-05ID14517              */
/*            With the U. S. Department of Energy               */
/*                                                              */
/*            See COPYRIGHT for full restrictions               */
/****************************************************************/

#pragma once

#include "Kernel.h"

/// ButlerVolmerCurrentDensity class object inherits from Kernel object
/** This class object inherits from the Kernel object in the MOOSE framework.
    All public and protected members of this class are required function overrides.
    The kernel interfaces the non-linear reaction variable with other information
    to calculate current density from redox reactions. */
class ButlerVolmerCurrentDensity : public Kernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    ButlerVolmerCurrentDensity(const InputParameters & parameters);

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

    const VariableValue & _rate;      ///< Variable for reaction rate (mol/area/time)
    const unsigned int _rate_var;     ///< Variable identification for reaction rate
    const VariableValue & _specarea;      ///< Variable for specific area (m^-1) [area/volume]
    const unsigned int _specarea_var;     ///< Variable identification for specific area

    Real _n;                                            ///< Number of electrons transferred (default = 1)
    Real _faraday;                                      ///< Value of Faraday's Constant (default = 96485.3 C/mol)

private:

};
