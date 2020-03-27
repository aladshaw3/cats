/*!
 *  \file MaterialBalance.h
 *  \brief Kernel for creating a material balance kernel
 *  \details This file creates a standard MOOSE kernel for the coupling a set of non-linear variables to
 *            resolve a material balance equation. This kernel is usually used with sets of chemical reactions
 *            to close the system of equations for the chemistry in a given system.
 *            The residual is as follows...
 *                      Res = CT - sum(b_i, C_i)
 *                      where CT = total concentration, b_i is a weight parameter, and C_i is a component of CT
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

#include "MaterialBalance.h"


registerMooseObject("catsApp", MaterialBalance);

template<>
InputParameters validParams<MaterialBalance>()
{
    InputParameters params = validParams<Kernel>();
    params.addParam< std::vector<Real> >("weights","List of weights for variables in the balance");
    params.addRequiredCoupledVar("coupled_list","List of names of the variables being coupled");
    params.addRequiredCoupledVar("total_material","Name of variable for total material");
    params.addRequiredCoupledVar("this_variable","Name of this variable the kernel acts on");
    return params;
}

MaterialBalance::MaterialBalance(const InputParameters & parameters)
: Kernel(parameters),
_weights(getParam<std::vector<Real> >("weights")),
_coupled_total(coupledValue("total_material")),
_coupled_var_total(coupled("total_material")),
_coupled_main(coupledValue("this_variable")),
_main_var(coupled("this_variable"))
{
    unsigned int n = coupledComponents("coupled_list");
    _coupled_vars.resize(n);
    _coupled.resize(n);
    inList = false;
    index = -1;

    for (unsigned int i = 0; i<_coupled.size(); ++i)
    {
        _coupled_vars[i] = coupled("coupled_list",i);
        _coupled[i] = &coupledValue("coupled_list",i);
        if (_coupled_vars[i] == _main_var)
            inList = true;
    }
    
    if (inList == true)
    {
        for (unsigned int i = 0; i<_coupled.size(); ++i)
        {
            if (_coupled_vars[i] == _main_var)
                index = i;
        }
    }

}

Real MaterialBalance::computeQpResidual()
{
    Real sum = 0.0;
    for (unsigned int i = 0; i<_coupled.size(); ++i)
    {
        sum += _weights[i] * ((*_coupled[i])[_qp]);
    }
    return (_coupled_total[_qp] - sum) * _test[_i][_qp];
}

Real MaterialBalance::computeQpJacobian()
{
    if (inList == true)
    {
        return -_phi[_j][_qp] * _weights[index] * _test[_i][_qp];
    }
    else
    {
        return _phi[_j][_qp] * _test[_i][_qp];
    }
}

Real MaterialBalance::computeQpOffDiagJacobian(unsigned int jvar)
{
    if (jvar == _coupled_var_total && jvar != _main_var)
    {
        return _phi[_j][_qp] * _test[_i][_qp];
    }
    for (unsigned int i = 0; i<_coupled.size(); ++i)
    {
        if (jvar == _coupled_vars[i] && jvar != _main_var)
        {
            return -_phi[_j][_qp] * _weights[index] * _test[_i][_qp];
        }
    }
    return 0.0;
}

