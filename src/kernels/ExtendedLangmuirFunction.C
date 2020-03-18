/*!
 *  \file ExtendedLangmuirFunction.h
 *	\brief Standard kernel for coupling a vector non-linear variables via an extended langmuir function
 *	\details This file creates a standard MOOSE kernel for the coupling of a vector non-linear variables
 *			together via an extended langmuir forcing function,
 *			i.e., variable = b_i * K_i * coupled_variable_i / 1 + sum(j, K_j * coupled_variable_j).
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

#include "ExtendedLangmuirFunction.h"


registerMooseObject("catsApp", ExtendedLangmuirFunction);

template<>
InputParameters validParams<ExtendedLangmuirFunction>()
{
	InputParameters params = validParams<Kernel>();
	params.addParam<Real>("site_density",0.0,"Maximum Capacity for Langmuir Function of this sorption site (mol/L)");
	params.addParam< std::vector<Real> >("langmuir_coeff","Coefficient for the langmuir function (L/mol)");
	params.addRequiredCoupledVar("coupled_list","List of names of the variables being coupled");
	params.addRequiredCoupledVar("main_coupled","Name of the primary variable being coupled");
	return params;
}

ExtendedLangmuirFunction::ExtendedLangmuirFunction(const InputParameters & parameters)
: Kernel(parameters),
_maxcap(getParam<Real>("site_density")),
_langmuir_coef(getParam<std::vector<Real> >("langmuir_coeff")),
_coupled_i(coupledValue("main_coupled")),
_coupled_var_i(coupled("main_coupled"))
{
	unsigned int n = coupledComponents("coupled_list");
	_coupled_vars.resize(n);
	_coupled.resize(n);

	for (unsigned int i = 0; i<_coupled.size(); ++i)
	{
		_coupled_vars[i] = coupled("coupled_list",i);
		_coupled[i] = &coupledValue("coupled_list",i);
		if (_coupled_vars[i] == _coupled_var_i)
			_lang_index = i;
	}

}

Real ExtendedLangmuirFunction::computeExtLangmuirEquilibrium()
{
	double sum = 0.0;
	for (unsigned int i = 0; i<_coupled.size(); ++i)
	{
        if ((*_coupled[i])[_qp] > 0.0)
            sum = sum + _langmuir_coef[i] * (*_coupled[i])[_qp];
	}
    return _maxcap*((_langmuir_coef[_lang_index]*_coupled_i[_qp])/(1.0+sum));
}

Real ExtendedLangmuirFunction::computeExtLangmuirConcJacobi()
{
	double sum = 0.0;
	for (unsigned int j = 0; j<_coupled.size(); ++j)
	{
        if ((*_coupled[j])[_qp] > 0.0)
            sum = sum + _langmuir_coef[j] * (*_coupled[j])[_qp];
	}
    double numerator = 0.0;
    numerator = _langmuir_coef[_lang_index]*_phi[_j][_qp] * (1.0 + sum - _langmuir_coef[_lang_index]*_coupled_i[_qp]);
	double denom = (1.0+sum)*(1.0+sum);
	return _maxcap*numerator/denom;
}

Real ExtendedLangmuirFunction::computeExtLangmuirOffJacobi(int i)
{
	double sum = 0.0;
	for (unsigned int j = 0; j<_coupled.size(); ++j)
	{
        if ((*_coupled[j])[_qp] > 0.0)
            sum = sum + _langmuir_coef[j] * (*_coupled[j])[_qp];
	}
    double numerator = 0.0;
    numerator = -_langmuir_coef[_lang_index]*_coupled_i[_qp]*_phi[_j][_qp]*_langmuir_coef[i];
	double denom = (1.0+sum)*(1.0+sum);
	return _maxcap*numerator/denom;

}

Real ExtendedLangmuirFunction::computeQpResidual()
{
	return -_test[_i][_qp]*computeExtLangmuirEquilibrium();
}

Real ExtendedLangmuirFunction::computeQpJacobian()
{
	return 0.0;
}

Real ExtendedLangmuirFunction::computeQpOffDiagJacobian(unsigned int jvar)
{
	for (unsigned int i = 0; i<_coupled.size(); ++i)
	{
		if (jvar == _coupled_vars[i] && jvar != _coupled_var_i)
		{
			return -_test[_i][_qp]*computeExtLangmuirOffJacobi(i);
		}
	}

	if (jvar == _coupled_var_i)
	{
		return -_test[_i][_qp]*computeExtLangmuirConcJacobi();
	}

	return 0.0;
}
