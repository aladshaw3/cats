/*!
 *  \file ScaledWeightedCoupledSumFunction.h
 *	\brief Standard kernel for coupling a vector non-linear variables via a weighted summation with scaling
 *	\details This file creates a standard MOOSE kernel for the coupling of a vector non-linear variables
 *			together to a variable whose value is to be determined by those coupled sums with scaling. This kernel is
 *      particularly useful if you have a variable that is a function of several different rate
 *      variables (e.g., dq/dt = r1 + 2*r2). In these cases, instead of rewriting each reaction
 *      kernel and redefining all parameters, you create a set of rate variables (r1, r2, etc), then
 *      coupled those rates to other non-linear variables and kernels.
 *
 *  \note The difference between this kernel and the 'WeightedCoupledSumFunction', which it inherits
 *        from, is that this function is multiplied by a common 'scale' variable. Typically, that 'scale'
 *        would be used as a unit conversion between mass balances. For instance, in a series of surface
 *        reaction that impact some bulk concentration, the 'scale' factor applied to all reactions
 *        would be the surface-to-volume ratio or the solids-to-total_volume ratio.
 *
 *  \note This should be used in conjunction with a TimeDerivative or Reaction kernel inside of the
 *        input file to enfore that the variable is the weighted sum of the coupled variables
 *
 *        Reaction kernel ==>   Res(u) = u*test
 *        Coupled Sum     ==>   Res(u) = -scale*(SUM(i, w_i * vars_i))*test
 *
 *  \author Austin Ladshaw
 *	\date 02/17/2021
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

#include "WeightedCoupledSumFunction.h"

/// ScaledWeightedCoupledSumFunction class object inherits from WeightedCoupledSumFunction object
/** This class object inherits from the Kernel object in the MOOSE framework.
	All public and protected members of this class are required function overrides.
	The kernel interfaces the set of non-linear variables to couple a summation functions
  to a list of coupled variables and their associated weight values, with variable scaling. */
class ScaledWeightedCoupledSumFunction : public WeightedCoupledSumFunction
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

	/// Required constructor for objects in MOOSE
	ScaledWeightedCoupledSumFunction(const InputParameters & parameters);

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

	const VariableValue & _scale;		  ///< Scaling variable
	const unsigned int _scale_var;		///< Variable identification for the scaling variable

private:

};
