/*!
 *  \file GasVolSpecHeat.h
 *    \brief AuxKernel kernel to compute the gas phase volumetric specific heat (Cv)
 *    \details This file is responsible for calculating the gas volumetric specific heat (Cv) in J/kg/K
 *
 *
 *  \author Austin Ladshaw
 *  \date 04/21/2020
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

#include "GasVolSpecHeat.h"

registerMooseObject("catsApp", GasVolSpecHeat);

InputParameters GasVolSpecHeat::validParams()
{
    InputParameters params = GasPropertiesBase::validParams();
    params.addParam< Real >("heat_cap_ratio",1.4,"Ratio of heat capacities (Cp/Cv) ==> Assumed = 1.4");

    return params;
}

GasVolSpecHeat::GasVolSpecHeat(const InputParameters & parameters) :
GasPropertiesBase(parameters),
_Cp_Cv_ratio(getParam< Real >("heat_cap_ratio"))
{
    // Check the bounds of the correction factor (typical values: 1.3 - 1.6)
    if (_Cp_Cv_ratio < 0.56)
    {
        _Cp_Cv_ratio = 0.56;
    }
    if (_Cp_Cv_ratio > 1.67)
    {
        _Cp_Cv_ratio = 1.67;
    }
}

Real GasVolSpecHeat::computeValue()
{
    prepareEgret();
    calculateAllProperties();
    Real Cv = _egret_dat.total_specific_heat*1000.0/_Cp_Cv_ratio;
    return Cv;
}
