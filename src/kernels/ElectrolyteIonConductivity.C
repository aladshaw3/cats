/*!
 *  \file ElectrolyteIonConductivity.h
 *	\brief Standard kernel for coupling gradients of ion concentrations to the electrolyte potential
 *	\details This file creates a standard MOOSE kernel for the coupling of a set of non-linear variable
 *            gradients for ion concentrations with variables for diffusion, porosity, and
 *            ion valence. This kernel should act on potential in the electrolyte to resolve the
 *            conservation of charge in the electrolyte phase based on diffusion of all ions in
 *            solution. This kernel is ONLY valid for isotropic diffusion, which should cover most all cases.
 *
 *
 *            Ref:  J.R. Clausen, V.E. Brunini, H.K. Moffat, M.J. Martinez, "Numerical Modeling
 *                  of an All Vanadium Redox Flow Battery", Sandia Report, SAND2014-0190,
 *                  Sandia National Laboratories, Albuquerque, NM, January 2014.
 *
 *  \author Austin Ladshaw
 *	\date 11/08/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "ElectrolyteIonConductivity.h"

registerMooseObject("catsApp", ElectrolyteIonConductivity);

InputParameters ElectrolyteIonConductivity::validParams()
{
    InputParameters params = Kernel::validParams();
    params.addCoupledVar("porosity",1,"Variable for volume fraction or porosity (default = 1)");

    params.addParam<Real>("faraday_const",96485.3, "Value of Faraday's constant (default = 96485.3 C/mol)");

    params.addRequiredCoupledVar("ion_conc","List of names of the ion concentration variables (mol/L^3)");
    params.addRequiredCoupledVar("diffusion","List of names of the diffusion variables (L^2/T)");
    params.addParam< std::vector<Real> >("ion_valence","List of valences for coupled ion concentrations");

    params.addParam<bool>("tight_coupling",true, "True = use tight coupling of gradients");
    return params;
}

ElectrolyteIonConductivity::ElectrolyteIonConductivity(const InputParameters & parameters) :
Kernel(parameters),
_porosity(coupledValue("porosity")),
_porosity_var(coupled("porosity")),

_faraday(getParam<Real>("faraday_const")),

_valence(getParam<std::vector<Real> >("ion_valence")),
_tight(getParam<bool>("tight_coupling"))
{
    unsigned int c = coupledComponents("ion_conc");
    _ion_conc_vars.resize(c);
    _ion_conc_grad.resize(c);

    unsigned int d = coupledComponents("diffusion");
    _diffusion_vars.resize(d);
    _diffusion.resize(d);

    //Check lists to ensure they are of same size
    if (c != d)
    {
        moose::internal::mooseErrorRaw("User is required to provide list of ion concentration variables of the same length as list of diffusion coefficients.");
    }
    if (_ion_conc_vars.size() != _valence.size())
    {
        moose::internal::mooseErrorRaw("User is required to provide list of ion concentration variables of the same length as list of ion valences.");
    }

    if (_diffusion_vars.size() != _valence.size())
    {
        moose::internal::mooseErrorRaw("User is required to provide list of diffusion variables of the same length as list of ion valences.");
    }

    //Grab the variables
    for (unsigned int i = 0; i<_ion_conc_grad.size(); ++i)
    {
        _ion_conc_vars[i] = coupled("ion_conc",i);
        if (_tight==false)
            _ion_conc_grad[i] = &coupledGradientOld("ion_conc",i);
        else
            _ion_conc_grad[i] = &coupledGradient("ion_conc",i);
    }

    for (unsigned int i = 0; i<_diffusion.size(); ++i)
    {
        _diffusion_vars[i] = coupled("diffusion",i);
        _diffusion[i] = &coupledValue("diffusion",i);
    }
}

Real ElectrolyteIonConductivity::sum_ion_gradient_terms()
{
    Real sum = 0.0;
    for (unsigned int i = 0; i<_ion_conc_grad.size(); ++i)
    {
        sum = sum + _valence[i]*(*_diffusion[i])[_qp]*( _grad_test[_i][_qp]*(*_ion_conc_grad[i])[_qp] );
    }
    return sum;
}

Real ElectrolyteIonConductivity::computeQpResidual()
{
    return _faraday*_porosity[_qp]*sum_ion_gradient_terms();
}

Real ElectrolyteIonConductivity::computeQpJacobian()
{
    return 0.0;
}

Real ElectrolyteIonConductivity::computeQpOffDiagJacobian(unsigned int jvar)
{
    if (jvar == _porosity_var)
    {
        return _faraday*_phi[_j][_qp]*sum_ion_gradient_terms();
    }

    Real offjac = 0.0;
    for (unsigned int i = 0; i<_ion_conc_grad.size(); ++i)
    {
        if (jvar == _ion_conc_vars[i] && _tight == true)
          offjac = _faraday*_porosity[_qp] * _valence[i]*(*_diffusion[i])[_qp]*( _grad_test[_i][_qp]*_grad_phi[_j][_qp] );
          break;
        if (jvar == _diffusion_vars[i])
          offjac = _faraday*_porosity[_qp] * _valence[i]*_phi[_j][_qp]*( _grad_test[_i][_qp]*(*_ion_conc_grad[i])[_qp] );
          break;
    }

    return offjac;
}
