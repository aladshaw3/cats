/*!
 *  \file LinearChangeInTime.h
 *    \brief Auxillary kernel to change an auxillary variable linearly in time
 *    \details This file is responsible for calculating the value of an auxvariable
 *              according to a linear trend in time. The user provides the start time,
 *              stop time, and end value for the auxillary value, then this kernel will
 *              calculate a new value within that time range according to what the value
 *              was initially and what value it should stop at.
 *
 *  \author Austin Ladshaw
 *  \date 03/18/2020
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

#include "LinearChangeInTime.h"

registerMooseObject("catsApp", LinearChangeInTime);

/*
template<>
InputParameters validParams<LinearChangeInTime>()
{
    InputParameters params = validParams<AuxKernel>();
    params.addParam<Real>("start_time",0,"Point in time to start the linear change");
    params.addParam<Real>("end_time",1,"Point in time to end the linear change");
    params.addParam<Real>("end_value",0,"Value of the variable to end at");
    return params;
}
 */

InputParameters LinearChangeInTime::validParams()
{
    InputParameters params = AuxKernel::validParams();
    params.addParam<Real>("start_time",0,"Point in time to start the linear change");
    params.addParam<Real>("end_time",1,"Point in time to end the linear change");
    params.addParam<Real>("end_value",0,"Value of the variable to end at");
    return params;
}

LinearChangeInTime::LinearChangeInTime(const InputParameters & parameters) :
AuxKernel(parameters),
_start_time(getParam<Real>("start_time")),
_end_time(getParam<Real>("end_time")),
_end_value(getParam<Real>("end_value"))
{
    if (_end_time <= _start_time)
        _end_time = _start_time*1.01;
    _start_set = false;
}

Real LinearChangeInTime::computeValue()
{
    Real value = _u[_qp];
    Real slope = 0.0;
    if (_t <= _start_time && _start_set == false)
    {
        _start_value = _u[_qp];
        _start_set = true;
    }
    if (_t >= _start_time && _t <= _end_time)
    {
        slope = (_end_value - _start_value)/(_end_time - _start_time);
        value = _start_value + slope*(_t-_start_time);
    }
    if (_t >= _end_time)
        value = _end_value;
    
    return value;
}
