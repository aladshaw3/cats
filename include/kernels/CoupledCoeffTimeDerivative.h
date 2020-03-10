/*!
 *  \file CoupledCoeffTimeDerivative.h
 *	\brief Standard kernel for coupling time derivatives
 *	\details This file creates a standard MOOSE kernel for the coupling of time derivative
 *			functions between different non-linear variables. It will serve as the basis
 *			for creating future heat and mass transfer kernels.
 *
 *  \author Austin Ladshaw
 *	\date 03/30/2017
 *	\copyright This kernel was designed and built at the Georgia Institute
 *             of Technology by Austin Ladshaw for PhD research in the area
 *             of adsorption and surface science and was developed for use
 *			   by Idaho National Laboratory and Oak Ridge National Laboratory
 *			   engineers and scientists. Portions Copyright (c) 2017, all
 *             rights reserved.
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

/// CoupledCoeffTimeDerivative class object forward declarationss
class CoupledCoeffTimeDerivative;

template<>
InputParameters validParams<CoupledCoeffTimeDerivative>();

/// CoupledCoeffTimeDerivative class object inherits from Kernel object
/** This class object inherits from the Kernel object in the MOOSE framework.
	All public and protected members of this class are required function overrides.
	The kernel interfaces the two non-linear variables to couple a time derivative
	function between given objects. */
class CoupledCoeffTimeDerivative : public Kernel
{
public:
	/// Required constructor for objects in MOOSE
	CoupledCoeffTimeDerivative(const InputParameters & parameters);
	
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
	
	bool _gaining;							///< Value is true if the time coef is positive
	Real _time_coef;						///< Time coefficient for the coupled time derivative
	const VariableValue & _coupled_dot;		///< Time derivative of the coupled variable
	const VariableValue & _coupled_ddot;	///< Cross derivative term for the coupled variables
	const unsigned int _coupled_var;		///< Variable identification for the coupled variable
	
private:

};
