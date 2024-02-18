/*!
 *  \file KozenyCarmanDarcyCoefficient.h
 *    \brief Auxillary kernel for a Kozney-Carman coefficient for implementation of Darcy's Law
 *    \details This file is responsible for calculating the value of an auxvariable
 *              according to the Kozney-Carman relationship for porous media. This calculated
 *              coefficient is to be used in the calculation of velocity in a porous media
 *              assuming Darcy flow. This is where all velocities are resolved via only
 *              pressure gradients in the domain and the pressure is resolved with a Laplace's
 *              equation with proper boundary conditions applied.
 *
 *              vel = Coeff * grad(P)   where Coeff is calculated from this kernel.
 *
 *              Laplace's Equation:  0 = Coeff * Div * grad(P)
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

#include "AuxKernel.h"

/// KozenyCarmanDarcyCoefficient class inherits from AuxKernel
class KozenyCarmanDarcyCoefficient : public AuxKernel
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Standard MOOSE public constructor
  KozenyCarmanDarcyCoefficient(const InputParameters & parameters);

protected:
  /// Required MOOSE function override
  virtual Real computeValue() override;

private:
  const VariableValue &
      _viscosity; ///< Variable for the viscosity of the fluid (typical units: Pressure * Time)
  const VariableValue & _macro_pore;   ///< Variable for the macro porosity
  const VariableValue & _particle_dia; ///< Particle diameter in the porous media (length)
  Real _K;                             ///< Kozeny-Carman constant of the porous media
};
