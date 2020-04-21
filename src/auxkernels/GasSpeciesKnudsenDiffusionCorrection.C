/*!
 *  \file GasSpeciesKnudsenDiffusionCorrection.h
 *    \brief AuxKernel kernel to compute the effective pore diffusivity with Knudsen correction for the micro-scale
 *    \details This file is responsible for calculating the effective pore diffusion in m^2/s
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

#include "GasSpeciesKnudsenDiffusionCorrection.h"

registerMooseObject("catsApp", GasSpeciesKnudsenDiffusionCorrection);

template<>
InputParameters validParams<GasSpeciesKnudsenDiffusionCorrection>()
{
    InputParameters params = validParams<GasPropertiesBase>();
    params.addParam< unsigned int >("species_index",0,"Index of the gas species we want the diffusion of");
    params.addRequiredCoupledVar("micro_porosity","Name of the micro-porosity variable");
    params.addRequiredCoupledVar("micro_pore_radius","Name of the micro-pore radius variable (m)");
    return params;
}

GasSpeciesKnudsenDiffusionCorrection::GasSpeciesKnudsenDiffusionCorrection(const InputParameters & parameters) :
GasPropertiesBase(parameters),
_index(getParam< unsigned int >("species_index")),
_porosity(coupledValue("micro_porosity")),
_porosity_var(coupled("micro_porosity")),
_pore_rad(coupledValue("micro_pore_radius")),
_pore_rad_var(coupled("micro_pore_radius"))
{
    if (_index > _gases.size())
    {
        moose::internal::mooseErrorRaw("Index out of bounds!");
    }
}

Real GasSpeciesKnudsenDiffusionCorrection::computeValue()
{
    prepareEgret();
    calculateAllProperties();
    Real Dp = _egret_dat.species_dat[_index].molecular_diffusion*_porosity[_qp]*_porosity[_qp];
    Real Dk = 9700.0*(_pore_rad[_qp]*100.0)*sqrt(_temp[_qp]/_egret_dat.species_dat[_index].molecular_weight);
    Real Deff = 1.0/((1.0/Dp)+(1.0/Dk));
    
    return Deff/100.0/100.0;
}
