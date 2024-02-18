/*!
 *  \file DGNSMomentumOutflowBC.h
 *	\brief Boundary Condition kernel for the flux of momentum out of a domain
 *	\details This file creates a generic boundary condition kernel for the flux of momentum out of
 *			a boundary. The flux is based on a velocity vector, as well as domain density, and is valid
 *			in all directions and all boundaries of a DG method. Since the DG method's flux boundary
 *			conditions are essitially the same for input and ouput boundaries, this kernel will check
 *			the sign of the flux normal to the boundary and determine automattically whether it is
 *			an output or input boundary, then apply the appropriate conditions. If the boundary is
 *      an input boundary, then no flux will be applied.
 *
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic
 *equations: Theory and Implementation, SIAM, Houston, TX, 2008.
 *
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

#include "DGNSMomentumOutflowBC.h"

registerMooseObject("catsApp", DGNSMomentumOutflowBC);

InputParameters
DGNSMomentumOutflowBC::validParams()
{
  InputParameters params = DGConcentrationFluxBC::validParams();
  params.addCoupledVar("density", 1, "Variable for the density of the domain/subdomain");
  params.addRequiredCoupledVar("this_variable", "Name of this variable the kernel acts on");
  return params;
}

DGNSMomentumOutflowBC::DGNSMomentumOutflowBC(const InputParameters & parameters)
  : DGConcentrationFluxBC(parameters),
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
    moose::internal::mooseErrorRaw(
        "Supplied 'this_variable' argument does NOT correspond to a velocity component");
  }

  // Force inlet term to be zero for now.
  // Cannot force a momentum flux by coupling with
  // actual velocity at the boundary. This is because
  // if initial velocity is zero, then no flux will
  // occur. Need separate BC for inflow of momentum.
  _u_input = 0;
}

Real
DGNSMomentumOutflowBC::computeQpResidual()
{
  _velocity(0) = _ux[_qp];
  _velocity(1) = _uy[_qp];
  _velocity(2) = _uz[_qp];

  Real r = 0;

  // Output
  if ((_velocity)*_normals[_qp] > 0.0)
  {
    r += _test[_i][_qp] * (_velocity * _normals[_qp]) * _u[_qp] * _density[_qp];
  }
  // Input
  else
  {
    r += _test[_i][_qp] * (_velocity * _normals[_qp]) * _u_input * _density[_qp];
  }

  return r;
}

Real
DGNSMomentumOutflowBC::computeQpJacobian()
{
  _velocity(0) = _ux[_qp];
  _velocity(1) = _uy[_qp];
  _velocity(2) = _uz[_qp];

  Real r = 0;

  // Output
  if ((_velocity)*_normals[_qp] > 0.0)
  {
    r += _test[_i][_qp] * (_velocity * _normals[_qp]) * _phi[_j][_qp] * _density[_qp];
    r += _test[_i][_qp] * (_phi[_j][_qp] * _normals[_qp](_dir)) * _u[_qp] * _density[_qp];
  }
  // Input
  else
  {
    r += 0.0;
    r += _test[_i][_qp] * (_phi[_j][_qp] * _normals[_qp](_dir)) * _u_input * _density[_qp];
  }

  return r;
}

Real
DGNSMomentumOutflowBC::computeQpOffDiagJacobian(unsigned int jvar)
{
  _velocity(0) = _ux[_qp];
  _velocity(1) = _uy[_qp];
  _velocity(2) = _uz[_qp];

  Real r = 0;

  if (jvar == _ux_var && jvar != _main_var)
  {
    // Output
    if ((_velocity)*_normals[_qp] > 0.0)
    {
      r += _test[_i][_qp] * _u[_qp] * (_phi[_j][_qp] * _normals[_qp](0)) * _density[_qp];
    }
    // Input
    else
    {
      r += _test[_i][_qp] * _u_input * (_phi[_j][_qp] * _normals[_qp](0)) * _density[_qp];
    }
    return r;
  }

  if (jvar == _uy_var && jvar != _main_var)
  {
    // Output
    if ((_velocity)*_normals[_qp] > 0.0)
    {
      r += _test[_i][_qp] * _u[_qp] * (_phi[_j][_qp] * _normals[_qp](1)) * _density[_qp];
    }
    // Input
    else
    {
      r += _test[_i][_qp] * _u_input * (_phi[_j][_qp] * _normals[_qp](1)) * _density[_qp];
    }
    return r;
  }

  if (jvar == _uz_var && jvar != _main_var)
  {
    // Output
    if ((_velocity)*_normals[_qp] > 0.0)
    {
      r += _test[_i][_qp] * _u[_qp] * (_phi[_j][_qp] * _normals[_qp](2)) * _density[_qp];
    }
    // Input
    else
    {
      r += _test[_i][_qp] * _u_input * (_phi[_j][_qp] * _normals[_qp](2)) * _density[_qp];
    }
    return r;
  }

  if (jvar == _density_var)
  {
    // Output
    if ((_velocity)*_normals[_qp] > 0.0)
    {
      r += _test[_i][_qp] * _u[_qp] * (_velocity * _normals[_qp]) * _phi[_j][_qp];
    }
    // Input
    else
    {
      r += _test[_i][_qp] * _u_input * (_velocity * _normals[_qp]) * _phi[_j][_qp];
    }
    return r;
  }

  return 0.0;
}
