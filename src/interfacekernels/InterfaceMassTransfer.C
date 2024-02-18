/*!
 *  \file InterfaceMassTransfer.h
 *  \brief Interface Kernel for creating an exchange of mass (or energy) across a physical boundary
 *  \details This file creates an iterface kernel for the coupling a pair of non-linear variables in
 * different subdomains across a boundary designated as a side-set in the mesh. The variables are
 *            coupled linearly in a via a constant transfer coefficient as shown below:
 *                  Res = test * km * (u - v)
 *                          where u = master variable in master domain
 *                          and v = neighbor variable in the adjacent subdomain
 *
 *  \note Only need 1 interface kernel for both non-linear variables that are coupled to handle
 * transfer in both domains
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

#include "InterfaceMassTransfer.h"

registerMooseObject("catsApp", InterfaceMassTransfer);

InputParameters
InterfaceMassTransfer::validParams()
{
  InputParameters params = InterfaceKernel::validParams();
  params.addCoupledVar(
      "transfer_rate", 1.0, "Variable for mass transfer coefficient (length/time)");
  params.addCoupledVar(
      "area_frac", 1, "Variable for contact area fraction (or volume fraction) (-)");
  return params;
}

InterfaceMassTransfer::InterfaceMassTransfer(const InputParameters & parameters)
  : InterfaceKernel(parameters),
    _km(coupledValue("transfer_rate")),
    _km_var(coupled("transfer_rate")),
    _areafrac(coupledValue("area_frac")),
    _areafrac_var(coupled("area_frac"))
{
}

Real
InterfaceMassTransfer::computeQpResidual(Moose::DGResidualType type)
{
  Real r = 0;
  switch (type)
  {
    // Move all the terms to the LHS to get residual, for master domain
    // Residual = km*(u - v)
    // Weak form for master domain is: (test, km*(u - v) )
    case Moose::Element:
      r = _test[_i][_qp] * _km[_qp] * _areafrac[_qp] * (_u[_qp] - _neighbor_value[_qp]);
      break;

    // Similarly, weak form for slave domain is: -(test, km*(u - v)),
    // flip the sign because the direction is opposite.
    case Moose::Neighbor:
      r = -_test_neighbor[_i][_qp] * _areafrac[_qp] * _km[_qp] * (_u[_qp] - _neighbor_value[_qp]);
      break;
  }
  return r;
}

Real
InterfaceMassTransfer::computeQpJacobian(Moose::DGJacobianType type)
{
  Real jac = 0;
  switch (type)
  {
    case Moose::ElementElement:
      jac = _test[_i][_qp] * _km[_qp] * _areafrac[_qp] * _phi[_j][_qp];
      break;
    case Moose::NeighborNeighbor:
      jac = -_test_neighbor[_i][_qp] * -_km[_qp] * _areafrac[_qp] * _phi_neighbor[_j][_qp];
      break;
    case Moose::NeighborElement:
      jac = -_test_neighbor[_i][_qp] * _km[_qp] * _areafrac[_qp] * _phi[_j][_qp];
      break;
    case Moose::ElementNeighbor:
      jac = _test[_i][_qp] * -_km[_qp] * _areafrac[_qp] * _phi_neighbor[_j][_qp];
      break;
  }
  return jac;
}

Real
InterfaceMassTransfer::computeQpOffDiagJacobian(Moose::DGJacobianType type, unsigned int jvar)
{
  Real jac = 0.0;

  if (jvar == _km_var)
  {
    switch (type)
    {
      case Moose::ElementElement:
        jac = _test[_i][_qp] * _phi[_j][_qp] * _areafrac[_qp] * (_u[_qp] - _neighbor_value[_qp]);
        break;

      case Moose::NeighborNeighbor:
        jac = -_test_neighbor[_i][_qp] * _phi[_j][_qp] * _areafrac[_qp] *
              (_u[_qp] - _neighbor_value[_qp]);
        break;

      case Moose::NeighborElement:
        jac = -_test_neighbor[_i][_qp] * _phi[_j][_qp] * _areafrac[_qp] *
              (_u[_qp] - _neighbor_value[_qp]);
        break;

      case Moose::ElementNeighbor:
        jac = _test[_i][_qp] * _phi[_j][_qp] * _areafrac[_qp] * (_u[_qp] - _neighbor_value[_qp]);
        break;
    }
    return jac;
  }

  if (jvar == _areafrac_var)
  {
    switch (type)
    {
      case Moose::ElementElement:
        jac = _test[_i][_qp] * _phi[_j][_qp] * _km[_qp] * (_u[_qp] - _neighbor_value[_qp]);
        break;

      case Moose::NeighborNeighbor:
        jac =
            -_test_neighbor[_i][_qp] * _phi[_j][_qp] * _km[_qp] * (_u[_qp] - _neighbor_value[_qp]);
        break;

      case Moose::NeighborElement:
        jac =
            -_test_neighbor[_i][_qp] * _phi[_j][_qp] * _km[_qp] * (_u[_qp] - _neighbor_value[_qp]);
        break;

      case Moose::ElementNeighbor:
        jac = _test[_i][_qp] * _phi[_j][_qp] * _km[_qp] * (_u[_qp] - _neighbor_value[_qp]);
        break;
    }
    return jac;
  }

  return 0.0;
}
