/*!
 *  \file AuxElectrodeCurrent.h
 *	\brief Auxiliary kernel for calculating current in the electrode
 *	\details This file creates an auxiliary kernel for the coupling of a non-linear variable
 *            gradient for electrode potential to calculate current. In the case of anisotopic
 *            conductivity, the user should provide the conductivity that corresponds with the
 *            direction of current that this kernel acts on.
 *
 *            This would be done INSTEAD of using ElectrodeCurrentFromPotentialGradient for
 *            residual based calculation of current (as it is not needed in that way)
 *
 *            Ref:  J.R. Clausen, V.E. Brunini, H.K. Moffat, M.J. Martinez, "Numerical Modeling
 *                  of an All Vanadium Redox Flow Battery", Sandia Report, SAND2014-0190,
 *                  Sandia National Laboratories, Albuquerque, NM, January 2014.
 *
 *  \note Users MUST provide the direction of the current vector being calculated (0=>x, 1=>y, 2=>z)
 *
 *  \author Austin Ladshaw
 *	\date 02/10/2022
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "AuxElectrodeCurrent.h"

registerMooseObject("catsApp", AuxElectrodeCurrent);

InputParameters AuxElectrodeCurrent::validParams()
{
    InputParameters params = AuxKernel::validParams();
    params.addRequiredParam<unsigned int>("direction","Directional index for current that this kernel acts on (0 = x, 1 = y, 2 = z)");
    params.addRequiredCoupledVar("electric_potential","Variable for electric potential (V or J/C)");
    params.addCoupledVar("solid_frac",1,"Variable for volume fraction or porosity (default = 1)");
    params.addCoupledVar("conductivity",50,"Variable for conductivity of the electrode in units of C/V/length/time or similar (default = 50 C/V/m/s)");
    return params;
}

AuxElectrodeCurrent::AuxElectrodeCurrent(const InputParameters & parameters) :
AuxKernel(parameters),
_dir(getParam<unsigned int>("direction")),
_e_potential_grad(coupledGradient("electric_potential")),
_sol_frac(coupledValue("solid_frac")),
_conductivity(coupledValue("conductivity"))
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

Real AuxElectrodeCurrent::computeValue()
{
    return -_sol_frac[_qp]*_conductivity[_qp]*(_norm_vec*_e_potential_grad[_qp]);
}
