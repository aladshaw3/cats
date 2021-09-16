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

#include "GasVelocityCylindricalReactor.h"

registerMooseObject("catsApp", GasVelocityCylindricalReactor);

InputParameters GasVelocityCylindricalReactor::validParams()
{
    InputParameters params = AuxKernel::validParams();
    params.addCoupledVar("porosity",0.0,"Value of bulk porosity");
    params.addRequiredCoupledVar("space_velocity","Name of the space-velocity variable (reactor volumes/time)");
    params.addRequiredCoupledVar("inlet_temperature","Name of the inlet temperature variable (in K)");
    params.addCoupledVar("inlet_pressure",101.35,"Name of the inlet pressure variable (in kPa)");
    params.addParam< Real >("ref_temperature",298.15,"Reference temperature for the space-velocity (in K)");
    params.addParam< Real >("ref_pressure",101.35,"Reference pressure for the space-velocity (in kPa)");
    params.addRequiredParam< Real >("radius","Radius of the cylindrical reactor");
    params.addRequiredParam< Real >("length","Length of the cylindrical reactor");
    return params;
}

GasVelocityCylindricalReactor::GasVelocityCylindricalReactor(const InputParameters & parameters) :
AuxKernel(parameters),
_space_velocity(coupledValue("space_velocity")),
_radius(getParam<Real>("radius")),
_length(getParam<Real>("length")),
_porosity(coupledValue("porosity")),
_temperature_in(coupledValue("inlet_temperature")),
_pressure_in(coupledValue("inlet_pressure")),
_temperature_ref(getParam<Real>("ref_temperature")),
_pressure_ref(getParam<Real>("ref_pressure"))
{

}

Real GasVelocityCylindricalReactor::computeValue()
{
    Real _area = _radius*_radius*3.14159;
    Real _ref_flow_rate = _space_velocity[_qp]*_length*_area*(1-_porosity[_qp]);
    Real _true_flow_rate = _temperature_in[_qp]*_ref_flow_rate/_temperature_ref*_pressure_ref/(_pressure_in[_qp]);
    return _true_flow_rate/_area/_porosity[_qp];
}
