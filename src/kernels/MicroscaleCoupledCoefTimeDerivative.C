/*!
 *  \file MicroscaleCoupledCoefTimeDerivative.h
 *    \brief Custom kernel for coupling time derivatives in a fictious microscale.
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

#include "MicroscaleCoupledCoefTimeDerivative.h"

registerMooseObject("catsApp", MicroscaleCoupledCoefTimeDerivative);

/*
template<>
InputParameters validParams<MicroscaleCoupledCoefTimeDerivative>()
{
    InputParameters params = validParams<Kernel>();
    params.addParam<Real>("nodal_time_coef",1.0,"Time coefficient at the current node in the microscale");
    params.addRequiredParam<Real>("micro_length","[Global] Total length of the microscale");
    params.addRequiredParam<unsigned int>("node_id","This variable's node id in the microscale");
    params.addRequiredParam<unsigned int>("num_nodes","[Global] Total number of nodes in microscale");
    params.addRequiredParam<unsigned int>("coord_id","[Global] Enum: 0 = cartesian, 1 = r-cylindrical, 2 = r-spherical");
    params.addRequiredCoupledVar("coupled_at_node","Name of the variable being coupled at the given microscale node");
    return params;
}
 */

InputParameters MicroscaleCoupledCoefTimeDerivative::validParams()
{
    InputParameters params = Kernel::validParams();
    params.addParam<Real>("nodal_time_coef",1.0,"Time coefficient at the current node in the microscale");
    params.addRequiredParam<Real>("micro_length","[Global] Total length of the microscale");
    params.addRequiredParam<unsigned int>("node_id","This variable's node id in the microscale");
    params.addRequiredParam<unsigned int>("num_nodes","[Global] Total number of nodes in microscale");
    params.addRequiredParam<unsigned int>("coord_id","[Global] Enum: 0 = cartesian, 1 = r-cylindrical, 2 = r-spherical");
    params.addRequiredCoupledVar("coupled_at_node","Name of the variable being coupled at the given microscale node");
    return params;
}

MicroscaleCoupledCoefTimeDerivative::MicroscaleCoupledCoefTimeDerivative(const InputParameters & parameters)
: Kernel(parameters),
_nodal_time_coef(getParam<Real>("nodal_time_coef")),
_total_length(getParam<Real>("micro_length")),
_node(getParam<unsigned int>("node_id")),
_total_nodes(getParam<unsigned int>("num_nodes")),
_coord_id(getParam<unsigned int>("coord_id")),
_coupled_dot(coupledDot("coupled_at_node")),
_coupled_ddot(coupledDotDu("coupled_at_node")),
_coupled_var(coupled("coupled_at_node"))
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

Real MicroscaleCoupledCoefTimeDerivative::computeQpResidual()
{
    return _rd_l*_nodal_time_coef*_coupled_dot[_qp]*_test[_i][_qp];
}

Real MicroscaleCoupledCoefTimeDerivative::computeQpJacobian()
{
    return 0.0;
}

Real MicroscaleCoupledCoefTimeDerivative::computeQpOffDiagJacobian(unsigned int jvar)
{
    if (jvar == _coupled_var)
        return _rd_l*_nodal_time_coef*_test[_i][_qp] * _phi[_j][_qp] * _coupled_ddot[_qp];
    
    return 0.0;
}

