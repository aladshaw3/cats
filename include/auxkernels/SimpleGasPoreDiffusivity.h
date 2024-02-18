/*!
 *  \file SimpleGasPoreDiffusivity.h
 *    \brief AuxKernel kernel to calculate pore diffusion coefficients in microscale
 *    \details This file is responsible for calculating the pore diffusivity
 *              for the microscale given some simple properties. Calculation is based
 *              diffusivities that are corrected via an Arrhenius like
 *              expression from a reference diffusivity and reference temperature.
 *              User provides input units for specific parameters and provides
 *              desired unit basis of the calculation of diffusivity.
 *
 *
 *  \author Austin Ladshaw
 *  \date 09/14/2021
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

/// SimpleGasPoreDiffusivity class object inherits from SimpleGasPropertiesBase object
class SimpleGasPoreDiffusivity : public SimpleGasPropertiesBase
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Required constructor for objects in MOOSE
  SimpleGasPoreDiffusivity(const InputParameters & parameters);

protected:
  /// Required MOOSE function override
  virtual Real computeValue() override;

private:
  std::string _output_length_unit; ///< Units of the length term in transfer coef (m, cm, mm)
  std::string _output_time_unit;   ///< Units of the time term in transfer coef (hr, min, s)
};
