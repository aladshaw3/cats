/*!
 *  \file MicroscaleIntegralTotal.h
 *    \brief Custom auxkernel for integrating a series of microscale variables over the fictious
 * microscale space \details This file creates a custom MOOSE kernel for the diffusion at the
 * microscale of a fictious mesh. Generally this kernel is to be used in conjunction with other
 *              Microscale kernels for mass transfer, time derivatives on the microscale, or
 * reactions.
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

#include "MicroscaleIntegralTotal.h"

registerMooseObject("catsApp", MicroscaleIntegralTotal);

InputParameters
MicroscaleIntegralTotal::validParams()
{
  InputParameters params = AuxKernel::validParams();
  params.addParam<Real>("space_factor",
                        1.0,
                        "if coord_id = 0, then this is x-sec area, if coord_id = 1, then this is "
                        "cylinder length, if coord_id = 2, then this is 1.0");
  params.addRequiredParam<Real>("micro_length", "[Global] Total length of the microscale");
  params.addRequiredParam<unsigned int>("num_nodes",
                                        "[Global] Total number of nodes in microscale");
  params.addRequiredParam<unsigned int>(
      "coord_id", "[Global] Enum: 0 = cartesian, 1 = r-cylindrical, 2 = r-spherical");
  params.addRequiredCoupledVar("micro_vars", "List of names of the microscale variables");
  params.addRequiredParam<unsigned int>(
      "first_node",
      "Node id for the first micro_var in the above list. WARNING: The micro_vars list must be in "
      "asscending order!!!");
  return params;
}

MicroscaleIntegralTotal::MicroscaleIntegralTotal(const InputParameters & parameters)
  : AuxKernel(parameters),
    _space_factor(getParam<Real>("space_factor")),
    _total_length(getParam<Real>("micro_length")),
    _total_nodes(getParam<unsigned int>("num_nodes")),
    _coord_id(getParam<unsigned int>("coord_id")),
    _first_node(getParam<unsigned int>("first_node"))
{
  unsigned int n = coupledComponents("micro_vars");
  _vars.resize(n);

  for (unsigned int i = 0; i < _vars.size(); ++i)
  {
    _vars[i] = &coupledValue("micro_vars", i);
  }

  if (_total_length <= 0.0)
  {
    moose::internal::mooseErrorRaw("Length of microscale must be a positive value!");
  }
  if (_coord_id > 2 || _coord_id < 0)
  {
    moose::internal::mooseErrorRaw(
        "Invalid option for coord_id: Pick 0 (cartesian), 1 (cylindrical), or 2 (spherical)");
  }
  if (_first_node < 0 || _first_node > _total_nodes)
  {
    moose::internal::mooseErrorRaw(
        "This Node id given is beyond limits! ( 0 <= node_id < _total_nodes )");
  }
  if (_total_nodes < 2)
  {
    moose::internal::mooseErrorRaw("These microscale kernels require at least 2 nodes!");
  }
  if (_vars.size() != _total_nodes - _first_node)
  {
    moose::internal::mooseErrorRaw(
        "Number of nodes to integrate over do not match number of variables given!");
  }

  _dr = _total_length / ((double)_total_nodes - 1.0);
}

Real
MicroscaleIntegralTotal::computeIntegral()
{
  Real total = 0.0;
  int l = _first_node;
  for (unsigned int i = 0; i < _vars.size() - 1; ++i)
  {
    total += 0.5 * ((*_vars[i])[_qp] + (*_vars[i + 1])[_qp]) *
             (std::pow((double)(l + 1), (double)(_coord_id + 1)) -
              std::pow((double)(l), (double)(_coord_id + 1)));
    l++;
  }

  Real integral = total * std::pow(_dr, (double)(_coord_id + 1));

  if (_coord_id == 0)
  {
    integral = integral * _space_factor;
  }
  else if (_coord_id == 1)
  {
    integral = integral * _space_factor * M_PI;
  }
  else
  {
    integral = integral * (4.0 / 3.0) * M_PI;
  }
  return integral;
}

Real
MicroscaleIntegralTotal::computeValue()
{
  return computeIntegral();
}
