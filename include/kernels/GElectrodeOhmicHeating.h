/*!
 *  \file GElectrodeOhmicHeating.h
 *	\brief Standard kernel for coupling electrode potentials with thermal energy density
 *	\details This file creates a standard MOOSE kernel for the coupling of electrode potentials
 *          and other parameters into an energy balance for the thermal behavior of the electrode
 *          phase during charging and discharging of the batteries.
 *
 *
 *  \author Austin Ladshaw
 *	\date 08/01/2022
 *	\copyright This kernel was designed and built at SPAN.io by Austin Ladshaw
 *            for research in battery charging/discharging behavior.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#pragma once

#include "Kernel.h"

/// GElectrodeOhmicHeating class object inherits from Kernel object
/** This class object inherits from the Kernel object in the MOOSE framework.
	All public and protected members of this class are required function overrides.*/
class GElectrodeOhmicHeating : public Kernel
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

	/// Required constructor for objects in MOOSE
	GElectrodeOhmicHeating(const InputParameters & parameters);

protected:
	/// Required residual function for standard kernels in MOOSE
	/** This function returns a residual contribution for this object.*/
	virtual Real computeQpResidual() override;

	/// Required Jacobian function for standard kernels in MOOSE
	/** This function returns a Jacobian contribution for this object. The Jacobian being
		computed is the associated diagonal element in the overall Jacobian matrix for the
		system and is used in preconditioning of the linear sub-problem. */
	virtual Real computeQpJacobian() override;

  /// Not Required, but aids in the preconditioning step
  /** This function returns the off diagonal Jacobian contribution for this object. By
        returning a non-zero value we will hopefully improve the convergence rate for the
        cross coupling of the variables. */
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  const VariableValue & _sol_frac;			  ///< Solids fraction variable
  const unsigned int _sol_frac_var;				///< Variable identification for solids fraction

  const VariableValue & _conductivity;			  ///< Conductivity variable (in C/V/time/length or C^2/energy/time/length)
  const unsigned int _conductivity_var;				///< Variable identification for conductivity

  const VariableGradient & _e_potential_grad;            ///< Coupled potential variable (V or J/C)
  const unsigned int _e_potential_var;                   ///< Variable identification for coupled potential

private:

};
