/*!
 *  \file InterfaceEnergyTransfer.h
 *  \brief Interface Kernel for creating an exchange of energy across a physical boundary
 *  \details This file creates an iterface kernel for the coupling a pair of energy variables in
 * different subdomains across a boundary designated as a side-set in the mesh. The variables are
 *            coupled from by their respective phase energies through a heat transfer coefficient
 *            and a contact area fraction (in the case of multiple phases in contact):
 *                  Res = test * h * fa * (Tu - Tv)
 *                          where Tu = master temperature variable in master domain
 *                          and Tv = neighbor temperature variable in the adjacent subdomain
 *                          h = heat transfer coefficient
 *                          fa = area fraction of contact between phases
 *
 *  \note Only need 1 interface kernel for both non-linear variables that are coupled to handle
 * transfer in both domains
 *
 *
 *  \author Austin Ladshaw
 *  \date 05/05/2020
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

#include "InterfaceKernel.h"

/// InterfaceEnergyTransfer class object inherits from InterfaceKernel object
/** This class object inherits from the InterfaceKernel object in the MOOSE framework.
    All public and protected members of this class are required function overrides.
    The kernel couples the pair of non-linear variables across a physical boundary to
    provide mass/energy transfer between domains.  */
class InterfaceEnergyTransfer : public InterfaceKernel
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Required constructor for objects in MOOSE
  InterfaceEnergyTransfer(const InputParameters & parameters);

protected:
  /// Required residual function for standard kernels in MOOSE
  /** This function returns a residual contribution for this object.*/
  virtual Real computeQpResidual(Moose::DGResidualType type) override;

  /// Required Jacobian function for standard kernels in MOOSE
  /** This function returns a Jacobian contribution for this object. The Jacobian being
   computed is the associated diagonal element in the overall Jacobian matrix for the
   system and is used in preconditioning of the linear sub-problem. */
  virtual Real computeQpJacobian(Moose::DGJacobianType type) override;

  /// Not required, but recomended function for DG kernels in MOOSE
  /** This function returns an off-diagonal jacobian contribution for this object. The jacobian
   being computed will be associated with the variables coupled to this object and not the
   main coupled variable itself. */
  virtual Real computeQpOffDiagJacobian(Moose::DGJacobianType type, unsigned int jvar) override;

  const VariableValue & _h;         ///< Variable for Heat transfer coefficient (W/m^2/K)
  const unsigned int _h_var;        ///< Variable identification for heat transfer
  const VariableValue & _Tu;        ///< Variable for master temperature (K)
  const unsigned int _Tu_var;       ///< Variable identification for master temperature
  MooseVariable & _Tv_moose_var;    ///< Neighbor variable
  const VariableValue & _Tv;        ///< Variable for neighbor temperature (K)
  const unsigned int _Tv_var;       ///< Variable identification for neighbor temperature
  const VariableValue & _areafrac;  ///< Variable for area fraction (-)
  const unsigned int _areafrac_var; ///< Variable identification for area fraction
};
