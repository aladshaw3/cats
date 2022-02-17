/*!
 *  \file InitialPhaseEnergy.h
 *    \brief Initial Condition kernel for the energy of a phase in the system
 *    \details This file creates an initial condition for phase energy in a system as a function
 *              of the initial temperature, initial density of the phase, initial heat capacity
 *              of the phase, and the volume fraction of the phase in the domain. All other variables
 *              that this kernel couples with must have their own initial conditions specified and
 *              may not couple with the phase energy variable.
 *
 *
 *  \author Austin Ladshaw
 *  \date 05/04/2020
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

#pragma once

#include "InitialCondition.h"

/// InitialPhaseEnergy class object inherits from InitialCondition object
/** This class object inherits from the InitialCondition object.
    All public and protected members of this class are required function overrides. */
class InitialPhaseEnergy : public InitialCondition
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for BC objects in MOOSE
    InitialPhaseEnergy(const InputParameters & parameters);

protected:
    /// Required function override for IC objects in MOOSE
    /** This function returns the value of the variable at point p in the mesh.*/
    virtual Real value(const Point & p) override;

    const VariableValue & _density;              ///< Variable for the density (kg/m^3)
    const unsigned int _density_var;             ///< Variable identification for the density
    const VariableValue & _specheat;              ///< Variable for the specific heat (J/kg/K)
    const unsigned int _specheat_var;             ///< Variable identification for the specific heat
    const VariableValue & _temp;              ///< Variable for the temperature of the phase (K)
    const unsigned int _temp_var;             ///< Variable identification for the temperature

private:

};
