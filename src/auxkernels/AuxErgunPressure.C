/*!
 *  \file AuxErgunPressure.h
 *    \brief AuxKernel kernel to compute pressure drop in system and total pressure
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

#include "AuxErgunPressure.h"

registerMooseObject("catsApp", AuxErgunPressure);

template<>
InputParameters validParams<AuxErgunPressure>()
{
    InputParameters params = validParams<AuxKernel>();
    params.addRequiredParam< Real >("inlet_pressure","Known pressure at reactor inlet");
    params.addRequiredParam< unsigned int >("direction","Direction that the Ergun gradient acts on (0=x, 1=y, 2=z)");
    params.addRequiredCoupledVar("porosity","Name of the bulk porosity variable");
    params.addRequiredCoupledVar("hydraulic_diameter","Name of the hydraulic diameter variable");
    params.addRequiredCoupledVar("velocity","Name of the velocity variable in this gradient direction");
    params.addRequiredCoupledVar("viscosity","Name of the viscosity variable");
    params.addRequiredCoupledVar("density","Name of the density variable");
    return params;
}

AuxErgunPressure::AuxErgunPressure(const InputParameters & parameters) :
AuxKernel(parameters),
_inlet_pressure(getParam<Real>("inlet_pressure")),
_dir(getParam<unsigned int>("direction")),
_porosity(coupledValue("porosity")),
_porosity_var(coupled("porosity")),
_char_len(coupledValue("hydraulic_diameter")),
_char_len_var(coupled("hydraulic_diameter")),
_vel(coupledValue("velocity")),
_vel_var(coupled("velocity")),
_vis(coupledValue("viscosity")),
_vis_var(coupled("viscosity")),
_dens(coupledValue("density")),
_dens_var(coupled("density"))
{
    if (_dir < 0 || _dir > 2)
    {
        moose::internal::mooseErrorRaw("Invalid direction for pressure gradient!");
    }
}

Real AuxErgunPressure::computeValue()
{
    Real L = _q_point[_qp](_dir);
    Real vis_term = 150.0*_vis[_qp]*(1.0-_porosity[_qp])*(1.0-_porosity[_qp])*_porosity[_qp]*_vel[_qp]/(_porosity[_qp]*_porosity[_qp]*_porosity[_qp]*_char_len[_qp]*_char_len[_qp]);
    Real dens_term = 1.75*(1.0-_porosity[_qp])*_char_len[_qp]*_dens[_qp]*_porosity[_qp]*_vel[_qp]*_porosity[_qp]*_vel[_qp]/(_porosity[_qp]*_porosity[_qp]*_porosity[_qp]*_char_len[_qp]*_char_len[_qp]);
    
    return _inlet_pressure - (vis_term+dens_term)*L;
}