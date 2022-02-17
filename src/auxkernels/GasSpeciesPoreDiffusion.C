/*!
 *  \file GasSpeciesPoreDiffusion.h
 *    \brief AuxKernel kernel to compute the pore diffusivity for the micro-scale
 *    \details This file is responsible for calculating the pore diffusion in m^2/s
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

#include "GasSpeciesPoreDiffusion.h"

registerMooseObject("catsApp", GasSpeciesPoreDiffusion);

InputParameters GasSpeciesPoreDiffusion::validParams()
{
    InputParameters params = GasPropertiesBase::validParams();
    params.addParam< unsigned int >("species_index",0,"Index of the gas species we want the diffusion of");
    params.addRequiredCoupledVar("micro_porosity","Name of the micro-porosity variable");
    return params;
}

GasSpeciesPoreDiffusion::GasSpeciesPoreDiffusion(const InputParameters & parameters) :
GasPropertiesBase(parameters),
_index(getParam< unsigned int >("species_index")),
_porosity(coupledValue("micro_porosity"))
{
    if (_index > _gases.size())
    {
        moose::internal::mooseErrorRaw("Index out of bounds!");
    }
}

Real GasSpeciesPoreDiffusion::computeValue()
{
    prepareEgret();
    calculateAllProperties();

    return _egret_dat.species_dat[_index].molecular_diffusion*_porosity[_qp]*_porosity[_qp]/100.0/100.0;
}
