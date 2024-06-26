/*!
 *  \file DGConcentrationAdvection.h
 *	\brief Discontinous Galerkin kernel for density advection
 *	\details This file creates a discontinous Galerkin kernel for density advection in a given
 *domain. It is a generic advection kernel that is meant to be inherited from to make a more
 *specific kernel for a given problem.
 *
 *	\note Any DG kernel under FENNEC will have a cooresponding G kernel (usually of same name) that
 *must be included with the DG kernel in the input file. This is because the DG finite element
 *method breaks into several different residual pieces, only a handful of which are handled by the
 *DG kernel system and the other parts must be handled by the standard Galerkin system. This my be
 *due to some legacy code in MOOSE. I am not sure if it is possible to lump all of these actions
 *into a single DG kernel.
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

#include "DGConcentrationAdvection.h"

registerMooseObject("catsApp", DGConcentrationAdvection);

InputParameters
DGConcentrationAdvection::validParams()
{
  InputParameters params = DGAdvection::validParams();
  params.addRequiredCoupledVar("ux", "Variable for velocity in x-direction");
  params.addRequiredCoupledVar("uy", "Variable for velocity in y-direction");
  params.addRequiredCoupledVar("uz", "Variable for velocity in z-direction");
  return params;
}

DGConcentrationAdvection::DGConcentrationAdvection(const InputParameters & parameters)
  : DGAdvection(parameters),
    _ux_mv(dynamic_cast<MooseVariable &>(*getVar("ux", 0))),
    _ux(_ux_mv.sln()),
    _ux_upwind(_ux_mv.slnNeighbor()),
    _ux_var(coupled("ux")),

    _uy_mv(dynamic_cast<MooseVariable &>(*getVar("uy", 0))),
    _uy(_uy_mv.sln()),
    _uy_upwind(_uy_mv.slnNeighbor()),
    _uy_var(coupled("uy")),

    _uz_mv(dynamic_cast<MooseVariable &>(*getVar("uz", 0))),
    _uz(_uz_mv.sln()),
    _uz_upwind(_uz_mv.slnNeighbor()),
    _uz_var(coupled("uz"))
{
}

Real
DGConcentrationAdvection::computeQpResidual(Moose::DGResidualType type)
{
  _velocity(0) = _ux[_qp];
  _velocity(1) = _uy[_qp];
  _velocity(2) = _uz[_qp];

  _velocity_upwind(0) = _ux_upwind[_qp];
  _velocity_upwind(1) = _uy_upwind[_qp];
  _velocity_upwind(2) = _uz_upwind[_qp];

  return DGAdvection::computeQpResidual(type);
}

Real
DGConcentrationAdvection::computeQpJacobian(Moose::DGJacobianType type)
{
  _velocity(0) = _ux[_qp];
  _velocity(1) = _uy[_qp];
  _velocity(2) = _uz[_qp];

  _velocity_upwind(0) = _ux_upwind[_qp];
  _velocity_upwind(1) = _uy_upwind[_qp];
  _velocity_upwind(2) = _uz_upwind[_qp];

  return DGAdvection::computeQpJacobian(type);
}

Real
DGConcentrationAdvection::computeQpOffDiagJacobian(Moose::DGJacobianType type, unsigned int jvar)
{
  _velocity(0) = _ux[_qp];
  _velocity(1) = _uy[_qp];
  _velocity(2) = _uz[_qp];

  _velocity_upwind(0) = _ux_upwind[_qp];
  _velocity_upwind(1) = _uy_upwind[_qp];
  _velocity_upwind(2) = _uz_upwind[_qp];

  if (jvar == _ux_var)
  {
    Real r = 0.0;

    switch (type)
    {

      case Moose::ElementElement:
        if ((_velocity * _normals[_qp]) >= 0.0)
          r += (_phi[_j][_qp] * _normals[_qp](0)) * _u[_qp] * _test[_i][_qp];
        else
          r += (_phi_neighbor[_j][_qp] * _normals[_qp](0)) * _u_neighbor[_qp] * _test[_i][_qp];
        break;

      case Moose::ElementNeighbor:
        if ((_velocity * _normals[_qp]) >= 0.0)
          r += (_phi[_j][_qp] * _normals[_qp](0)) * _u[_qp] * _test[_i][_qp];
        else
          r += (_phi_neighbor[_j][_qp] * _normals[_qp](0)) * _u_neighbor[_qp] * _test[_i][_qp];
        break;

      case Moose::NeighborElement:
        if ((_velocity * _normals[_qp]) >= 0.0)
          r += -(_phi[_j][_qp] * _normals[_qp](0)) * _u[_qp] * _test_neighbor[_i][_qp];
        else
          r += -(_phi_neighbor[_j][_qp] * _normals[_qp](0)) * _u_neighbor[_qp] *
               _test_neighbor[_i][_qp];
        break;

      case Moose::NeighborNeighbor:
        if ((_velocity * _normals[_qp]) >= 0.0)
          r += -(_phi[_j][_qp] * _normals[_qp](0)) * _u[_qp] * _test_neighbor[_i][_qp];
        else
          r += -(_phi_neighbor[_j][_qp] * _normals[_qp](0)) * _u_neighbor[_qp] *
               _test_neighbor[_i][_qp];
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
        if ((_velocity * _normals[_qp]) >= 0.0)
          r += (_phi[_j][_qp] * _normals[_qp](1)) * _u[_qp] * _test[_i][_qp];
        else
          r += (_phi_neighbor[_j][_qp] * _normals[_qp](1)) * _u_neighbor[_qp] * _test[_i][_qp];
        break;

      case Moose::ElementNeighbor:
        if ((_velocity * _normals[_qp]) >= 0.0)
          r += (_phi[_j][_qp] * _normals[_qp](1)) * _u[_qp] * _test[_i][_qp];
        else
          r += (_phi_neighbor[_j][_qp] * _normals[_qp](1)) * _u_neighbor[_qp] * _test[_i][_qp];
        break;

      case Moose::NeighborElement:
        if ((_velocity * _normals[_qp]) >= 0.0)
          r += -(_phi[_j][_qp] * _normals[_qp](1)) * _u[_qp] * _test_neighbor[_i][_qp];
        else
          r += -(_phi_neighbor[_j][_qp] * _normals[_qp](1)) * _u_neighbor[_qp] *
               _test_neighbor[_i][_qp];
        break;

      case Moose::NeighborNeighbor:
        if ((_velocity * _normals[_qp]) >= 0.0)
          r += -(_phi[_j][_qp] * _normals[_qp](1)) * _u[_qp] * _test_neighbor[_i][_qp];
        else
          r += -(_phi_neighbor[_j][_qp] * _normals[_qp](1)) * _u_neighbor[_qp] *
               _test_neighbor[_i][_qp];
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
        if ((_velocity * _normals[_qp]) >= 0.0)
          r += (_phi[_j][_qp] * _normals[_qp](2)) * _u[_qp] * _test[_i][_qp];
        else
          r += (_phi_neighbor[_j][_qp] * _normals[_qp](2)) * _u_neighbor[_qp] * _test[_i][_qp];
        break;

      case Moose::ElementNeighbor:
        if ((_velocity * _normals[_qp]) >= 0.0)
          r += (_phi[_j][_qp] * _normals[_qp](2)) * _u[_qp] * _test[_i][_qp];
        else
          r += (_phi_neighbor[_j][_qp] * _normals[_qp](2)) * _u_neighbor[_qp] * _test[_i][_qp];
        break;

      case Moose::NeighborElement:
        if ((_velocity * _normals[_qp]) >= 0.0)
          r += -(_phi[_j][_qp] * _normals[_qp](2)) * _u[_qp] * _test_neighbor[_i][_qp];
        else
          r += -(_phi_neighbor[_j][_qp] * _normals[_qp](2)) * _u_neighbor[_qp] *
               _test_neighbor[_i][_qp];
        break;

      case Moose::NeighborNeighbor:
        if ((_velocity * _normals[_qp]) >= 0.0)
          r += -(_phi[_j][_qp] * _normals[_qp](2)) * _u[_qp] * _test_neighbor[_i][_qp];
        else
          r += -(_phi_neighbor[_j][_qp] * _normals[_qp](2)) * _u_neighbor[_qp] *
               _test_neighbor[_i][_qp];
        break;
    }

    return r;
  }

  return 0.0;
}
