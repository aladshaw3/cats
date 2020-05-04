/*!
 *  \file PhaseEnergyTransfer.h
 *  \brief Kernel for creating an exchange of energy between two phases
 *  \details This file creates a kernel for the coupling a pair of energy variables in
 *            the same domain as a form of energy transfer. The variables are implicitly
 *            coupled through the temperatures of each phase and the heat transfer coefficient:
 *                  Res = test * h * A * fv * (T_this - T_other)
 *                          where T_this = temperature of this energy variable's phase (K)
 *                          and T_other = temperature of the other energy variable's phase (K)
 *                          h = heat transfer coefficient (W/m^2/K)
 *                          A = specific contact area per volume between the phases (m^-1)
 *                              = area of solids per volume of solids
 *                          fv = volume fraction of the phases (volume solids / total volume)
 *
 *
 *  \author Austin Ladshaw
 *  \date 05/04/2020
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
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

/// PhaseEnergyTransfer class object inherits from Kernel object
/** This class object inherits from the Kernel object in the MOOSE framework.
    All public and protected members of this class are required function overrides.
    The kernel interfaces the pair of non-linear variables to create a kernel for a
    mass/energy transfer. */
class PhaseEnergyTransfer : public Kernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();
    
    /// Required constructor for objects in MOOSE
    PhaseEnergyTransfer(const InputParameters & parameters);

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

    const VariableValue & _hs;            ///< Variable for Heat transfer coefficient (W/m^2/K)
    const unsigned int _hs_var;           ///< Variable identification for hw
    const VariableValue & _this_temp;          ///< Variable for this phase's temperature (K)
    const unsigned int _this_temp_var;         ///< Variable identification for this phase temperature
    const VariableValue & _other_temp;      ///< Variable for other phase temperature (K)
    const unsigned int _other_temp_var;     ///< Variable identification for other phase temperature
    const VariableValue & _volfrac;      ///< Variable for volume fraction (-)
    const unsigned int _volfrac_var;     ///< Variable identification for volume fraction
    const VariableValue & _specarea;      ///< Variable for specific area (m^-1)
    const unsigned int _specarea_var;     ///< Variable identification for specific area
    
private:

};

