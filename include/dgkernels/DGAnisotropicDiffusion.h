/*!
 *  \file DGAnisotropicDiffusion.h
 *	\brief Discontinous Galerkin kernel for anisotropic diffusion
 *	\details This file creates a discontinous Galerkin kernel for anisotropic diffusion in a given domain. It is a generic
 *			diffusion kernel that is meant to be inherited from to make a more specific kernel for a given problem. The
 *			physical parameter in this kernel's formulation is a diffusion tensor. That tensor can be built piecewise by
 *			the respective components of the tensor at a given quadrature point.
 *
 *      The DG method for diffusion involves 2 correction parameters:
 *
 *          (1) sigma - penalty term that should be >= 0 [if too large, it may cause errors]
 *          (2) epsilon - integer term with values of either -1, 0, or 1
 *
 *      Different values for epsilon result in slightly different discretizations:
 *
 *          (1) epsilon = -1   ==>   Symmetric Interior Penalty Galerkin (SIPG)
 *                                   Very efficient for symmetric problems, but may only
 *                                   converge if sigma is high.
 *          (2) epsilon = 0    ==>   Incomplete Interior Penalty Galerkin (IIPG)
 *                                   Works well for non-symmetic, well posed problems, but
 *                                   only converges under same sigma values as SIPG.
 *          (3) epsilon = 1    ==>   Non-symmetric Interior Penalty Galerking (NIPG)
 *                                   Most stable and easily convergable method that can
 *                                   work for symmetic and non-symmetric systems. Much
 *                                   less dependent on sigma values for convergence.
 *
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic equations:
 *                    Theory and Implementation, SIAM, Houston, TX, 2008.
 *
 *	\note Any DG kernel under DGOSPREY will have a cooresponding G kernel (usually of same name) that must be included
 *		with the DG kernel in the input file. This is because the DG finite element method breaks into several different
 *		residual pieces, only a handful of which are handled by the DG kernel system and the other parts must be handled
 *		by the standard Galerkin system. This my be due to some legacy code in MOOSE. I am not sure if it is possible to
 *		lump all of these actions into a single DG kernel.
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

#include "DGKernel.h"
#include "MooseVariable.h"
#include <cmath>

/// DGAnisotropicDiffusion class object inherits from DGKernel object
/** This class object inherits from the DGKernel object in the MOOSE framework.
	All public and protected members of this class are required function overrides. The object
	will provide residuals and Jacobians for the discontinous Galerkin formulation of advection
	physics in the MOOSE framework. The only parameter for this kernel is a diffusion tensor,
	whose components can be set piecewise in the input file or by inheriting from this base class
	and manually altering the tensor matrix.

	\note As a reminder, any DGKernel in MOOSE was be accompanied by the equivalent GKernel in
	order to provide the full residuals and Jacobians for the system. */
class DGAnisotropicDiffusion : public DGKernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

	/// Required constructor for objects in MOOSE
	DGAnisotropicDiffusion(const InputParameters & parameters);

protected:
	/// Required residual function for DG kernels in MOOSE
	/** This function returns a residual contribution for this object.*/
	virtual Real computeQpResidual(Moose::DGResidualType type) override;
	/// Required Jacobian function for DG kernels in MOOSE
	/** This function returns a Jacobian contribution for this object. The Jacobian being
		computed is the associated diagonal element in the overall Jacobian matrix for the
		system and is used in preconditioning of the linear sub-problem. */
	virtual Real computeQpJacobian(Moose::DGJacobianType type) override;

  MooseEnum _dg_scheme;					///< Enumerator to determine what scheme to use (NIPG, IIPG, or SIPG)
	Real _epsilon;									///< Penalty term for gradient jumps between the solution and test functions
	Real _sigma;										///< Penalty term applied to element size
	RealTensorValue _Diffusion;			///< Diffusion tensor matrix parameter

	Real _Dxx, _Dxy, _Dxz;
	Real _Dyx, _Dyy, _Dyz;
	Real _Dzx, _Dzy, _Dzz;

private:

};
