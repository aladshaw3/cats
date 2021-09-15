/*!
 *  \file SphericalAreaVolumeRatio.h
 *    \brief Auxillary kernel to calculate the area-to-volume ratio of spherical particles
 *    \details This file is responsible for calculating the area-to-volume ratio
 *            for spherical particles of a particular size. The purpose is to have
 *            these values automatically calculated for usage in the 'FilmMassTransfer'
 *            or similar mass or energy transfer functions.
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

#include "SphericalAreaVolumeRatio.h"

registerMooseObject("catsApp", SphericalAreaVolumeRatio);

InputParameters SphericalAreaVolumeRatio::validParams()
{
    InputParameters params = AuxKernel::validParams();
    params.addParam<Real>("particle_diameter",1,"Diameter of the particles for ratio calculation");
    params.addCoupledVar("porosity",0.5,"Ratio of bulk voids volume to total volume (e.g., bulk porosity)");
    params.addParam<bool>("per_solids_volume",true,"If true, then ratio is in units of solid area per solid volume. If false, then ratio is in solids volume per total volume ");
    return params;
}

SphericalAreaVolumeRatio::SphericalAreaVolumeRatio(const InputParameters & parameters) :
AuxKernel(parameters),
_particle_diameter(getParam<Real>("particle_diameter")),
_bulk_porosity(coupledValue("porosity")),
_PerSolidsVolume(getParam<bool>("per_solids_volume"))
{

}

Real SphericalAreaVolumeRatio::computeValue()
{
  if (_PerSolidsVolume == true)
    return 6.0/_particle_diameter;
  else
    return (6.0/_particle_diameter)*(1.0-_bulk_porosity[_qp]);
}
