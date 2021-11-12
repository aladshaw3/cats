/*!
 *  \file GElectrolytePotentialConductivity.h
 *	\brief Standard kernel for a Poisson's equation for electrolyte conductivity
 *	\details This file creates a standard MOOSE kernel for the coupling of this kernel's variable for
 *            electrolyte potential (_u and _u_grad) with variables for ion concentration, diffusion
 *            coefficients for ions, temperature, and ion valence. This kernel is ONLY valid
 *            for isotropic diffusion, which should cover most all cases.
 *
 *  \note This kernel is meant to be used in conjunction with DGElectrolytePotentialConductivity
 *        to fully describe the physics of current transport in a DG sense.
 *
 *            Ref:  J.R. Clausen, V.E. Brunini, H.K. Moffat, M.J. Martinez, "Numerical Modeling
 *                  of an All Vanadium Redox Flow Battery", Sandia Report, SAND2014-0190,
 *                  Sandia National Laboratories, Albuquerque, NM, January 2014.
 *
 *  \author Austin Ladshaw
 *	\date 11/12/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

/****************************************************************/
/*               DO NOT MODIFY THIS HEADER                      */
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*           (c) 2010 Battelle Energy Alliance, LLC             */
/*                   ALL RIGHTS RESERVED                        */
/*                                                              */
/*          Prepared by Battelle Energy Alliance, LLC           */
/*            Under Contract No. DE-AC07-05ID14517              */
/*            With the U. S. Department of Energy               */
/*                                                              */
/*            See COPYRIGHT for full restrictions               */
/****************************************************************/

#pragma once

#include "ElectrolytePotentialConductivity.h"

/// GElectrolytePotentialConductivity class object inherits from ElectrolytePotentialConductivity object
/** This class object inherits from the Kernel object in the MOOSE framework.
	All public and protected members of this class are required function overrides.

	\note This kernel is effectively just a name change to follow our convention of
  DG kernel implementation. The base kernel it derives from should be used for
  standard continuous Galkerkin formulation of this kernel (with LAGRANGE functions)*/
class GElectrolytePotentialConductivity : public ElectrolytePotentialConductivity
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

	/// Required constructor for objects in MOOSE
	GElectrolytePotentialConductivity(const InputParameters & parameters);

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

private:

};
