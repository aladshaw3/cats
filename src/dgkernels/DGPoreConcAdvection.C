/*!
*  \file DGPoreConcAdvection.h
*	\brief Discontinous Galerkin kernel for density advection with variable porosity
*	\details This file creates a discontinous Galerkin kernel for density advection in a given domain that
*           has a particular porosity. The porosity is represented by another non-linear variable, though
*           you can often specify that variable to be part of the Auxillary system with a constant value.
*
*	\note Any DG kernel under CATS will have a cooresponding G kernel (usually of same name) that must be included
*		with the DG kernel in the input file. This is because the DG finite element method breaks into several different
*		residual pieces, only a handful of which are handled by the DG kernel system and the other parts must be handled
*		by the standard Galerkin system.
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

#include "DGPoreConcAdvection.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", DGPoreConcAdvection);

/*
template<>
InputParameters validParams<DGPoreConcAdvection>()
{
	InputParameters params = validParams<DGConcentrationAdvection>();
    params.addRequiredCoupledVar("porosity","Variable for the porosity of the domain/subdomain");
	return params;
}
 */

InputParameters DGPoreConcAdvection::validParams()
{
    InputParameters params = DGConcentrationAdvection::validParams();
    params.addRequiredCoupledVar("porosity","Variable for the porosity of the domain/subdomain");
    return params;
}

DGPoreConcAdvection::DGPoreConcAdvection(const InputParameters & parameters) :
DGConcentrationAdvection(parameters),
_porosity(coupledValue("porosity")),
_porosity_var(coupled("porosity"))
{

}

Real DGPoreConcAdvection::computeQpResidual(Moose::DGResidualType type)
{
	_velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

	return DGAdvection::computeQpResidual(type)*_porosity[_qp];
}

Real DGPoreConcAdvection::computeQpJacobian(Moose::DGJacobianType type)
{
	_velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

	return DGAdvection::computeQpJacobian(type)*_porosity[_qp];
}

Real DGPoreConcAdvection::computeQpOffDiagJacobian(Moose::DGJacobianType type, unsigned int jvar)
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
					r += ( _phi[_j][_qp] * _normals[_qp](0) )*_porosity[_qp] * _u[_qp] * _test[_i][_qp];
				else
					r += ( _phi[_j][_qp] * _normals[_qp](0) )*_porosity[_qp] * _u_neighbor[_qp] * _test[_i][_qp];
				break;

			case Moose::ElementNeighbor:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += ( _phi[_j][_qp] * _normals[_qp](0) )*_porosity[_qp] * _u[_qp] * _test[_i][_qp];
				else
					r += ( _phi[_j][_qp] * _normals[_qp](0) )*_porosity[_qp] * _u_neighbor[_qp] * _test[_i][_qp];
				break;

			case Moose::NeighborElement:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += -( _phi[_j][_qp] * _normals[_qp](0) )*_porosity[_qp] * _u[_qp] * _test_neighbor[_i][_qp];
				else
					r += -( _phi[_j][_qp] * _normals[_qp](0) )*_porosity[_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
				break;

			case Moose::NeighborNeighbor:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += -( _phi[_j][_qp] * _normals[_qp](0) )*_porosity[_qp] * _u[_qp] * _test_neighbor[_i][_qp];
				else
					r += -( _phi[_j][_qp] * _normals[_qp](0) )*_porosity[_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
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
					r += ( _phi[_j][_qp] * _normals[_qp](1) )*_porosity[_qp] * _u[_qp] * _test[_i][_qp];
				else
					r += ( _phi[_j][_qp] * _normals[_qp](1) )*_porosity[_qp] * _u_neighbor[_qp] * _test[_i][_qp];
				break;

			case Moose::ElementNeighbor:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += ( _phi[_j][_qp] * _normals[_qp](1) )*_porosity[_qp] * _u[_qp] * _test[_i][_qp];
				else
					r += ( _phi[_j][_qp] * _normals[_qp](1) )*_porosity[_qp] * _u_neighbor[_qp] * _test[_i][_qp];
				break;

			case Moose::NeighborElement:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += -( _phi[_j][_qp] * _normals[_qp](1) )*_porosity[_qp] * _u[_qp] * _test_neighbor[_i][_qp];
				else
					r += -( _phi[_j][_qp] * _normals[_qp](1) )*_porosity[_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
				break;

			case Moose::NeighborNeighbor:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += -( _phi[_j][_qp] * _normals[_qp](1) )*_porosity[_qp] * _u[_qp] * _test_neighbor[_i][_qp];
				else
					r += -( _phi[_j][_qp] * _normals[_qp](1) )*_porosity[_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
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
					r += ( _phi[_j][_qp] * _normals[_qp](2) )*_porosity[_qp] * _u[_qp] * _test[_i][_qp];
				else
					r += ( _phi[_j][_qp] * _normals[_qp](2) )*_porosity[_qp] * _u_neighbor[_qp] * _test[_i][_qp];
				break;

			case Moose::ElementNeighbor:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += ( _phi[_j][_qp] * _normals[_qp](2) )*_porosity[_qp] * _u[_qp] * _test[_i][_qp];
				else
					r += ( _phi[_j][_qp] * _normals[_qp](2) )*_porosity[_qp] * _u_neighbor[_qp] * _test[_i][_qp];
				break;

			case Moose::NeighborElement:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += -( _phi[_j][_qp] * _normals[_qp](2) )*_porosity[_qp] * _u[_qp] * _test_neighbor[_i][_qp];
				else
					r += -( _phi[_j][_qp] * _normals[_qp](2) )*_porosity[_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
				break;

			case Moose::NeighborNeighbor:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += -( _phi[_j][_qp] * _normals[_qp](2) )*_porosity[_qp] * _u[_qp] * _test_neighbor[_i][_qp];
				else
					r += -( _phi[_j][_qp] * _normals[_qp](2) )*_porosity[_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
				break;
		}

		return r;
	}

  if (jvar == _porosity_var)
  {
    Real r = 0.0;

    switch (type)
    {

      case Moose::ElementElement:
        if ( (_velocity * _normals[_qp]) >= 0.0)
          r += ( _velocity * _normals[_qp] )*_phi[_j][_qp] * _u[_qp] * _test[_i][_qp];
        else
          r += ( _velocity * _normals[_qp] )*_phi[_j][_qp] * _u_neighbor[_qp] * _test[_i][_qp];
        break;

      case Moose::ElementNeighbor:
        if ( (_velocity * _normals[_qp]) >= 0.0)
          r += ( _velocity * _normals[_qp] )*_phi[_j][_qp] * _u[_qp] * _test[_i][_qp];
        else
          r += ( _velocity * _normals[_qp] )*_phi[_j][_qp] * _u_neighbor[_qp] * _test[_i][_qp];
        break;

      case Moose::NeighborElement:
        if ( (_velocity * _normals[_qp]) >= 0.0)
          r += -( _velocity * _normals[_qp] )*_phi[_j][_qp] * _u[_qp] * _test_neighbor[_i][_qp];
        else
          r += -( _velocity * _normals[_qp] )*_phi[_j][_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
        break;

      case Moose::NeighborNeighbor:
        if ( (_velocity * _normals[_qp]) >= 0.0)
          r += -( _velocity * _normals[_qp] )*_phi[_j][_qp] * _u[_qp] * _test_neighbor[_i][_qp];
        else
          r += -( _velocity * _normals[_qp] )*_phi[_j][_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
        break;
    }

    return r;
  }

	return 0.0;
}
