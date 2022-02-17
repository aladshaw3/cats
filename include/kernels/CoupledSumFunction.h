/*!
 *  \file CoupledSumFunction.h
 *	\brief Standard kernel for coupling a vector non-linear variables via summation function
 *	\details This file creates a standard MOOSE kernel for the coupling of a vector non-linear variables
 *			together to a variable whose value is to be determined by those coupled sums. This kernel is
 *      particularly useful if you have something like a heterogenous sorption problem and you want
 *      track individually the sorbed species on each type of surface site, but also want to couple
 *      to all surface sites through a single total adsorption value.
 *
 *  \note This should be used in conjunction with a TimeDerivative or Reaction kernel inside of the
 *        input file to enfore that the variable is the sum of the coupled variables
 *
 *        Reaction kernel ==>   Res(u) = u*test
 *        Coupled Sum     ==>   Res(u) = -(SUM(vars))*test
 *
 *  \author Austin Ladshaw
 *	\date 03/10/2020
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

#include "Kernel.h"

/// CoupledSumFunction class object inherits from Kernel object
class CoupledSumFunction : public Kernel
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

	/// Required constructor for objects in MOOSE
	CoupledSumFunction(const InputParameters & parameters);

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

	std::vector<const VariableValue *> _coupled;		///< Pointer list to the coupled gases (mol/L)
	std::vector<unsigned int> _coupled_vars;			  ///< Indices for the gas species in the system (sorbed + competetors)

private:

};
