/*!
 *  \file PhaseTemperature.h
 *    \brief Kernel to create a residual to solve for the temperature of a given phase based on energy per volume
 *    \details This file creates a standard MOOSE kernel that is used to calculate the temperature of a phase
 *              from the energy per volume, as well as density, specific heat, and volume fraction of the phase.
 *              This kernel is a necessary component when doing energy balances where density and heat
 *              capacity change in space-time.
 *
 *  \author Austin Ladshaw
 *    \date 05/04/2020
 *    \copyright This kernel was designed and built at Oak Ridge National
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

/// PhaseTemperature class object inherits from Kernel object
/** This class object inherits from the Kernel object in the MOOSE framework.
    All public and protected members of this class are required function overrides.
    The kernel interfaces the set of non-linear variables to solve a material balance.  */
class PhaseTemperature : public Kernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();
    
    /// Required constructor for objects in MOOSE
    PhaseTemperature(const InputParameters & parameters);

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

    const VariableValue & _energy;               ///< Variable for the energy density (J/m^3)
    const unsigned int _energy_var;              ///< Variable identification for the energy density
    const VariableValue & _density;              ///< Variable for the density (kg/m^3)
    const unsigned int _density_var;             ///< Variable identification for the density
    const VariableValue & _specheat;              ///< Variable for the specific heat (J/kg/K)
    const unsigned int _specheat_var;             ///< Variable identification for the specific heat
    
private:

};
