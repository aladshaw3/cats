/*!
 *  \file VarSiteDensityExtLangModel.h
 *	\brief Standard kernel for coupling a vector non-linear variables via an extended langmuir function with variable site density
 *	\details This file creates a standard MOOSE kernel for the coupling of a vector non-linear variables
 *			together via an extended langmuir forcing function while including a coupling for the site density term.
 *      Utilization of this kernel will allow users to specify a function or set of residuals to solve for
 *      the site density and couple that site density to this function that calculates the Langmuir capacity
 *      in terms of that site density. This is particularly useful to adding the effects of aging to the model.
 *
 *  \note This should be used in conjunction with a TimeDerivative or Reaction kernel inside of the
 *        input file to enfore that the variable sorbs material according to Langmuir
 *
 *        Reaction kernel ==>   Res(u) = u*test
 *        Extended Langmuir ==> Res(u) = -VarSiteDensLang*test
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

#include "VarSiteDensityExtLangModel.h"

registerMooseObject("catsApp", VarSiteDensityExtLangModel);

InputParameters VarSiteDensityExtLangModel::validParams()
{
    InputParameters params = ExtendedLangmuirModel::validParams();
    params.addRequiredCoupledVar("coupled_site_density","Name of the coupled site density variable (mol/L)");
    return params;
}

VarSiteDensityExtLangModel::VarSiteDensityExtLangModel(const InputParameters & parameters)
: ExtendedLangmuirModel(parameters),
_coupled_site_density(coupledValue("coupled_site_density")),
_coupled_var_site_density(coupled("coupled_site_density"))
{
	unsigned int n = coupledComponents("coupled_list");
	_coupled_vars.resize(n);
	_coupled.resize(n);
	_langmuir_coef.resize(n);

	for (unsigned int i = 0; i<_coupled.size(); ++i)
	{
		_coupled_vars[i] = coupled("coupled_list",i);
		_coupled[i] = &coupledValue("coupled_list",i);
		if (_coupled_vars[i] == _coupled_var_i)
			_lang_index = i;
	}
}

Real VarSiteDensityExtLangModel::computeExtLangmuirSiteJacobi()
{
  double sum = 0.0;
	for (unsigned int i = 0; i<_coupled.size(); ++i)
	{
      if ((*_coupled[i])[_qp] > 0.0)
          sum = sum + _langmuir_coef[i] * (*_coupled[i])[_qp];
	}
  return _phi[_j][_qp]*((_langmuir_coef[_lang_index]*_coupled_i[_qp])/(1.0+sum));
}

Real VarSiteDensityExtLangModel::computeQpResidual()
{
	_maxcap = _coupled_site_density[_qp];
	return ExtendedLangmuirModel::computeQpResidual();
}

Real VarSiteDensityExtLangModel::computeQpJacobian()
{
  _maxcap = _coupled_site_density[_qp];
	return ExtendedLangmuirModel::computeQpJacobian();
}

Real VarSiteDensityExtLangModel::computeQpOffDiagJacobian(unsigned int jvar)
{
	ExtendedLangmuirModel::computeAllLangmuirCoeffs();
  _maxcap = _coupled_site_density[_qp];

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
		return -_test[_i][_qp]*ExtendedLangmuirModel::computeExtLangmuirTempJacobi();
	}
  //Off-diagonal for site density
  if (jvar == _coupled_var_site_density)
  {
    return -_test[_i][_qp]*computeExtLangmuirSiteJacobi();
  }

	return 0.0;
}
