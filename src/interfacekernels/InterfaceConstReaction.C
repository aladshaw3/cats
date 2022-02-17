/*!
 *  \file InterfaceConstReaction.h
 *  \brief Interface Kernel for creating a Henry's Law type of reaction between domains
 *  \details This file creates an iterface kernel for the coupling a pair of non-linear variables in different
 *            subdomains across a boundary designated as a side-set in the mesh. The variables are
 *            coupled linearly in a via a Henry's Law type reaction as shown below:
 *                  Res = test * (kf*u - kr*v)
 *                          where u = master variable in master domain
 *                          and v = neighbor variable in the adjacent subdomain
 *                          kf is always associated with variable u
 *                          and kr is always associated with variable v
 *
 *  \note Only need 1 interface kernel for both non-linear variables that are coupled to handle transfer in both domains
 *
 *
 *  \author Austin Ladshaw
 *  \date 04/06/2020
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "InterfaceConstReaction.h"

registerMooseObject("catsApp", InterfaceConstReaction);

InputParameters InterfaceConstReaction::validParams()
{
    InputParameters params = InterfaceKernel::validParams();
    params.addParam< Real >("variable_rate",1.0,"Forward reaction rate coefficient");
    params.addParam< Real >("neighbor_rate",1.0,"Reverse reaction rate coefficient");
    return params;
}

InterfaceConstReaction::InterfaceConstReaction(const InputParameters & parameters)
  : InterfaceKernel(parameters),
_variable_rate(getParam<Real>("variable_rate")),
_neighbor_rate(getParam<Real>("neighbor_rate"))
{
}

Real InterfaceConstReaction::computeQpResidual(Moose::DGResidualType type)
{
  Real r = 0;
  switch (type)
  {
    // Move all the terms to the LHS to get residual, for master domain
    // Residual = (kf*u - kr*v)
    // Weak form for master domain is: (test, kf*u - kr*v )
    case Moose::Element:
      r = _test[_i][_qp] * (_variable_rate*_u[_qp] - _neighbor_rate*_neighbor_value[_qp]);
      break;

    // Similarly, weak form for slave domain is: -(test, kf*u - kr*v),
    // flip the sign because the direction is opposite.
    case Moose::Neighbor:
      r = -_test_neighbor[_i][_qp] * (_variable_rate*_u[_qp] - _neighbor_rate*_neighbor_value[_qp]);
      break;
  }
  return r;
}

Real InterfaceConstReaction::computeQpJacobian(Moose::DGJacobianType type)
{
  Real jac = 0;
  switch (type)
  {
    case Moose::ElementElement:
      jac = _test[_i][_qp] * _variable_rate * _phi[_j][_qp];
      break;
    case Moose::NeighborNeighbor:
      jac = -_test_neighbor[_i][_qp] * -_neighbor_rate * _phi_neighbor[_j][_qp];
      break;
    case Moose::NeighborElement:
      jac = -_test_neighbor[_i][_qp] * _variable_rate * _phi[_j][_qp];
      break;
    case Moose::ElementNeighbor:
      jac = _test[_i][_qp] * -_neighbor_rate * _phi_neighbor[_j][_qp];
      break;
  }
  return jac;
}
