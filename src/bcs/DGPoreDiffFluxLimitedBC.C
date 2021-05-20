/*!
 *  \file DGPoreDiffFluxLimitedBC.h
 *	\brief Boundary Condition kernel to mimic a Dirichlet BC for DG methods with coupled velocity, diffusivity, and porosity
 *	\details This file creates a boundary condition kernel to impose a dirichlet-like boundary
 *			condition in DG methods. True DG methods do not have Dirichlet boundary conditions,
 *			so this kernel seeks to impose a constraint on the inlet of a boundary that is met
 *			if the value of a variable at the inlet boundary is equal to the finite element
 *			solution at that boundary. When the condition is not met, the residuals get penalyzed
 *			until the condition is met.
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
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic equations:
 *                    Theory and Implementation, SIAM, Houston, TX, 2008.
 *
 *  \author Austin Ladshaw
 *	\date 03/09/2020
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

#include "DGPoreDiffFluxLimitedBC.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", DGPoreDiffFluxLimitedBC);

InputParameters DGPoreDiffFluxLimitedBC::validParams()
{
    InputParameters params = DGVarVelDiffFluxLimitedBC::validParams();
  params.addRequiredCoupledVar("porosity","Variable for the porosity of the domain/subdomain");
    return params;
}

DGPoreDiffFluxLimitedBC::DGPoreDiffFluxLimitedBC(const InputParameters & parameters) :
DGVarVelDiffFluxLimitedBC(parameters),
_porosity(coupledValue("porosity")),
_porosity_var(coupled("porosity"))
{

}

Real DGPoreDiffFluxLimitedBC::computeQpResidual()
{
	_velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

  _Diffusion(0,0) = _Dx[_qp];
  _Diffusion(0,1) = 0.0;
  _Diffusion(0,2) = 0.0;

  _Diffusion(1,0) = 0.0;
  _Diffusion(1,1) = _Dy[_qp];
  _Diffusion(1,2) = 0.0;

  _Diffusion(2,0) = 0.0;
  _Diffusion(2,1) = 0.0;
  _Diffusion(2,2) = _Dz[_qp];

  Real r = 0;

  const unsigned int elem_b_order = static_cast<unsigned int> (_var.order());
  const double h_elem = _current_elem->volume()/_current_side_elem->volume() * 1./std::pow(elem_b_order, 2.);

  //Output (Standard Flux Out)
  if ((_velocity)*_normals[_qp] > 0.0)
  {
    r += _test[_i][_qp]*(_velocity*_normals[_qp])*_u[_qp]*_porosity[_qp];
  }
  //Input (Dirichlet BC)
  else
  {
    r += _test[_i][_qp]*(_velocity*_normals[_qp])*_u_input*_porosity[_qp];
    r -= _test[_i][_qp]*(_velocity*_normals[_qp])*(_u[_qp] - _u_input)*_porosity[_qp];
    r += _epsilon * (_u[_qp] - _u_input) * _Diffusion * _grad_test[_i][_qp] * _normals[_qp]*_porosity[_qp];
    r += _sigma/h_elem * (_u[_qp] - _u_input) * _test[_i][_qp];
    r -= (_Diffusion * _grad_u[_qp] * _normals[_qp] * _test[_i][_qp])*_porosity[_qp];
  }

  return r;
}

Real DGPoreDiffFluxLimitedBC::computeQpJacobian()
{
	_velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

  _Diffusion(0,0) = _Dx[_qp];
  _Diffusion(0,1) = 0.0;
  _Diffusion(0,2) = 0.0;

  _Diffusion(1,0) = 0.0;
  _Diffusion(1,1) = _Dy[_qp];
  _Diffusion(1,2) = 0.0;

  _Diffusion(2,0) = 0.0;
  _Diffusion(2,1) = 0.0;
  _Diffusion(2,2) = _Dz[_qp];

  Real r = 0;

  const unsigned int elem_b_order = static_cast<unsigned int> (_var.order());
  const double h_elem = _current_elem->volume()/_current_side_elem->volume() * 1./std::pow(elem_b_order, 2.);

  //Output (Standard Flux Out)
  if ((_velocity)*_normals[_qp] > 0.0)
  {
    r += _test[_i][_qp]*(_velocity*_normals[_qp])*_phi[_j][_qp]*_porosity[_qp];
  }
  //Input (Dirichlet BC)
  else
  {
    r += 0.0;
    r -= _test[_i][_qp]*(_velocity*_normals[_qp])*_phi[_j][_qp]*_porosity[_qp];
    r += _epsilon * _phi[_j][_qp] * _Diffusion * _grad_test[_i][_qp] * _normals[_qp]*_porosity[_qp];
    r += _sigma/h_elem * _phi[_j][_qp] * _test[_i][_qp];
    r -= (_Diffusion * _grad_phi[_j][_qp] * _normals[_qp] * _test[_i][_qp])*_porosity[_qp];
  }

  return r;
}

Real DGPoreDiffFluxLimitedBC::computeQpOffDiagJacobian(unsigned int jvar)
{
	_velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

  _Diffusion(0,0) = _Dx[_qp];
  _Diffusion(0,1) = 0.0;
  _Diffusion(0,2) = 0.0;

  _Diffusion(1,0) = 0.0;
  _Diffusion(1,1) = _Dy[_qp];
  _Diffusion(1,2) = 0.0;

  _Diffusion(2,0) = 0.0;
  _Diffusion(2,1) = 0.0;
  _Diffusion(2,2) = _Dz[_qp];

  Real r = 0;

  if (jvar == _ux_var)
  {
    return DGConcentrationFluxLimitedBC::computeQpOffDiagJacobian(jvar)*_porosity[_qp];
  }

  if (jvar == _uy_var)
  {
    return DGConcentrationFluxLimitedBC::computeQpOffDiagJacobian(jvar)*_porosity[_qp];
  }

  if (jvar == _uz_var)
  {
    return DGConcentrationFluxLimitedBC::computeQpOffDiagJacobian(jvar)*_porosity[_qp];
  }

  if (jvar == _Dx_var)
  {
    return DGVarVelDiffFluxLimitedBC::computeQpOffDiagJacobian(jvar)*_porosity[_qp];
  }

  if (jvar == _Dy_var)
  {
    return DGVarVelDiffFluxLimitedBC::computeQpOffDiagJacobian(jvar)*_porosity[_qp];
  }

  if (jvar == _Dz_var)
  {
    return DGVarVelDiffFluxLimitedBC::computeQpOffDiagJacobian(jvar)*_porosity[_qp];
  }

  if (jvar == _porosity_var)
  {
    //Output (Standard Flux Out)
    if ((_velocity)*_normals[_qp] > 0.0)
    {
      r += _test[_i][_qp]*(_velocity*_normals[_qp])*_u[_qp]*_phi[_j][_qp];
    }
    //Input (Dirichlet BC)
    else
    {
      r += _test[_i][_qp]*(_velocity*_normals[_qp])*_u_input*_phi[_j][_qp];
      r -= _test[_i][_qp]*(_velocity*_normals[_qp])*(_u[_qp] - _u_input)*_phi[_j][_qp];
      r += _epsilon * (_u[_qp] - _u_input) * _Diffusion * _grad_test[_i][_qp] * _normals[_qp]*_phi[_j][_qp];
      r += 0.0;
      r -= (_Diffusion * _grad_u[_qp] * _normals[_qp] * _test[_i][_qp])*_phi[_j][_qp];
    }
    return r;
  }

  return 0.0;
}
