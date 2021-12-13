/*!
 *  \file SimpleFluidViscosity.h
 *    \brief AuxKernel kernel to calculate viscosity of a liquid (default = water)
 *    \details This file is responsible for calculating the viscosity of a liquid by
 *            using an emperical relationship (see SimpleFluidPropertiesBase for
 *            more details). User can specify if they want a pressure unit basis
 *            or a mass unit basis on output.
 *
 *            Pressure Basis:   [Pressure * Time]
 *            Mass Basis:       [Mass / Length / Time]
 *
 *
 *  \author Austin Ladshaw
 *  \date 12/13/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
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

#pragma once

#include "SimpleFluidPropertiesBase.h"

/// SimpleFluidViscosity class object inherits from SimpleFluidPropertiesBase object
/** This class object inherits from the SimpleFluidPropertiesBase object in the CATS framework.
    All public and protected members of this class are required function overrides. */
class SimpleFluidViscosity : public SimpleFluidPropertiesBase
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    SimpleFluidViscosity(const InputParameters & parameters);

protected:
    /// Required MOOSE function override
    /** This is the function that is called by the MOOSE framework when a calculation of the total
        system pressure is needed. You are required to override this function for any inherited
        AuxKernel. */
    virtual Real computeValue() override;

private:
    std::string _output_length_unit;                ///< Units of the length term in viscosity (m, cm, mm)
    std::string _output_mass_unit;                  ///< Units of the mass term in viscosity (kg, g, mg)
    std::string _output_time_unit;                  ///< Units of the time term in viscosity (hr, min, s)

    std::string _output_pressure_unit;              ///< Units of the pressure term in viscosity (kPa, Pa, mPa)

    MooseEnum _output_basis;					              ///< Enumerator to determine what basis to use (pressure or mass)

};
