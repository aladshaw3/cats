/*!
 *  \file VariableVectorCoupledGradient.h
 *	\brief Standard kernel for coupling a gradient of another variable with a variable vector
 *	\details This file creates a standard MOOSE kernel for the coupling of a non-linear variable
 *            gradient dotted with a variable vector (i.e., vec * grad_v). The purpose of this
 *            kernel is to use with pressure and velocity variables to establish a simple flow
 *            field by enforcing continuity and coupling velocity with a pressure gradient.
 *            It should be noted that this in of itself is not enough to establish a true flow
 *            field, unless we are strictly only concerned with laminar flow and/or Darcy flow.
 *
 *            This kernel will inherit from VectorCoupledGradient and simply replace the constants
 *            of the vector in each direction with non-linear variables. This will allow the user
 *            to define those vector components in other kernels or aux kernels. A usage example
 *            would be Darcy Flow, where each component of the velocity variable vector is solved
 *            by a function with the pressure gradient in that direction.
 *
 *            e.g.,    vel_x = Var_Coeff * grad(P)_x
 *
 *            where Var_Coeff can be a variable to define the Kozeny-Carmen law for Darcy flux.
 *
 *            In the above case, the user would ONLY provide Var_Coeff variable as 'ux' in the
 *            input file, and then both 'uy' and 'uz' would be zero to denote that the 'vel_x'
 *            function is independent of the pressure gradients in the other directions.
 *
 *            Also note, this kernel ONLY calculates the RHS of the above relationship, thus,
 *            this needs to be combined with the 'Reaction' kernel to fully describe the physics.
 *
 *            e.g.,   Reaction:                         Res = -vel_x
 *                    VariableVectorCoupledGradient:    Res = Var_Coeff * grad(P)_x
 *
 *  \note The vectors are allowed to just be unit vectors in a specific direction. This is particularly
 *        useful when enforcing the Divergence of velocity to be zero in a piecewise manner.
 *
 *  \author Austin Ladshaw
 *	\date 10/29/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "VariableVectorCoupledGradient.h"

registerMooseObject("catsApp", VariableVectorCoupledGradient);

InputParameters VariableVectorCoupledGradient::validParams()
{
    InputParameters params = VectorCoupledGradient::validParams();
    params.addCoupledVar("ux",0,"Variable coefficent in x-direction");
    params.addCoupledVar("uy",0,"Variable coefficent in y-direction");
    params.addCoupledVar("uz",0,"Variable coefficent in z-direction");
    return params;
}

VariableVectorCoupledGradient::VariableVectorCoupledGradient(const InputParameters & parameters) :
VectorCoupledGradient(parameters),
_ux(coupledValue("ux")),
_uy(coupledValue("uy")),
_uz(coupledValue("uz")),
_ux_var(coupled("ux")),
_uy_var(coupled("uy")),
_uz_var(coupled("uz"))
{

}

Real VariableVectorCoupledGradient::computeQpResidual()
{
    _vec(0)=_ux[_qp];
    _vec(1)=_uy[_qp];
    _vec(2)=_uz[_qp];

    return _test[_i][_qp]*(_vec*_coupled_grad[_qp]);
}

Real VariableVectorCoupledGradient::computeQpJacobian()
{
    return 0.0;
}

Real VariableVectorCoupledGradient::computeQpOffDiagJacobian(unsigned int jvar)
{
  _vec(0)=_ux[_qp];
  _vec(1)=_uy[_qp];
  _vec(2)=_uz[_qp];
  if (jvar == _coupled_var)
  {
      return _test[_i][_qp]*(_vec*_grad_phi[_j][_qp]);
  }

  if (jvar == _ux_var)
	{
  		return _test[_i][_qp]*(_phi[_j][_qp]*_coupled_grad[_qp](0));
	}

	if (jvar == _uy_var)
	{
		  return _test[_i][_qp]*(_phi[_j][_qp]*_coupled_grad[_qp](1));
	}

	if (jvar == _uz_var)
	{
		  return _test[_i][_qp]*(_phi[_j][_qp]*_coupled_grad[_qp](2));
	}
  return 0.0;
}
