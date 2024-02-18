/*!
 *  \file SimpleGasVolumeFractionToConcentration.h
 *    \brief AuxKernel kernel to calculate a gas concentration from a volume fraction
 *    \details This file is responsible for calculating the concentration of a gas
 *            species as a function of gas temperature and pressure. User's may
 *            provide volume fraction in %, ppm, or ppb. Then the gas concentration
 *            can be calculated in mol/L, mol/cm^3, mol/m^3, mol/mL, etc. (any of
 *            the available volumes in SimpleGasPropertiesBase).
 *
 *
 *  \author Austin Ladshaw
 *  \date 02/18/2022
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

/// SimpleGasVolumeFractionToConcentration class object inherits from SimpleGasPropertiesBase object
class SimpleGasVolumeFractionToConcentration : public SimpleGasPropertiesBase
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Required constructor for objects in MOOSE
  SimpleGasVolumeFractionToConcentration(const InputParameters & parameters);

protected:
  /// Required MOOSE function override
  virtual Real computeValue() override;

private:
  std::string
      _output_volume_unit; ///< Units of the volume term in concentration (kL, L, mL, m^3, cm^3, mm^3)
  std::string _input_volfrac_unit; ///< Units of the volume fraction term (%, ppm, ppb)
  const VariableValue & _volfrac;  ///< Variable/value of the volume fraction term
};
