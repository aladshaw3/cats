/*!
 *  \file InitialLangmuirInhibition.h
 *    \brief Initial Condition kernel for the Langmuir Inhibition variables
 *    \details This file creates an initial condition for a Langmuir Inhibition variable.
 *            i.e., R_IC = 1 + sum(i, K_i * coupled_variable_i)
 *                  where K_i = A*T^B*exp(-E/R/T)
 *
 *            T is a coupled temperature and coupled_variable_i are coupled concentrations
 *
 *  \author Austin Ladshaw
 *  \date 12/30/2020
 *  \copyright This kernel was designed and built at the Georgia Institute
 *             of Technology by Austin Ladshaw for PhD research in the area
 *             of adsorption and surface science and was developed for use
 *               by Idaho National Laboratory and Oak Ridge National Laboratory
 *               engineers and scientists. Portions Copyright (c) 2015, all
 *             rights reserved.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
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

#include "InitialLangmuirInhibition.h"


registerMooseObject("catsApp", InitialLangmuirInhibition);

InputParameters InitialLangmuirInhibition::validParams()
{
    InputParameters params = InitialCondition::validParams();
    params.addRequiredParam< std::vector<Real> >("pre_exponentials","Pre-exponential terms for the Langmuir coefficients");
    params.addParam< std::vector<Real> >("betas","Beta terms for the Langmuir coefficients");
    params.addParam< std::vector<Real> >("activation_energies","Activation energy terms for the Langmuir coefficients");
    params.addRequiredCoupledVar("coupled_list","List of names of the variables being coupled");
    params.addRequiredCoupledVar("temperature","Name of the coupled temperature variable (K)");
    return params;
}

InitialLangmuirInhibition::InitialLangmuirInhibition(const InputParameters & parameters)
: InitialCondition(parameters),
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

void InitialLangmuirInhibition::computeAllLangmuirCoeffs()
{
    for (unsigned int i = 0; i<_coupled.size(); ++i)
    {
        _langmuir_coef[i] = _pre_exp[i] * std::pow(_temp[_qp], _beta[i]) * std::exp(-_act_energy[i]/Rstd/_temp[_qp]);
    }
}

Real InitialLangmuirInhibition::computeLangmuirTerm(int i)
{
    Real val = 0.0;
    if ((*_coupled[i])[_qp] > 0.0)
        val = _langmuir_coef[i] * (*_coupled[i])[_qp];
    return val;
}

Real InitialLangmuirInhibition::value(const Point & /*p*/)
{
    computeAllLangmuirCoeffs();
    Real sum = 1.0;
    for (unsigned int i = 0; i<_coupled.size(); ++i)
    {
        sum += computeLangmuirTerm(i);
    }
    return sum;
}
