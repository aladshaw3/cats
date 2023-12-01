/*!
 *  \file ElectrolyteCurrentFromPotentialGradient.h
 *	\brief Standard kernel for coupling a gradient of potential to the formation of current
 *	\details This file creates a standard MOOSE kernel for the coupling of a non-linear variable
 *            gradient for electrolyte potential with variables for ion concentration, diffusion
 *            coefficients for ions, temperature, and ion valence. In the case of anisotopic
 *            diffusion, the diffusion coefficent the user provides should correspond to the
 *            direction of the electrolyte current this kernel acts on.
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

#include "ElectrolyteCurrentFromPotentialGradient.h"

registerMooseObject("catsApp", ElectrolyteCurrentFromPotentialGradient);

InputParameters ElectrolyteCurrentFromPotentialGradient::validParams()
{
    InputParameters params = Kernel::validParams();
    params.addRequiredParam<unsigned int>("direction","Directional index for current that this kernel acts on (0 = x, 1 = y, 2 = z)");

    params.addRequiredCoupledVar("electric_potential","Variable for electric potential (V or J/C)");
    params.addCoupledVar("porosity",1,"Variable for volume fraction or porosity (default = 1)");
    params.addCoupledVar("temperature",298,"Variable for temperature of the media (default = 298 K)");

    params.addParam<Real>("faraday_const",96485.3, "Value of Faraday's constant (default = 96485.3 C/mol)");
    params.addParam<Real>("gas_const",8.314462, "Value of the gas law constant (default = 8.314462 J/K/mol)");

    params.addRequiredCoupledVar("ion_conc","List of names of the ion concentration variables (mol/L^3)");
    params.addRequiredCoupledVar("diffusion","List of names of the diffusion variables (L^2/T)");
    params.addRequiredParam< std::vector<Real> >("ion_valence","List of valences for coupled ion concentrations");

    params.addParam<Real>("min_conductivity",0, "Minimum/background value of conductivity of the media");
    return params;
}

ElectrolyteCurrentFromPotentialGradient::ElectrolyteCurrentFromPotentialGradient(const InputParameters & parameters) :
Kernel(parameters),
_dir(getParam<unsigned int>("direction")),

_e_potential_grad(coupledGradient("electric_potential")),
_e_potential_var(coupled("electric_potential")),
_porosity(coupledValue("porosity")),
_porosity_var(coupled("porosity")),
_temp(coupledValue("temperature")),
_temp_var(coupled("temperature")),

_faraday(getParam<Real>("faraday_const")),
_gas_const(getParam<Real>("gas_const")),

_valence(getParam<std::vector<Real> >("ion_valence")),
_min_conductivity(getParam<Real>("min_conductivity"))
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

    if (_min_conductivity < 0.0)
        _min_conductivity = 0.0;
}

Real ElectrolyteCurrentFromPotentialGradient::sum_ion_terms()
{
    Real sum = 0.0;
    for (unsigned int i = 0; i<_ion_conc.size(); ++i)
    {
        sum = sum + _valence[i]*_valence[i]*(*_diffusion[i])[_qp]*(*_ion_conc[i])[_qp];
    }
    return sum;
}

Real ElectrolyteCurrentFromPotentialGradient::effective_ionic_conductivity()
{
    return ((_faraday*_faraday/_gas_const/_temp[_qp])*_porosity[_qp]*sum_ion_terms()) + _min_conductivity;
}

Real ElectrolyteCurrentFromPotentialGradient::computeQpResidual()
{
    return _test[_i][_qp]*effective_ionic_conductivity()*(_norm_vec*_e_potential_grad[_qp]);
}

Real ElectrolyteCurrentFromPotentialGradient::computeQpJacobian()
{
    return 0.0;
}

Real ElectrolyteCurrentFromPotentialGradient::computeQpOffDiagJacobian(unsigned int jvar)
{
    if (jvar == _e_potential_var)
    {
        return _test[_i][_qp]*effective_ionic_conductivity()*(_norm_vec*_grad_phi[_j][_qp]);
    }
    if (jvar == _porosity_var)
    {
        return _test[_i][_qp]*(_faraday*_faraday/_gas_const/_temp[_qp])*_phi[_j][_qp]*sum_ion_terms()*(_norm_vec*_e_potential_grad[_qp]);
    }
    if (jvar == _temp_var)
    {
        return _test[_i][_qp]*effective_ionic_conductivity()*(_norm_vec*_e_potential_grad[_qp])*(-1.0/_temp[_qp])*_phi[_j][_qp];
    }

    Real offjac = 0.0;
    for (unsigned int i = 0; i<_ion_conc.size(); ++i)
    {
        if (jvar == _ion_conc_vars[i])
          offjac = _test[_i][_qp]*( (_faraday*_faraday/_gas_const/_temp[_qp])*_porosity[_qp]*_valence[i]*_valence[i]*(*_diffusion[i])[_qp]*_phi[_j][_qp] )*(_norm_vec*_e_potential_grad[_qp]);
          break;
        if (jvar == _diffusion_vars[i])
          offjac = _test[_i][_qp]*( (_faraday*_faraday/_gas_const/_temp[_qp])*_porosity[_qp]*_valence[i]*_valence[i]*_phi[_j][_qp]*(*_ion_conc[i])[_qp] )*(_norm_vec*_e_potential_grad[_qp]);
          break;
    }

    return offjac;
}
