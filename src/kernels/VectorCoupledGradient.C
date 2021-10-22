/*!
 *  \file VectorCoupledGradient.h
 *	\brief Standard kernel for coupling a gradient of another variable with a constant vector
 *	\details This file creates a standard MOOSE kernel for the coupling of a non-linear variable
 *            gradient dotted with a constant vector (i.e., vec * grad_v). The purpose of this
 *            kernel is to use with pressure and velocity variables to establish a simple flow
 *            field by enforcing continuity and coupling velocity with a pressure gradient.
 *            It should be noted that this in of itself is not enough to establish a true flow
 *            field, unless we are strictly only concerned with laminar flow and/or Darcy flow.
 *
 *  \note The vectors are allowed to just be unit vectors in a specific direction. This is particularly
 *        useful when enforcing the Divergence of velocity to be zero in a piecewise manner. 
 *
 *
 *  \author Austin Ladshaw
 *	\date 10/21/2021
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

#include "VectorCoupledGradient.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", VectorCoupledGradient);

InputParameters VectorCoupledGradient::validParams()
{
    InputParameters params = Kernel::validParams();
    params.addRequiredCoupledVar("coupled","Variable that we couple the gradient to");
    params.addParam<Real>("vx",0,"x-component of vector");
    params.addParam<Real>("vy",0,"y-component of vector");
    params.addParam<Real>("vz",0,"z-component of vector");
    return params;
}

VectorCoupledGradient::VectorCoupledGradient(const InputParameters & parameters) :
Kernel(parameters),
_vx(getParam<Real>("vx")),
_vy(getParam<Real>("vy")),
_vz(getParam<Real>("vz")),
_coupled_grad(coupledGradient("coupled")),
_coupled_var(coupled("coupled"))
{
  _vec(0)=_vx;
	_vec(1)=_vy;
	_vec(2)=_vz;
}

Real VectorCoupledGradient::computeQpResidual()
{
    return _test[_i][_qp]*(_vec*_coupled_grad[_qp]);
}

Real VectorCoupledGradient::computeQpJacobian()
{
    return 0.0;
}

Real VectorCoupledGradient::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _coupled_var)
  {
      return _test[_i][_qp]*(_vec*_grad_phi[_j][_qp]);
  }
  return 0.0;
}
