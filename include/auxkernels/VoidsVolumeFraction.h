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

#pragma once

#include "AuxKernel.h"

/// VoidsVolumeFraction class inherits from AuxKernel
class VoidsVolumeFraction : public AuxKernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Standard MOOSE public constructor
    VoidsVolumeFraction(const InputParameters & parameters);

protected:
    /// Required MOOSE function override
    virtual Real computeValue() override;

private:
    Real _particle_diameter;        ///< Average diameter of the particle for which the ratio is calculated (L)
    Real _particle_mass;            ///< Average mass of the particle for which the ratio is calculated (M)
    Real _packing_density;          ///< Average packing density of the particles in the bed (M/L^3)
    Real _particle_density;         ///< Calculated particle density
    bool _OverrideLimits;           ///< Boolean to determine whether or not to override value bounds
    Real _void_fraction;         ///< Calculated particle density

};
