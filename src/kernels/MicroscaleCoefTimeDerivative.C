/*!
 *  \file MicroscaleCoefTimeDerivative.h
 *    \brief Custom kernel for time derivatives in a fictious microscale.
 *    \details This file creates a custom MOOSE kernel for the time derivative at the microscale
 *              of a fictious mesh. Generally this kernel is to be used in conjunction with other
 *              Microscale kernels for mass transfer, diffusion on the microscale, or reactions.
 *
 *  \author Austin Ladshaw
 *    \date 04/16/2020
 *    \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "MicroscaleCoefTimeDerivative.h"

registerMooseObject("catsApp", MicroscaleCoefTimeDerivative);

InputParameters MicroscaleCoefTimeDerivative::validParams()
{
    InputParameters params = TimeDerivative::validParams();
    params.addParam<Real>("nodal_time_coef",1.0,"Time coefficient at the current node in the microscale");
    params.addRequiredParam<Real>("micro_length","[Global] Total length of the microscale");
    params.addRequiredParam<unsigned int>("node_id","This variable's node id in the microscale");
    params.addRequiredParam<unsigned int>("num_nodes","[Global] Total number of nodes in microscale");
    params.addRequiredParam<unsigned int>("coord_id","[Global] Enum: 0 = cartesian, 1 = r-cylindrical, 2 = r-spherical");
    return params;
}

MicroscaleCoefTimeDerivative::MicroscaleCoefTimeDerivative(const InputParameters & parameters)
: TimeDerivative(parameters),
_nodal_time_coef(getParam<Real>("nodal_time_coef")),
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

Real MicroscaleCoefTimeDerivative::computeQpResidual()
{
    return _rd_l*_nodal_time_coef*TimeDerivative::computeQpResidual();
}

Real MicroscaleCoefTimeDerivative::computeQpJacobian()
{
    return _rd_l*_nodal_time_coef*TimeDerivative::computeQpJacobian();
}
