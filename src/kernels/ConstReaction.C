/*!
 *  \file ConstReaction.h
 *  \brief Kernel for creating a generic reaction with forward and/or reverse components
 *  \details This file creates a standard MOOSE kernel for the coupling a set of non-linear variables to
 *            create a generic reaction with constant rate coefficients. This kernel has a list of reactants
 *            and a list of products, with corresponding lists for stoichiometric coefficients. Additionally, there
 *            is an option "scale" parameter that is useful when constructing an overall reaction rate from
 *            a set of these kernels that represent a reaction pathway or mechanism.
 *            The residual for this kernel is as follows
 *                      Res = - a*kf*prod(C_i, v_i) + a*kr*prod(C_j, v_j)
 *                      where a = scaling parameter, kf = forward rate, kr = reverse rate,
 *                      v_i's = stoichiometry, and C_i's = chemical species concentrations
 *
 *
 *  \author Austin Ladshaw
 *  \date 03/25/2020
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
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

#include "ConstReaction.h"


registerMooseObject("catsApp", ConstReaction);

/*
template<>
InputParameters validParams<ConstReaction>()
{
    InputParameters params = validParams<Kernel>();
    params.addParam< std::vector<Real> >("reactant_stoich","List of stoichiometry for reactants");
    params.addParam< std::vector<Real> >("product_stoich","List of stoichiometry for products");
    params.addParam< Real >("forward_rate",0.0,"Forward rate constant");
    params.addParam< Real >("reverse_rate",0.0,"Reverse rate constant");
    params.addParam< Real >("scale",1.0,"Scaling parameter for this reaction");
    params.addRequiredCoupledVar("reactants","List of names of the reactant variables");
    params.addRequiredCoupledVar("products","List of names of the product variables");
    params.addRequiredCoupledVar("this_variable","Name of this variable the kernel acts on");
    return params;
}
 */

InputParameters ConstReaction::validParams()
{
    InputParameters params = Kernel::validParams();
    params.addParam< std::vector<Real> >("reactant_stoich","List of stoichiometry for reactants");
    params.addParam< std::vector<Real> >("product_stoich","List of stoichiometry for products");
    params.addParam< Real >("forward_rate",0.0,"Forward rate constant");
    params.addParam< Real >("reverse_rate",0.0,"Reverse rate constant");
    params.addParam< Real >("scale",1.0,"Scaling parameter for this reaction");
    params.addRequiredCoupledVar("reactants","List of names of the reactant variables");
    params.addRequiredCoupledVar("products","List of names of the product variables");
    params.addRequiredCoupledVar("this_variable","Name of this variable the kernel acts on");
    return params;
}

ConstReaction::ConstReaction(const InputParameters & parameters)
: Kernel(parameters),
_forward_rate(getParam< Real >("forward_rate")),
_reverse_rate(getParam< Real >("reverse_rate")),
_scale(getParam< Real >("scale")),
_react_stoich(getParam<std::vector<Real> >("reactant_stoich")),
_prod_stoich(getParam<std::vector<Real> >("product_stoich")),
_coupled_main(coupledValue("this_variable")),
_main_var(coupled("this_variable"))
{
    unsigned int r = coupledComponents("reactants");
    _react_vars.resize(r);
    _reactants.resize(r);
    
    unsigned int p = coupledComponents("products");
    _prod_vars.resize(p);
    _products.resize(p);
    
    inReactList = false;
    inProdList = false;
    indexReact = -1;
    indexProd = -1;

    for (unsigned int i = 0; i<_reactants.size(); ++i)
    {
        _react_vars[i] = coupled("reactants",i);
        _reactants[i] = &coupledValue("reactants",i);
        if (_react_vars[i] == _main_var)
            inReactList = true;
    }
    
    for (unsigned int i = 0; i<_products.size(); ++i)
    {
        _prod_vars[i] = coupled("products",i);
        _products[i] = &coupledValue("products",i);
        if (_prod_vars[i] == _main_var)
            inProdList = true;
    }
    
    if (inReactList == true)
    {
        for (unsigned int i = 0; i<_reactants.size(); ++i)
        {
            if (_react_vars[i] == _main_var)
                indexReact = i;
        }
    }
    
    if (inProdList == true)
       {
           for (unsigned int i = 0; i<_products.size(); ++i)
           {
               if (_prod_vars[i] == _main_var)
                   indexProd = i;
           }
       }

}

