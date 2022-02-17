/*!
 *  \file GasSpeciesAxialDispersion.h
 *    \brief AuxKernel kernel to compute the axial dispersion for a given gas species
 *    \details This file is responsible for calculating the axial dispersion in m^2/s
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

#include "GasSpeciesAxialDispersion.h"

registerMooseObject("catsApp", GasSpeciesAxialDispersion);

InputParameters GasSpeciesAxialDispersion::validParams()
{
    InputParameters params = GasPropertiesBase::validParams();
    params.addParam< unsigned int >("species_index",0,"Index of the gas species we want the diffusion of");
    params.addRequiredCoupledVar("macroscale_diameter","Name of the macrocale column diameter variable (m)");
    return params;
}

GasSpeciesAxialDispersion::GasSpeciesAxialDispersion(const InputParameters & parameters) :
GasPropertiesBase(parameters),
_index(getParam< unsigned int >("species_index")),
_column_dia(coupledValue("macroscale_diameter"))
{
    if (_index > _gases.size())
    {
        moose::internal::mooseErrorRaw("Index out of bounds!");
    }
}

Real GasSpeciesAxialDispersion::computeValue()
{
    prepareEgret();
    calculateAllProperties();

    Real Sc = ScNum(_egret_dat.kinematic_viscosity,_egret_dat.species_dat[_index].molecular_diffusion);
    Real Re = ReNum(_egret_dat.velocity,_column_dia[_qp]*100.0,_egret_dat.kinematic_viscosity);
    Real factor = (20.0/Re/Sc) + 0.5;

    return _egret_dat.velocity*_egret_dat.char_length*factor/100.0/100.0;
}
