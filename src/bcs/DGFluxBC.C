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

#include "DGFluxBC.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", DGFluxBC);

template<>
InputParameters validParams<DGFluxBC>()
{
	InputParameters params = validParams<IntegratedBC>();
	params.addParam<Real>("vx",0, "x-component of velocity vector");
	params.addParam<Real>("vy",0,"y-component of velocity vector");
	params.addParam<Real>("vz",0,"z-component of velocity vector");
	params.addParam<Real>("u_input", 1.0, "input value of u");
	return params;
}

DGFluxBC::DGFluxBC(const InputParameters & parameters) :
IntegratedBC(parameters),
_vx(getParam<Real>("vx")),
_vy(getParam<Real>("vy")),
_vz(getParam<Real>("vz")),
_u_input(getParam<Real>("u_input"))
{
	_velocity(0)=_vx;
	_velocity(1)=_vy;
	_velocity(2)=_vz;
}

Real
DGFluxBC::computeQpResidual()
{
	Real r = 0;

	//Output
	if ((_velocity)*_normals[_qp] > 0.0)
	{
		r += _test[_i][_qp]*(_velocity*_normals[_qp])*_u[_qp];
	}
	//Input
	else
	{
		r += _test[_i][_qp]*(_velocity*_normals[_qp])*_u_input;
	}

	return r;
}

Real
DGFluxBC::computeQpJacobian()
{
	Real r = 0;

	//Output
	if ((_velocity)*_normals[_qp] > 0.0)
	{
		r += _test[_i][_qp]*(_velocity*_normals[_qp])*_phi[_j][_qp];
	}
	//Input
	else
	{
		r += 0.0;
	}

	return r;
}
