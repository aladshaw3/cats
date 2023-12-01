/*!
 *  \file LangmuirInhibition.h
 *    \brief Kernel for creating an inhibition function of a Langmuir form
 *    \details This file creates a standard MOOSE kernel for the coupling of a vector non-linear variables
 *            together via a Langmuir forcing function as follows...
 *            i.e., Res = 1 + sum(i, K_i * coupled_variable_i)
 *                  where K_i = A*T^B*exp(-E/R/T)
 *
 *            T is a coupled temperature and coupled_variable_i are coupled concentrations
 *
 *  \note This should be used in conjunction with a Reaction kernel inside of the
 *        input file to enfore that the inhibition variable value equals this function. The reason it is
 *        done in this fashion is so that it will be more modular in how the inhibition variable R could
 *        be represented if multiple instances of these objects are necessary to define its behavior
 *
 *        Reaction kernel ==>   Res(R) = R*test
 *        Langmuir Inhibition ==> Res(R) = -LangmuirInhibition*test
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

#include "LangmuirInhibition.h"

registerMooseObject("catsApp", LangmuirInhibition);

InputParameters LangmuirInhibition::validParams()
{
    InputParameters params = Kernel::validParams();
    params.addRequiredParam< std::vector<Real> >("pre_exponentials","Pre-exponential terms for the Langmuir coefficients");
    params.addParam< std::vector<Real> >("betas",{0},"Beta terms for the Langmuir coefficients");
    params.addParam< std::vector<Real> >("activation_energies",{0},"Activation energy terms for the Langmuir coefficients");
    params.addRequiredCoupledVar("coupled_list","List of names of the variables being coupled");
    params.addRequiredCoupledVar("temperature","Name of the coupled temperature variable (K)");
    return params;
}

LangmuirInhibition::LangmuirInhibition(const InputParameters & parameters)
: Kernel(parameters),
_pre_exp(getParam<std::vector<Real> >("pre_exponentials")),
_beta(getParam<std::vector<Real> >("betas")),
_act_energy(getParam<std::vector<Real> >("activation_energies")),
_temp(coupledValue("temperature")),
_temp_var(coupled("temperature"))
{
    unsigned int n = coupledComponents("coupled_list");
    _coupled_vars.resize(n);
    _coupled.resize(n);
    _langmuir_coef.resize(n);

    if (_pre_exp.size() != _langmuir_coef.size())
    {
        moose::internal::mooseErrorRaw("User is required to provide (at minimum) a list of pre-exponential factors equal to the number of coupled concentrations.");
    }

    for (int i=0; i<_pre_exp.size(); i++)
    {
        if (_pre_exp[i] < 0)
            moose::internal::mooseErrorRaw("Pre-exponentials can NOT be negative numbers!");
    }

    if (_beta.size() != _langmuir_coef.size())
    {
        _beta.resize(n);
        for (int i=0; i<_beta.size(); i++)
        {
            _beta[i] = 0.0;
        }
    }

    if (_act_energy.size() != _langmuir_coef.size())
    {
        _act_energy.resize(n);
        for (int i=0; i<_act_energy.size(); i++)
        {
            _act_energy[i] = 0.0;
        }
    }


    for (unsigned int i = 0; i<_coupled.size(); ++i)
    {
        _coupled_vars[i] = coupled("coupled_list",i);
        _coupled[i] = &coupledValue("coupled_list",i);
    }

}

void LangmuirInhibition::computeAllLangmuirCoeffs()
{
    for (unsigned int i = 0; i<_coupled.size(); ++i)
    {
        _langmuir_coef[i] = _pre_exp[i] * std::pow(_temp[_qp], _beta[i]) * std::exp(-_act_energy[i]/Rstd/_temp[_qp]);
    }
}

Real LangmuirInhibition::computeLangmuirTerm(int i)
{
    Real val = 0.0;
    if ((*_coupled[i])[_qp] > 0.0)
        val = _langmuir_coef[i] * (*_coupled[i])[_qp];
    return val;
}

Real LangmuirInhibition::computeLangmuirConcJacobi(int i)
{
    Real val = 0.0;
    if ((*_coupled[i])[_qp] > 0.0)
        val = _langmuir_coef[i] * _phi[_j][_qp];
    return val;
}

Real LangmuirInhibition::computeLangmuirTempJacobiTerm(int i)
{
    Real val = 0.0;
    if ((*_coupled[i])[_qp] > 0.0)
        val = _langmuir_coef[i] * (*_coupled[i])[_qp] * ((_act_energy[i]/Rstd/_temp[_qp]/_temp[_qp]) + (_beta[i]/_temp[_qp])) * _phi[_j][_qp];
    return val;
}

Real LangmuirInhibition::computeLangmuirTempJacobi()
{
    Real val = 0.0;
    for (unsigned int i = 0; i<_coupled.size(); ++i)
    {
        val += computeLangmuirTempJacobiTerm(i);
    }
    return val;
}

Real LangmuirInhibition::computeQpResidual()
{
    computeAllLangmuirCoeffs();
    Real sum = 1.0;
    for (unsigned int i = 0; i<_coupled.size(); ++i)
    {
        sum += computeLangmuirTerm(i);
    }
    return -_test[_i][_qp]*sum;
}

Real LangmuirInhibition::computeQpJacobian()
{
    return 0.0;
}

Real LangmuirInhibition::computeQpOffDiagJacobian(unsigned int jvar)
{
    computeAllLangmuirCoeffs();

    if (jvar == _temp_var)
    {
        return -_test[_i][_qp]*computeLangmuirTempJacobi();
    }

    for (unsigned int i = 0; i<_coupled.size(); ++i)
    {
        if (jvar == _coupled_vars[i])
            return -_test[_i][_qp]*computeLangmuirConcJacobi(i);
    }

    return 0.0;
}
