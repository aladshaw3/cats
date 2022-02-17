/*!
 *  \file MonolithMicroscaleTotalThickness.h
 *    \brief Auxillary kernel to calculate the 1D microscale thickness for monoliths
 *    \details This file is responsible for calculating the effective 1D thickness
 *              for monoliths to be used in the Microscale set of kernels to resolve
 *              the intralayer diffusion equations using the hybrid FD/FE method
 *              of CATS. It should be noted that this is an effective thickness
 *              and not a true thickness. This effective thickness needs to be
 *              used to help account for diffusion in all walls and corners. However,
 *              due to how the Microscale kernels are implemented, you cannot
 *              automatically integrate this calculation into those kernels yet. Also,
 *              the units you get from this kernel will align with the units you
 *              give on input (i.e., if your cell density is in units of # cells
 *              per cm^2, then the thickness will be in cm).
 *
 *  \note The 'micro_length' parameter for Microscale kernels is implemented as a
 *        Param and not a Var. This is because you cannot place Vars in the
 *        [GlobalParams] block of an input file. Changing this convention would
 *        require a substaintial redesign of the user interface for Microscale
 *        kernels, which is why this change is not being made. User's who wish
 *        to use the Microscale kernels for a monolith domain should first
 *        calculate this value in a separate input file, then use that calculated
 *        value as the 'micro_length' Param in [GlobalParams] for evaluation of
 *        Microscale kinetics for monoliths.
 *
 *
 *  \author Austin Ladshaw
 *  \date 09/16/2021
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "MonolithMicroscaleTotalThickness.h"

registerMooseObject("catsApp", MonolithMicroscaleTotalThickness);

InputParameters MonolithMicroscaleTotalThickness::validParams()
{
    InputParameters params = AuxKernel::validParams();
    params.addParam<Real>("cell_density",50,"Cell density of the monolith (# of cells per face area)");
    params.addRequiredCoupledVar("channel_vol_ratio","Ratio of channel volume to total volume ");
    params.addParam<Real>("wall_factor",1.0,"Factor applied to thickness to represent how many walls you want to divide the thickness into. NOTE: Default = 1 (total thickness). If you give actual number of walls, then this represents a single wall thickness");
    return params;
}

MonolithMicroscaleTotalThickness::MonolithMicroscaleTotalThickness(const InputParameters & parameters) :
AuxKernel(parameters),
_cell_density(getParam<Real>("cell_density")),
_bulk_porosity(coupledValue("channel_vol_ratio")),
_wall_factor(getParam<Real>("wall_factor"))
{
    if (_wall_factor < 1.0)
      _wall_factor = 1.0;
}

Real MonolithMicroscaleTotalThickness::computeValue()
{
    Real Ac = _bulk_porosity[_qp]/_cell_density;
    Real dc = 2.0*sqrt((Ac/3.14159));
    Real ds = sqrt(Ac);
    Real dh = 0.5*(dc+ds);
    Real A1c = 1.0/_cell_density;
    Real wt = sqrt(A1c - dh*dh);
    return wt/_wall_factor;
}
