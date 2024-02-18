/*!
 *  \file SimpleFluidDispersion.h
 *    \brief AuxKernel kernel to calculate dispersion coefficients
 *    \details This file is responsible for calculating the dispersion coefficient
 *              for the domain given some simple properties. Calculation is based
 *              diffusivities that are corrected via an Arrhenius like
 *              expression from a reference diffusivity and reference temperature.
 *              User provides input units for specific parameters and provides
 *              desired unit basis of the calculation of dispersion.
 *
 *  \note Calculation can optionally involve a 'dispersivity' correction factor.
 *        Users must provide the length unit for the correction factor.
 *              Correction:   D = Dm * alpha*vel
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

#pragma once

#include "SimpleFluidPropertiesBase.h"

/// SimpleFluidDispersion class object inherits from SimpleFluidPropertiesBase object
class SimpleFluidDispersion : public SimpleFluidPropertiesBase
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Required constructor for objects in MOOSE
  SimpleFluidDispersion(const InputParameters & parameters);

protected:
  /// Required MOOSE function override
  virtual Real computeValue() override;

private:
  std::string _output_length_unit; ///< Units of the length term in transfer coef (m, cm, mm)
  std::string _output_time_unit;   ///< Units of the time term in transfer coef (hr, min, s)
  bool
      _includeDispersivityCorrection; ///< Boolean to determine if we should add correction for dispersivity
  bool
      _includePorosityCorrection; ///< Boolean to determine if we should add correction for porosity
};
