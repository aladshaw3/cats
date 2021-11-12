/*!
 *  \file DGDiffusionFluxBC.h
 *	\brief Boundary Condition kernel apply diffusion flux at a boundary
 *	\details This file creates a boundary condition kernel to impose a diffusion flux
 *            boundary condition. Users can optionally provide a 'u_input' value for
 *            the value of the variable just outside the boundary. What this effectively
 *            does is impose of pseudo-Dirichlet BC at that boundary. By default, this
 *            value is taken to be zero, thus, material fluxes out of the box according
 *            to the given rate of diffusion. 
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
 *  \author Austin Ladshaw
 *	\date 11/12/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
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

#include "IntegratedBC.h"
#include "libmesh/vector_value.h"
#include "MooseVariable.h"

/// DGDiffusionFluxBC class object inherits from IntegratedBC object
/** This class object inherits from the IntegratedBC object.
	All public and protected members of this class are required function overrides.  */
class DGDiffusionFluxBC : public IntegratedBC
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

	/// Required constructor for BC objects in MOOSE
	DGDiffusionFluxBC(const InputParameters & parameters);

protected:
	/// Required function override for BC objects in MOOSE
	/** This function returns a residual contribution for this object.*/
	virtual Real computeQpResidual() override;
	/// Required function override for BC objects in MOOSE
	/** This function returns a Jacobian contribution for this object. The Jacobian being
		computed is the associated diagonal element in the overall Jacobian matrix for the
		system and is used in preconditioning of the linear sub-problem. */
	virtual Real computeQpJacobian() override;

	MooseEnum _dg_scheme;					///< Enumerator to determine what scheme to use (NIPG, IIPG, or SIPG)
	/// Penalty term applied to the difference between the solution at the inlet and the value it is supposed to be
	Real _epsilon;
	/// Penalty term based on the size of the element at the boundary
	Real _sigma;

	/// Diffusivity tensory in the system or at the boundary
	RealTensorValue _Diffusion;

	Real _Dxx, _Dxy, _Dxz;
	Real _Dyx, _Dyy, _Dyz;
	Real _Dzx, _Dzy, _Dzz;

	/// Value of the non-linear variable at the input of the boundary
	Real _u_input;

private:

};
