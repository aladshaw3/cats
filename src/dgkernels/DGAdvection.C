/*!
 *  \file DGAdvection.h
 *	\brief Discontinous Galerkin kernel for advection
 *	\details This file creates a discontinous Galerkin kernel for advection physics in a given domain. It is a generic
 *			advection kernel that is meant to be inherited from to make a more specific kernel for a given problem. The
 *			physical parameter in this kernel's formulation is a velocity vector. That vector can be built piecewise by
 *			the respective x, y, and z components of a velocity field at a given quadrature point.
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

#include "DGAdvection.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", DGAdvection);

InputParameters DGAdvection::validParams()
{
    InputParameters params = DGKernel::validParams();
    params.addParam<Real>("vx",0,"x-component of velocity vector");
    params.addParam<Real>("vy",0,"y-component of velocity vector");
    params.addParam<Real>("vz",0,"z-component of velocity vector");
    return params;
}

DGAdvection::DGAdvection(const InputParameters & parameters) :
DGKernel(parameters),
_vx(getParam<Real>("vx")),
_vy(getParam<Real>("vy")),
_vz(getParam<Real>("vz"))
{
	_velocity(0)=_vx;
	_velocity(1)=_vy;
	_velocity(2)=_vz;

  _velocity_upwind(0)=_vx;
  _velocity_upwind(1)=_vy;
  _velocity_upwind(2)=_vz;
}

Real DGAdvection::computeQpResidual(Moose::DGResidualType type)
{
	Real r = 0;

	switch (type)
	{
		case Moose::Element:
			if ( (_velocity * _normals[_qp]) >= 0.0)
				r += (_velocity * _normals[_qp]) * _u[_qp] * _test[_i][_qp];
			else
				r += (_velocity_upwind * _normals[_qp]) * _u_neighbor[_qp] * _test[_i][_qp];
			break;

		case Moose::Neighbor:
			if ( (_velocity * _normals[_qp]) >= 0.0)
				r += -(_velocity * _normals[_qp]) * _u[_qp] * _test_neighbor[_i][_qp];
			else
				r += -(_velocity_upwind * _normals[_qp]) * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
			break;
	}
	return r;
}

Real DGAdvection::computeQpJacobian(Moose::DGJacobianType type)
{
	Real r = 0;

	switch (type)
	{

		case Moose::ElementElement:
			if ( (_velocity * _normals[_qp]) >= 0.0)
				r += (_velocity * _normals[_qp]) * _phi[_j][_qp] * _test[_i][_qp];
			else
				r += 0.0;
			break;

		case Moose::ElementNeighbor:
			if ( (_velocity * _normals[_qp]) >= 0.0)
				r += 0.0;
			else
				r += (_velocity_upwind * _normals[_qp]) * _phi_neighbor[_j][_qp] * _test[_i][_qp];
			break;

		case Moose::NeighborElement:
			if ( (_velocity * _normals[_qp]) >= 0.0)
				r += -(_velocity * _normals[_qp]) * _phi[_j][_qp] * _test_neighbor[_i][_qp];
			else
				r += 0.0;
			break;

		case Moose::NeighborNeighbor:
			if ( (_velocity * _normals[_qp]) >= 0.0)
				r += 0.0;
			else
				r += -(_velocity_upwind * _normals[_qp]) * _phi_neighbor[_j][_qp] * _test_neighbor[_i][_qp];
			break;
	}
	return r;
}
