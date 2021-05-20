/*!
 *  \file DGFluxBC.h
 *	\brief Boundary Condition kernel for the flux across a boundary of the domain
 *	\details This file creates a generic boundary condition kernel for the flux of material accross
 *			a boundary. The flux is based on a velocity vector and is valid
 *			in all directions and all boundaries of a DG method. Since the DG method's flux boundary
 *			conditions are essitially the same for input and ouput boundaries, this kernel will check
 *			the sign of the flux normal to the boundary and determine automattically whether it is
 *			an output or input boundary, then apply the appropriate conditions.
 *
 *			This type of boundary condition for DG kernels applies the true flux boundary condition.
 *			In true finite volumes or DG methods, there is no Dirichlet	boundary conditions,
 *			because the solutions are based on fluxes into and out of cells in a domain.
 *
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic equations:
 *                    Theory and Implementation, SIAM, Houston, TX, 2008.
 *
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

#include "IntegratedBC.h"
#include "libmesh/vector_value.h"

/// DGFluxBC class object inherits from IntegratedBC object
/** This class object inherits from the IntegratedBC object.
	All public and protected members of this class are required function overrides.
	The flux BC uses the velocity in the system to apply a boundary
	condition based on whether or not material is leaving or entering the boundary. */
class DGFluxBC : public IntegratedBC
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

	/// Required constructor for BC objects in MOOSE
	DGFluxBC(const InputParameters & parameters);

protected:
	/// Required function override for BC objects in MOOSE
	/** This function returns a residual contribution for this object.*/
	virtual Real computeQpResidual() override;
	/// Required function override for BC objects in MOOSE
	/** This function returns a Jacobian contribution for this object. The Jacobian being
		computed is the associated diagonal element in the overall Jacobian matrix for the
		system and is used in preconditioning of the linear sub-problem. */
	virtual Real computeQpJacobian() override;

	/// Velocity vector in the system or at the boundary
	RealVectorValue _velocity;

	Real _vx;
	Real _vy;
	Real _vz;

	/// Value of the non-linear variable at the input of the boundary
	Real _u_input;

private:

};
