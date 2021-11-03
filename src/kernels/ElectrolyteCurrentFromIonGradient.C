/*!
 *  \file ElectrolyteCurrentFromIonGradient.h
 *	\brief Standard kernel for coupling gradients of ion concentrations to the formation of current
 *	\details This file creates a standard MOOSE kernel for the coupling of a set of non-linear variable
 *            gradients for ion concentrations with variables for diffusion, porosity, and
 *            ion valence. In the case of anisotopic diffusion, the diffusion coefficent the user
 *            provides should correspond to the direction of the electrolyte current this kernel acts on.
 *
 *            Ref:  J.R. Clausen, V.E. Brunini, H.K. Moffat, M.J. Martinez, "Numerical Modeling
 *                  of an All Vanadium Redox Flow Battery", Sandia Report, SAND2014-0190,
 *                  Sandia National Laboratories, Albuquerque, NM, January 2014.
 *
 *  \note Users MUST provide the direction of the current vector being calculated (0=>x, 1=>y, 2=>z)
 *
 *  \author Austin Ladshaw
 *	\date 11/03/2021
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

#include "ElectrolyteCurrentFromIonGradient.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", ElectrolyteCurrentFromIonGradient);

InputParameters ElectrolyteCurrentFromIonGradient::validParams()
{
    InputParameters params = Kernel::validParams();
    params.addRequiredParam<unsigned int>("direction","Directional index for current that this kernel acts on (0 = x, 1 = y, 2 = z)");

    params.addCoupledVar("porosity",1,"Variable for volume fraction or porosity (default = 1)");

    params.addParam<Real>("faraday_const",96485.3, "Value of Faraday's constant (default = 96485.3 C/mol)");

    params.addRequiredCoupledVar("ion_conc","List of names of the ion concentration variables (mol/L^3)");
    params.addRequiredCoupledVar("diffusion","List of names of the diffusion variables (L^2/T)");
    params.addParam< std::vector<Real> >("ion_valence","List of valences for coupled ion concentrations");
    return params;
}

ElectrolyteCurrentFromIonGradient::ElectrolyteCurrentFromIonGradient(const InputParameters & parameters) :
Kernel(parameters),
_dir(getParam<unsigned int>("direction")),

_porosity(coupledValue("porosity")),
_porosity_var(coupled("porosity")),

_faraday(getParam<Real>("faraday_const")),

_valence(getParam<std::vector<Real> >("ion_valence"))

{
    if (_dir > 2 || _dir < 0)
    {
        moose::internal::mooseErrorRaw("Invalid current direction index!");
    }

    _norm_vec(0) = 0.0;
    _norm_vec(1) = 0.0;
    _norm_vec(2) = 0.0;
    _norm_vec(_dir) = 1.0;

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
        _ion_conc_grad[i] = &coupledGradient("ion_conc",i);
    }

    for (unsigned int i = 0; i<_diffusion.size(); ++i)
    {
        _diffusion_vars[i] = coupled("diffusion",i);
        _diffusion[i] = &coupledValue("diffusion",i);
    }
}

Real ElectrolyteCurrentFromIonGradient::sum_ion_gradient_terms()
{
    Real sum = 0.0;
    for (unsigned int i = 0; i<_ion_conc_grad.size(); ++i)
    {
        sum = sum + _valence[i]*(*_diffusion[i])[_qp]*( _norm_vec*(*_ion_conc_grad[i])[_qp] );
    }
    return sum;
}

Real ElectrolyteCurrentFromIonGradient::computeQpResidual()
{
    return -_test[_i][_qp]*_faraday*_porosity[_qp]*sum_ion_gradient_terms();
}

Real ElectrolyteCurrentFromIonGradient::computeQpJacobian()
{
    return 0.0;
}

Real ElectrolyteCurrentFromIonGradient::computeQpOffDiagJacobian(unsigned int jvar)
{
    if (jvar == _porosity_var)
    {
        return -_test[_i][_qp]*_faraday*_phi[_j][_qp]*sum_ion_gradient_terms();
    }

    Real offjac = 0.0;
    for (unsigned int i = 0; i<_ion_conc_grad.size(); ++i)
    {
        if (jvar == _ion_conc_vars[i])
          offjac = -_test[_i][_qp]*_faraday*_porosity[_qp] * _valence[i]*(*_diffusion[i])[_qp]*( _norm_vec*_grad_phi[_j][_qp] );
          break;
        if (jvar == _diffusion_vars[i])
          offjac = -_test[_i][_qp]*_faraday*_porosity[_qp] * _valence[i]*_phi[_j][_qp]*( _norm_vec*(*_ion_conc_grad[i])[_qp] );
          break;
    }

    return offjac;
}
