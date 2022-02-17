/*!
 *  \file ElectrodeCurrentFromPotentialGradient.h
 *	\brief Standard kernel for coupling a gradient of potential to the formation of current
 *	\details This file creates a standard MOOSE kernel for the coupling of a non-linear variable
 *            gradient for electrode potential to calculate current. In the case of anisotopic
 *            conductivity, the user should provide the conductivity that corresponds with the
 *            direction of current that this kernel acts on.
 *
 *            Ref:  J.R. Clausen, V.E. Brunini, H.K. Moffat, M.J. Martinez, "Numerical Modeling
 *                  of an All Vanadium Redox Flow Battery", Sandia Report, SAND2014-0190,
 *                  Sandia National Laboratories, Albuquerque, NM, January 2014.
 *
 *  \note Users MUST provide the direction of the current vector being calculated (0=>x, 1=>y, 2=>z)
 *
 *  \author Austin Ladshaw
 *	\date 11/15/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "ElectrodeCurrentFromPotentialGradient.h"

registerMooseObject("catsApp", ElectrodeCurrentFromPotentialGradient);

InputParameters ElectrodeCurrentFromPotentialGradient::validParams()
{
    InputParameters params = Kernel::validParams();
    params.addRequiredParam<unsigned int>("direction","Directional index for current that this kernel acts on (0 = x, 1 = y, 2 = z)");

    params.addRequiredCoupledVar("electric_potential","Variable for electric potential (V or J/C)");
    params.addCoupledVar("solid_frac",1,"Variable for volume fraction or porosity (default = 1)");
    params.addCoupledVar("conductivity",50,"Variable for conductivity of the electrode in units of C/V/length/time or similar (default = 50 C/V/m/s)");

    return params;
}

ElectrodeCurrentFromPotentialGradient::ElectrodeCurrentFromPotentialGradient(const InputParameters & parameters) :
Kernel(parameters),
_dir(getParam<unsigned int>("direction")),

_e_potential_grad(coupledGradient("electric_potential")),
_e_potential_var(coupled("electric_potential")),
_sol_frac(coupledValue("solid_frac")),
_sol_frac_var(coupled("solid_frac")),
_conductivity(coupledValue("conductivity")),
_conductivity_var(coupled("conductivity"))
{
    if (_dir > 2 || _dir < 0)
    {
        moose::internal::mooseErrorRaw("Invalid current direction index!");
    }

    _norm_vec(0) = 0.0;
    _norm_vec(1) = 0.0;
    _norm_vec(2) = 0.0;
    _norm_vec(_dir) = 1.0;
}

Real ElectrodeCurrentFromPotentialGradient::computeQpResidual()
{
    return _test[_i][_qp]*_sol_frac[_qp]*_conductivity[_qp]*(_norm_vec*_e_potential_grad[_qp]);
}

Real ElectrodeCurrentFromPotentialGradient::computeQpJacobian()
{
    return 0.0;
}

Real ElectrodeCurrentFromPotentialGradient::computeQpOffDiagJacobian(unsigned int jvar)
{
    if (jvar == _e_potential_var)
    {
        return _test[_i][_qp]*_sol_frac[_qp]*_conductivity[_qp]*(_norm_vec*_grad_phi[_j][_qp]);
    }
    if (jvar == _sol_frac_var)
    {
        return _test[_i][_qp]*_conductivity[_qp]*_phi[_j][_qp]*(_norm_vec*_e_potential_grad[_qp]);
    }
    if (jvar == _conductivity_var)
    {
        return _test[_i][_qp]*_sol_frac[_qp]*_phi[_j][_qp]*(_norm_vec*_e_potential_grad[_qp]);
    }

    return 0.0;
}
