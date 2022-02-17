/*!
 *  \file ButlerVolmerCurrentDensity.h
 *  \brief Kernel for calculating current density from a Bulter-Volmer reaction rate variable
 *  \details This file creates a kernel for the coupling the reaction rate calculated from
 *            a Butler-Volmer relationship with a variable for specific electrode surface
 *            area and the number of electrons transferred in that reaction. This kernel
 *            should be used in conjuction with the 'Reaction' kernel to fully describe
 *            the equations being solved.
 *
 *            Reaction:                     test * -J = 0
 *            ButlerVolmerCurrentDensity:   test * n*As*F*(-r) = 0
 *
 *                          where J = current density (C / (total volume) / time)
 *                                n = number of electrons transferred in reaction 'r'
 *                                As = specific surface area (total electrode surface area / total volume)
 *                                      [total volume would include void volume]
 *                                F = Faraday's constant (default = 96,485.3 C/mol)
 *                                r = reaction rate variable (moles / electrode surface area / time)
 *
 *
 *  \author Austin Ladshaw
 *  \date 11/29/2021
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "ButlerVolmerCurrentDensity.h"

registerMooseObject("catsApp", ButlerVolmerCurrentDensity);

InputParameters ButlerVolmerCurrentDensity::validParams()
{
    InputParameters params = Kernel::validParams();
    params.addRequiredCoupledVar("rate_var","Variable for reaction rate that exchanges electrons (moles / electrode area / time)");
    params.addCoupledVar("specific_area",1.0,"Specific area for transfer [surface area of electrode / total volume] (m^-1)");

    params.addParam<Real>("faraday_const",96485.3, "Value of Faraday's constant (default = 96485.3 C/mol)");
    params.addParam<Real>("number_of_electrons",1.0,"Number of electrons transferred the redox reaction");
    return params;
}

ButlerVolmerCurrentDensity::ButlerVolmerCurrentDensity(const InputParameters & parameters)
: Kernel(parameters),
_rate(coupledValue("rate_var")),
_rate_var(coupled("rate_var")),
_specarea(coupledValue("specific_area")),
_specarea_var(coupled("specific_area")),
_n(getParam<Real>("number_of_electrons")),
_faraday(getParam<Real>("faraday_const"))
{

}

Real ButlerVolmerCurrentDensity::computeQpResidual()
{
    return _test[_i][_qp] * _n * _specarea[_qp] * _faraday * (-_rate[_qp]);
}

Real ButlerVolmerCurrentDensity::computeQpJacobian()
{
    return 0.0;
}

Real ButlerVolmerCurrentDensity::computeQpOffDiagJacobian(unsigned int jvar)
{

    if (jvar == _specarea_var)
    {
        return _test[_i][_qp] * _n * _phi[_j][_qp] * _faraday * (-_rate[_qp]);
    }
    if (jvar == _rate_var)
    {
        return _test[_i][_qp] * _n * _specarea[_qp] * _faraday * (-_phi[_j][_qp]);
    }

    return 0.0;
}
