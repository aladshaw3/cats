/*!
 *  \file TemporalStepFunction.h
 *    \brief Auxillary kernel to change an auxillary variable according to a step function in time
 *    \details This file is responsible for calculating the value of an auxvariable
 *              according to a step function. The step function is made of a set of
 *              time-value pairs that dictate what the new value is based on a current
 *              time value. Users may also optionally provide a set of 'time_spans' which
 *              will allow for a gradual change from the previous to current time value of
 *              the length of the span.
 *
 *  \note You MUST specify 'execute_on = 'initial timestep_begin'' in order for this kernel
 *        to work properly!!!
 *
 *  \author Austin Ladshaw
 *  \date 01/18/2022
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "TemporalStepFunction.h"

registerMooseObject("catsApp", TemporalStepFunction);

InputParameters TemporalStepFunction::validParams()
{
    InputParameters params = AuxKernel::validParams();
    params.addParam<Real>("start_value",0,"Value of the variable to start at");
    params.addRequiredParam< std::vector<Real> >("aux_vals","Values for aux at corresponding times");
    params.addRequiredParam< std::vector<Real> >("aux_times","Time values at which to update aux value");
    params.addParam< std::vector<Real> >("time_spans",{0},"Amount of time it takes to go from one input to the next");
    return params;
}

TemporalStepFunction::TemporalStepFunction(const InputParameters & parameters) :
AuxKernel(parameters),
_start_value(getParam<Real>("start_value")),
_input_vals(getParam<std::vector<Real> >("aux_vals")),
_input_times(getParam<std::vector<Real> >("aux_times")),
_time_spans(getParam<std::vector<Real> >("time_spans"))
{
    if (_input_vals.size() != _input_times.size())
    {
        moose::internal::mooseErrorRaw("input_vals and input_times must have same size!");
    }
    if (_time_spans.size() !=_input_times.size())
    {
        _time_spans.resize(_input_times.size());
        for (int i=0; i<_time_spans.size(); i++)
        {
            _time_spans[i] = 0.0;
        }
    }
    if (_input_vals.size() == 0 && _input_times.size() == 0)
    {
        _input_vals.resize(1);
        _input_times.resize(1);
        _time_spans.resize(1);
        _input_vals[0] = _start_value;
        _input_times[0] = 0.0;
        _time_spans[0] = 0.0;
    }
    index = 0;
    _slopes.resize(_time_spans.size());
    _slopes[0] = (_input_vals[0]-_start_value)/(_time_spans[0]);
    for (int i=1; i<_slopes.size(); i++)
    {
        _slopes[i] = (_input_vals[i]-_input_vals[i-1])/(_time_spans[i]);
    }
}

Real TemporalStepFunction::newValue(Real time)
{
    Real val = _start_value;
    for (int i=index; i<_input_times.size(); i++)
    {
        if (time >= _input_times[i]-(_time_spans[i]/2.0))
        {
            if (time >= _input_times[i]+(_time_spans[i]/2.0))
            {
                val = _input_vals[i];
                index++;
                break;
            }
            else
            {
                val = _input_vals[i]-_slopes[i]*(_input_times[i]+(_time_spans[i]/2.0)-time);
                break;
            }
        }
    }
    return val;
}

Real TemporalStepFunction::computeValue()
{
    _start_value = newValue(_t);
    return _start_value;
}
