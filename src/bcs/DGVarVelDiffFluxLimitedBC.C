/*!
 *  \file DGVarVelDiffFluxLimitedBC.h
 *	\brief Boundary Condition kernel to mimic a Dirichlet BC for DG methods with coupled velocity and diffusivity
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

#include "DGVarVelDiffFluxLimitedBC.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", DGVarVelDiffFluxLimitedBC);

InputParameters DGVarVelDiffFluxLimitedBC::validParams()
{
    InputParameters params = DGConcentrationFluxLimitedBC::validParams();
    params.addRequiredCoupledVar("Dx","Variable for diffusion in x-direction");
    params.addRequiredCoupledVar("Dy","Variable for diffusion in y-direction");
    params.addRequiredCoupledVar("Dz","Variable for diffusion in z-direction");
    return params;
}

DGVarVelDiffFluxLimitedBC::DGVarVelDiffFluxLimitedBC(const InputParameters & parameters) :
DGConcentrationFluxLimitedBC(parameters),
_Dx(coupledValue("Dx")),
_Dy(coupledValue("Dy")),
_Dz(coupledValue("Dz")),
_Dx_var(coupled("Dx")),
_Dy_var(coupled("Dy")),
_Dz_var(coupled("Dz"))
{

}

Real DGVarVelDiffFluxLimitedBC::computeQpResidual()
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

	return DGFluxLimitedBC::computeQpResidual();
}

Real DGVarVelDiffFluxLimitedBC::computeQpJacobian()
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

	return DGFluxLimitedBC::computeQpJacobian();
}

Real DGVarVelDiffFluxLimitedBC::computeQpOffDiagJacobian(unsigned int jvar)
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
    return DGConcentrationFluxLimitedBC::computeQpOffDiagJacobian(jvar);
  }

  if (jvar == _uy_var)
  {
    return DGConcentrationFluxLimitedBC::computeQpOffDiagJacobian(jvar);
  }

  if (jvar == _uz_var)
  {
    return DGConcentrationFluxLimitedBC::computeQpOffDiagJacobian(jvar);
  }

  if (jvar == _Dx_var)
  {
    //Output
    if ((_velocity)*_normals[_qp] > 0.0)
    {
      r += 0.0;
    }
    //Input
    else
    {
      r += _epsilon * (_u[_qp] - _u_input) * _phi[_j][_qp] * _grad_test[_i][_qp](0) * _normals[_qp](0);
      r -= (_phi[_j][_qp] * _grad_u[_qp](0) * _normals[_qp](0) * _test[_i][_qp]);
    }
    return r;
  }

  if (jvar == _Dy_var)
  {
    //Output
    if ((_velocity)*_normals[_qp] > 0.0)
    {
      r += 0.0;
    }
    //Input
    else
    {
      r += _epsilon * (_u[_qp] - _u_input) * _phi[_j][_qp] * _grad_test[_i][_qp](1) * _normals[_qp](1);
      r -= (_phi[_j][_qp] * _grad_u[_qp](1) * _normals[_qp](1) * _test[_i][_qp]);
    }
    return r;
  }

  if (jvar == _Dz_var)
  {
    //Output
    if ((_velocity)*_normals[_qp] > 0.0)
    {
      r += 0.0;
    }
    //Input
    else
    {
      r += _epsilon * (_u[_qp] - _u_input) * _phi[_j][_qp] * _grad_test[_i][_qp](2) * _normals[_qp](2);
      r -= (_phi[_j][_qp] * _grad_u[_qp](2) * _normals[_qp](2) * _test[_i][_qp]);
    }
    return r;
  }

  return 0.0;
}
