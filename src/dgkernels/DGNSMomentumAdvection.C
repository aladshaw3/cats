/*!
*  \file DGNSMomentumAdvection.h
*	\brief Discontinous Galerkin kernel for momentum advection in Navier-Stokes
*	\details This file creates a discontinous Galerkin kernel for momentum advection in a given domain.
*           This file is to be used to solve the Navier-Stokes equations for a fluid
*           using discontinous Galerkin methods and shape functions.
*
*	\note Any DG kernel under CATS will have a cooresponding G kernel (usually of same name) that must be included
*		with the DG kernel in the input file. This is because the DG finite element method breaks into several different
*		residual pieces, only a handful of which are handled by the DG kernel system and the other parts must be handled
*		by the standard Galerkin system.
*
*  \author Austin Ladshaw
*	\date 10/26/2021
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

#include "DGNSMomentumAdvection.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", DGNSMomentumAdvection);

InputParameters DGNSMomentumAdvection::validParams()
{
    InputParameters params = DGConcentrationAdvection::validParams();
    params.addRequiredCoupledVar("density","Variable for the density of the domain/subdomain");
    params.addRequiredCoupledVar("this_variable","Name of this variable the kernel acts on");
    return params;
}

DGNSMomentumAdvection::DGNSMomentumAdvection(const InputParameters & parameters) :
DGConcentrationAdvection(parameters),
_density(coupledValue("density")),
_density_var(coupled("density")),
_coupled_main(coupledValue("this_variable")),
_main_var(coupled("this_variable"))
{
  if (_main_var == _ux_var)
    _dir = 0;
  else if (_main_var == _uy_var)
    _dir = 1;
  else if (_main_var == _uz_var)
    _dir = 2;
  else
  {
    moose::internal::mooseErrorRaw("Supplied 'this_variable' argument does NOT correspond to a velocity component");
  }
}

Real DGNSMomentumAdvection::computeQpResidual(Moose::DGResidualType type)
{
	_velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

	return DGAdvection::computeQpResidual(type)*_density[_qp];
}

Real DGNSMomentumAdvection::computeQpJacobian(Moose::DGJacobianType type)
{
	_velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

  Real jac = DGAdvection::computeQpJacobian(type)*_density[_qp];

  switch (type)
  {

    case Moose::ElementElement:
      if ( (_velocity * _normals[_qp]) >= 0.0)
        jac += ( _phi[_j][_qp] * _normals[_qp](_dir) )*_density[_qp] * _u[_qp] * _test[_i][_qp];
      else
        jac += ( _phi[_j][_qp] * _normals[_qp](_dir) )*_density[_qp] * _u_neighbor[_qp] * _test[_i][_qp];
      break;

    case Moose::ElementNeighbor:
      if ( (_velocity * _normals[_qp]) >= 0.0)
        jac += ( _phi[_j][_qp] * _normals[_qp](_dir) )*_density[_qp] * _u[_qp] * _test[_i][_qp];
      else
        jac += ( _phi[_j][_qp] * _normals[_qp](_dir) )*_density[_qp] * _u_neighbor[_qp] * _test[_i][_qp];
      break;

    case Moose::NeighborElement:
      if ( (_velocity * _normals[_qp]) >= 0.0)
        jac += -( _phi[_j][_qp] * _normals[_qp](_dir) )*_density[_qp] * _u[_qp] * _test_neighbor[_i][_qp];
      else
        jac += -( _phi[_j][_qp] * _normals[_qp](_dir) )*_density[_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
      break;

    case Moose::NeighborNeighbor:
      if ( (_velocity * _normals[_qp]) >= 0.0)
        jac += -( _phi[_j][_qp] * _normals[_qp](_dir) )*_density[_qp] * _u[_qp] * _test_neighbor[_i][_qp];
      else
        jac += -( _phi[_j][_qp] * _normals[_qp](_dir) )*_density[_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
      break;
  }

	return jac;
}

Real DGNSMomentumAdvection::computeQpOffDiagJacobian(Moose::DGJacobianType type, unsigned int jvar)
{
	_velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

	if (jvar == _ux_var && jvar != _main_var)
	{
		Real r = 0.0;

		switch (type)
		{

			case Moose::ElementElement:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += ( _phi[_j][_qp] * _normals[_qp](0) )*_density[_qp] * _u[_qp] * _test[_i][_qp];
				else
					r += ( _phi[_j][_qp] * _normals[_qp](0) )*_density[_qp] * _u_neighbor[_qp] * _test[_i][_qp];
				break;

			case Moose::ElementNeighbor:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += ( _phi[_j][_qp] * _normals[_qp](0) )*_density[_qp] * _u[_qp] * _test[_i][_qp];
				else
					r += ( _phi[_j][_qp] * _normals[_qp](0) )*_density[_qp] * _u_neighbor[_qp] * _test[_i][_qp];
				break;

			case Moose::NeighborElement:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += -( _phi[_j][_qp] * _normals[_qp](0) )*_density[_qp] * _u[_qp] * _test_neighbor[_i][_qp];
				else
					r += -( _phi[_j][_qp] * _normals[_qp](0) )*_density[_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
				break;

			case Moose::NeighborNeighbor:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += -( _phi[_j][_qp] * _normals[_qp](0) )*_density[_qp] * _u[_qp] * _test_neighbor[_i][_qp];
				else
					r += -( _phi[_j][_qp] * _normals[_qp](0) )*_density[_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
				break;
		}

		return r;
	}

	if (jvar == _uy_var && jvar != _main_var)
	{
		Real r = 0.0;

		switch (type)
		{

			case Moose::ElementElement:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += ( _phi[_j][_qp] * _normals[_qp](1) )*_density[_qp] * _u[_qp] * _test[_i][_qp];
				else
					r += ( _phi[_j][_qp] * _normals[_qp](1) )*_density[_qp] * _u_neighbor[_qp] * _test[_i][_qp];
				break;

			case Moose::ElementNeighbor:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += ( _phi[_j][_qp] * _normals[_qp](1) )*_density[_qp] * _u[_qp] * _test[_i][_qp];
				else
					r += ( _phi[_j][_qp] * _normals[_qp](1) )*_density[_qp] * _u_neighbor[_qp] * _test[_i][_qp];
				break;

			case Moose::NeighborElement:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += -( _phi[_j][_qp] * _normals[_qp](1) )*_density[_qp] * _u[_qp] * _test_neighbor[_i][_qp];
				else
					r += -( _phi[_j][_qp] * _normals[_qp](1) )*_density[_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
				break;

			case Moose::NeighborNeighbor:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += -( _phi[_j][_qp] * _normals[_qp](1) )*_density[_qp] * _u[_qp] * _test_neighbor[_i][_qp];
				else
					r += -( _phi[_j][_qp] * _normals[_qp](1) )*_density[_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
				break;
		}

		return r;
	}

	if (jvar == _uz_var && jvar != _main_var)
	{
		Real r = 0.0;

		switch (type)
		{

			case Moose::ElementElement:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += ( _phi[_j][_qp] * _normals[_qp](2) )*_density[_qp] * _u[_qp] * _test[_i][_qp];
				else
					r += ( _phi[_j][_qp] * _normals[_qp](2) )*_density[_qp] * _u_neighbor[_qp] * _test[_i][_qp];
				break;

			case Moose::ElementNeighbor:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += ( _phi[_j][_qp] * _normals[_qp](2) )*_density[_qp] * _u[_qp] * _test[_i][_qp];
				else
					r += ( _phi[_j][_qp] * _normals[_qp](2) )*_density[_qp] * _u_neighbor[_qp] * _test[_i][_qp];
				break;

			case Moose::NeighborElement:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += -( _phi[_j][_qp] * _normals[_qp](2) )*_density[_qp] * _u[_qp] * _test_neighbor[_i][_qp];
				else
					r += -( _phi[_j][_qp] * _normals[_qp](2) )*_density[_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
				break;

			case Moose::NeighborNeighbor:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += -( _phi[_j][_qp] * _normals[_qp](2) )*_density[_qp] * _u[_qp] * _test_neighbor[_i][_qp];
				else
					r += -( _phi[_j][_qp] * _normals[_qp](2) )*_density[_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
				break;
		}

		return r;
	}

  if (jvar == _density_var)
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
