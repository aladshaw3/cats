/*!
 *  \file ExtendedLangmuirModel.h
 *	\brief Standard kernel for coupling a vector non-linear variables via an extended langmuir function
 *	\details This file creates a standard MOOSE kernel for the coupling of a vector non-linear variables
 *			together via an extended langmuir forcing function,
 *			i.e., variable = b_i * K_i * coupled_variable_i / 1 + sum(j, K_j * coupled_variable_j).
 *			In this kernel, the langmuir coefficients {K_i} are calculated as a function of temperature
 *			using the van't Hoff expression: ln(K_i) = -dH_i/(R*T) + dS_i/R
 *
 *  \note This should be used in conjunction with a TimeDerivative or Reaction kernel inside of the
 *        input file to enfore that the variable sorbs material according to Langmuir
 *
 *        Reaction kernel ==>   Res(u) = u*test
 *        Extended Langmuir ==> Res(u) = -ExtLangFunc*test
 *
 *  \author Austin Ladshaw
 *	\date 03/10/2020
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
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

#include "ExtendedLangmuirModel.h"

registerMooseObject("catsApp", ExtendedLangmuirModel);

/*
template<>
InputParameters validParams<ExtendedLangmuirModel>()
{
	InputParameters params = validParams<ExtendedLangmuirFunction>();
	params.addParam< std::vector<Real> >("enthalpies","Enthalpies for the Langmuir Coefficients (J/mol)");
	params.addParam< std::vector<Real> >("entropies","Entropies for the Langmuir Coefficients (J/K/mol)");
	params.addRequiredCoupledVar("coupled_temp","Name of the coupled temperature variable");
	return params;
}
 */

InputParameters ExtendedLangmuirModel::validParams()
{
    InputParameters params = ExtendedLangmuirFunction::validParams();
    params.addParam< std::vector<Real> >("enthalpies","Enthalpies for the Langmuir Coefficients (J/mol)");
    params.addParam< std::vector<Real> >("entropies","Entropies for the Langmuir Coefficients (J/K/mol)");
    params.addRequiredCoupledVar("coupled_temp","Name of the coupled temperature variable");
    return params;
}

ExtendedLangmuirModel::ExtendedLangmuirModel(const InputParameters & parameters)
: ExtendedLangmuirFunction(parameters),
_enthalpies(getParam<std::vector<Real> >("enthalpies")),
_entropies(getParam<std::vector<Real> >("entropies")),
_coupled_temp(coupledValue("coupled_temp")),
_coupled_var_temp(coupled("coupled_temp"))
{
	unsigned int n = coupledComponents("coupled_list");
	_coupled_vars.resize(n);
	_coupled.resize(n);
	_langmuir_coef.resize(n);

  if (_coupled.size() != _enthalpies.size())
  {
    moose::internal::mooseErrorRaw("User is required to provide list of variables of the same length as list of enthalpy coefficients.");
  }

  if (_coupled.size() != _entropies.size())
  {
    moose::internal::mooseErrorRaw("User is required to provide list of variables of the same length as list of entropy coefficients.");
  }

	for (unsigned int i = 0; i<_coupled.size(); ++i)
	{
		_coupled_vars[i] = coupled("coupled_list",i);
		_coupled[i] = &coupledValue("coupled_list",i);
		if (_coupled_vars[i] == _coupled_var_i)
			_lang_index = i;
	}
}

void ExtendedLangmuirModel::computeAllLangmuirCoeffs()
{
	for (unsigned int i = 0; i<_coupled.size(); ++i)
	{
		_langmuir_coef[i] = std::exp( lnKo(_enthalpies[i], _entropies[i], _coupled_temp[_qp]) );
	}
}

Real ExtendedLangmuirModel::computeExtLangmuirTempJacobi()
{
	double kc_sum = 0.0, kch_sum = 0.0;
	for (unsigned int j = 0; j<_coupled.size(); ++j)
	{
        if ((*_coupled[j])[_qp] > 0.0)
        {
            kc_sum = kc_sum + _langmuir_coef[j] * (*_coupled[j])[_qp];
            kch_sum = kch_sum + _langmuir_coef[j] * (*_coupled[j])[_qp] * _enthalpies[j];
        }
	}
	double numerator = _enthalpies[_lang_index] + (_enthalpies[_lang_index]*kc_sum) - kch_sum;
	double denom = (1.0+kc_sum)*(1.0+kc_sum);
    return _maxcap*_langmuir_coef[_lang_index]*_coupled_i[_qp]*_phi[_j][_qp]*(1.0/Rstd/_coupled_temp[_qp]/_coupled_temp[_qp])*numerator/denom;
}

Real ExtendedLangmuirModel::computeQpResidual()
{
	computeAllLangmuirCoeffs();
	return ExtendedLangmuirFunction::computeQpResidual();
}

Real ExtendedLangmuirModel::computeQpJacobian()
{
	return ExtendedLangmuirFunction::computeQpJacobian();
}

Real ExtendedLangmuirModel::computeQpOffDiagJacobian(unsigned int jvar)
{
	computeAllLangmuirCoeffs();

	//Off-diagonals for non-main concentrations
	for (unsigned int i = 0; i<_coupled.size(); ++i)
	{
		if (jvar == _coupled_vars[i] && jvar != _coupled_var_i)
		{
			return -_test[_i][_qp]*ExtendedLangmuirFunction::computeExtLangmuirOffJacobi(i);
		}
	}
	//Off-diagonal for main concentration
	if (jvar == _coupled_var_i)
	{
		return -_test[_i][_qp]*ExtendedLangmuirFunction::computeExtLangmuirConcJacobi();
	}
	//Off-diagonal for temperature
	if (jvar == _coupled_var_temp)
	{
		return -_test[_i][_qp]*computeExtLangmuirTempJacobi();
	}

	return 0.0;
}
