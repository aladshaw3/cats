/*!
 *  \file AuxAvgGasDensity.h
 *    \brief Auxillary kernel to calculate the average gas density given reference pressures, temperatures, and gas species
 *    \details This file is responsible for calculating the value of an auxvariable
 *              according to the ideal gas law to estimate an average gas density.
 *              The calculate of the density is basically the same as GasDensity.h, except
 *              we explicitly remove the coupling with velocities and other non-essential
 *              parameters. This can then be used later in conjunction with other AuxKernels
 *              and variables to approximate velocity changes caused by density variations.
 *
 *  \author Austin Ladshaw
 *  \date 04/28/2020
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

#include "AuxAvgGasDensity.h"

registerMooseObject("catsApp", AuxAvgGasDensity);

InputParameters AuxAvgGasDensity::validParams()
{
    InputParameters params = AuxKernel::validParams();
    params.addRequiredCoupledVar("gases","List of names of the gas species variables (mol/m^3)");
    params.addRequiredCoupledVar("pressure","Pressure variable for the domain (Pa)");
    params.addRequiredCoupledVar("temperature","Temperature variable for the domain (K)");
    
    params.addParam< std::vector<Real> >("molar_weights","List of molecular weights (g/mol)");
    return params;
}

AuxAvgGasDensity::AuxAvgGasDensity(const InputParameters & parameters) :
AuxKernel(parameters),
_press(coupledValue("pressure")),
_press_var(coupled("pressure")),
_temp(coupledValue("temperature")),
_temp_var(coupled("temperature")),
_MW(getParam<std::vector<Real> >("molar_weights"))
{
    unsigned int n = coupledComponents("gases");
    _gases_vars.resize(n);
    _gases.resize(n);

    for (unsigned int i = 0; i<_gases.size(); ++i)
    {
        _gases_vars[i] = coupled("gases",i);
        _gases[i] = &coupledValue("gases",i);
    }
    
    if (_MW.size() != _gases.size())
    {
        moose::internal::mooseErrorRaw("Must have same number of gas species and molecular weights!");
    }
}

void AuxAvgGasDensity::calculateMolefractions()
{
    std::vector<Real> partials;
    partials.resize(_gases.size());
    Real total = 0.0;
    _avg_MW = 0.0;
    for (unsigned int i = 0; i<_gases.size(); ++i)
    {
        if ((*_gases[i])[_qp] > 0.0)
        {
            partials[i] = Pstd((*_gases[i])[_qp],_temp[_qp])*1000.0;
        }
        else
        {
            partials[i] = 0.0;
        }
        total += partials[i];
    }
    
    // Do not add "carrier" gas
    if (total >= _press[_qp])
    {
        _mole_frac.resize(_gases.size());
        
        Real total_moles = 0.0;
        for (unsigned int i = 0; i<_gases.size(); ++i)
        {
            if ((*_gases[i])[_qp] > 0.0)
            {
                total_moles += (*_gases[i])[_qp];
            }
        }
        
        for (unsigned int i = 0; i<_gases.size(); ++i)
        {
            if ((*_gases[i])[_qp] > 0.0)
            {
                _mole_frac[i] = (*_gases[i])[_qp]/total_moles;
            }
        }
        
        for (unsigned int i = 0; i<_gases.size(); ++i)
        {
            _avg_MW += _MW[i]*_mole_frac[i];
        }
    }
    // Add a "carrier" gas
    else
    {
        _mole_frac.resize(_gases.size()+1);
        Real carrier_press = _press[_qp] - total;
        
        for (unsigned int i = 0; i<_gases.size(); ++i)
        {
            if ((*_gases[i])[_qp] > 0.0)
            {
                _mole_frac[i] = Pstd((*_gases[i])[_qp],_temp[_qp])*1000.0/_press[_qp];
            }
        }
        _mole_frac[_gases.size()] = carrier_press/_press[_qp];
        for (unsigned int i = 0; i<_gases.size(); ++i)
        {
            _avg_MW += _MW[i]*_mole_frac[i];
        }
        _avg_MW += 28.85*_mole_frac[_gases.size()];
    }
}

Real AuxAvgGasDensity::computeValue()
{
    calculateMolefractions();
    return (_press[_qp]/1000.0)*_avg_MW/Rstd/_temp[_qp];
}


