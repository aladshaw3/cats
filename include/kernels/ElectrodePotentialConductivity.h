/*!
 *  \file ElectrodePotentialConductivity.h
 *	\brief Standard kernel for coupling porosity and conductivity to gradients of electrode potential
 *	\details This file creates a standard MOOSE kernel for the coupling of a set of non-linear variables
 *          for solids fraction and conductivity to the electric potential of a porous electrode. By default,
 *          the solids fraction is 1, thus, you can also use this kernel for non-porous electrodes. The
 *          conductivity can be a constant given value or another non-linear variable. This file
 *          assumes isotropic conductivity of the electrode, which is true in most all cases.
 *
 *
 *            Ref:  J.R. Clausen, V.E. Brunini, H.K. Moffat, M.J. Martinez, "Numerical Modeling
 *                  of an All Vanadium Redox Flow Battery", Sandia Report, SAND2014-0190,
 *                  Sandia National Laboratories, Albuquerque, NM, January 2014.
 *
 *  \author Austin Ladshaw
 *	\date 11/15/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#pragma once

#include "Kernel.h"

/// ElectrodePotentialConductivity class object inherits from Kernel object
/** This class object inherits from the Kernel object in the MOOSE framework.
	All public and protected members of this class are required function overrides.*/
class ElectrodePotentialConductivity : public Kernel
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

	/// Required constructor for objects in MOOSE
	ElectrodePotentialConductivity(const InputParameters & parameters);

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

private:

};
