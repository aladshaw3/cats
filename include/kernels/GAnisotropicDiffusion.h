/*!
 *  \file GAnisotropicDiffusion.h
 *	\brief Kernel for use with the corresponding DGAnisotropicDiffusion object
 *	\details This file creates a standard MOOSE kernel that is to be used in conjunction with the DGAnisotropicDiffusion kernel
 *			for the discontinous Galerkin formulation of advection physics in MOOSE. In order to complete the DG
 *			formulation of the advective physics, this kernel must be utilized with every variable that also uses
 *			the DGAAnisotropicDiffusion kernel.
 *
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic equations:
 *                    Theory and Implementation, SIAM, Houston, TX, 2008.
 *
 *  \author Austin Ladshaw
 *	\date 11/20/2015
 *	\copyright This kernel was designed and built at the Georgia Institute
 *             of Technology by Austin Ladshaw for PhD research in the area
 *             of adsorption and surface science and was developed for use
 *			   by Idaho National Laboratory and Oak Ridge National Laboratory
 *			   engineers and scientists. Portions Copyright (c) 2015, all
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

/// GAnisotropicDiffusion class object forward declarations
class GAnisotropicDiffusion;

template<>
InputParameters validParams<GAnisotropicDiffusion>();

/// GAnisotropicDiffusion class object inherits from Kernel object
/** This class object inherits from the Kernel object in the MOOSE framework.
	All public and protected members of this class are required function overrides.
	The kernel has a diffusion tensor whose components can be set piecewise in an
	input file.

	\note To create a specific GAnisotropicDiffusion kernel, inherit from this class and override
	the components of the diffusion tensor, then call the residual and Jacobian functions
	for this object. */
class GAnisotropicDiffusion : public Kernel
{
public:
	/// Required constructor for objects in MOOSE
	GAnisotropicDiffusion(const InputParameters & parameters);

protected:
	/// Required residual function for standard kernels in MOOSE
	/** This function returns a residual contribution for this object.*/
	virtual Real computeQpResidual() override;
	/// Required Jacobian function for standard kernels in MOOSE
	/** This function returns a Jacobian contribution for this object. The Jacobian being
		computed is the associated diagonal element in the overall Jacobian matrix for the
		system and is used in preconditioning of the linear sub-problem. */
	virtual Real computeQpJacobian() override;

	RealTensorValue _Diffusion;			///< Diffusion tensor matrix parameter

	Real _Dxx, _Dxy, _Dxz;
	Real _Dyx, _Dyy, _Dyz;
	Real _Dzx, _Dzy, _Dzz;

private:

};
