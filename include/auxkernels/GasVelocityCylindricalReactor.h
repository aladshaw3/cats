/*!
 *  \file GasVelocityCylindricalReactor.h
 *    \brief Auxillary kernel to calculate linear velocity in cylindrical reactor
 *    \details This file is responsible for calculating the value of an auxvariable
 *              according to the standard expression for linear velocity as a function
 *              of "Space-Velocity", "Gas-temperature", and "Reactor radius". The
 *              user must provide a reference temperature for the given space-velocity
 *              such that the impact of linear velocity on temperature can be computed
 *              if temperature changes. This kernel assumes that the mass-flow rate
 *              must remain constant as temperature changes. Thus, the flow rate would
 *              increase as temperature increases and concentrations would decrease
 *              proportionally as temperature increase.
 *
 *                    PV = nRT  --> P*Q = n_dot*R*T     n_dot is assumed constant
 *
 *                          Q*C = n_dot    --> Q increases while C decreases proportionally
 *
 *  \note This kernel DOES NOT calculate changes in inlet concentrations with temperature
 *        increases. User must provide changes in inlet concentrations with temperature as
 *        a boundary condition.
 *
 *  \note This method only gives the magnitude of the velocity (not the vector components)
 *
 *  \author Austin Ladshaw
 *  \date 03/13/2021
 *  \copyright This kernel was designed and built at Oak Ridge National Laboratory
 *              for research in catalysis for vehicle emissions.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#pragma once

#include "AuxKernel.h"

/// GasVelocityCylindricalReactor class inherits from AuxKernel
/** This class object creates an AuxKernel for use in the MOOSE framework. The AuxKernel will
    calculate the new values for the auxvariable based on temperature and given space-velocity. */
class GasVelocityCylindricalReactor : public AuxKernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Standard MOOSE public constructor
    GasVelocityCylindricalReactor(const InputParameters & parameters);

protected:
    /// Required MOOSE function override
    virtual Real computeValue() override;

private:
    const VariableValue & _space_velocity;           ///< Variable for space-velocity (reactor volumes / time)
    Real _radius;                                   ///< Value for the radius of the cylindrical reactor
    Real _length;                                   ///< Value for reactor length
    const VariableValue &  _porosity;               ///< Variable for the porosity
    const VariableValue & _temperature_in;          ///< Variable for inlet temperature (in K)
    const VariableValue & _pressure_in;             ///< Variable for inlet pressure (in kPa)
    Real _temperature_ref;                          ///< Value of the reference temperature (in K)
    Real _pressure_ref;                             ///< Value of the reference pressure (in kPa)

};
