/*!
 *  \file MonolithHydraulicDiameter.h
 *    \brief Auxillary kernel to calculate the hydraulic diameter for the monolith
 *    \details This file is responsible for calculating the hydraulic diameter for
 *              the monolith. This value may not be used on its own, but will likely
 *              be used in conjunction with other properties (such as film mass transfer
 *              or diffusion rates).
 *
 *  \author Austin Ladshaw
 *  \date 09/14/2021
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#pragma once

#include "AuxKernel.h"

/// MonolithHydraulicDiameter class inherits from AuxKernel
class MonolithHydraulicDiameter : public AuxKernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Standard MOOSE public constructor
    MonolithHydraulicDiameter(const InputParameters & parameters);

protected:
    /// Required MOOSE function override
    virtual Real computeValue() override;

private:
    Real _cell_density;        ///< Cell density of the monolith (cells per total face area)
    const VariableValue & _bulk_porosity;       ///< Ratio of channel volume to total volume

};
