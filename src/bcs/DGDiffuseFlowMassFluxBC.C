/*!
 *  \file DGDiffuseFlowMassFluxBC.h
 *	\brief Boundary Condition kernel for diffuse driven mass flux at a boundary (includes velocity
 *if needed) \details This file creates a boundary condition kernel to impose a dirichlet-like
 *boundary condition in DG methods. True DG methods do not have Dirichlet boundary conditions, so
 *this kernel seeks to impose a constraint on the inlet of a boundary that is met if the value of a
 *variable at the inlet boundary is equal to the finite element solution at that boundary. When the
 *condition is not met, the residuals get penalyzed until the condition is met.
 *
 *      This kernel inherits from DGFluxLimitedBC and uses coupled x, y, and z components
 *      of the coupled velocity to build an edge velocity vector. This also now requires the
 *      addition of OffDiagJacobian elements. In addition, we now also coupled with a variable
 *      diffusivity.
 *
 *      The DG method for diffusion involves 2 correction parameters:
 *
 *          (1) sigma - penalty term that should be >= 0 [if too large, it may cause errors]
 *          (2) epsilon - integer term with values of either -1, 0, or 1
 *
 *      Different values for epsilon result in slightly different discretizations:
 *
 *          (1) epsilon = -1   ==>   Symmetric Interior Penalty Galerkin (SIPG)
 *                                   Very efficient for symmetric problems, but may only
 *                                   converge if sigma is high.
 *          (2) epsilon = 0    ==>   Incomplete Interior Penalty Galerkin (IIPG)
 *                                   Works well for non-symmetic, well posed problems, but
 *                                   only converges under same sigma values as SIPG.
 *          (3) epsilon = 1    ==>   Non-symmetric Interior Penalty Galerking (NIPG)
 *                                   Most stable and easily convergable method that can
 *                                   work for symmetic and non-symmetric systems. Much
 *                                   less dependent on sigma values for convergence.
 *
 *      User provides a variable for the inlet condition, thus, allowing the user to provide an
 *      inlet as a function of space-time or other non-linear relations through the Auxilary system.
 *
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic
 *equations: Theory and Implementation, SIAM, Houston, TX, 2008.
 *
 *  \author Austin Ladshaw
 *	\date 01/14/2022
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "DGDiffuseFlowMassFluxBC.h"

registerMooseObject("catsApp", DGDiffuseFlowMassFluxBC);

InputParameters
DGDiffuseFlowMassFluxBC::validParams()
{
  InputParameters params = DGPoreDiffFluxLimitedBC::validParams();
  params.addCoupledVar("input_var", 0, "Variable for the inlet condition");
  return params;
}

DGDiffuseFlowMassFluxBC::DGDiffuseFlowMassFluxBC(const InputParameters & parameters)
  : DGPoreDiffFluxLimitedBC(parameters),
    _input(coupledValue("input_var")),
    _input_var(coupled("input_var"))
{
}

Real
DGDiffuseFlowMassFluxBC::computeQpResidual()
{
  _u_input = _input[_qp];
  _velocity(0) = _ux[_qp];
  _velocity(1) = _uy[_qp];
  _velocity(2) = _uz[_qp];

  _Diffusion(0, 0) = _Dx[_qp];
  _Diffusion(0, 1) = 0.0;
  _Diffusion(0, 2) = 0.0;

  _Diffusion(1, 0) = 0.0;
  _Diffusion(1, 1) = _Dy[_qp];
  _Diffusion(1, 2) = 0.0;

  _Diffusion(2, 0) = 0.0;
  _Diffusion(2, 1) = 0.0;
  _Diffusion(2, 2) = _Dz[_qp];

  Real r = 0;

  const unsigned int elem_b_order = static_cast<unsigned int>(_var.order());
  const double h_elem =
      _current_elem->volume() / _current_side_elem->volume() * 1. / std::pow(elem_b_order, 2.);

  // Output (Standard Flux Out)
  if ((_velocity)*_normals[_qp] > 0.0)
  {
    r += _test[_i][_qp] * (_velocity * _normals[_qp]) * _u[_qp] * _porosity[_qp];
  }
  // Input (Dirichlet BC)
  else
  {
    r += _test[_i][_qp] * (_velocity * _normals[_qp]) * _u_input * _porosity[_qp];
    r -= _test[_i][_qp] * (_velocity * _normals[_qp]) * (_u[_qp] - _u_input) * _porosity[_qp];
    r += _epsilon * (_u[_qp] - _u_input) * _Diffusion * _grad_test[_i][_qp] * _normals[_qp] *
         _porosity[_qp];
    r += _sigma / h_elem * (_u[_qp] - _u_input) * _test[_i][_qp];
    r -= (_Diffusion * _grad_u[_qp] * _normals[_qp] * _test[_i][_qp]) * _porosity[_qp];
  }

  return r;
}

Real
DGDiffuseFlowMassFluxBC::computeQpJacobian()
{
  _u_input = _input[_qp];
  _velocity(0) = _ux[_qp];
  _velocity(1) = _uy[_qp];
  _velocity(2) = _uz[_qp];

  _Diffusion(0, 0) = _Dx[_qp];
  _Diffusion(0, 1) = 0.0;
  _Diffusion(0, 2) = 0.0;

  _Diffusion(1, 0) = 0.0;
  _Diffusion(1, 1) = _Dy[_qp];
  _Diffusion(1, 2) = 0.0;

  _Diffusion(2, 0) = 0.0;
  _Diffusion(2, 1) = 0.0;
  _Diffusion(2, 2) = _Dz[_qp];

  Real r = 0;

  const unsigned int elem_b_order = static_cast<unsigned int>(_var.order());
  const double h_elem =
      _current_elem->volume() / _current_side_elem->volume() * 1. / std::pow(elem_b_order, 2.);

  // Output (Standard Flux Out)
  if ((_velocity)*_normals[_qp] > 0.0)
  {
    r += _test[_i][_qp] * (_velocity * _normals[_qp]) * _phi[_j][_qp] * _porosity[_qp];
  }
  // Input (Dirichlet BC)
  else
  {
    r += 0.0;
    r -= _test[_i][_qp] * (_velocity * _normals[_qp]) * _phi[_j][_qp] * _porosity[_qp];
    r += _epsilon * _phi[_j][_qp] * _Diffusion * _grad_test[_i][_qp] * _normals[_qp] *
         _porosity[_qp];
    r += _sigma / h_elem * _phi[_j][_qp] * _test[_i][_qp];
    r -= (_Diffusion * _grad_phi[_j][_qp] * _normals[_qp] * _test[_i][_qp]) * _porosity[_qp];
  }

  return r;
}

Real
DGDiffuseFlowMassFluxBC::computeQpOffDiagJacobian(unsigned int jvar)
{
  _u_input = _input[_qp];
  _velocity(0) = _ux[_qp];
  _velocity(1) = _uy[_qp];
  _velocity(2) = _uz[_qp];

  _Diffusion(0, 0) = _Dx[_qp];
  _Diffusion(0, 1) = 0.0;
  _Diffusion(0, 2) = 0.0;

  _Diffusion(1, 0) = 0.0;
  _Diffusion(1, 1) = _Dy[_qp];
  _Diffusion(1, 2) = 0.0;

  _Diffusion(2, 0) = 0.0;
  _Diffusion(2, 1) = 0.0;
  _Diffusion(2, 2) = _Dz[_qp];

  Real r = 0;

  const unsigned int elem_b_order = static_cast<unsigned int>(_var.order());
  const double h_elem =
      _current_elem->volume() / _current_side_elem->volume() * 1. / std::pow(elem_b_order, 2.);

  if (jvar == _ux_var)
  {
    // Output
    if ((_velocity)*_normals[_qp] > 0.0)
    {
      r += _test[_i][_qp] * _u[_qp] * (_phi[_j][_qp] * _normals[_qp](0));
    }
    // Input
    else
    {
      r += _test[_i][_qp] * _u_input * (_phi[_j][_qp] * _normals[_qp](0));
      r -= _test[_i][_qp] * (_u[_qp] - _u_input) * (_phi[_j][_qp] * _normals[_qp](0));
    }
    return r * _porosity[_qp];
  }

  if (jvar == _uy_var)
  {
    // Output
    if ((_velocity)*_normals[_qp] > 0.0)
    {
      r += _test[_i][_qp] * _u[_qp] * (_phi[_j][_qp] * _normals[_qp](1));
    }
    // Input
    else
    {
      r += _test[_i][_qp] * _u_input * (_phi[_j][_qp] * _normals[_qp](1));
      r -= _test[_i][_qp] * (_u[_qp] - _u_input) * (_phi[_j][_qp] * _normals[_qp](1));
    }
    return r * _porosity[_qp];
  }

  if (jvar == _uz_var)
  {
    // Output
    if ((_velocity)*_normals[_qp] > 0.0)
    {
      r += _test[_i][_qp] * _u[_qp] * (_phi[_j][_qp] * _normals[_qp](2));
    }
    // Input
    else
    {
      r += _test[_i][_qp] * _u_input * (_phi[_j][_qp] * _normals[_qp](2));
      r -= _test[_i][_qp] * (_u[_qp] - _u_input) * (_phi[_j][_qp] * _normals[_qp](2));
    }
    return r * _porosity[_qp];
  }

  if (jvar == _Dx_var)
  {
    // Output
    if ((_velocity)*_normals[_qp] > 0.0)
    {
      r += 0.0;
    }
    // Input
    else
    {
      r += _epsilon * (_u[_qp] - _u_input) * _phi[_j][_qp] * _grad_test[_i][_qp](0) *
           _normals[_qp](0);
      r -= (_phi[_j][_qp] * _grad_u[_qp](0) * _normals[_qp](0) * _test[_i][_qp]);
    }
    return r * _porosity[_qp];
  }

  if (jvar == _Dy_var)
  {
    // Output
    if ((_velocity)*_normals[_qp] > 0.0)
    {
      r += 0.0;
    }
    // Input
    else
    {
      r += _epsilon * (_u[_qp] - _u_input) * _phi[_j][_qp] * _grad_test[_i][_qp](1) *
           _normals[_qp](1);
      r -= (_phi[_j][_qp] * _grad_u[_qp](1) * _normals[_qp](1) * _test[_i][_qp]);
    }
    return r * _porosity[_qp];
  }

  if (jvar == _Dz_var)
  {
    // Output
    if ((_velocity)*_normals[_qp] > 0.0)
    {
      r += 0.0;
    }
    // Input
    else
    {
      r += _epsilon * (_u[_qp] - _u_input) * _phi[_j][_qp] * _grad_test[_i][_qp](2) *
           _normals[_qp](2);
      r -= (_phi[_j][_qp] * _grad_u[_qp](2) * _normals[_qp](2) * _test[_i][_qp]);
    }
    return r * _porosity[_qp];
  }

  if (jvar == _porosity_var)
  {
    // Output (Standard Flux Out)
    if ((_velocity)*_normals[_qp] > 0.0)
    {
      r += _test[_i][_qp] * (_velocity * _normals[_qp]) * _u[_qp] * _phi[_j][_qp];
    }
    // Input (Dirichlet BC)
    else
    {
      r += _test[_i][_qp] * (_velocity * _normals[_qp]) * _u_input * _phi[_j][_qp];
      r -= _test[_i][_qp] * (_velocity * _normals[_qp]) * (_u[_qp] - _u_input) * _phi[_j][_qp];
      r += _epsilon * (_u[_qp] - _u_input) * _Diffusion * _grad_test[_i][_qp] * _normals[_qp] *
           _phi[_j][_qp];
      r += 0.0;
      r -= (_Diffusion * _grad_u[_qp] * _normals[_qp] * _test[_i][_qp]) * _phi[_j][_qp];
    }
    return r;
  }

  if (jvar == _input_var)
  {
    // Output (Standard Flux Out)
    if ((_velocity)*_normals[_qp] > 0.0)
    {
      r += 0;
    }
    // Input (Dirichlet BC)
    else
    {
      r += _test[_i][_qp] * (_velocity * _normals[_qp]) * _phi[_j][_qp] * _porosity[_qp];
      r -= _test[_i][_qp] * (_velocity * _normals[_qp]) * (-_phi[_j][_qp]) * _porosity[_qp];
      r += _epsilon * (-_phi[_j][_qp]) * _Diffusion * _grad_test[_i][_qp] * _normals[_qp] *
           _porosity[_qp];
      r += _sigma / h_elem * (-_phi[_j][_qp]) * _test[_i][_qp];
      r -= 0;
    }
    return r;
  }

  return 0.0;
}
