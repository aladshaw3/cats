/*!
 *  \file MonolithAreaVolumeRatio.h
 *    \brief Auxillary kernel to calculate the area-to-volume ratio of monolith channels
 *    \details This file is responsible for calculating the area-to-volume ratio
 *            for monolith channels based on the bulk channel volume to total volume
 *            ratio for the reactor (i.e., bulk porosity) and the cell density of
 *            the monolith (cells per total face area). Usits on output will be same
 *            unit basis on input.
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

#include "MonolithAreaVolumeRatio.h"

registerMooseObject("catsApp", MonolithAreaVolumeRatio);

InputParameters
MonolithAreaVolumeRatio::validParams()
{
  InputParameters params = AuxKernel::validParams();
  params.addParam<Real>(
      "cell_density", 50, "Cell density of the monolith (# of cells per face area)");
  params.addRequiredCoupledVar("channel_vol_ratio", "Ratio of channel volume to total volume ");
  params.addParam<bool>("per_solids_volume",
                        true,
                        "If true, then ratio is in units of solid area per solid volume. If false, "
                        "then ratio is in solids volume per total volume ");
  return params;
}

MonolithAreaVolumeRatio::MonolithAreaVolumeRatio(const InputParameters & parameters)
  : AuxKernel(parameters),
    _cell_density(getParam<Real>("cell_density")),
    _bulk_porosity(coupledValue("channel_vol_ratio")),
    _PerSolidsVolume(getParam<bool>("per_solids_volume"))
{
}

Real
MonolithAreaVolumeRatio::computeValue()
{
  Real Ac = _bulk_porosity[_qp] / _cell_density;
  Real dc = 2.0 * sqrt((Ac / 3.14159));
  Real ds = sqrt(Ac);
  Real dh = 0.5 * (dc + ds);
  if (_PerSolidsVolume == true)
    return 4.0 * _cell_density * dh / (1 - _bulk_porosity[_qp]);
  else
    return 4.0 * _cell_density * dh;
}
