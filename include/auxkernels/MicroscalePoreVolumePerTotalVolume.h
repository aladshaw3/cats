/*!
 *  \file MicroscalePoreVolumePerTotalVolume.h
 *    \brief Auxillary kernel to calculate the microscale pore volume per total volume
 *    \details This file is responsible for calculating the microscale pore volume per
 *            total volume ratio. This is an auxkernel of convenience, as we often
 *            need this ratio (if the microscale balance is in terms of total volume).
 *            The ratio calculated is ew*(1-eb), where ew = microscale porosity (in
 *            volume of pore per volume of solid and eb = volume of voids per total
 *            system volume. This calculation is generally only used as a coefficient
 *            for the time derivative of the microscale mass balance.
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

#include "AuxKernel.h"

/// MicroscalePoreVolumePerTotalVolume class inherits from AuxKernel
class MicroscalePoreVolumePerTotalVolume : public AuxKernel
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Standard MOOSE public constructor
  MicroscalePoreVolumePerTotalVolume(const InputParameters & parameters);

protected:
  /// Required MOOSE function override
  virtual Real computeValue() override;

private:
  const VariableValue & _bulk_porosity;       ///< Variable for bulk porosity
  const VariableValue & _microscale_porosity; ///< Variable for microscale porosity
};
