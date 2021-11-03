/*!
 *  \file VariableDiffusionOutflowFluxBC.h
 *	\brief Boundary Condition kernel for diffusion flux leaving a domain
 *  \details A FluxBC which is consistent with the boundary terms arising from
 *            a Diffusion process. The flux vector in this case is simply
 *            Diffusion*grad(u) and the residual contribution is:
 *
 *                Res = -eps*Diffusion*grad(u)*normals*test
 *
 *            where eps is an optional 'porosity' term and 'Diffusion' is
 *            a RealTensor to allow for anisotopic behaviors.
 *
 *            In contrast to e.g. VectorNeumannBC, the user does not provide a
 *            specified value of the flux when using this class, instead the
 *            residual contribution corresponding to the current value of grad(u)
 *            is computed and accumulated into the residual vector.
 *
 *
 *  \author Austin Ladshaw
 *	\date 11/03/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
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

#include "VariableDiffusionOutflowFluxBC.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", VariableDiffusionOutflowFluxBC);

InputParameters VariableDiffusionOutflowFluxBC::validParams()
{
  InputParameters params = FluxBC::validParams();
  params.addRequiredCoupledVar("Dx","Variable for diffusion in x-direction");
  params.addRequiredCoupledVar("Dy","Variable for diffusion in y-direction");
  params.addRequiredCoupledVar("Dz","Variable for diffusion in z-direction");
  params.addCoupledVar("porosity",1,"Variable for the porosity of the domain/subdomain");
  return params;
}

VariableDiffusionOutflowFluxBC::VariableDiffusionOutflowFluxBC(const InputParameters & parameters) :
FluxBC(parameters),
_Dx(coupledValue("Dx")),
_Dy(coupledValue("Dy")),
_Dz(coupledValue("Dz")),
_Dx_var(coupled("Dx")),
_Dy_var(coupled("Dy")),
_Dz_var(coupled("Dz")),
_porosity(coupledValue("porosity")),
_porosity_var(coupled("porosity"))
{
  _Diffusion(0,0) = 0.0;
  _Diffusion(0,1) = 0.0;
  _Diffusion(0,2) = 0.0;

  _Diffusion(1,0) = 0.0;
  _Diffusion(1,1) = 0.0;
  _Diffusion(1,2) = 0.0;

  _Diffusion(2,0) = 0.0;
  _Diffusion(2,1) = 0.0;
  _Diffusion(2,2) = 0.0;
}

Real VariableDiffusionOutflowFluxBC::computeQpOffDiagJacobian(unsigned int jvar)
{
  //Res = -_porosity[_qp]*_Diffusion*_grad_u[_qp] * _normals[_qp] * _test[_i][_qp];
  _Diffusion(0,0) = _Dx[_qp];
  _Diffusion(1,1) = _Dy[_qp];
  _Diffusion(2,2) = _Dz[_qp];

  if (jvar == _porosity_var)
  {
    return -_phi[_j][_qp]*_Diffusion*_grad_u[_qp] * _normals[_qp] * _test[_i][_qp];
  }
  if (jvar == _Dx_var)
  {
    return -_porosity[_qp]*_phi[_j][_qp]*_grad_u[_qp](0) * _normals[_qp](0) * _test[_i][_qp];
  }
  if (jvar == _Dy_var)
  {
    return -_porosity[_qp]*_phi[_j][_qp]*_grad_u[_qp](1) * _normals[_qp](1) * _test[_i][_qp];
  }
  if (jvar == _Dz_var)
  {
    return -_porosity[_qp]*_phi[_j][_qp]*_grad_u[_qp](2) * _normals[_qp](2) * _test[_i][_qp];
  }
  return 0.0;
}

RealGradient VariableDiffusionOutflowFluxBC::computeQpFluxResidual()
{
  _Diffusion(0,0) = _Dx[_qp];
  _Diffusion(1,1) = _Dy[_qp];
  _Diffusion(2,2) = _Dz[_qp];

  return _porosity[_qp]*_Diffusion*_grad_u[_qp];
}

RealGradient VariableDiffusionOutflowFluxBC::computeQpFluxJacobian()
{
  _Diffusion(0,0) = _Dx[_qp];
  _Diffusion(1,1) = _Dy[_qp];
  _Diffusion(2,2) = _Dz[_qp];

  return _porosity[_qp]*_Diffusion*_grad_phi[_j][_qp];
}
