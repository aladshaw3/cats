/*!
 *  \file SimpleGasIsobaricHeatCapacity.h
 *    \brief AuxKernel kernel to calculate heat capacity (at constant pressure) of air
 *    \details This file is responsible for calculating the isobaric heat capacity
 *            of air assuming that the air is an ideal gas composed primarily of
 *            N2 and O2. An emperical formula is used to calculate this heat
 *            capacity as a function of gas temperature. This estimate is good
 *            between 1 to 20 bar of pressure (up to ~ 20 atm) and between
 *            -50 and 1600 oC for standard air.
 *
 *
 *  \author Austin Ladshaw
 *  \date 10/13/2021
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
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

#include "SimpleGasPropertiesBase.h"

/// SimpleGasIsobaricHeatCapacity class object inherits from GasPropertiesBase object
/** This class object inherits from the SimpleGasPropertiesBase object in the CATS framework.
    All public and protected members of this class are required function overrides. */
class SimpleGasIsobaricHeatCapacity : public SimpleGasPropertiesBase
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    SimpleGasIsobaricHeatCapacity(const InputParameters & parameters);

protected:
    /// Required MOOSE function override
    /** This is the function that is called by the MOOSE framework when a calculation of the total
        system pressure is needed. You are required to override this function for any inherited
        AuxKernel. */
    virtual Real computeValue() override;

private:
    std::string _output_energy_unit;                ///< Units of the energy term in heat capacity (kJ, J)
    std::string _output_mass_unit;                  ///< Units of the mass term in heat capacity (kg, g, mg)

};
