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

#pragma once

#include "AuxKernel.h"

/// LinearChangeInTime class inherits from AuxKernel
class LinearChangeInTime : public AuxKernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Standard MOOSE public constructor
    LinearChangeInTime(const InputParameters & parameters);

protected:
    /// Required MOOSE function override
    /** This is the function that is called by the MOOSE framework when a calculation of the total
        system pressure is needed. You are required to override this function for any inherited
        AuxKernel. */
    virtual Real computeValue() override;

private:
    Real _start_time;           ///< Start time for the linear change
    Real _end_time;             ///< End time for the linear change
    Real _end_value;            ///< Final value of the auxvariable after linearly changing
    Real _start_value;          ///< Start value of the auxvariable after linearly changing
    bool _start_set;            ///< Boolean to denote when value starts

};
