/*!
 *  \file VoidsVolumeFraction.h
 *    \brief Auxillary kernel to calculate the voids volume fraction of a packed bed
 *    \details This file is responsible for calculating the voids volume fraction
 *            based on the material density and the bulk packing density. Calculation
 *            of material density is based on average particle size (assuming roughly
 *            spherical particles) and the average particle mass. Then, user provides
 *            an approximate bed packing density in total mass per total volume of
 *            the packed bed. The voids fraction (eb) is then calculated as (1 - rho_b/rho_p),
 *            where rho_b is the packing density and rho_p is the calculated material
 *            or single particle density. This kernel will automatically check values
 *            calculated to ensure that there are no errors in the estimated voids fraction
 *            and will report warnings or errors accordingly.
 *
 *            Maximum allowed voids fraction = 0.66
 *                Theoretical maximum based on very loose packing of spheres
 *                Ref:  Hilbert, D. and Cohn-Vossen, S. Geometry and the Imagination. New York: Chelsea, pp. 45-53, 1999.
 *
 *            Minimum allowed voids fraction = 0.26
 *                Theoretical minimum based on very tight packing of spheres
 *                Ref:  Steinhaus, H. Mathematical Snapshots, 3rd ed. New York: Dover, pp. 202-203, 1999.
 *                Ref:  Wells, D. The Penguin Dictionary of Curious and Interesting Numbers. Middlesex, England: Penguin Books, p. 29, 1986.
 *
 *  \note The user is responsible for making sure that their units work out and are appropriate.
 *              Units for given packing density must be same basis as units for particle size
 *              and particle mass. Otherwise, the calculation will not come out correct.
 *
 *  \author Austin Ladshaw
 *  \date 09/14/2021
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

#include "VoidsVolumeFraction.h"

registerMooseObject("catsApp", VoidsVolumeFraction);

InputParameters VoidsVolumeFraction::validParams()
{
    InputParameters params = AuxKernel::validParams();
    params.addParam<Real>("particle_diameter",1,"Average diameter of the particles for ratio calculation");
    params.addParam<Real>("particle_mass",5,"Average mass of the particles for ratio calculation");
    params.addParam<Real>("packing_density",1,"Average bulk packing density of the fixed bed");
    params.addParam<bool>("override_limits",false,"If true, then ratio is allowed to go beyond physical limits. If false, then ratio is bounded to theoretical max and min ");
    return params;
}

VoidsVolumeFraction::VoidsVolumeFraction(const InputParameters & parameters) :
AuxKernel(parameters),
_particle_diameter(getParam<Real>("particle_diameter")),
_particle_mass(getParam<Real>("particle_mass")),
_packing_density(getParam<Real>("packing_density")),
_OverrideLimits(getParam<bool>("override_limits"))
{
    //Calculate the particle density
    Real _p_vol = 3.14159*_particle_diameter*_particle_diameter*_particle_diameter/6.0;
    _particle_density = _particle_mass/_p_vol;

    if (_packing_density > _particle_density)
    {
        std::cout << "Packing Density = " << _packing_density << std::endl;
        std::cout << "Particle Density = " << _particle_density << std::endl;
        moose::internal::mooseErrorRaw("Packing density cannot be larger than particle density!");
    }

    _void_fraction = (1.0 - _packing_density/_particle_density);

    if (_void_fraction >= 1)
    {
        _void_fraction = 0.99;
    }
    if (_void_fraction <= 0)
    {
        _void_fraction = 0.01;
    }

    if (_OverrideLimits == false)
    {
        if (_void_fraction > 0.66)
        {
            std::cout << "\n================================= WARNING ===========================================\n";
            std::cout <<   "  Calculated void fraction (" << _void_fraction << ") is above 0.66 theoretical limit\n";
            std::cout <<   "     Value is being automatically reset to 0.66\n";
            std::cout <<   "     To avoid reset, you can set 'override_limits' to 'true' in your input file\n";
            std::cout <<   "         (this is not recommended)\n";
            std::cout << "\n------------------------------------------------------------------------------------\n";
            _void_fraction = 0.66;
        }
        if (_void_fraction < 0.26)
        {
            std::cout << "\n================================= WARNING ===========================================\n";
            std::cout <<   "  Calculated void fraction (" << _void_fraction << ") is below 0.26 theoretical limit\n";
            std::cout <<   "     Value is being automatically reset to 0.26\n";
            std::cout <<   "     To avoid reset, you can set 'override_limits' to 'true' in your input file\n";
            std::cout <<   "         (this is not recommended)\n";
            std::cout << "\n------------------------------------------------------------------------------------\n";
            _void_fraction = 0.26;
        }
    }
}

Real VoidsVolumeFraction::computeValue()
{
      return _void_fraction;
}
