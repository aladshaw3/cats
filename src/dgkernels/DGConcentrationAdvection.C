/*!
 *  \file DGConcentrationAdvection.h
 *	\brief Discontinous Galerkin kernel for density advection
 *	\details This file creates a discontinous Galerkin kernel for density advection in a given domain. It is a generic
 *			advection kernel that is meant to be inherited from to make a more specific kernel for a given problem.
 *
 *	\note Any DG kernel under FENNEC will have a cooresponding G kernel (usually of same name) that must be included
 *		with the DG kernel in the input file. This is because the DG finite element method breaks into several different
 *		residual pieces, only a handful of which are handled by the DG kernel system and the other parts must be handled
 *		by the standard Galerkin system. This my be due to some legacy code in MOOSE. I am not sure if it is possible to
 *		lump all of these actions into a single DG kernel.
 *
 *  \author Austin Ladshaw
 *	\date 07/12/2018
 *	\copyright This kernel was designed and built at the Georgia Institute
 *             of Technology by Austin Ladshaw for PhD research in the area
 *             of radioactive particle transport and settling following a
 *			   nuclear event. It was developed for the US DOD under DTRA
 *			   project No. 14-24-FRCWMD-BAA. Portions Copyright (c) 2018, all
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

#include "DGConcentrationAdvection.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", DGConcentrationAdvection);

/*
template<>
InputParameters validParams<DGConcentrationAdvection>()
{
	InputParameters params = validParams<DGAdvection>();
	params.addRequiredCoupledVar("ux","Variable for velocity in x-direction");
	params.addRequiredCoupledVar("uy","Variable for velocity in y-direction");
	params.addRequiredCoupledVar("uz","Variable for velocity in z-direction");
	return params;
}
 */

InputParameters DGConcentrationAdvection::validParams()
{
    InputParameters params = DGAdvection::validParams();
    params.addRequiredCoupledVar("ux","Variable for velocity in x-direction");
    params.addRequiredCoupledVar("uy","Variable for velocity in y-direction");
    params.addRequiredCoupledVar("uz","Variable for velocity in z-direction");
    return params;
}

DGConcentrationAdvection::DGConcentrationAdvection(const InputParameters & parameters) :
DGAdvection(parameters),
_ux(coupledValue("ux")),
_uy(coupledValue("uy")),
_uz(coupledValue("uz")),
_ux_var(coupled("ux")),
_uy_var(coupled("uy")),
_uz_var(coupled("uz"))
{

}

Real DGConcentrationAdvection::computeQpResidual(Moose::DGResidualType type)
{
	_velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

	return DGAdvection::computeQpResidual(type);
}

Real DGConcentrationAdvection::computeQpJacobian(Moose::DGJacobianType type)
{
	_velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

	return DGAdvection::computeQpJacobian(type);
}

Real DGConcentrationAdvection::computeQpOffDiagJacobian(Moose::DGJacobianType type, unsigned int jvar)
{
	_velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

	if (jvar == _ux_var)
	{
		Real r = 0.0;

		switch (type)
		{

			case Moose::ElementElement:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += ( _phi[_j][_qp] * _normals[_qp](0) ) * _u[_qp] * _test[_i][_qp];
				else
					r += ( _phi[_j][_qp] * _normals[_qp](0) ) * _u_neighbor[_qp] * _test[_i][_qp];
				break;

			case Moose::ElementNeighbor:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += ( _phi[_j][_qp] * _normals[_qp](0) ) * _u[_qp] * _test[_i][_qp];
				else
					r += ( _phi[_j][_qp] * _normals[_qp](0) ) * _u_neighbor[_qp] * _test[_i][_qp];
				break;

			case Moose::NeighborElement:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += -( _phi[_j][_qp] * _normals[_qp](0) ) * _u[_qp] * _test_neighbor[_i][_qp];
				else
					r += -( _phi[_j][_qp] * _normals[_qp](0) ) * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
				break;

			case Moose::NeighborNeighbor:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += -( _phi[_j][_qp] * _normals[_qp](0) ) * _u[_qp] * _test_neighbor[_i][_qp];
				else
					r += -( _phi[_j][_qp] * _normals[_qp](0) ) * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
				break;
		}

		return r;
	}

	if (jvar == _uy_var)
	{
		Real r = 0.0;

		switch (type)
		{

			case Moose::ElementElement:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += ( _phi[_j][_qp] * _normals[_qp](1) ) * _u[_qp] * _test[_i][_qp];
				else
					r += ( _phi[_j][_qp] * _normals[_qp](1) ) * _u_neighbor[_qp] * _test[_i][_qp];
				break;

			case Moose::ElementNeighbor:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += ( _phi[_j][_qp] * _normals[_qp](1) ) * _u[_qp] * _test[_i][_qp];
				else
					r += ( _phi[_j][_qp] * _normals[_qp](1) ) * _u_neighbor[_qp] * _test[_i][_qp];
				break;

			case Moose::NeighborElement:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += -( _phi[_j][_qp] * _normals[_qp](1) ) * _u[_qp] * _test_neighbor[_i][_qp];
				else
					r += -( _phi[_j][_qp] * _normals[_qp](1) ) * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
				break;

			case Moose::NeighborNeighbor:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += -( _phi[_j][_qp] * _normals[_qp](1) ) * _u[_qp] * _test_neighbor[_i][_qp];
				else
					r += -( _phi[_j][_qp] * _normals[_qp](1) ) * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
				break;
		}

		return r;
	}

	if (jvar == _uz_var)
	{
		Real r = 0.0;

		switch (type)
		{

			case Moose::ElementElement:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += ( _phi[_j][_qp] * _normals[_qp](2) ) * _u[_qp] * _test[_i][_qp];
				else
					r += ( _phi[_j][_qp] * _normals[_qp](2) ) * _u_neighbor[_qp] * _test[_i][_qp];
				break;

			case Moose::ElementNeighbor:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += ( _phi[_j][_qp] * _normals[_qp](2) ) * _u[_qp] * _test[_i][_qp];
				else
					r += ( _phi[_j][_qp] * _normals[_qp](2) ) * _u_neighbor[_qp] * _test[_i][_qp];
				break;

			case Moose::NeighborElement:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += -( _phi[_j][_qp] * _normals[_qp](2) ) * _u[_qp] * _test_neighbor[_i][_qp];
				else
					r += -( _phi[_j][_qp] * _normals[_qp](2) ) * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
				break;

			case Moose::NeighborNeighbor:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += -( _phi[_j][_qp] * _normals[_qp](2) ) * _u[_qp] * _test_neighbor[_i][_qp];
				else
					r += -( _phi[_j][_qp] * _normals[_qp](2) ) * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
				break;
		}

		return r;
	}

	return 0.0;
}
