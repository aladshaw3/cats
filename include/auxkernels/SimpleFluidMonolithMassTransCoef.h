/*!
 *  \file SimpleFluidMonolithMassTransCoef.h
 *    \brief AuxKernel kernel to calculate mass transfer coefficient for a monolith or cylinder
 *    \details This file is responsible for calculating the mass transfer coefficient
 *              for cylindrical domains given some simple properties. Calculation is based
 *              off of the Reynolds, Schmidt, and Sherwood numbers for cylinder
 *              surfaces. Diffusivities are corrected via an Arrhenius like
 *              expression from a reference diffusivity and reference temperature.
 *              User provides input units for specific parameters and provides
 *              desired unit basis of the calculation of mass transfer.
 *
 *
 *  \author Austin Ladshaw
 *  \date 02/24/2022
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#pragma once

#include "SimpleFluidPropertiesBase.h"

/// SimpleFluidMonolithMassTransCoef class object inherits from SimpleFluidPropertiesBase object
class SimpleFluidMonolithMassTransCoef : public SimpleFluidPropertiesBase
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Required constructor for objects in MOOSE
  SimpleFluidMonolithMassTransCoef(const InputParameters & parameters);

protected:
  /// Required MOOSE function override
  virtual Real computeValue() override;

private:
  std::string _output_length_unit; ///< Units of the length term in transfer coef (m, cm, mm)
  std::string _output_time_unit;   ///< Units of the time term in transfer coef (hr, min, s)
};
