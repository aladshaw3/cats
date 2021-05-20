/*!
 *  \file DGVariableDiffusion.h
 *	\brief Discontinous Galerkin kernel for density diffusion with variable diffusivity coefficients
 *	\details This file creates a discontinous Galerkin kernel for density diffusion in a given domain that
 *           has a variable diffusivity. The diffusivity is represented by a set of non-linear variables
 *           in the x, y, and z directions (in the case of anisotropic diffusion).
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
 *	\note Any DG kernel under CATS will have a cooresponding G kernel (usually of same name) that must be included
 *		with the DG kernel in the input file. This is because the DG finite element method breaks into several different
 *		residual pieces, only a handful of which are handled by the DG kernel system and the other parts must be handled
 *		by the standard Galerkin system.
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

#include "DGVariableDiffusion.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", DGVariableDiffusion);

InputParameters DGVariableDiffusion::validParams()
{
    InputParameters params = DGAnisotropicDiffusion::validParams();
    params.addRequiredCoupledVar("Dx","Variable for diffusion in x-direction");
    params.addRequiredCoupledVar("Dy","Variable for diffusion in y-direction");
    params.addRequiredCoupledVar("Dz","Variable for diffusion in z-direction");
    return params;
}

DGVariableDiffusion::DGVariableDiffusion(const InputParameters & parameters) :
DGAnisotropicDiffusion(parameters),
_Dx(coupledValue("Dx")),
_Dy(coupledValue("Dy")),
_Dz(coupledValue("Dz")),
_Dx_var(coupled("Dx")),
_Dy_var(coupled("Dy")),
_Dz_var(coupled("Dz"))
{

}

Real DGVariableDiffusion::computeQpResidual(Moose::DGResidualType type)
{
  _Diffusion(0,0) = _Dx[_qp];
  _Diffusion(0,1) = 0.0;
  _Diffusion(0,2) = 0.0;

  _Diffusion(1,0) = 0.0;
  _Diffusion(1,1) = _Dy[_qp];
  _Diffusion(1,2) = 0.0;

  _Diffusion(2,0) = 0.0;
  _Diffusion(2,1) = 0.0;
  _Diffusion(2,2) = _Dz[_qp];

  return DGAnisotropicDiffusion::computeQpResidual(type);
}

Real DGVariableDiffusion::computeQpJacobian(Moose::DGJacobianType type)
{
  _Diffusion(0,0) = _Dx[_qp];
  _Diffusion(0,1) = 0.0;
  _Diffusion(0,2) = 0.0;

  _Diffusion(1,0) = 0.0;
  _Diffusion(1,1) = _Dy[_qp];
  _Diffusion(1,2) = 0.0;

  _Diffusion(2,0) = 0.0;
  _Diffusion(2,1) = 0.0;
  _Diffusion(2,2) = _Dz[_qp];

  return DGAnisotropicDiffusion::computeQpJacobian(type);
}

Real DGVariableDiffusion::computeQpOffDiagJacobian(Moose::DGJacobianType type, unsigned int jvar)
{
  _Diffusion(0,0) = _Dx[_qp];
  _Diffusion(0,1) = 0.0;
  _Diffusion(0,2) = 0.0;

  _Diffusion(1,0) = 0.0;
  _Diffusion(1,1) = _Dy[_qp];
  _Diffusion(1,2) = 0.0;

  _Diffusion(2,0) = 0.0;
  _Diffusion(2,1) = 0.0;
  _Diffusion(2,2) = _Dz[_qp];

  if (jvar == _Dx_var)
  {
    Real r = 0;
    switch (type)
		{
      //Uses test and grad_test
			case Moose::ElementElement:
        r -= 0.5 * (_phi[_j][_qp] * _grad_u[_qp](0) * _normals[_qp](0) +
            _phi[_j][_qp] * _grad_u_neighbor[_qp](0) * _normals[_qp](0)) *
            _test[_i][_qp];
        r += _epsilon * 0.5 * (_u[_qp] - _u_neighbor[_qp]) * _phi[_j][_qp] * _grad_test[_i][_qp](0) *
            _normals[_qp](0);
				break;
      //Uses test and grad_test
			case Moose::ElementNeighbor:
        r -= 0.5 * (_phi[_j][_qp] * _grad_u[_qp](0) * _normals[_qp](0) +
            _phi[_j][_qp] * _grad_u_neighbor[_qp](0) * _normals[_qp](0)) *
            _test[_i][_qp];
        r += _epsilon * 0.5 * (_u[_qp] - _u_neighbor[_qp]) * _phi[_j][_qp] * _grad_test[_i][_qp](0) *
            _normals[_qp](0);
				break;

      //Uses _test_neighbor and _grad_test_neighbor
			case Moose::NeighborElement:
        r += 0.5 * (_phi[_j][_qp] * _grad_u[_qp](0) * _normals[_qp](0) +
            _phi[_j][_qp] * _grad_u_neighbor[_qp](0) * _normals[_qp](0)) *
            _test_neighbor[_i][_qp];
        r += _epsilon * 0.5 * (_u[_qp] - _u_neighbor[_qp]) * _phi[_j][_qp] *
            _grad_test_neighbor[_i][_qp](0) * _normals[_qp](0);
				break;
      //Uses _test_neighbor and _grad_test_neighbor
			case Moose::NeighborNeighbor:
        r += 0.5 * (_phi[_j][_qp] * _grad_u[_qp](0) * _normals[_qp](0) +
            _phi[_j][_qp] * _grad_u_neighbor[_qp](0) * _normals[_qp](0)) *
            _test_neighbor[_i][_qp];
        r += _epsilon * 0.5 * (_u[_qp] - _u_neighbor[_qp]) * _phi[_j][_qp] *
            _grad_test_neighbor[_i][_qp](0) * _normals[_qp](0);
				break;
		}
    return r;
  }
  if (jvar == _Dy_var)
  {
    Real r = 0;
    switch (type)
    {
      //Uses test and grad_test
      case Moose::ElementElement:
        r -= 0.5 * (_phi[_j][_qp] * _grad_u[_qp](1) * _normals[_qp](1) +
            _phi[_j][_qp] * _grad_u_neighbor[_qp](1) * _normals[_qp](1)) *
            _test[_i][_qp];
        r += _epsilon * 0.5 * (_u[_qp] - _u_neighbor[_qp]) * _phi[_j][_qp] * _grad_test[_i][_qp](1) *
            _normals[_qp](1);
        break;
      //Uses test and grad_test
      case Moose::ElementNeighbor:
        r -= 0.5 * (_phi[_j][_qp] * _grad_u[_qp](1) * _normals[_qp](1) +
            _phi[_j][_qp] * _grad_u_neighbor[_qp](1) * _normals[_qp](1)) *
            _test[_i][_qp];
        r += _epsilon * 0.5 * (_u[_qp] - _u_neighbor[_qp]) * _phi[_j][_qp] * _grad_test[_i][_qp](1) *
            _normals[_qp](1);
        break;

      //Uses _test_neighbor and _grad_test_neighbor
      case Moose::NeighborElement:
        r += 0.5 * (_phi[_j][_qp] * _grad_u[_qp](1) * _normals[_qp](1) +
            _phi[_j][_qp] * _grad_u_neighbor[_qp](1) * _normals[_qp](1)) *
            _test_neighbor[_i][_qp];
        r += _epsilon * 0.5 * (_u[_qp] - _u_neighbor[_qp]) * _phi[_j][_qp] *
            _grad_test_neighbor[_i][_qp](1) * _normals[_qp](1);
        break;
      //Uses _test_neighbor and _grad_test_neighbor
      case Moose::NeighborNeighbor:
        r += 0.5 * (_phi[_j][_qp] * _grad_u[_qp](1) * _normals[_qp](1) +
            _phi[_j][_qp] * _grad_u_neighbor[_qp](1) * _normals[_qp](1)) *
            _test_neighbor[_i][_qp];
        r += _epsilon * 0.5 * (_u[_qp] - _u_neighbor[_qp]) * _phi[_j][_qp] *
            _grad_test_neighbor[_i][_qp](1) * _normals[_qp](1);
        break;
    }
    return r;
  }
  if (jvar == _Dz_var)
  {
    Real r = 0;
    switch (type)
    {
      //Uses test and grad_test
      case Moose::ElementElement:
        r -= 0.5 * (_phi[_j][_qp] * _grad_u[_qp](2) * _normals[_qp](2) +
            _phi[_j][_qp] * _grad_u_neighbor[_qp](2) * _normals[_qp](2)) *
            _test[_i][_qp];
        r += _epsilon * 0.5 * (_u[_qp] - _u_neighbor[_qp]) * _phi[_j][_qp] * _grad_test[_i][_qp](2) *
            _normals[_qp](2);
        break;
      //Uses test and grad_test
      case Moose::ElementNeighbor:
        r -= 0.5 * (_phi[_j][_qp] * _grad_u[_qp](2) * _normals[_qp](2) +
            _phi[_j][_qp] * _grad_u_neighbor[_qp](2) * _normals[_qp](2)) *
            _test[_i][_qp];
        r += _epsilon * 0.5 * (_u[_qp] - _u_neighbor[_qp]) * _phi[_j][_qp] * _grad_test[_i][_qp](2) *
            _normals[_qp](2);
        break;

      //Uses _test_neighbor and _grad_test_neighbor
      case Moose::NeighborElement:
        r += 0.5 * (_phi[_j][_qp] * _grad_u[_qp](2) * _normals[_qp](2) +
            _phi[_j][_qp] * _grad_u_neighbor[_qp](2) * _normals[_qp](2)) *
            _test_neighbor[_i][_qp];
        r += _epsilon * 0.5 * (_u[_qp] - _u_neighbor[_qp]) * _phi[_j][_qp] *
            _grad_test_neighbor[_i][_qp](2) * _normals[_qp](2);
        break;
      //Uses _test_neighbor and _grad_test_neighbor
      case Moose::NeighborNeighbor:
        r += 0.5 * (_phi[_j][_qp] * _grad_u[_qp](2) * _normals[_qp](2) +
            _phi[_j][_qp] * _grad_u_neighbor[_qp](2) * _normals[_qp](2)) *
            _test_neighbor[_i][_qp];
        r += _epsilon * 0.5 * (_u[_qp] - _u_neighbor[_qp]) * _phi[_j][_qp] *
            _grad_test_neighbor[_i][_qp](2) * _normals[_qp](2);
        break;
    }
    return r;
  }

  return 0.0;
}
