/*!
 *  \file AuxRatio.h
 *    \brief Auxillary kernel to calculate a value based on a ratio of other values
 *    \details This file is responsible for calculating the value of an auxvariable
 *              according to the ratio of a set of coupled variables for the denominator
 *              and numerator.
 *
 *  \author Austin Ladshaw
 *  \date 06/24/2022
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

/// AuxRatio class inherits from AuxKernel
/** This class object creates an AuxKernel for use in the MOOSE framework. */
class AuxRatio : public AuxKernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Standard MOOSE public constructor
    AuxRatio(const InputParameters & parameters);

protected:
    /// Required MOOSE function override
    virtual Real computeValue() override;

private:
    std::vector<const VariableValue *> _numerator;     ///< Pointer list to the coupled vars as the numerator (top)
    std::vector<const VariableValue *> _denominator;     ///< Pointer list to the coupled vars as the denominator (bottom)

};
