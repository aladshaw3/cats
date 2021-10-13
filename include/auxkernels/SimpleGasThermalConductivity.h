/*!
 *  \file SimpleGasThermalConductivity.h
 *    \brief AuxKernel kernel to calculate thermal conductivity of air
 *    \details This file is responsible for calculating the thermal conductivity
 *            of air assuming an ideal gas made up of primarily O2 and N2. This
 *            kernel uses an emperical formula for thermal conductivity for
 *            standard air that is accurate between -50 and 1600 oC.
 *
 *            Ref: K. Ramanathan, C.S. Sharma, "Kinetic parameters estimation
 *                    for three way catalyst modeling," Ind. Eng. Chem. Res.
 *                    50 (2011) 9960-9979.
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

/// SimpleGasThermalConductivity class object inherits from GasPropertiesBase object
/** This class object inherits from the SimpleGasPropertiesBase object in the CATS framework.
    All public and protected members of this class are required function overrides. */
class SimpleGasThermalConductivity : public SimpleGasPropertiesBase
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    SimpleGasThermalConductivity(const InputParameters & parameters);

protected:
    /// Required MOOSE function override
    /** This is the function that is called by the MOOSE framework when a calculation of the total
        system pressure is needed. You are required to override this function for any inherited
        AuxKernel. */
    virtual Real computeValue() override;

private:
    std::string _output_energy_unit;                ///< Units of the energy term in thermal conductivity (kJ, J)
    std::string _output_length_unit;                ///< Units of the length term in thermal conductivity (m, cm, mm)
    std::string _output_time_unit;                  ///< Units of the time term in thermal conductivity (hr, min, s)

};
