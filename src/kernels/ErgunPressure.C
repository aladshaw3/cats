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

#include "ErgunPressure.h"


registerMooseObject("catsApp", ErgunPressure);

template<>
InputParameters validParams<ErgunPressure>()
{
    InputParameters params = validParams<Kernel>();
    params.addParam< Real >("scale_factor",1E-6,"Scaling factor for the residuals to improve convergence for dilute systems");
    params.addRequiredParam< unsigned int >("direction","Direction that the Ergun gradient acts on (0=x, 1=y, 2=z)");
    params.addRequiredCoupledVar("porosity","Name of the bulk porosity variable");
    params.addRequiredCoupledVar("hydraulic_diameter","Name of the hydraulic diameter variable");
    params.addRequiredCoupledVar("velocity","Name of the velocity variable in this gradient direction");
    params.addRequiredCoupledVar("viscosity","Name of the viscosity variable");
    params.addRequiredCoupledVar("density","Name of the density variable");
    params.addRequiredCoupledVar("inlet_pressure","Name of the inlet pressure variable");
    return params;
}

ErgunPressure::ErgunPressure(const InputParameters & parameters)
: Kernel(parameters),
_scale_factor(getParam<Real>("scale_factor")),
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
_dens_var(coupled("density")),
_press_in(coupledValue("inlet_pressure")),
_press_in_var(coupled("inlet_pressure"))
{
    if (_dir < 0 || _dir > 2)
    {
        moose::internal::mooseErrorRaw("Invalid direction for pressure gradient!");
    }
}

/// NOTE: We have to multiply the residual by factor 1e-6, otherwise it completely dominates the residuals!!!
Real ErgunPressure::computeQpResidual()
{
    Real part2 = 150.0*_vis[_qp]*(1.0-_porosity[_qp])*(1.0-_porosity[_qp])*_porosity[_qp]*_vel[_qp]*_test[_i][_qp]/(_porosity[_qp]*_porosity[_qp]*_porosity[_qp]*_char_len[_qp]*_char_len[_qp]);
    Real part3 = 1.75*(1.0-_porosity[_qp])*_char_len[_qp]*_dens[_qp]*_porosity[_qp]*_vel[_qp]*_porosity[_qp]*fabs(_vel[_qp])*_test[_i][_qp]/(_porosity[_qp]*_porosity[_qp]*_porosity[_qp]*_char_len[_qp]*_char_len[_qp]);
    
    return (_press_in[_qp]*_test[_i][_qp]-part2*_q_point[_qp](_dir)-part3*_q_point[_qp](_dir)-_u[_qp]*_test[_i][_qp])*_scale_factor;
}

Real ErgunPressure::computeQpJacobian()
{
    return -_phi[_j][_qp]*_test[_i][_qp]*_scale_factor;
}

Real ErgunPressure::computeQpOffDiagJacobian(unsigned int jvar)
{
    /** NOTE: This kernel is incomplete! */
    if (jvar == _porosity_var)
    {
        return 0.0;
    }
    if (jvar == _char_len_var)
    {
        return 0.0;
    }
    if (jvar == _vel_var)
    {
        return 0.0;
    }
    if (jvar == _vis_var)
    {
        return 0.0;
    }
    if (jvar == _dens_var)
    {
        return 0.0;
    }
    if (jvar == _press_in_var)
    {
        return 0.0;
    }
    
    return 0.0;
}

