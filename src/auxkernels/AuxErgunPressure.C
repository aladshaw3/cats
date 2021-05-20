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

InputParameters AuxErgunPressure::validParams()
{
    InputParameters params = GasPropertiesBase::validParams();
    params.addRequiredParam< unsigned int >("direction","Direction that the Ergun gradient acts on (0=x, 1=y, 2=z)");
    params.addParam< bool >("is_inlet_press",true,"If true, calculation assumes given pressure is inlet pressure. If false, calculation assumes given pressure is outlet pressure.");
    params.addRequiredCoupledVar("porosity","Name of the bulk porosity variable");
    params.addParam< Real >("start_point",0.0,"Starting distance for pressure drop (m)");
    params.addParam< Real >("end_point",-1.0,"Ending distance for pressure drop (m)");
    return params;
}

AuxErgunPressure::AuxErgunPressure(const InputParameters & parameters) :
GasPropertiesBase(parameters),
_dir(getParam<unsigned int>("direction")),
_porosity(coupledValue("porosity")),
_porosity_var(coupled("porosity")),
_start(getParam<Real>("start_point")),
_end(getParam<Real>("end_point")),
_inlet(getParam<bool>("is_inlet_press"))
{
    if (_dir < 0 || _dir > 2)
    {
        moose::internal::mooseErrorRaw("Invalid direction for pressure gradient!");
    }

    if (_inlet == false && _end == -1.0)
    {
        moose::internal::mooseErrorRaw("Must provide an end_point if given pressure is not inlet pressure!");
    }
}

Real AuxErgunPressure::computeValue()
{
    prepareEgret();
    calculateAllProperties();

    Real vis = _egret_dat.total_dyn_vis/1000.0*100.0;
    Real dens = _egret_dat.total_density/1000.0*100.0*100.0*100.0;
    Real vel = 0.0;
    if (_dir == 0)
    {
        vel = _velx[_qp];
    }
    if (_dir == 1)
    {
        vel = _vely[_qp];
    }
    if (_dir == 2)
    {
        vel = _velz[_qp];
    }

    Real z = _q_point[_qp](_dir);
    Real vis_term = 150.0*vis*(1.0-_porosity[_qp])*(1.0-_porosity[_qp])*_porosity[_qp]*vel/(_porosity[_qp]*_porosity[_qp]*_porosity[_qp]*_char_len[_qp]*_char_len[_qp]);
    Real dens_term = 1.75*(1.0-_porosity[_qp])*_char_len[_qp]*dens*_porosity[_qp]*vel*_porosity[_qp]*fabs(vel)/(_porosity[_qp]*_porosity[_qp]*_porosity[_qp]*_char_len[_qp]*_char_len[_qp]);

    if (_inlet == true)
    {
        return _press[_qp] - (vis_term+dens_term)*(z-_start);
    }
    else
    {
        return _press[_qp] + (vis_term+dens_term)*(_end-z);
    }
}
