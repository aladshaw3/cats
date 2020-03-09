/*!
 *  \file GPoreConcAdvection.h
 *	\brief Kernel for use with the corresponding DGPoreConcAdvection object
 *	\details This file creates a standard MOOSE kernel that is to be used in conjunction with DGPoreConcAdvection
 *			for the discontinous Galerkin formulation of advection in MOOSE. In order to complete the DG
 *			formulation of the advective physics, this kernel must be utilized with every variable that also uses
 *			the DGPoreConcAdvection kernel.
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

#include "GConcentrationAdvection.h"

/// GPoreConcAdvection class object forward declarations
class GPoreConcAdvection;

template<>
InputParameters validParams<GPoreConcAdvection>();

/// GConcentrationAdvection class object inherits from Kernel object
/** This class object inherits from the Kernel object in the MOOSE framework.
	All public and protected members of this class are required function overrides.
	The kernel has a velocity vector whose components can be set piecewise in an
	input file.

	\note To create a specific GAdvection kernel, inherit from this class and override
	the components of the velocity vector, then call the residual and Jacobian functions
	for this object. */
class GPoreConcAdvection : public GConcentrationAdvection
{
public:
	/// Required constructor for objects in MOOSE
	GPoreConcAdvection(const InputParameters & parameters);

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

	const VariableValue & _porosity;			    ///< Porosity variable
	const unsigned int _porosity_var;					///< Variable identification for porosity

private:

};
