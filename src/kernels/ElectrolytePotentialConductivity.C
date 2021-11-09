/*!
 *  \file ElectrolytePotentialConductivity.h
 *	\brief Standard kernel for a Poisson's equation for electrolyte conductivity
 *	\details This file creates a standard MOOSE kernel for the coupling of this kernel's variable for
 *            electrolyte potential (_u and _u_grad) with variables for ion concentration, diffusion
 *            coefficients for ions, temperature, and ion valence. This kernel is ONLY valid
 *            for isotropic diffusion, which should cover most all cases.
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

#include "ElectrolytePotentialConductivity.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", ElectrolytePotentialConductivity);

InputParameters ElectrolytePotentialConductivity::validParams()
{
    InputParameters params = Kernel::validParams();

    params.addCoupledVar("porosity",1,"Variable for volume fraction or porosity (default = 1)");
    params.addCoupledVar("temperature",298,"Variable for temperature of the media (default = 298 K)");

    params.addParam<Real>("faraday_const",96485.3, "Value of Faraday's constant (default = 96485.3 C/mol)");
    params.addParam<Real>("gas_const",8.314462, "Value of the gas law constant (default = 8.314462 J/K/mol)");

    params.addRequiredCoupledVar("ion_conc","List of names of the ion concentration variables (mol/L^3)");
    params.addRequiredCoupledVar("diffusion","List of names of the diffusion variables (L^2/T)");
    params.addParam< std::vector<Real> >("ion_valence","List of valences for coupled ion concentrations");

    params.addParam<Real>("min_conductivity",1e-30, "Minimum value of conductivity to prevent zero diagonals in Jacobians");
    return params;
}

ElectrolytePotentialConductivity::ElectrolytePotentialConductivity(const InputParameters & parameters) :
Kernel(parameters),

_porosity(coupledValue("porosity")),
_porosity_var(coupled("porosity")),
_temp(coupledValue("temperature")),
_temp_var(coupled("temperature")),

_faraday(getParam<Real>("faraday_const")),
_gas_const(getParam<Real>("gas_const")),

_valence(getParam<std::vector<Real> >("ion_valence")),
_min_conductivity(getParam<Real>("min_conductivity"))
{
    unsigned int c = coupledComponents("ion_conc");
    _ion_conc_vars.resize(c);
    _ion_conc.resize(c);

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
    for (unsigned int i = 0; i<_ion_conc.size(); ++i)
    {
        _ion_conc_vars[i] = coupled("ion_conc",i);
        _ion_conc[i] = &coupledValue("ion_conc",i);
    }

    for (unsigned int i = 0; i<_diffusion.size(); ++i)
    {
        _diffusion_vars[i] = coupled("diffusion",i);
        _diffusion[i] = &coupledValue("diffusion",i);
    }

    if (_min_conductivity > 1e-20)
        _min_conductivity = 1e-20;
    if (_min_conductivity < 1e-50)
        _min_conductivity = 1e-50;
}

Real ElectrolytePotentialConductivity::sum_ion_terms()
{
    Real sum = 0.0;
    for (unsigned int i = 0; i<_ion_conc.size(); ++i)
    {
        sum = sum + _valence[i]*_valence[i]*(*_diffusion[i])[_qp]*(*_ion_conc[i])[_qp];
    }
    return sum + _min_conductivity;
}

Real ElectrolytePotentialConductivity::effective_ionic_conductivity()
{
    return (_faraday*_faraday/_gas_const/_temp[_qp])*_porosity[_qp]*sum_ion_terms();
}

Real ElectrolytePotentialConductivity::computeQpResidual()
{
    return _grad_test[_i][_qp]*effective_ionic_conductivity()*_grad_u[_qp];
}

Real ElectrolytePotentialConductivity::computeQpJacobian()
{
    return _grad_test[_i][_qp]*effective_ionic_conductivity()*_grad_phi[_j][_qp];
}

Real ElectrolytePotentialConductivity::computeQpOffDiagJacobian(unsigned int jvar)
{
    if (jvar == _porosity_var)
    {
        return _grad_test[_i][_qp]*(_faraday*_faraday/_gas_const/_temp[_qp])*_phi[_j][_qp]*sum_ion_terms()*_grad_u[_qp];
    }
    if (jvar == _temp_var)
    {
        return _grad_test[_i][_qp]*effective_ionic_conductivity()*_grad_u[_qp]*(-1.0/_temp[_qp])*_phi[_j][_qp];
    }

    Real offjac = 0.0;
    for (unsigned int i = 0; i<_ion_conc.size(); ++i)
    {
        if (jvar == _ion_conc_vars[i])
          offjac = _grad_test[_i][_qp]*( (_faraday*_faraday/_gas_const/_temp[_qp])*_porosity[_qp]*_valence[i]*_valence[i]*(*_diffusion[i])[_qp]*_phi[_j][_qp] )*_grad_u[_qp];
          break;
        if (jvar == _diffusion_vars[i])
          offjac = _grad_test[_i][_qp]*( (_faraday*_faraday/_gas_const/_temp[_qp])*_porosity[_qp]*_valence[i]*_valence[i]*_phi[_j][_qp]*(*_ion_conc[i])[_qp] )*_grad_u[_qp];
          break;
    }

    return offjac;
}
