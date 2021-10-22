/*!
 *  \file VectorCoupledGradient.h
 *	\brief Standard kernel for coupling a gradient of another variable with a constant vector
 *	\details This file creates a standard MOOSE kernel for the coupling of a non-linear variable
 *            gradient dotted with a constant vector (i.e., vec * grad_v). The purpose of this
 *            kernel is to use with pressure and velocity variables to establish a simple flow
 *            field by enforcing continuity and coupling velocity with a pressure gradient.
 *            It should be noted that this in of itself is not enough to establish a true flow
 *            field, unless we are strictly only concerned with laminar flow and/or Darcy flow.
 *
 *  \note The vectors are allowed to just be unit vectors in a specific direction. This is particularly
 *        useful when enforcing the Divergence of velocity to be zero in a piecewise manner.
 *
 *  \author Austin Ladshaw
 *	\date 10/21/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
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

#include "Kernel.h"

/// VectorCoupledGradient class object inherits from Kernel object
/** This class object inherits from the Kernel object in the MOOSE framework.
	All public and protected members of this class are required function overrides.
	The kernel has a vector whose components can be set piecewise in an
	input file. */
class VectorCoupledGradient : public Kernel
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

	/// Required constructor for objects in MOOSE
	VectorCoupledGradient(const InputParameters & parameters);

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

	RealVectorValue _vec;	///< Vector

	Real _vx;					///< x-component of vector (optional - set in input file)
	Real _vy;					///< y-component of vector (optional - set in input file)
	Real _vz;					///< z-component of vector (optional - set in input file)

  const VariableGradient & _coupled_grad;            ///< Coupled variable gradient
  const unsigned int _coupled_var;                   ///< Variable identification for coupled variable

private:

};
