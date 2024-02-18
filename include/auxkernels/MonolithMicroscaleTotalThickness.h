/*!
 *  \file MonolithMicroscaleTotalThickness.h
 *    \brief Auxillary kernel to calculate the 1D microscale thickness for monoliths
 *    \details This file is responsible for calculating the effective 1D thickness
 *              for monoliths to be used in the Microscale set of kernels to resolve
 *              the intralayer diffusion equations using the hybrid FD/FE method
 *              of CATS. It should be noted that this is an effective thickness
 *              and not a true thickness. This effective thickness needs to be
 *              used to help account for diffusion in all walls and corners. However,
 *              due to how the Microscale kernels are implemented, you cannot
 *              automatically integrate this calculation into those kernels yet. Also,
 *              the units you get from this kernel will align with the units you
 *              give on input (i.e., if your cell density is in units of # cells
 *              per cm^2, then the thickness will be in cm).
 *
 *  \note The 'micro_length' parameter for Microscale kernels is implemented as a
 *        Param and not a Var. This is because you cannot place Vars in the
 *        [GlobalParams] block of an input file. Changing this convention would
 *        require a substaintial redesign of the user interface for Microscale
 *        kernels, which is why this change is not being made. User's who wish
 *        to use the Microscale kernels for a monolith domain should first
 *        calculate this value in a separate input file, then use that calculated
 *        value as the 'micro_length' Param in [GlobalParams] for evaluation of
 *        Microscale kinetics for monoliths.
 *
 *
 *  \author Austin Ladshaw
 *  \date 09/16/2021
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

/// MonolithMicroscaleTotalThickness class inherits from AuxKernel
class MonolithMicroscaleTotalThickness : public AuxKernel
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Standard MOOSE public constructor
  MonolithMicroscaleTotalThickness(const InputParameters & parameters);

protected:
  /// Required MOOSE function override
  virtual Real computeValue() override;

private:
  Real _cell_density; ///< Cell density of the monolith (cells per total face area)
  const VariableValue & _bulk_porosity; ///< Ratio of channel volume to total volume
  Real _wall_factor; ///< Multiplicity factor for the number of walls (default = 1)
};
