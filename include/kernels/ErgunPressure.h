/*!
 *  \file ErgunPressure.h
 *    \brief Kernel kernel to compute pressure drop in system and total pressure
 *    \details This file is responsible for calculating the pressure drop in a reactor
 *              system using a linearized Ergun equation. User must provide the inlet
 *              pressure condition boundary condition and couple with a number of non-linear
 *              or auxillary variables for viscosity, density, velocity, porosity, and
 *              hydraulic diameter.
 *
 *  \note This kernel provides a residual for pressure drop in a specific direction. User must
 *          provide the velocity component corresponding to the given direction.
 *
 *  \author Austin Ladshaw
 *  \date 04/20/2020
 *  \copyright This kernel was designed and built at the Georgia Institute
 *             of Technology by Austin Ladshaw for PhD research in the area
 *             of adsorption and surface science and was developed for use
 *               by Idaho National Laboratory and Oak Ridge National Laboratory
 *               engineers and scientists. Portions Copyright (c) 2015, all
 *             rights reserved.
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

/// ErgunPressure class object forward declarations
class ErgunPressure;

template<>
InputParameters validParams<ErgunPressure>();

/// MaterialBalance class object inherits from Kernel object
/** This class object inherits from the Kernel object in the MOOSE framework.
    All public and protected members of this class are required function overrides.
    The kernel interfaces the set of non-linear variables to the Ergun Equation.  */
class ErgunPressure : public Kernel
{
public:
    /// Required constructor for objects in MOOSE
    ErgunPressure(const InputParameters & parameters);

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

    unsigned int _dir;                              ///< Direction of the Ergun gradient for pressure (0 = x, 1 = y, 2 = z)
    const VariableValue & _porosity;                ///< Variable for the porosity
    const unsigned int _porosity_var;               ///< Variable identification for the porosity
    const VariableValue & _char_len;                ///< Variable for the characteristic length (hydralic diameter)
    const unsigned int _char_len_var;               ///< Variable identification for the characteristic length (hydralic diameter)
    const VariableValue & _vel;                     ///< Variable for the velocity in the given direction
    const unsigned int _vel_var;                    ///< Variable identification for the velocity in the given direction
    const VariableValue & _vis;                     ///< Variable for the dynamic viscosity
    const unsigned int _vis_var;                    ///< Variable identification for the dynamic viscosity
    const VariableValue & _dens;                     ///< Variable for the density
    const unsigned int _dens_var;                    ///< Variable identification for the density
    const VariableValue & _press_in;                 ///< Variable for the inlet pressure
    const unsigned int _press_in_var;                ///< Variable identification for the inlet pressure
    
private:

};
