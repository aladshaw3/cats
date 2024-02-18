/*!
 *  \file MicroscaleVariableDiffusionOuterBC.h
 *    \brief Microscale kernel mass-transfer flux/diffusion BC with variable diffusion and
 * mass-transfer. \details This file creates a custom MOOSE kernel for the inner diffusion BC at the
 * microscale of a fictious mesh. Generally this kernel is to be used in conjunction with other
 *              Microscale kernels for mass transfer, time derivatives on the microscale, or
 * reactions.
 *
 *  \author Austin Ladshaw
 *    \date 05/21/2020
 *    \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "MicroscaleVariableDiffusionOuterBC.h"

registerMooseObject("catsApp", MicroscaleVariableDiffusionOuterBC);

InputParameters
MicroscaleVariableDiffusionOuterBC::validParams()
{
  InputParameters params = MicroscaleDiffusionOuterBC::validParams();
  params.addRequiredCoupledVar("current_diff", "Variable for this diffusion coefficient");
  params.addRequiredCoupledVar("rate_variable", "Variable for mass transfer rate");
  params.addRequiredCoupledVar("lower_diff", "Variable for lower diffusion coefficient");

  return params;
}

MicroscaleVariableDiffusionOuterBC::MicroscaleVariableDiffusionOuterBC(
    const InputParameters & parameters)
  : MicroscaleDiffusionOuterBC(parameters),

    _current_diffusion(coupledValue("current_diff")),
    _current_diff_var(coupled("current_diff")),

    _mass_trans(coupledValue("rate_variable")),
    _mass_trans_var(coupled("rate_variable")),

    _lower_diffusion(coupledValue("lower_diff")),
    _lower_diff_var(coupled("lower_diff"))
{
}

Real
MicroscaleVariableDiffusionOuterBC::computeQpResidual()
{
  _current_diff = _current_diffusion[_qp];
  _upper_diff = _current_diffusion[_qp];
  _lower_diff = _lower_diffusion[_qp];
  _trans_const = _mass_trans[_qp];

  return MicroscaleDiffusionOuterBC::computeQpResidual();
}

Real
MicroscaleVariableDiffusionOuterBC::computeQpJacobian()
{
  _current_diff = _current_diffusion[_qp];
  _upper_diff = _current_diffusion[_qp];
  _lower_diff = _lower_diffusion[_qp];
  _trans_const = _mass_trans[_qp];

  return MicroscaleDiffusionOuterBC::computeQpJacobian();
}

Real
MicroscaleVariableDiffusionOuterBC::computeQpOffDiagJacobian(unsigned int jvar)
{
  _current_diff = _current_diffusion[_qp];
  _upper_diff = _current_diffusion[_qp];
  _lower_diff = _lower_diffusion[_qp];
  _trans_const = _mass_trans[_qp];

  if (jvar == _macro_var)
  {
    return MicroscaleDiffusionOuterBC::computeQpOffDiagJacobian(jvar);
  }
  if (jvar == _lower_var)
  {
    return MicroscaleDiffusionOuterBC::computeQpOffDiagJacobian(jvar);
  }

  if (jvar == _current_diff_var)
  {
    return _test[_i][_qp] * ((_rd_lm1 / _dr / _dr / 2.0) + (_rd_lp1 / _dr / _dr)) * _phi[_j][_qp] *
           (_u[_qp] - _lower_neighbor[_qp]);
  }
  if (jvar == _mass_trans_var)
  {
    return _test[_i][_qp] * ((_rd_lp1 * 2.0 / _dr)) * _phi[_j][_qp] *
           (_u[_qp] - _macro_variable[_qp]);
  }
  if (jvar == _lower_diff_var)
  {
    return _test[_i][_qp] * ((_rd_lm1 / _dr / _dr / 2.0)) * _phi[_j][_qp] *
           (_u[_qp] - _lower_neighbor[_qp]);
  }

  return 0.0;
}
