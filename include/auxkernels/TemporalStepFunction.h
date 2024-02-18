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

#pragma once

#include "AuxKernel.h"

/// TemporalStepFunction class inherits from AuxKernel
class TemporalStepFunction : public AuxKernel
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Standard MOOSE public constructor
  TemporalStepFunction(const InputParameters & parameters);

protected:
  /// Function  to update the aux value based on given time
  Real newValue(Real time);

  /// Required MOOSE function override
  virtual Real computeValue() override;

private:
  Real _start_value;              ///< Start value of the auxvariable
  std::vector<Real> _input_vals;  ///< Values for aux that update at corresponding times
  std::vector<Real> _input_times; ///< Values for determining when to change aux
  std::vector<Real> _time_spans;  ///< Amount of time it take to change to new input value
  std::vector<Real> _slopes;      ///< Slopes between each subsequent aux
  int index;                      ///< Index variable to keep track of location in vectors
};
