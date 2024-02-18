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
 *            Ref: Engineering ToolBox, (2004). Air - Specific Heat vs. Temperature
 *                    and Constant Pressure. [online] Available at: https://www.
 *                    engineeringtoolbox.com/air-specific-heat-capacity-d_705.html
 *                    [Accessed 13 Oct. 2021].
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

#pragma once

#include "SimpleGasPropertiesBase.h"

/// SimpleGasIsobaricHeatCapacity class object inherits from SimpleGasPropertiesBase object
class SimpleGasIsobaricHeatCapacity : public SimpleGasPropertiesBase
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Required constructor for objects in MOOSE
  SimpleGasIsobaricHeatCapacity(const InputParameters & parameters);

protected:
  /// Required MOOSE function override
  virtual Real computeValue() override;

private:
  std::string _output_energy_unit; ///< Units of the energy term in heat capacity (kJ, J)
  std::string _output_mass_unit;   ///< Units of the mass term in heat capacity (kg, g, mg)
};
