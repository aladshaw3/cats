/*!
 *  \file GasSpeciesEffectiveTransferCoef.h
 *    \brief AuxKernel kernel to compute the effective mass transfer coefficient for a given gas species
 *    \details This file is responsible for calculating the mass transfer in m/s
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

#include "GasSpeciesEffectiveTransferCoef.h"

registerMooseObject("catsApp", GasSpeciesEffectiveTransferCoef);

template<>
InputParameters validParams<GasSpeciesEffectiveTransferCoef>()
{
    InputParameters params = validParams<GasPropertiesBase>();
    params.addParam< unsigned int >("species_index",0,"Index of the gas species we want the diffusion of");
    params.addRequiredCoupledVar("micro_porosity","Name of the micro-porosity variable");
    return params;
}

GasSpeciesEffectiveTransferCoef::GasSpeciesEffectiveTransferCoef(const InputParameters & parameters) :
GasPropertiesBase(parameters),
_index(getParam< unsigned int >("species_index")),
_porosity(coupledValue("micro_porosity")),
_porosity_var(coupled("micro_porosity"))
{
    if (_index > _gases.size())
    {
        moose::internal::mooseErrorRaw("Index out of bounds!");
    }
}

Real GasSpeciesEffectiveTransferCoef::computeValue()
{
    prepareEgret();
    calculateAllProperties();
    
    return FilmMTCoeff(_egret_dat.species_dat[_index].molecular_diffusion*_porosity[_qp]*_porosity[_qp], _egret_dat.char_length, _egret_dat.Reynolds, ScNum(_egret_dat.kinematic_viscosity,_egret_dat.species_dat[_index].molecular_diffusion*_porosity[_qp]*_porosity[_qp]))/100.0;
}


