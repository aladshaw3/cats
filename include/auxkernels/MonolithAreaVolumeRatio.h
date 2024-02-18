/*!
 *  \file MonolithAreaVolumeRatio.h
 *    \brief Auxillary kernel to calculate the area-to-volume ratio of monolith channels
 *    \details This file is responsible for calculating the area-to-volume ratio
 *            for monolith channels based on the bulk channel volume to total volume
 *            ratio for the reactor (i.e., bulk porosity) and the cell density of
 *            the monolith (cells per total face area). Usits on output will be same
 *            unit basis on input.
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

/// MonolithAreaVolumeRatio class inherits from AuxKernel
class MonolithAreaVolumeRatio : public AuxKernel
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Standard MOOSE public constructor
  MonolithAreaVolumeRatio(const InputParameters & parameters);

protected:
  /// Required MOOSE function override
  virtual Real computeValue() override;

private:
  Real _cell_density; ///< Cell density of the monolith (cells per total face area)
  const VariableValue & _bulk_porosity; ///< Ratio of channel volume to total volume
  bool
      _PerSolidsVolume; ///< Boolean to determine if ratio to be calculated is per solid volume or per total volume
};
