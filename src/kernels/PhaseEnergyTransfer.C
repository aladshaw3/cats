/*!
 *  \file PhaseEnergyTransfer.h
 *  \brief Kernel for creating an exchange of energy between two phases
 *  \details This file creates a kernel for the coupling a pair of energy variables in
 *            the same domain as a form of energy transfer. The variables are implicitly
 *            coupled through the temperatures of each phase and the heat transfer coefficient:
 *                  Res = test * h * A * fv * (T_this - T_other)
 *                          where T_this = temperature of this energy variable's phase (K)
 *                          and T_other = temperature of the other energy variable's phase (K)
 *                          h = heat transfer coefficient (W/m^2/K)
 *                          A = specific contact area per volume between the phases (m^-1)
 *                              = area of solids per volume of solids
 *                          fv = volume fraction of the phases (volume solids / total volume)
 *
 *
 *  \author Austin Ladshaw
 *  \date 05/04/2020
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "PhaseEnergyTransfer.h"

registerMooseObject("catsApp", PhaseEnergyTransfer);

InputParameters
PhaseEnergyTransfer::validParams()
{
  InputParameters params = Kernel::validParams();
  params.addRequiredCoupledVar("transfer_coef", "Variable for heat transfer coefficient (W/m^2/K)");
  params.addRequiredCoupledVar("other_phase_temp", "Variable for the other phase temperature (K)");
  params.addRequiredCoupledVar("this_phase_temp", "Variable for this phase temperature (K)");
  params.addRequiredCoupledVar("volume_frac",
                               "Variable for volume fraction (solid volume / total volume) (-)");
  params.addRequiredCoupledVar(
      "specific_area",
      "Specific area for transfer [surface area of solids / volume solids] (m^-1)");
  return params;
}

PhaseEnergyTransfer::PhaseEnergyTransfer(const InputParameters & parameters)
  : Kernel(parameters),
    _hs(coupledValue("transfer_coef")),
    _hs_var(coupled("transfer_coef")),
    _this_temp(coupledValue("this_phase_temp")),
    _this_temp_var(coupled("this_phase_temp")),
    _other_temp(coupledValue("other_phase_temp")),
    _other_temp_var(coupled("other_phase_temp")),
    _volfrac(coupledValue("volume_frac")),
    _volfrac_var(coupled("volume_frac")),
    _specarea(coupledValue("specific_area")),
    _specarea_var(coupled("specific_area"))
{
}

Real
PhaseEnergyTransfer::computeQpResidual()
{
  return _test[_i][_qp] * _hs[_qp] * _specarea[_qp] * _volfrac[_qp] *
         (_this_temp[_qp] - _other_temp[_qp]);
}

Real
PhaseEnergyTransfer::computeQpJacobian()
{
  return 0.0;
}

Real
PhaseEnergyTransfer::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _this_temp_var)
  {
    return _test[_i][_qp] * _hs[_qp] * _specarea[_qp] * _volfrac[_qp] * _phi[_j][_qp];
  }

  if (jvar == _other_temp_var)
  {
    return -_test[_i][_qp] * _hs[_qp] * _specarea[_qp] * _volfrac[_qp] * _phi[_j][_qp];
  }

  if (jvar == _hs_var)
  {
    return _test[_i][_qp] * _phi[_j][_qp] * _specarea[_qp] * _volfrac[_qp] *
           (_this_temp[_qp] - _other_temp[_qp]);
  }

  if (jvar == _volfrac_var)
  {
    return _test[_i][_qp] * _hs[_qp] * _specarea[_qp] * _phi[_j][_qp] *
           (_this_temp[_qp] - _other_temp[_qp]);
  }

  if (jvar == _specarea_var)
  {
    return _test[_i][_qp] * _hs[_qp] * _phi[_j][_qp] * _volfrac[_qp] *
           (_this_temp[_qp] - _other_temp[_qp]);
  }

  return 0.0;
}
