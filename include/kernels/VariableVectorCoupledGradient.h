/*!
 *  \file VariableVectorCoupledGradient.h
 *	\brief Standard kernel for coupling a gradient of another variable with a variable vector
 *	\details This file creates a standard MOOSE kernel for the coupling of a non-linear variable
 *            gradient dotted with a variable vector (i.e., vec * grad_v). The purpose of this
 *            kernel is to use with pressure and velocity variables to establish a simple flow
 *            field by enforcing continuity and coupling velocity with a pressure gradient.
 *            It should be noted that this in of itself is not enough to establish a true flow
 *            field, unless we are strictly only concerned with laminar flow and/or Darcy flow.
 *
 *            This kernel will inherit from VectorCoupledGradient and simply replace the constants
 *            of the vector in each direction with non-linear variables. This will allow the user
 *            to define those vector components in other kernels or aux kernels. A usage example
 *            would be Darcy Flow, where each component of the velocity variable vector is solved
 *            by a function with the pressure gradient in that direction.
 *
 *            e.g.,    vel_x = Var_Coeff * grad(P)_x
 *
 *            where Var_Coeff can be a variable to define the Kozeny-Carmen law for Darcy flux.
 *
 *            In the above case, the user would ONLY provide Var_Coeff variable as 'ux' in the
 *            input file, and then both 'uy' and 'uz' would be zero to denote that the 'vel_x'
 *            function is independent of the pressure gradients in the other directions.
 *
 *            Also note, this kernel ONLY calculates the RHS of the above relationship, thus,
 *            this needs to be combined with the 'Reaction' kernel to fully describe the physics.
 *
 *            e.g.,   Reaction:                         Res = -vel_x
 *                    VariableVectorCoupledGradient:    Res = Var_Coeff * grad(P)_x
 *
 *  \note The vectors are allowed to just be unit vectors in a specific direction. This is particularly
 *        useful when enforcing the Divergence of velocity to be zero in a piecewise manner.
 *
 *  \author Austin Ladshaw
 *	\date 10/29/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#pragma once

#include "VectorCoupledGradient.h"

/// VariableVectorCoupledGradient class object inherits from VectorCoupledGradient object
/** This class object inherits from the VectorCoupledGradient object in the MOOSE framework.
	All public and protected members of this class are required function overrides.
	The kernel has a vector whose components can be set piecewise in an
	input file. */
class VariableVectorCoupledGradient : public VectorCoupledGradient
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

	/// Required constructor for objects in MOOSE
	VariableVectorCoupledGradient(const InputParameters & parameters);

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

  const VariableValue & _ux;			///< variable for the x-direction derivatives
	const VariableValue & _uy;			///< variable for the y-direction derivatives
	const VariableValue & _uz;			///< variable for the z-direction derivatives

	const unsigned int _ux_var;					///< Variable identification for ux
	const unsigned int _uy_var;					///< Variable identification for uy
	const unsigned int _uz_var;					///< Variable identification for uz

private:

};
