/*!
 *  \file VarSiteDensityExtLangModel.h
 *	\brief Standard kernel for coupling a vector non-linear variables via an extended langmuir function with variable site density
 *	\details This file creates a standard MOOSE kernel for the coupling of a vector non-linear variables
 *			together via an extended langmuir forcing function while including a coupling for the site density term.
 *      Utilization of this kernel will allow users to specify a function or set of residuals to solve for
 *      the site density and couple that site density to this function that calculates the Langmuir capacity
 *      in terms of that site density. This is particularly useful to adding the effects of aging to the model.
 *
 *  \note This should be used in conjunction with a TimeDerivative or Reaction kernel inside of the
 *        input file to enfore that the variable sorbs material according to Langmuir
 *
 *        Reaction kernel ==>   Res(u) = u*test
 *        Extended Langmuir ==> Res(u) = -VarSiteDensLang*test
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

#include "ExtendedLangmuirModel.h"

/// VarSiteDensityExtLangModel class object forward declarationss
//class VarSiteDensityExtLangModel;

//template<>
//InputParameters validParams<VarSiteDensityExtLangModel>();

/// VarSiteDensityExtLangModel class object inherits from ExtendedLangmuirModel object
/** This class object inherits from the CoupledExtendedLangmuirFunction object in the MOOSE framework.
	All public and protected members of this class are required function overrides.
	The kernel interfaces the set of non-linear variables to couple an extended Langmuir
	forcing function between given objects. */
class VarSiteDensityExtLangModel : public ExtendedLangmuirModel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();
    
	/// Required constructor for objects in MOOSE
	VarSiteDensityExtLangModel(const InputParameters & parameters);

protected:
	/// Function to compute the Jacobi for the coupled site density
	Real computeExtLangmuirSiteJacobi();

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

	const VariableValue & _coupled_site_density;				///< Coupled variable for site density (mol/L)
	const unsigned int _coupled_var_site_density;				///< Index for the coupled temperature variable

private:

};
