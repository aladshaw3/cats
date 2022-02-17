/*!
 *  \file DivergenceFreeCondition.h
 *	\brief Standard kernel for creating a Divergence Free Condition in CATS
 *	\details This file creates a standard MOOSE kernel for the divergence free condition. The
 *            divergence free condition can be generically represented mathematically as follows...
 *
 *            Div * (c * v) == c*d/dx(v_x) + v_x*d/dx(c) +
 *                              c*d/dy(v_y) + v_y*d/dy(c) +
 *                              c*d/dz(v_z) + v_z*d/dz(c)   ==  0
 *
 *            where c is a scalar non-linear variable and v is a vector non-linear variable.
 *
 *            This implementation performs a 'piecewise' formulation of the divergence free
 *            condition. As such, this kernel is only valid in a Cartesian coordinate system.
 *
 *  \note If the scalar non-linear variable (c) does not vary spatially, then this formulation
 *          becomes equivalent to the divergence free condition seen in Incompressible Navier-
 *          Stokes formulations.
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

#include "DivergenceFreeCondition.h"

registerMooseObject("catsApp", DivergenceFreeCondition);

InputParameters DivergenceFreeCondition::validParams()
{
    InputParameters params = Kernel::validParams();
    params.addCoupledVar("ux",0,"Vector Variable coefficent in x-direction");
    params.addCoupledVar("uy",0,"Vector Variable coefficent in y-direction");
    params.addCoupledVar("uz",0,"Vector Variable coefficent in z-direction");
    params.addCoupledVar("coupled_scalar",1,"Scalar variable that we couple the divergence to (default = 1)");
    return params;
}

DivergenceFreeCondition::DivergenceFreeCondition(const InputParameters & parameters) :
Kernel(parameters),
_ux(coupledValue("ux")),
_ux_grad(coupledGradient("ux")),

_uy(coupledValue("uy")),
_uy_grad(coupledGradient("uy")),

_uz(coupledValue("uz")),
_uz_grad(coupledGradient("uz")),

_ux_var(coupled("ux")),
_uy_var(coupled("uy")),
_uz_var(coupled("uz")),

_coupled(coupledValue("coupled_scalar")),
_coupled_grad(coupledGradient("coupled_scalar")),
_coupled_var(coupled("coupled_scalar"))
{

}

Real DivergenceFreeCondition::computeQpResidual()
{
    return _test[_i][_qp]*(_coupled[_qp]*_ux_grad[_qp](0) + _ux[_qp]*_coupled_grad[_qp](0)
                          + _coupled[_qp]*_uy_grad[_qp](1) + _uy[_qp]*_coupled_grad[_qp](1)
                          + _coupled[_qp]*_uz_grad[_qp](2) + _uz[_qp]*_coupled_grad[_qp](2));
}

Real DivergenceFreeCondition::computeQpJacobian()
{
    return 0.0;
}

Real DivergenceFreeCondition::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _coupled_var)
  {
      return _test[_i][_qp]*(_phi[_j][_qp]*_ux_grad[_qp](0) + _ux[_qp]*_grad_phi[_j][_qp](0)
                            + _phi[_j][_qp]*_uy_grad[_qp](1) + _uy[_qp]*_grad_phi[_j][_qp](1)
                            + _phi[_j][_qp]*_uz_grad[_qp](2) + _uz[_qp]*_grad_phi[_j][_qp](2));
  }

  if (jvar == _ux_var)
	{
  		return _test[_i][_qp]*(_coupled[_qp]*_grad_phi[_j][_qp](0) + _phi[_j][_qp]*_coupled_grad[_qp](0));
	}

	if (jvar == _uy_var)
	{
		  return _test[_i][_qp]*(_coupled[_qp]*_grad_phi[_j][_qp](1) + _phi[_j][_qp]*_coupled_grad[_qp](1));
	}

	if (jvar == _uz_var)
	{
		  return _test[_i][_qp]*(_coupled[_qp]*_grad_phi[_j][_qp](2) + _phi[_j][_qp]*_coupled_grad[_qp](2));
	}

  return 0.0;
}
