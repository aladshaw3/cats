/*!
 *  \file ActivityConstraint.h
 *  \brief Kernel for calculating activity of a chemical species based on activity coefficient and concentration
 *  \details This file creates a kernel for the coupling a concentration of a species (C)
 *            with an activity coefficient (gamma) through a reference concentration (Cref)
 *            in order to establish the activity of that species in solution or on a surface.
 *            The activity coefficient (gamma) should be a unitless number. The Cref concentration
 *            is generally either total concentration or a reference concentration for a given
 *            phase (e.g., in electrolyte chemistry, this is generally taken to be 1 M). The
 *            concentration for the species must have same units as Cref such that the calculated
 *            activity (a) is unitless.
 *
 *            To use this kernel, combine the 'Reaction' kernel with this 'ActivityConstraint'
 *            kernel to fully describe the constraint.
 *
 *            Reaction:                     test * -a = 0
 *            ActivityConstraint:           test * -gamma*(C/Cref) = 0
 *
 *                          where gamma = activity coefficient variable (unitless)
 *                                C = concentration variable (amount / volume)
 *                                Cref = given constant or calculated total concentration
 *                                      [Must have same units as C]
 *
 *
 *  \author Austin Ladshaw
 *  \date 02/02/2022
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "ActivityConstraint.h"

registerMooseObject("catsApp", ActivityConstraint);

InputParameters ActivityConstraint::validParams()
{
    InputParameters params = Kernel::validParams();
    params.addRequiredCoupledVar("concentration","Variable for species concentration");
    params.addCoupledVar("activity_coeff",1.0,"Activity coefficient for the species [default: ideal solution]");
    params.addCoupledVar("ref_conc",1.0,"Reference or total concentration of the mixture (same units as 'concentration') [default = 1 M]");

    return params;
}

ActivityConstraint::ActivityConstraint(const InputParameters & parameters)
: Kernel(parameters),
_gamma(coupledValue("activity_coeff")),
_gamma_var(coupled("activity_coeff")),
_conc(coupledValue("concentration")),
_conc_var(coupled("concentration")),
_ref_conc(coupledValue("ref_conc")),
_ref_conc_var(coupled("ref_conc"))
{

}

Real ActivityConstraint::computeQpResidual()
{
    return -_test[_i][_qp] * _gamma[_qp] * _conc[_qp] / _ref_conc[_qp];
}

Real ActivityConstraint::computeQpJacobian()
{
    return 0.0;
}

Real ActivityConstraint::computeQpOffDiagJacobian(unsigned int jvar)
{

    if (jvar == _gamma_var)
    {
        return -_test[_i][_qp] * _phi[_j][_qp] * _conc[_qp] / _ref_conc[_qp];
    }
    if (jvar == _conc_var)
    {
        return -_test[_i][_qp] * _gamma[_qp] * _phi[_j][_qp] / _ref_conc[_qp];
    }
    if (jvar == _ref_conc_var)
    {
        return _test[_i][_qp] * _gamma[_qp] * _conc[_qp] / _ref_conc[_qp] / _ref_conc[_qp] * _phi[_j][_qp];
    }

    return 0.0;
}
