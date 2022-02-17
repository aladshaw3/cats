/*!
 *  \file MonolithHydraulicDiameter.h
 *    \brief Auxillary kernel to calculate the hydraulic diameter for the monolith
 *    \details This file is responsible for calculating the hydraulic diameter for
 *              the monolith. This value may not be used on its own, but will likely
 *              be used in conjunction with other properties (such as film mass transfer
 *              or diffusion rates).
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

#include "MonolithHydraulicDiameter.h"

registerMooseObject("catsApp", MonolithHydraulicDiameter);

InputParameters MonolithHydraulicDiameter::validParams()
{
    InputParameters params = AuxKernel::validParams();
    params.addParam<Real>("cell_density",50,"Cell density of the monolith (# of cells per face area)");
    params.addRequiredCoupledVar("channel_vol_ratio","Ratio of channel volume to total volume ");
    return params;
}

MonolithHydraulicDiameter::MonolithHydraulicDiameter(const InputParameters & parameters) :
AuxKernel(parameters),
_cell_density(getParam<Real>("cell_density")),
_bulk_porosity(coupledValue("channel_vol_ratio"))
{

}

Real MonolithHydraulicDiameter::computeValue()
{
    Real Ac = _bulk_porosity[_qp]/_cell_density;
    Real dc = 2.0*sqrt((Ac/3.14159));
    Real ds = sqrt(Ac);
    Real dh = 0.5*(dc+ds);
    return dh;
}
