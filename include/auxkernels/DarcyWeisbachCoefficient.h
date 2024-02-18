/*!
 *  \file DarcyWeisbachCoefficient.h
 *    \brief AuxKernel kernel base to calculate the coefficient to be used in the Darcy-Weisbach
 *relationship \details This file is responsible for calculating the Darcy-Weisbach coefficient
 *value to be used with the VariableLaplacian kernel to resolve pressure gradients in a fluid
 *conduit of given hydraulic diameter. Those pressure gradients are then coupled with the velocity
 *vector for superficial velocity in the media.
 *
 *  \note Users are responsible for making sure that their units will work out.
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

/// DarcyWeisbachCoefficient class object inherits from Kernel object
class DarcyWeisbachCoefficient : public AuxKernel
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Required constructor for objects in MOOSE
  DarcyWeisbachCoefficient(const InputParameters & parameters);

protected:
  /// Required MOOSE function override
  virtual Real computeValue() override;

  const VariableValue & _velocity; ///< Variable for the magnitude of velocity (length / time)
  const VariableValue & _density;  ///< Variable for the density of the fluid (mass / length^3)
  const VariableValue &
      _friction_factor; ///< Variable for friction factor (unitless --> User may calculate however they wish)
  const VariableValue & _hydraulic_dia; ///< Hydraulic diameter in the porous media (length)

private:
};
