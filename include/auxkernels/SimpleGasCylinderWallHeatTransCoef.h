/*!
 *  \file SimpleGasCylinderWallHeatTransCoef.h
 *    \brief AuxKernel kernel to calculate heat transfer from reactor walls
 *    \details This file is responsible for calculating the heat transfer coefficient
 *              for reactor walls. The gas is assumed an ideal mixture of
 *              mostly O2 and N2. The hydraulic diameter used is the diameter
 *              of the cylindrical reactor. Uses the Sieder-Tate correlation.
 *
 *            Ref: F.P. Incropera, D.P. DeWitt, Fundamentals of Heat and Mass
 *                    Transfer (4th ed), New York: Wiley, 2000, p. 493.
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

/// SimpleGasCylinderWallHeatTransCoef class object inherits from SimpleGasPropertiesBase object
class SimpleGasCylinderWallHeatTransCoef : public SimpleGasPropertiesBase
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Required constructor for objects in MOOSE
  SimpleGasCylinderWallHeatTransCoef(const InputParameters & parameters);

protected:
  /// Required MOOSE function override
  virtual Real computeValue() override;

private:
  std::string _output_energy_unit; ///< Units of the energy term in thermal conductivity (kJ, J)
  std::string _output_length_unit; ///< Units of the length term in thermal conductivity (m, cm, mm)
  std::string _output_time_unit;   ///< Units of the time term in thermal conductivity (hr, min, s)
};
