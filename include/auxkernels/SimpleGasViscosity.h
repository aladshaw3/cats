/*!
 *  \file SimpleGasViscosity.h
 *    \brief AuxKernel kernel to calculate viscosity of air
 *    \details This file is responsible for calculating the viscosity of air by
 *            assuming an ideal gas of mostly O2 and N2 (i.e., standard air)
 *
 *
 *  \author Austin Ladshaw
 *  \date 10/18/2021
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

#include "SimpleGasPropertiesBase.h"

/// SimpleGasViscosity class object inherits from SimpleGasPropertiesBase object
class SimpleGasViscosity : public SimpleGasPropertiesBase
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    SimpleGasViscosity(const InputParameters & parameters);

protected:
    /// Required MOOSE function override
    virtual Real computeValue() override;

private:
    std::string _output_length_unit;                ///< Units of the length term in viscosity (m, cm, mm)
    std::string _output_mass_unit;                  ///< Units of the mass term in viscosity (kg, g, mg)
    std::string _output_time_unit;                  ///< Units of the time term in viscosity (hr, min, s)

};
