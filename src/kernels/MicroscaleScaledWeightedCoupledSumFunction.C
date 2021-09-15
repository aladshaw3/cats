/*!
 *  \file MicroscaleScaledWeightedCoupledSumFunction.h
 *	\brief Microscale kernel for coupling a vector non-linear variables via a weighted summation with scaling
 *	\details This file creates a Microscale version of the ScaledWeightedCoupledSumFunction kernel for the
 *      coupling of a vector non-linear variables together to a variable whose value is to be determined by
 *      those coupled sums with scaling. This kernel is particularly useful if you have a variable that is
 *      a function of several different rate variables (e.g., dq/dt = r1 + 2*r2). In these cases, instead
 *      of rewriting each reaction kernel and redefining all parameters, you create a set of rate variables
 *      (r1, r2, etc), then coupled those rates to other non-linear variables and kernels.
 *
 *  \note The difference between this kernel and the 'WeightedCoupledSumFunction', which it inherits
 *        from, is that this function is multiplied by a common 'scale' variable. Typically, that 'scale'
 *        would be used as a unit conversion between mass balances. For instance, in a series of surface
 *        reaction that impact some bulk concentration, the 'scale' factor applied to all reactions
 *        would be the surface-to-volume ratio or the solids-to-total_volume ratio.
 *
 *  \note This should be used in conjunction with a TimeDerivative or Reaction kernel inside of the
 *        input file to enfore that the variable is the weighted sum of the coupled variables
 *
 *        Reaction kernel ==>   Res(u) = u*test
 *        Coupled Sum     ==>   Res(u) = -scale*(SUM(i, w_i * vars_i))*test
 *
 *  \note This is meant to be used within the Microscale physics system for hybrid FD/FE resolution of
 *        microscale domain. You can use this to more easily add a series of reactions to the microscale
 *        physics for particles and monoliths.
 *
 *  \author Austin Ladshaw
 *	\date 09/15/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
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

#include "MicroscaleScaledWeightedCoupledSumFunction.h"

registerMooseObject("catsApp", MicroscaleScaledWeightedCoupledSumFunction);

InputParameters MicroscaleScaledWeightedCoupledSumFunction::validParams()
{
    InputParameters params = ScaledWeightedCoupledSumFunction::validParams();
    params.addRequiredParam<Real>("micro_length","[Global] Total length of the microscale");
    params.addRequiredParam<unsigned int>("node_id","This variable's node id in the microscale");
    params.addRequiredParam<unsigned int>("num_nodes","[Global] Total number of nodes in microscale");
    params.addRequiredParam<unsigned int>("coord_id","[Global] Enum: 0 = cartesian, 1 = r-cylindrical, 2 = r-spherical");
    return params;
}

MicroscaleScaledWeightedCoupledSumFunction::MicroscaleScaledWeightedCoupledSumFunction(const InputParameters & parameters)
: ScaledWeightedCoupledSumFunction(parameters),
_total_length(getParam<Real>("micro_length")),
_node(getParam<unsigned int>("node_id")),
_total_nodes(getParam<unsigned int>("num_nodes")),
_coord_id(getParam<unsigned int>("coord_id"))
{
    if (_total_length <= 0.0)
    {
        moose::internal::mooseErrorRaw("Length of microscale must be a positive value!");
    }
    if (_coord_id > 2 || _coord_id < 0)
    {
        moose::internal::mooseErrorRaw("Invalid option for coord_id: Pick 0 (cartesian), 1 (cylindrical), or 2 (spherical)");
    }
    if (_node < 0 || _node > (_total_nodes-1))
    {
        moose::internal::mooseErrorRaw("Node id given is beyond limits! ( 0 <= node_id < _total_nodes )");
    }
    if (_total_nodes < 2)
    {
        moose::internal::mooseErrorRaw("These microscale kernels require at least 2 nodes!");
    }

    _dr = _total_length / ((double)_total_nodes - 1.0);
    _rl = (double)_node * _dr;
    _rd_l = std::pow(_rl, (double)_coord_id);
}

Real MicroscaleScaledWeightedCoupledSumFunction::computeQpResidual()
{
    return _rd_l*ScaledWeightedCoupledSumFunction::computeQpResidual();
}

Real MicroscaleScaledWeightedCoupledSumFunction::computeQpJacobian()
{
    return _rd_l*ScaledWeightedCoupledSumFunction::computeQpJacobian();
}

Real MicroscaleScaledWeightedCoupledSumFunction::computeQpOffDiagJacobian(unsigned int jvar)
{
    return _rd_l*ScaledWeightedCoupledSumFunction::computeQpOffDiagJacobian(jvar);
}
