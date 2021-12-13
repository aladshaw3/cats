/*!
 *  \file SimpleFluidDensity.h
 *    \brief AuxKernel kernel to calculate density of a fluid (default = water)
 *    \details This file is responsible for calculating the density of a fluid by
 *            using an emperical relationship that is based on a polynomial fitting
 *            of data with temperature and pressure. The default configuration of
 *            this calculation is for the density of water between 0 and 350 oC.
 *            Pressure range that this is valid for is between 1 and 200 bar.
 *            User's may update the parameter information for other fluids and
 *            temperature/pressure ranges as needed.
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

/// SimpleFluidDensity class object inherits from SimpleFluidPropertiesBase object
/** This class object inherits from the SimpleFluidPropertiesBase object in the CATS framework.
    All public and protected members of this class are required function overrides. */
class SimpleFluidDensity : public SimpleFluidPropertiesBase
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    SimpleFluidDensity(const InputParameters & parameters);

protected:
    /// Required MOOSE function override
    /** This is the function that is called by the MOOSE framework when a calculation of the total
        system pressure is needed. You are required to override this function for any inherited
        AuxKernel. */
    virtual Real computeValue() override;

private:
    std::string _output_volume_unit;                ///< Units of the volume term in denisty (kL, L, mL, uL, m^3, cm^3, mm^3)
    std::string _output_mass_unit;                  ///< Units of the mass term in density (kg, g, mg)

};
