/*!
 *  \file FilmMassTransfer.h
 *  \brief Kernel for creating an exchange of mass (or energy) between non-linear variables with a
 * variable rate \details This file creates a kernel for the coupling a pair of non-linear variables
 * in the same domain as a form of mass/energy transfer. The variables are coupled linearly in a via
 * a constant transfer coefficient as shown below: Res = test * vf * Ga * km * (u - v) where u =
 * this variable and v = coupled variable Ga = area-to-volume ratio for the transfer (L^-1) km =
 * transfer rate coupled variable (L/T) vf = volume fraction (-) common fraction is (1 - eb) =
 * (solids volume / total volume)
 *
 *
 *  \author Austin Ladshaw
 *  \date 04/21/2020
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "FilmMassTransfer.h"

registerMooseObject("catsApp", FilmMassTransfer);

InputParameters
FilmMassTransfer::validParams()
{
  InputParameters params = ConstMassTransfer::validParams();
  params.addCoupledVar("av_ratio", 1.0, "Area to volume ratio at which mass transfer occurs");
  params.addRequiredCoupledVar("rate_variable", "Name of the coupled rate variable");
  params.addCoupledVar(
      "volume_frac",
      1.0,
      "Variable for volume fraction (used to convert av_ratio units if needed) (-)");
  return params;
}

FilmMassTransfer::FilmMassTransfer(const InputParameters & parameters)
  : ConstMassTransfer(parameters),
    _area_to_volume(coupledValue("av_ratio")),
    _area_to_volume_var(coupled("av_ratio")),
    _coupled_rate(coupledValue("rate_variable")),
    _coupled_rate_var(coupled("rate_variable")),
    _volfrac(coupledValue("volume_frac")),
    _volfrac_var(coupled("volume_frac"))
{
}

Real
FilmMassTransfer::computeQpResidual()
{
  _trans_rate = _volfrac[_qp] * _area_to_volume[_qp] * _coupled_rate[_qp];
  return ConstMassTransfer::computeQpResidual();
}

Real
FilmMassTransfer::computeQpJacobian()
{
  _trans_rate = _volfrac[_qp] * _area_to_volume[_qp] * _coupled_rate[_qp];
  return ConstMassTransfer::computeQpJacobian();
}

Real
FilmMassTransfer::computeQpOffDiagJacobian(unsigned int jvar)
{
  _trans_rate = _volfrac[_qp] * _area_to_volume[_qp] * _coupled_rate[_qp];
  if (jvar == _coupled_rate_var)
  {
    return -_test[_i][_qp] * _volfrac[_qp] * _area_to_volume[_qp] * _phi[_j][_qp] *
           (_u[_qp] - _coupled[_qp]);
  }
  else if (jvar == _area_to_volume_var)
  {
    return -_test[_i][_qp] * _volfrac[_qp] * _phi[_j][_qp] * _coupled_rate[_qp] *
           (_u[_qp] - _coupled[_qp]);
  }
  else if (jvar == _volfrac_var)
  {
    return -_test[_i][_qp] * _phi[_j][_qp] * _area_to_volume[_qp] * _coupled_rate[_qp] *
           (_u[_qp] - _coupled[_qp]);
  }
  else
  {
    return ConstMassTransfer::computeQpOffDiagJacobian(jvar);
  }
  return 0.0;
}
