/*!
 *  \file InitialInhibitionProducts.h
 *    \brief Initial Condition kernel for an Inhibition product variable
 *    \details This file creates an initial condition for an Inhibition Product variable.
 *            The value for this kernel is as follows
 *                      R_IC = - prod(R_i, p_i)
 *                      where R_i is the i-th inhibition term and p_i is the power for that term
 *
 *  \author Austin Ladshaw
 *  \date 12/30/2020
 *  \copyright This kernel was designed and built at the Georgia Institute
 *             of Technology by Austin Ladshaw for PhD research in the area
 *             of adsorption and surface science and was developed for use
 *               by Idaho National Laboratory and Oak Ridge National Laboratory
 *               engineers and scientists. Portions Copyright (c) 2015, all
 *             rights reserved.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "InitialInhibitionProducts.h"

registerMooseObject("catsApp", InitialInhibitionProducts);

InputParameters InitialInhibitionProducts::validParams()
{
    InputParameters params = InitialCondition::validParams();
    params.addParam< std::vector<Real> >("power_list","List of powers for coupled inhibition terms");
    params.addRequiredCoupledVar("coupled_list","List of names of the inhibition variables");
    return params;
}

InitialInhibitionProducts::InitialInhibitionProducts(const InputParameters & parameters)
: InitialCondition(parameters),
_power(getParam<std::vector<Real> >("power_list"))
{
    unsigned int r = coupledComponents("coupled_list");
    _inhibition_vars.resize(r);
    _inhibition.resize(r);

    if (_inhibition.size() != _power.size())
    {
        moose::internal::mooseErrorRaw("User is required to provide (at minimum) a list of power factors equal to the number of coupled inhibition terms.");
    }

    for (unsigned int i = 0; i<_inhibition.size(); ++i)
    {
        _inhibition_vars[i] = coupled("coupled_list",i);
        _inhibition[i] = &coupledValue("coupled_list",i);
    }

}

Real InitialInhibitionProducts::value(const Point & /*p*/)
{
    Real prod = 1.0;
    if (_inhibition.size() == 0)
        prod = 0.0;
    for (unsigned int i = 0; i<_inhibition.size(); ++i)
    {
        prod = prod * std::pow( (*_inhibition[i])[_qp], _power[i] );
    }
    return prod;
}