Real ConstReaction::computeQpResidual()
{
    Real res = 0.0;
    Real react_prod = 1.0;
    Real prod_prod = 1.0;
    if (_reactants.size() == 0)
        react_prod = 0.0;
    if (_products.size() == 0)
        prod_prod = 0.0;
    for (unsigned int i = 0; i<_reactants.size(); ++i)
    {
        react_prod = react_prod * std::pow( (*_reactants[i])[_qp], _react_stoich[i] );
    }
    for (unsigned int i = 0; i<_products.size(); ++i)
    {
        prod_prod = prod_prod * std::pow( (*_products[i])[_qp], _prod_stoich[i] );
    }
    res = -_scale*_forward_rate*react_prod*_test[_i][_qp] + _scale*_reverse_rate*prod_prod*_test[_i][_qp];
    return res;
}

Real ConstReaction::computeQpJacobian()
{
    Real jac = 0.0;
    
    if (inReactList == true)
    {
        Real react_prod = 1.0;
        if (_reactants.size() == 0)
            react_prod = 0.0;
        for (unsigned int i = 0; i<_reactants.size(); ++i)
        {
            if (_react_vars[i] != _main_var)
            {
                react_prod = react_prod * std::pow( (*_reactants[i])[_qp], _react_stoich[i] );
            }
        }
        jac += -react_prod*_scale*_forward_rate*_react_stoich[indexReact] * std::pow( (*_reactants[indexReact])[_qp], _react_stoich[indexReact]-1.0 ) * _test[_i][_qp] * _phi[_j][_qp];
    }
    if (inProdList == true)
    {
        Real prod_prod = 1.0;
        if (_products.size() == 0)
            prod_prod = 0.0;
        for (unsigned int i = 0; i<_products.size(); ++i)
        {
            if (_prod_vars[i] != _main_var)
            {
                prod_prod = prod_prod * std::pow( (*_products[i])[_qp], _prod_stoich[i] );
            }
        }
        jac += prod_prod*_scale*_reverse_rate*_prod_stoich[indexProd] * std::pow( (*_products[indexProd])[_qp], _prod_stoich[indexProd]-1.0 ) * _test[_i][_qp] * _phi[_j][_qp];
    }
    return jac;
}

Real ConstReaction::computeQpOffDiagJacobian(unsigned int jvar)
{
    bool exists = false;
    for (unsigned int i = 0; i<_reactants.size(); ++i)
    {
        if (jvar == _react_vars[i] && jvar != _main_var)
        {
            exists = true;
            break;
        }
    }
    for (unsigned int i = 0; i<_products.size(); ++i)
    {
        if (jvar == _prod_vars[i] && jvar != _main_var)
        {
            exists = true;
            break;
        }
    }
    if (exists == false)
    {
        return 0.0;
    }
    
    Real offjac = 0.0;
    Real react_prod = 1.0;
    Real prod_prod = 1.0;
    if (_reactants.size() == 0)
        react_prod = 0.0;
    if (_products.size() == 0)
        prod_prod = 0.0;
    int ri = -1;
    int pi = -1;
    for (unsigned int i = 0; i<_reactants.size(); ++i)
    {
        if (jvar != _react_vars[i])
        {
            react_prod = react_prod * std::pow( (*_reactants[i])[_qp], _react_stoich[i] );
        }
        else
        {
            ri = i;
        }
    }
    if (ri == -1)
        react_prod = 0.0;
    else
        react_prod = react_prod*_react_stoich[ri] * std::pow( (*_reactants[ri])[_qp], _react_stoich[ri]-1.0 ) * _test[_i][_qp] * _phi[_j][_qp];
    for (unsigned int i = 0; i<_products.size(); ++i)
    {
        if (jvar != _prod_vars[i])
        {
            prod_prod = prod_prod * std::pow( (*_products[i])[_qp], _prod_stoich[i] );
        }
        else
        {
            pi = i;
        }
    }
    if (pi == -1)
        prod_prod = 0.0;
    else
        prod_prod = prod_prod*_prod_stoich[pi] * std::pow( (*_products[pi])[_qp], _prod_stoich[pi]-1.0 ) * _test[_i][_qp] * _phi[_j][_qp];
    
    offjac = -_scale*_forward_rate*react_prod + _scale*_reverse_rate*prod_prod;
    
    return offjac;
}
