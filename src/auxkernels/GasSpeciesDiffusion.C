/*!
 *  \file GasSpeciesDiffusion.h
 *    \brief AuxKernel kernel to compute the molecular diffusion for a given gas species
 *    \details This file is responsible for calculating the molecular diffusion in m^2/s
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

#include "GasSpeciesDiffusion.h"

registerMooseObject("catsApp", GasSpeciesDiffusion);

InputParameters GasSpeciesDiffusion::validParams()
{
    InputParameters params = GasPropertiesBase::validParams();
    params.addParam< unsigned int >("species_index",0,"Index of the gas species we want the diffusion of");
    return params;
}

GasSpeciesDiffusion::GasSpeciesDiffusion(const InputParameters & parameters) :
GasPropertiesBase(parameters),
_index(getParam< unsigned int >("species_index"))
{
    if (_index > _gases.size())
    {
        moose::internal::mooseErrorRaw("Index out of bounds!");
    }
}

Real GasSpeciesDiffusion::computeValue()
{
    prepareEgret();
    calculateAllProperties();

    return _egret_dat.species_dat[_index].molecular_diffusion/100.0/100.0;
}
