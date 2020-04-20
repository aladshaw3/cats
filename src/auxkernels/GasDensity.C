/*!
 *  \file GasDensity.h
 *    \brief AuxKernel kernel to compute the gas density
 *    \details This file is responsible for calculating the gas density in kg/m^3.
 *
 *
 *  \author Austin Ladshaw
 *  \date 04/20/2020
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

#include "GasDensity.h"

registerMooseObject("catsApp", GasDensity);

template<>
InputParameters validParams<GasDensity>()
{
    InputParameters params = validParams<GasPropertiesBase>();
    
    return params;
}

GasDensity::GasDensity(const InputParameters & parameters) :
GasPropertiesBase(parameters)
{

}

Real GasDensity::computeValue()
{
    prepareEgret();
    calculateAllProperties();
    
    return _egret_dat.total_density/1000.0*100.0*100.0*100.0;
}


