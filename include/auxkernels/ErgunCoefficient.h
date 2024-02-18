/*!
 *  \file ErgunCoefficient.h
 *    \brief AuxKernel kernel base to calculate the coefficient to be used in the Ergun relationship
 *    \details This file is responsible for calculating the Ergun coefficient value
 *              to be used with the VariableLaplacian kernel to resolve pressure gradients
 *              in a packed-bed. Those pressure gradients are then coupled with the velocity
 *              vector for superficial velocity in the media.
 *
 *  \note Users are responsible for making sure that their units will work out.
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

#include "AuxKernel.h"

/// ErgunCoefficient class object inherits from Kernel object
class ErgunCoefficient : public AuxKernel
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Required constructor for objects in MOOSE
  ErgunCoefficient(const InputParameters & parameters);

protected:
  /// Required MOOSE function override
  virtual Real computeValue() override;

  const VariableValue & _velocity; ///< Variable for the magnitude of velocity (length / time)
  const VariableValue &
      _viscosity; ///< Variable for the viscosity of the fluid (mass / length / time)
  const VariableValue & _density;      ///< Variable for the density of the fluid (mass / length^3)
  const VariableValue & _macro_pore;   ///< Variable for the macro porosity
  const VariableValue & _particle_dia; ///< Particle diameter in the porous media (length)

private:
};
