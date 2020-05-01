/*!
 *  \file DGWallHeatFluxBC.h
 *    \brief Boundary Condition kernel to for heat flux caused by a wall
 *    \details This file creates a boundary condition kernel to account for heat loss or
 *          gained from a wall. The user must supply a coupled variable for the
 *          heat transfer coefficient at the wall. The wall temperature is assumed constant
 *          in this case. Inherit from this kernel to add variable wall temperature.
 *
 *    \author Austin Ladshaw
 *    \date 04/29/2020
 *    \copyright This kernel was designed and built at the Georgia Institute
 *             of Technology by Austin Ladshaw for PhD research in the area
 *             of adsorption and surface science and was developed for use
 *               by Idaho National Laboratory and Oak Ridge National Laboratory
 *               engineers and scientists. Portions Copyright (c) 2015, all
 *             rights reserved.
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

#include "DGWallHeatFluxBC.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", DGWallHeatFluxBC);

InputParameters DGWallHeatFluxBC::validParams()
{
    InputParameters params = IntegratedBC::validParams();
    params.addRequiredCoupledVar("hw","Variable for heat transfer coefficient");
    params.addParam<Real>("u_input", 1.0, "input value of for the temperature variable");
    return params;
}

DGWallHeatFluxBC::DGWallHeatFluxBC(const InputParameters & parameters) :
IntegratedBC(parameters),
_hw(coupledValue("hw")),
_hw_var(coupled("hw")),
_u_input(getParam<Real>("u_input"))
{

}

Real DGWallHeatFluxBC::computeQpResidual()
{
    return _test[_i][_qp]*_hw[_qp]*(_u[_qp] - _u_input);
}

Real DGWallHeatFluxBC::computeQpJacobian()
{
    return _test[_i][_qp]*_hw[_qp]*_phi[_j][_qp];
}

Real DGWallHeatFluxBC::computeQpOffDiagJacobian(unsigned int jvar)
{
    if (jvar == _hw_var)
    {
        return _test[_i][_qp]*_phi[_j][_qp]*(_u[_qp] - _u_input);
    }
    
    return 0.0;
}
