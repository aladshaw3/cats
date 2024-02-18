/*!
 *  \file GPhaseThermalConductivity.h
 *    \brief Kernel for use with the corresponding DGPhaseThermalConductivity object
 *    \details This file creates a standard MOOSE kernel that is to be used in conjunction with the
 * DGPhaseThermalConductivity kernel for the discontinous Galerkin formulation of thermal
 * conductivity physics in MOOSE. In order to complete the DG formulation of the conductivity
 * physics, this kernel must be utilized with every variable that also uses the
 * DGPhaseThermalConductivity kernel.
 *
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic
 * equations: Theory and Implementation, SIAM, Houston, TX, 2008.
 *
 *  \author Austin Ladshaw
 *    \date 05/04/2020
 *    \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "GPhaseThermalConductivity.h"

registerMooseObject("catsApp", GPhaseThermalConductivity);

InputParameters
GPhaseThermalConductivity::validParams()
{
  InputParameters params = GThermalConductivity::validParams();
  params.addRequiredCoupledVar("volume_frac", "Variable for volume fraction (-)");
  return params;
}

GPhaseThermalConductivity::GPhaseThermalConductivity(const InputParameters & parameters)
  : GThermalConductivity(parameters),
    _volfrac(coupledValue("volume_frac")),
    _volfrac_var(coupled("volume_frac"))
{
}

Real
GPhaseThermalConductivity::computeQpResidual()
{
  _Diffusion(0, 0) = _Dx[_qp];
  _Diffusion(0, 1) = 0.0;
  _Diffusion(0, 2) = 0.0;

  _Diffusion(1, 0) = 0.0;
  _Diffusion(1, 1) = _Dy[_qp];
  _Diffusion(1, 2) = 0.0;

  _Diffusion(2, 0) = 0.0;
  _Diffusion(2, 1) = 0.0;
  _Diffusion(2, 2) = _Dz[_qp];

  return _Diffusion * _volfrac[_qp] * _grad_test[_i][_qp] * _temp_grad[_qp];
}

Real
GPhaseThermalConductivity::computeQpJacobian()
{
  return 0.0;
}

Real
GPhaseThermalConductivity::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _Dx_var)
  {
    return _phi[_j][_qp] * _volfrac[_qp] * _grad_test[_i][_qp](0) * _temp_grad[_qp](0);
  }
  if (jvar == _Dy_var)
  {
    return _phi[_j][_qp] * _volfrac[_qp] * _grad_test[_i][_qp](1) * _temp_grad[_qp](1);
  }
  if (jvar == _Dz_var)
  {
    return _phi[_j][_qp] * _volfrac[_qp] * _grad_test[_i][_qp](2) * _temp_grad[_qp](2);
  }
  if (jvar == _temp_var)
  {
    _Diffusion(0, 0) = _Dx[_qp];
    _Diffusion(0, 1) = 0.0;
    _Diffusion(0, 2) = 0.0;

    _Diffusion(1, 0) = 0.0;
    _Diffusion(1, 1) = _Dy[_qp];
    _Diffusion(1, 2) = 0.0;

    _Diffusion(2, 0) = 0.0;
    _Diffusion(2, 1) = 0.0;
    _Diffusion(2, 2) = _Dz[_qp];

    return _Diffusion * _volfrac[_qp] * _grad_test[_i][_qp] * _grad_phi[_j][_qp];
  }
  if (jvar == _volfrac_var)
  {
    _Diffusion(0, 0) = _Dx[_qp];
    _Diffusion(0, 1) = 0.0;
    _Diffusion(0, 2) = 0.0;

    _Diffusion(1, 0) = 0.0;
    _Diffusion(1, 1) = _Dy[_qp];
    _Diffusion(1, 2) = 0.0;

    _Diffusion(2, 0) = 0.0;
    _Diffusion(2, 1) = 0.0;
    _Diffusion(2, 2) = _Dz[_qp];

    return _Diffusion * _phi[_j][_qp] * _grad_test[_i][_qp] * _temp_grad[_qp];
  }
  return 0.0;
}
