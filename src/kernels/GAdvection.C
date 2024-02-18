/*!
 *  \file GAdvection.h
 *	\brief Kernel for use with the corresponding DGAdvection object
 *	\details This file creates a standard MOOSE kernel that is to be used in conjunction with the
 *DGAdvection kernel for the discontinous Galerkin formulation of advection physics in MOOSE. In
 *order to complete the DG formulation of the advective physics, this kernel must be utilized with
 *every variable that also uses the DGAdvection kernel.
 *
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic
 *equations: Theory and Implementation, SIAM, Houston, TX, 2008.
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

#include "GAdvection.h"

registerMooseObject("catsApp", GAdvection);

InputParameters
GAdvection::validParams()
{
  InputParameters params = Kernel::validParams();
  params.addParam<Real>("vx", 0, "x-component of velocity vector");
  params.addParam<Real>("vy", 0, "y-component of velocity vector");
  params.addParam<Real>("vz", 0, "z-component of velocity vector");
  return params;
}

GAdvection::GAdvection(const InputParameters & parameters)
  : Kernel(parameters),
    _vx(getParam<Real>("vx")),
    _vy(getParam<Real>("vy")),
    _vz(getParam<Real>("vz"))

{
  _velocity(0) = _vx;
  _velocity(1) = _vy;
  _velocity(2) = _vz;
}

Real
GAdvection::computeQpResidual()
{
  return -_u[_qp] * (_velocity * _grad_test[_i][_qp]);
}

Real
GAdvection::computeQpJacobian()
{
  return -_phi[_j][_qp] * (_velocity * _grad_test[_i][_qp]);
}
