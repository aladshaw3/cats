/*!
 *  \file PairedLangmuirInhibition.h
 *    \brief Kernel for creating an inhibition function of a Langmuir form with paired species
 *    \details This file creates a standard MOOSE kernel for the coupling of a vector non-linear
 * variables together via a Langmuir forcing function with paired species as follows... i.e., Res =
 * 1 + sum(i, K_i * coupled_variable_i) + sum( (i,j) , K_ij * coupled_i * coupled_j) where K_i and
 * K_ij = A*T^B*exp(-E/R/T)
 *
 *            T is a coupled temperature and coupled_variable_i are coupled concentrations
 *
 *  \note This should be used in conjunction with a Reaction kernel inside of the
 *        input file to enfore that the inhibition variable value equals this function. The reason
 * it is done in this fashion is so that it will be more modular in how the inhibition variable R
 * could be represented if multiple instances of these objects are necessary to define its behavior
 *
 *        Reaction kernel ==>   Res(R) = R*test
 *        Langmuir Inhibition ==> Res(R) = -PairedLangmuirInhibition*test
 *
 *  \author Austin Ladshaw
 *    \date 09/22/2020
 *    \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "PairedLangmuirInhibition.h"

registerMooseObject("catsApp", PairedLangmuirInhibition);

InputParameters
PairedLangmuirInhibition::validParams()
{
  InputParameters params = LangmuirInhibition::validParams();
  params.addRequiredParam<std::vector<Real>>(
      "binary_pre_exp", " Binary Pre-exponential terms for the Langmuir coefficients.");
  params.addParam<std::vector<Real>>(
      "binary_betas", {0}, "Binary Beta terms for the Langmuir coefficients.");
  params.addParam<std::vector<Real>>(
      "binary_energies", {0}, "Binary Activation energy terms for the Langmuir coefficients.");
  params.addRequiredCoupledVar(
      "coupled_i_list", "List of names of the i-th variables being paired to the j-th variables");
  params.addRequiredCoupledVar(
      "coupled_j_list", "List of names of the j-th variables being paired to the i-th variables");
  return params;
}

PairedLangmuirInhibition::PairedLangmuirInhibition(const InputParameters & parameters)
  : LangmuirInhibition(parameters),
    _binary_pre_exp(getParam<std::vector<Real>>("binary_pre_exp")),
    _binary_beta(getParam<std::vector<Real>>("binary_betas")),
    _binary_act_energy(getParam<std::vector<Real>>("binary_energies"))
{
  unsigned int n = coupledComponents("coupled_i_list");
  unsigned int m = coupledComponents("coupled_j_list");

  if (n != m)
  {
    moose::internal::mooseErrorRaw(
        "User is required to provide list of paired variables of the same length (i.e., length of "
        "coupled_i_list must be same as coupled_j_list).");
  }

  _coupled_i_vars.resize(n);
  _coupled_i.resize(n);
  _coupled_j_vars.resize(n);
  _coupled_j.resize(n);
  _binary_coef.resize(n);

  if (_binary_pre_exp.size() != _binary_coef.size())
  {
    moose::internal::mooseErrorRaw(
        "User is required to provide (at minimum) a list of binary pre-exponential factors equal "
        "to the number of coupled concentrations in the coupled_i_list and/or coupled_j_list.");
  }

  for (int i = 0; i < _binary_pre_exp.size(); i++)
  {
    if (_binary_pre_exp[i] < 0)
      moose::internal::mooseErrorRaw("Pre-exponentials can NOT be negative numbers!");
  }

  if (_binary_beta.size() != _binary_coef.size())
  {
    _binary_beta.resize(n);
    for (int i = 0; i < _binary_beta.size(); i++)
    {
      _binary_beta[i] = 0.0;
    }
  }

  if (_binary_act_energy.size() != _binary_coef.size())
  {
    _binary_act_energy.resize(n);
    for (int i = 0; i < _binary_act_energy.size(); i++)
    {
      _binary_act_energy[i] = 0.0;
    }
  }

  for (unsigned int n = 0; n < _coupled_i.size(); ++n)
  {
    _coupled_i_vars[n] = coupled("coupled_i_list", n);
    _coupled_i[n] = &coupledValue("coupled_i_list", n);
  }

  for (unsigned int n = 0; n < _coupled_j.size(); ++n)
  {
    _coupled_j_vars[n] = coupled("coupled_j_list", n);
    _coupled_j[n] = &coupledValue("coupled_j_list", n);
  }
}

void
PairedLangmuirInhibition::computeAllLangmuirCoeffs()
{
  LangmuirInhibition::computeAllLangmuirCoeffs();
  for (int n = 0; n < _binary_coef.size(); n++)
  {
    _binary_coef[n] = _binary_pre_exp[n] * std::pow(_temp[_qp], _binary_beta[n]) *
                      std::exp(-_binary_act_energy[n] / Rstd / _temp[_qp]);
  }
}

Real
PairedLangmuirInhibition::computePairedLangmuirTerm(int n)
{
  Real val = 0.0;
  if ((*_coupled_i[n])[_qp] > 0.0 && (*_coupled_j[n])[_qp] > 0.0)
    val = _binary_coef[n] * (*_coupled_i[n])[_qp] * (*_coupled_j[n])[_qp];
  return val;
}

Real
PairedLangmuirInhibition::computePairedLangmuirConcJacobi(int jvar)
{
  Real val = 0.0;
  for (int n = 0; n < _binary_coef.size(); n++)
  {
    if (jvar == _coupled_i_vars[n])
    {
      if ((*_coupled_i[n])[_qp] > 0.0 && (*_coupled_j[n])[_qp] > 0.0)
        val += _binary_coef[n] * _phi[_j][_qp] * (*_coupled_j[n])[_qp];
    }
    if (jvar == _coupled_j_vars[n])
    {
      if ((*_coupled_i[n])[_qp] > 0.0 && (*_coupled_j[n])[_qp] > 0.0)
        val += _binary_coef[n] * (*_coupled_i[n])[_qp] * _phi[_j][_qp];
    }
  }
  return val;
}

Real
PairedLangmuirInhibition::computePairedLangmuirTempJacobiTerm(int n)
{
  Real val = 0.0;
  if ((*_coupled_i[n])[_qp] > 0.0 && (*_coupled_j[n])[_qp] > 0.0)
    val = _binary_coef[n] * (*_coupled_i[n])[_qp] * (*_coupled_j[n])[_qp] *
          ((_binary_act_energy[n] / Rstd / _temp[_qp] / _temp[_qp]) +
           (_binary_beta[n] / _temp[_qp])) *
          _phi[_j][_qp];
  return val;
}

Real
PairedLangmuirInhibition::computePairedLangmuirTempJacobi()
{
  Real val = 0.0;
  for (unsigned int n = 0; n < _coupled_i.size(); ++n)
  {
    val += computePairedLangmuirTempJacobiTerm(n);
  }
  return val;
}

Real
PairedLangmuirInhibition::computeQpResidual()
{
  computeAllLangmuirCoeffs();
  Real sum = 1.0;
  for (unsigned int i = 0; i < _coupled.size(); ++i)
  {
    sum += LangmuirInhibition::computeLangmuirTerm(i);
  }
  for (unsigned int n = 0; n < _coupled_i.size(); ++n)
  {
    sum += computePairedLangmuirTerm(n);
  }
  return -_test[_i][_qp] * sum;
}

Real
PairedLangmuirInhibition::computeQpJacobian()
{
  return 0.0;
}

Real
PairedLangmuirInhibition::computeQpOffDiagJacobian(unsigned int jvar)
{
  computeAllLangmuirCoeffs();

  if (jvar == _temp_var)
  {
    return -_test[_i][_qp] *
           (LangmuirInhibition::computeLangmuirTempJacobi() + computePairedLangmuirTempJacobi());
  }

  Real jac = LangmuirInhibition::computeQpOffDiagJacobian(jvar);
  jac += -_test[_i][_qp] * computePairedLangmuirConcJacobi(jvar);

  return jac;
}
