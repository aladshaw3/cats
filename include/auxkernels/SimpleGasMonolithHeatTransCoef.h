/*!
 *  \file SimpleGasMonolithHeatTransCoef.h
 *    \brief AuxKernel kernel to calculate heat transfer from monolith walls
 *    \details This file is responsible for calculating the heat transfer coefficient
 *              for monolith walls. The gas is assumed an ideal mixture of
 *              mostly O2 and N2. The hydraulic diameter used is the diameter
 *              of the open monolith channels.
 *
 *            Ref: K. Ramanathan, V. Balakotaiah, D.H. West, "Light-off criterion
 *                    and transient analysis of catalytic monoliths," Chem. Eng.
 *                    Sci., 58 (2003) 1381-1405.
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

/// SimpleGasMonolithHeatTransCoef class object inherits from GasPropertiesBase object
/** This class object inherits from the SimpleGasPropertiesBase object in the CATS framework.
    All public and protected members of this class are required function overrides. */
class SimpleGasMonolithHeatTransCoef : public SimpleGasPropertiesBase
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    SimpleGasMonolithHeatTransCoef(const InputParameters & parameters);

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
