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

#include "DGNSMomentumAdvection.h"

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

_dens_mv(dynamic_cast<MooseVariable &>(*getVar("density", 0))),
_density(_dens_mv.sln()),
_density_upwind(_dens_mv.slnNeighbor()),
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

  _velocity_upwind(0)=_ux_upwind[_qp];
  _velocity_upwind(1)=_uy_upwind[_qp];
  _velocity_upwind(2)=_uz_upwind[_qp];

  if ( (_velocity * _normals[_qp]) >= 0.0)
	   return DGAdvection::computeQpResidual(type)*_density[_qp];
  else
     return DGAdvection::computeQpResidual(type)*_density_upwind[_qp];
}

Real DGNSMomentumAdvection::computeQpJacobian(Moose::DGJacobianType type)
{
	_velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

  _velocity_upwind(0)=_ux_upwind[_qp];
  _velocity_upwind(1)=_uy_upwind[_qp];
  _velocity_upwind(2)=_uz_upwind[_qp];

  Real jac = 0.0;

  if ( (_velocity * _normals[_qp]) >= 0.0)
    jac = DGAdvection::computeQpJacobian(type)*_density[_qp];
  else
    jac = DGAdvection::computeQpJacobian(type)*_density_upwind[_qp];

  switch (type)
  {

    case Moose::ElementElement:
      if ( (_velocity * _normals[_qp]) >= 0.0)
        jac += ( _phi[_j][_qp] * _normals[_qp](_dir) )*_density[_qp] * _u[_qp] * _test[_i][_qp];
      else
        jac += ( _phi_neighbor[_j][_qp] * _normals[_qp](_dir) )*_density_upwind[_qp] * _u_neighbor[_qp] * _test[_i][_qp];
      break;

    case Moose::ElementNeighbor:
      if ( (_velocity * _normals[_qp]) >= 0.0)
        jac += ( _phi[_j][_qp] * _normals[_qp](_dir) )*_density[_qp] * _u[_qp] * _test[_i][_qp];
      else
        jac += ( _phi_neighbor[_j][_qp] * _normals[_qp](_dir) )*_density_upwind[_qp] * _u_neighbor[_qp] * _test[_i][_qp];
      break;

    case Moose::NeighborElement:
      if ( (_velocity * _normals[_qp]) >= 0.0)
        jac += -( _phi[_j][_qp] * _normals[_qp](_dir) )*_density[_qp] * _u[_qp] * _test_neighbor[_i][_qp];
      else
        jac += -( _phi_neighbor[_j][_qp] * _normals[_qp](_dir) )*_density_upwind[_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
      break;

    case Moose::NeighborNeighbor:
      if ( (_velocity * _normals[_qp]) >= 0.0)
        jac += -( _phi[_j][_qp] * _normals[_qp](_dir) )*_density[_qp] * _u[_qp] * _test_neighbor[_i][_qp];
      else
        jac += -( _phi_neighbor[_j][_qp] * _normals[_qp](_dir) )*_density_upwind[_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
      break;
  }

	return jac;
}

Real DGNSMomentumAdvection::computeQpOffDiagJacobian(Moose::DGJacobianType type, unsigned int jvar)
{
	_velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

  _velocity_upwind(0)=_ux_upwind[_qp];
  _velocity_upwind(1)=_uy_upwind[_qp];
  _velocity_upwind(2)=_uz_upwind[_qp];

	if (jvar == _ux_var && jvar != _main_var)
	{
		Real r = 0.0;

		switch (type)
		{

			case Moose::ElementElement:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += ( _phi[_j][_qp] * _normals[_qp](0) )*_density[_qp] * _u[_qp] * _test[_i][_qp];
				else
					r += ( _phi_neighbor[_j][_qp] * _normals[_qp](0) )*_density_upwind[_qp] * _u_neighbor[_qp] * _test[_i][_qp];
				break;

			case Moose::ElementNeighbor:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += ( _phi[_j][_qp] * _normals[_qp](0) )*_density[_qp] * _u[_qp] * _test[_i][_qp];
				else
					r += ( _phi_neighbor[_j][_qp] * _normals[_qp](0) )*_density_upwind[_qp] * _u_neighbor[_qp] * _test[_i][_qp];
				break;

			case Moose::NeighborElement:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += -( _phi[_j][_qp] * _normals[_qp](0) )*_density[_qp] * _u[_qp] * _test_neighbor[_i][_qp];
				else
					r += -( _phi_neighbor[_j][_qp] * _normals[_qp](0) )*_density_upwind[_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
				break;

			case Moose::NeighborNeighbor:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += -( _phi[_j][_qp] * _normals[_qp](0) )*_density[_qp] * _u[_qp] * _test_neighbor[_i][_qp];
				else
					r += -( _phi_neighbor[_j][_qp] * _normals[_qp](0) )*_density_upwind[_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
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
					r += ( _phi_neighbor[_j][_qp] * _normals[_qp](1) )*_density_upwind[_qp] * _u_neighbor[_qp] * _test[_i][_qp];
				break;

			case Moose::ElementNeighbor:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += ( _phi[_j][_qp] * _normals[_qp](1) )*_density[_qp] * _u[_qp] * _test[_i][_qp];
				else
					r += ( _phi_neighbor[_j][_qp] * _normals[_qp](1) )*_density_upwind[_qp] * _u_neighbor[_qp] * _test[_i][_qp];
				break;

			case Moose::NeighborElement:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += -( _phi[_j][_qp] * _normals[_qp](1) )*_density[_qp] * _u[_qp] * _test_neighbor[_i][_qp];
				else
					r += -( _phi_neighbor[_j][_qp] * _normals[_qp](1) )*_density_upwind[_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
				break;

			case Moose::NeighborNeighbor:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += -( _phi[_j][_qp] * _normals[_qp](1) )*_density[_qp] * _u[_qp] * _test_neighbor[_i][_qp];
				else
					r += -( _phi_neighbor[_j][_qp] * _normals[_qp](1) )*_density_upwind[_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
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
					r += ( _phi_neighbor[_j][_qp] * _normals[_qp](2) )*_density_upwind[_qp] * _u_neighbor[_qp] * _test[_i][_qp];
				break;

			case Moose::ElementNeighbor:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += ( _phi[_j][_qp] * _normals[_qp](2) )*_density[_qp] * _u[_qp] * _test[_i][_qp];
				else
					r += ( _phi_neighbor[_j][_qp] * _normals[_qp](2) )*_density_upwind[_qp] * _u_neighbor[_qp] * _test[_i][_qp];
				break;

			case Moose::NeighborElement:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += -( _phi[_j][_qp] * _normals[_qp](2) )*_density[_qp] * _u[_qp] * _test_neighbor[_i][_qp];
				else
					r += -( _phi_neighbor[_j][_qp] * _normals[_qp](2) )*_density_upwind[_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
				break;

			case Moose::NeighborNeighbor:
				if ( (_velocity * _normals[_qp]) >= 0.0)
					r += -( _phi_neighbor[_j][_qp] * _normals[_qp](2) )*_density[_qp] * _u[_qp] * _test_neighbor[_i][_qp];
				else
					r += -( _phi_neighbor[_j][_qp] * _normals[_qp](2) )*_density_upwind[_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
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
          r += ( _velocity_upwind * _normals[_qp] )*_phi_neighbor[_j][_qp] * _u_neighbor[_qp] * _test[_i][_qp];
        break;

      case Moose::ElementNeighbor:
        if ( (_velocity * _normals[_qp]) >= 0.0)
          r += ( _velocity * _normals[_qp] )*_phi[_j][_qp] * _u[_qp] * _test[_i][_qp];
        else
          r += ( _velocity_upwind * _normals[_qp] )*_phi_neighbor[_j][_qp] * _u_neighbor[_qp] * _test[_i][_qp];
        break;

      case Moose::NeighborElement:
        if ( (_velocity * _normals[_qp]) >= 0.0)
          r += -( _velocity * _normals[_qp] )*_phi[_j][_qp] * _u[_qp] * _test_neighbor[_i][_qp];
        else
          r += -( _velocity_upwind * _normals[_qp] )*_phi_neighbor[_j][_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
        break;

      case Moose::NeighborNeighbor:
        if ( (_velocity * _normals[_qp]) >= 0.0)
          r += -( _velocity * _normals[_qp] )*_phi[_j][_qp] * _u[_qp] * _test_neighbor[_i][_qp];
        else
          r += -( _velocity_upwind * _normals[_qp] )*_phi_neighbor[_j][_qp] * _u_neighbor[_qp] * _test_neighbor[_i][_qp];
        break;
    }

    return r;
  }

	return 0.0;
}
