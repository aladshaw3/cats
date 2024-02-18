/*!
 *  \file DGPoreConcAdvection.h
 *	\brief Discontinous Galerkin kernel for density advection with variable porosity
 *	\details This file creates a discontinous Galerkin kernel for density advection in a given
 *domain that has a particular porosity. The porosity is represented by another non-linear variable,
 *though you can often specify that variable to be part of the Auxillary system with a constant
 *value.
 *
 *	\note Any DG kernel under CATS will have a cooresponding G kernel (usually of same name) that
 *must be included with the DG kernel in the input file. This is because the DG finite element
 *method breaks into several different residual pieces, only a handful of which are handled by the
 *DG kernel system and the other parts must be handled by the standard Galerkin system.
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

#include "DGPoreConcAdvection.h"

registerMooseObject("catsApp", DGPoreConcAdvection);

InputParameters
DGPoreConcAdvection::validParams()
{
  InputParameters params = DGConcentrationAdvection::validParams();
  params.addRequiredCoupledVar("porosity", "Variable for the porosity of the domain/subdomain");
  return params;
}

DGPoreConcAdvection::DGPoreConcAdvection(const InputParameters & parameters)
  : DGConcentrationAdvection(parameters),
    _porosity(coupledValue("porosity")),
    _porosity_var(coupled("porosity"))
{
}

Real
DGPoreConcAdvection::computeQpResidual(Moose::DGResidualType type)
{
  _velocity(0) = _ux[_qp];
  _velocity(1) = _uy[_qp];
  _velocity(2) = _uz[_qp];

  _velocity_upwind(0) = _ux_upwind[_qp];
  _velocity_upwind(1) = _uy_upwind[_qp];
  _velocity_upwind(2) = _uz_upwind[_qp];

  return DGAdvection::computeQpResidual(type) * _porosity[_qp];
}

Real
DGPoreConcAdvection::computeQpJacobian(Moose::DGJacobianType type)
{
  _velocity(0) = _ux[_qp];
  _velocity(1) = _uy[_qp];
  _velocity(2) = _uz[_qp];

  _velocity_upwind(0) = _ux_upwind[_qp];
  _velocity_upwind(1) = _uy_upwind[_qp];
  _velocity_upwind(2) = _uz_upwind[_qp];

  return DGAdvection::computeQpJacobian(type) * _porosity[_qp];
}

Real
DGPoreConcAdvection::computeQpOffDiagJacobian(Moose::DGJacobianType type, unsigned int jvar)
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
          r += (_phi[_j][_qp] * _normals[_qp](0)) * _porosity[_qp] * _u[_qp] * _test[_i][_qp];
        else
          r += (_phi_neighbor[_j][_qp] * _normals[_qp](0)) * _porosity[_qp] * _u_neighbor[_qp] *
               _test[_i][_qp];
        break;

      case Moose::ElementNeighbor:
        if ((_velocity * _normals[_qp]) >= 0.0)
          r += (_phi[_j][_qp] * _normals[_qp](0)) * _porosity[_qp] * _u[_qp] * _test[_i][_qp];
        else
          r += (_phi_neighbor[_j][_qp] * _normals[_qp](0)) * _porosity[_qp] * _u_neighbor[_qp] *
               _test[_i][_qp];
        break;

      case Moose::NeighborElement:
        if ((_velocity * _normals[_qp]) >= 0.0)
          r += -(_phi[_j][_qp] * _normals[_qp](0)) * _porosity[_qp] * _u[_qp] *
               _test_neighbor[_i][_qp];
        else
          r += -(_phi_neighbor[_j][_qp] * _normals[_qp](0)) * _porosity[_qp] * _u_neighbor[_qp] *
               _test_neighbor[_i][_qp];
        break;

      case Moose::NeighborNeighbor:
        if ((_velocity * _normals[_qp]) >= 0.0)
          r += -(_phi[_j][_qp] * _normals[_qp](0)) * _porosity[_qp] * _u[_qp] *
               _test_neighbor[_i][_qp];
        else
          r += -(_phi_neighbor[_j][_qp] * _normals[_qp](0)) * _porosity[_qp] * _u_neighbor[_qp] *
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
          r += (_phi[_j][_qp] * _normals[_qp](1)) * _porosity[_qp] * _u[_qp] * _test[_i][_qp];
        else
          r += (_phi_neighbor[_j][_qp] * _normals[_qp](1)) * _porosity[_qp] * _u_neighbor[_qp] *
               _test[_i][_qp];
        break;

      case Moose::ElementNeighbor:
        if ((_velocity * _normals[_qp]) >= 0.0)
          r += (_phi[_j][_qp] * _normals[_qp](1)) * _porosity[_qp] * _u[_qp] * _test[_i][_qp];
        else
          r += (_phi_neighbor[_j][_qp] * _normals[_qp](1)) * _porosity[_qp] * _u_neighbor[_qp] *
               _test[_i][_qp];
        break;

      case Moose::NeighborElement:
        if ((_velocity * _normals[_qp]) >= 0.0)
          r += -(_phi[_j][_qp] * _normals[_qp](1)) * _porosity[_qp] * _u[_qp] *
               _test_neighbor[_i][_qp];
        else
          r += -(_phi_neighbor[_j][_qp] * _normals[_qp](1)) * _porosity[_qp] * _u_neighbor[_qp] *
               _test_neighbor[_i][_qp];
        break;

      case Moose::NeighborNeighbor:
        if ((_velocity * _normals[_qp]) >= 0.0)
          r += -(_phi[_j][_qp] * _normals[_qp](1)) * _porosity[_qp] * _u[_qp] *
               _test_neighbor[_i][_qp];
        else
          r += -(_phi_neighbor[_j][_qp] * _normals[_qp](1)) * _porosity[_qp] * _u_neighbor[_qp] *
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
          r += (_phi[_j][_qp] * _normals[_qp](2)) * _porosity[_qp] * _u[_qp] * _test[_i][_qp];
        else
          r += (_phi_neighbor[_j][_qp] * _normals[_qp](2)) * _porosity[_qp] * _u_neighbor[_qp] *
               _test[_i][_qp];
        break;

      case Moose::ElementNeighbor:
        if ((_velocity * _normals[_qp]) >= 0.0)
          r += (_phi[_j][_qp] * _normals[_qp](2)) * _porosity[_qp] * _u[_qp] * _test[_i][_qp];
        else
          r += (_phi_neighbor[_j][_qp] * _normals[_qp](2)) * _porosity[_qp] * _u_neighbor[_qp] *
               _test[_i][_qp];
        break;

      case Moose::NeighborElement:
        if ((_velocity * _normals[_qp]) >= 0.0)
          r += -(_phi[_j][_qp] * _normals[_qp](2)) * _porosity[_qp] * _u[_qp] *
               _test_neighbor[_i][_qp];
        else
          r += -(_phi_neighbor[_j][_qp] * _normals[_qp](2)) * _porosity[_qp] * _u_neighbor[_qp] *
               _test_neighbor[_i][_qp];
        break;

      case Moose::NeighborNeighbor:
        if ((_velocity * _normals[_qp]) >= 0.0)
          r += -(_phi[_j][_qp] * _normals[_qp](2)) * _porosity[_qp] * _u[_qp] *
               _test_neighbor[_i][_qp];
        else
          r += -(_phi_neighbor[_j][_qp] * _normals[_qp](2)) * _porosity[_qp] * _u_neighbor[_qp] *
               _test_neighbor[_i][_qp];
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
        if ((_velocity * _normals[_qp]) >= 0.0)
          r += (_velocity * _normals[_qp]) * _phi[_j][_qp] * _u[_qp] * _test[_i][_qp];
        else
          r += (_velocity_upwind * _normals[_qp]) * _phi[_j][_qp] * _u_neighbor[_qp] *
               _test[_i][_qp];
        break;

      case Moose::ElementNeighbor:
        if ((_velocity * _normals[_qp]) >= 0.0)
          r += (_velocity * _normals[_qp]) * _phi[_j][_qp] * _u[_qp] * _test[_i][_qp];
        else
          r += (_velocity_upwind * _normals[_qp]) * _phi[_j][_qp] * _u_neighbor[_qp] *
               _test[_i][_qp];
        break;

      case Moose::NeighborElement:
        if ((_velocity * _normals[_qp]) >= 0.0)
          r += -(_velocity * _normals[_qp]) * _phi[_j][_qp] * _u[_qp] * _test_neighbor[_i][_qp];
        else
          r += -(_velocity_upwind * _normals[_qp]) * _phi[_j][_qp] * _u_neighbor[_qp] *
               _test_neighbor[_i][_qp];
        break;

      case Moose::NeighborNeighbor:
        if ((_velocity * _normals[_qp]) >= 0.0)
          r += -(_velocity * _normals[_qp]) * _phi[_j][_qp] * _u[_qp] * _test_neighbor[_i][_qp];
        else
          r += -(_velocity_upwind * _normals[_qp]) * _phi[_j][_qp] * _u_neighbor[_qp] *
               _test_neighbor[_i][_qp];
        break;
    }

    return r;
  }

  return 0.0;
}
