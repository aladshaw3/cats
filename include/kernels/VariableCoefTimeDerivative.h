/*!
 *  \file VariableCoefTimeDerivative.h
 *	\brief Kernel to create a time derivative that is linearly dependent on another variable
 *	\details This file creates a standard MOOSE kernel that is to be used to coupled another
 *          MOOSE variable with the current variable. An example of usage would be to couple
 *          a concentration time derivative with a variable for porosity if that porosity
 *          where a non-linear or linear function of space-time.
 *
 *  \author Austin Ladshaw
 *	\date 03/09/2020
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

#include "CoefTimeDerivative.h"

//class VariableCoefTimeDerivative;

//template <>
//InputParameters validParams<VariableCoefTimeDerivative>();

/// VariableCoefTimeDerivative class object inherits from CoefTimeDerivative object
/**
 * Time derivative term multiplied by another variable as the coefficient.
 *  This will be useful for domains that have a pososity that varies in space
 *  and time.
 */
class VariableCoefTimeDerivative : public CoefTimeDerivative
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();
    
  /// Required constructor for objects in MOOSE
  VariableCoefTimeDerivative(const InputParameters & parameters);

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

  const VariableValue & _coupled;			///< Coupled non-linear variable
	const unsigned int _coupled_var;		///< Variable identification for _coupled
};
