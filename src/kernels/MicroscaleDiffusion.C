/*!
 *  \file MicroscaleDiffusion.h
 *    \brief Custom kernel for diffusion in a fictious microscale.
 *    \details This file creates a custom MOOSE kernel for the diffusion at the microscale
 *              of a fictious mesh. Generally this kernel is to be used in conjunction with other
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

#include "MicroscaleDiffusion.h"

registerMooseObject("catsApp", MicroscaleDiffusion);

InputParameters
MicroscaleDiffusion::validParams()
{
  InputParameters params = Kernel::validParams();
  params.addParam<Real>("diffusion_const", 1.0, "[Global] Diffusion constant in the microscale");
  params.addRequiredParam<Real>("micro_length", "[Global] Total length of the microscale");
  params.addRequiredParam<unsigned int>("node_id", "This variable's node id in the microscale");
  params.addRequiredParam<unsigned int>("num_nodes",
                                        "[Global] Total number of nodes in microscale");
  params.addRequiredParam<unsigned int>(
      "coord_id", "[Global] Enum: 0 = cartesian, 1 = r-cylindrical, 2 = r-spherical");

  params.addRequiredCoupledVar("upper_neighbor", "Variable for upper neigbor");
  params.addRequiredCoupledVar("lower_neighbor", "Variable for lower neighbor");
  return params;
}

MicroscaleDiffusion::MicroscaleDiffusion(const InputParameters & parameters)
  : Kernel(parameters),
    _diff_const(getParam<Real>("diffusion_const")),
    _total_length(getParam<Real>("micro_length")),
    _this_node(getParam<unsigned int>("node_id")),
    _total_nodes(getParam<unsigned int>("num_nodes")),
    _coord_id(getParam<unsigned int>("coord_id")),

    _upper_neighbor(coupledValue("upper_neighbor")),
    _upper_var(coupled("upper_neighbor")),

    _lower_neighbor(coupledValue("lower_neighbor")),
    _lower_var(coupled("lower_neighbor"))
{
  if (_total_length <= 0.0)
  {
    moose::internal::mooseErrorRaw("Length of microscale must be a positive value!");
  }
  if (_coord_id > 2 || _coord_id < 0)
  {
    moose::internal::mooseErrorRaw(
        "Invalid option for coord_id: Pick 0 (cartesian), 1 (cylindrical), or 2 (spherical)");
  }
  if (_this_node < 0 || _this_node > (_total_nodes - 1))
  {
    moose::internal::mooseErrorRaw(
        "This Node id given is beyond limits! ( 0 <= node_id < _total_nodes )");
  }
  _upper_node = _this_node + 1;
  if (_upper_node < 0 || _upper_node > (_total_nodes - 1))
  {
    moose::internal::mooseErrorRaw(
        "Upper Node id calculated is beyond limits! ( 0 <= node_id < _total_nodes )");
  }
  _lower_node = _this_node - 1;
  if (_lower_node < 0 || _lower_node > (int)(_total_nodes - 1))
  {
    moose::internal::mooseErrorRaw(
        "Lower Node id calculated is beyond limits! ( 0 <= node_id < _total_nodes )");
  }
  if (_total_nodes < 2)
  {
    moose::internal::mooseErrorRaw("These microscale kernels require at least 2 nodes!");
  }

  _dr = _total_length / ((double)_total_nodes - 1.0);
  _rl = (double)_this_node * _dr;
  _rd_l = std::pow(_rl, (double)_coord_id);

  _rlp1 = (double)_upper_node * _dr;
  _rd_lp1 = 0.5 * (pow(_rlp1, (double)_coord_id) + _rd_l);

  _rlm1 = (double)_lower_node * _dr;
  _rd_lm1 = 0.5 * (pow(_rlm1, (double)_coord_id) + _rd_l);

  _current_diff = _diff_const;
  _upper_diff = _diff_const;
  _lower_diff = _diff_const;
}

void
MicroscaleDiffusion::calculateFluxes()
{
  Real _avg_upper_diff = 0.5 * (_upper_diff + _current_diff);
  Real _avg_lower_diff = 0.5 * (_lower_diff + _current_diff);
  _flux_upper = (_rd_lp1 * _avg_upper_diff) / _dr / _dr;
  _flux_lower = (_rd_lm1 * _avg_lower_diff) / _dr / _dr;
}

Real
MicroscaleDiffusion::computeQpResidual()
{
  calculateFluxes();
  return _test[_i][_qp] * _flux_upper * (_u[_qp] - _upper_neighbor[_qp]) +
         _test[_i][_qp] * _flux_lower * (_u[_qp] - _lower_neighbor[_qp]);
}

Real
MicroscaleDiffusion::computeQpJacobian()
{
  calculateFluxes();
  return _test[_i][_qp] * _flux_upper * _phi[_j][_qp] +
         _test[_i][_qp] * _flux_lower * _phi[_j][_qp];
}

Real
MicroscaleDiffusion::computeQpOffDiagJacobian(unsigned int jvar)
{
  calculateFluxes();
  if (jvar == _upper_var)
  {
    return -_test[_i][_qp] * _flux_upper * _phi[_j][_qp];
  }
  if (jvar == _lower_var)
  {
    return -_test[_i][_qp] * _flux_lower * _phi[_j][_qp];
  }
  return 0.0;
}
