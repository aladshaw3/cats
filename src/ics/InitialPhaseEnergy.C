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

#include "InitialPhaseEnergy.h"


registerMooseObject("catsApp", InitialPhaseEnergy);

InputParameters InitialPhaseEnergy::validParams()
{
    InputParameters params = InitialCondition::validParams();
    params.addRequiredCoupledVar("specific_heat","Variable for specific heat (J/kg/K)");
    params.addRequiredCoupledVar("volume_frac","Variable for volume fraction (-)");
    params.addRequiredCoupledVar("density","Variable for density (kg/m^3)");
    params.addRequiredCoupledVar("temperature","Variable for temperature (K)");
    return params;
}

InitialPhaseEnergy::InitialPhaseEnergy(const InputParameters & parameters)
: InitialCondition(parameters),
_density(coupledValue("density")),
_density_var(coupled("density")),
_specheat(coupledValue("specific_heat")),
_specheat_var(coupled("specific_heat")),
_volfrac(coupledValue("volume_frac")),
_volfrac_var(coupled("volume_frac")),
_temp(coupledValue("temperature")),
_temp_var(coupled("temperature"))
{

}

Real InitialPhaseEnergy::value(const Point & /*p*/)
{
    return _volfrac[_qp]*_density[_qp]*_specheat[_qp]*_temp[_qp];
}
