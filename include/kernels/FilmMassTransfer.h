/*!
 *  \file FilmMassTransfer.h
 *  \brief Kernel for creating an exchange of mass (or energy) between non-linear variables with a
 * variable rate \details This file creates a kernel for the coupling a pair of non-linear variables
 * in the same domain as a form of mass/energy transfer. The variables are coupled linearly in a via
 * a constant transfer coefficient as shown below: Res = test * vf * Ga * km * (u - v) where u =
 * this variable and v = coupled variable Ga = area-to-volume ratio for the transfer (L^-1) km =
 * transfer rate coupled variable (L/T) vf = volume fraction (-) common fraction is (1 - eb) =
 * (solids volume / total volume)
 *
 *
 *  \author Austin Ladshaw
 *  \date 04/21/2020
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

#include "ConstMassTransfer.h"

/// FilmMassTransfer class object inherits from ConstMassTransfer object
/** This class object inherits from the ConstMassTransfer object in the MOOSE framework.
    All public and protected members of this class are required function overrides.
    The kernel interfaces the pair of non-linear variables to create a kernel for a
    mass/energy transfer with a variable transfer rate and non-variable surface-to-volume ratio. */
class FilmMassTransfer : public ConstMassTransfer
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Required constructor for objects in MOOSE
  FilmMassTransfer(const InputParameters & parameters);

protected:
  /// Required residual function for standard kernels in MOOSE
  /** This function returns a residual contribution for this object.*/
  virtual Real computeQpResidual();

  /// Required Jacobian function for standard kernels in MOOSE
  /** This function returns a Jacobian contribution for this object. The Jacobian being
   computed is the associated diagonal element in the overall Jacobian matrix for the
   system and is used in preconditioning of the linear sub-problem. */
  virtual Real computeQpJacobian();

  /// Not Required, but aids in the preconditioning step
  /** This function returns the off diagonal Jacobian contribution for this object. By
   returning a non-zero value we will hopefully improve the convergence rate for the
   cross coupling of the variables. */
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  const VariableValue & _area_to_volume;  ///< Area to volume ratio (L^-1)
  const unsigned int _area_to_volume_var; ///< Variable identification for couled area to vol ratio
  const VariableValue & _coupled_rate;    ///< Coupled rate variable (L/T)
  const unsigned int _coupled_rate_var;   ///< Variable identification for the coupled rate variable
  const VariableValue & _volfrac;         ///< Variable for volume fraction (-)
  const unsigned int _volfrac_var;        ///< Variable identification for volume fraction

private:
};
