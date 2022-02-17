/*!
 *  \file SimpleGasDispersion.h
 *    \brief AuxKernel kernel to calculate dispersion coefficients
 *    \details This file is responsible for calculating the dispersion coefficient
 *              for the domain given some simple properties. Calculation is based
 *              diffusivities that are corrected via an Arrhenius like
 *              expression from a reference diffusivity and reference temperature.
 *              User provides input units for specific parameters and provides
 *              desired unit basis of the calculation of dispersion.
 *
 *  \note IMPORTANT: The characteristic_length for this kernel is the diameter of
 *          of the column! NOT the hydraulic diameter of particles or monolith channels.
 *
 *  \author Austin Ladshaw
 *  \date 09/15/2021
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

/// SimpleGasDispersion class object inherits from SimpleGasPropertiesBase object
class SimpleGasDispersion : public SimpleGasPropertiesBase
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    SimpleGasDispersion(const InputParameters & parameters);

protected:
    /// Required MOOSE function override
    virtual Real computeValue() override;

private:
    std::string _output_length_unit;                ///< Units of the length term in transfer coef (m, cm, mm)
    std::string _output_time_unit;                  ///< Units of the time term in transfer coef (hr, min, s)

};
