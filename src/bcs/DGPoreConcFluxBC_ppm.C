/*!
 *  \file DGPoreConcFluxBC_ppm.h
 *    \brief Boundary Condition kernel for the flux  across a boundary of the domain with a ppm input value
 *    \details This file creates a generic boundary condition kernel for the flux of matter accross
 *            a boundary. The flux is based on a velocity vector, as well as domain porosity, and is valid
 *            in all directions and all boundaries of a DG method. Since the DG method's flux boundary
 *            conditions are essitially the same for input and ouput boundaries, this kernel will check
 *            the sign of the flux normal to the boundary and determine automattically whether it is
 *            an output or input boundary, then apply the appropriate conditions.
 *
 *           Concentration will be converted from an inlet ppm value to molarity (either per L or per m^3).
 *            Conversions will assume ideal gas conditions.
 *
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic equations:
 *                    Theory and Implementation, SIAM, Houston, TX, 2008.
 *
 *
 *  \author Austin Ladshaw
 *    \date 08/04/2021
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

#include "DGPoreConcFluxBC_ppm.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", DGPoreConcFluxBC_ppm);

InputParameters DGPoreConcFluxBC_ppm::validParams()
{
    InputParameters params = DGPoreConcFluxBC::validParams();
    params.addRequiredCoupledVar("temperature","Variable for the phase temperature (K)");
    params.addCoupledVar("pressure",101.35,"Variable for the gas pressure (kPa)");
    params.addParam<Real>("inlet_ppm", 0.0, "input value of variable in ppm");
    return params;
}

DGPoreConcFluxBC_ppm::DGPoreConcFluxBC_ppm(const InputParameters & parameters) :
DGPoreConcFluxBC(parameters),
_temp(coupledValue("temperature")),
_temp_var(coupled("temperature")),
_press(coupledValue("pressure")),
_press_var(coupled("pressure")),
_u_input_ppm(getParam<Real>("inlet_ppm"))
{
    _R = Rstd;
}

Real DGPoreConcFluxBC_ppm::computeQpResidual()
{
    _u_input = _press[_qp]*(_u_input_ppm/1e6)/_R/_temp[_qp];
    return DGPoreConcFluxBC::computeQpResidual();
}

Real DGPoreConcFluxBC_ppm::computeQpJacobian()
{
    _u_input = _press[_qp]*(_u_input_ppm/1e6)/_R/_temp[_qp];
    return DGPoreConcFluxBC::computeQpJacobian();
}

Real DGPoreConcFluxBC_ppm::computeQpOffDiagJacobian(unsigned int jvar)
{
    _u_input = _press[_qp]*(_u_input_ppm/1e6)/_R/_temp[_qp];
    if (jvar != _temp_var && jvar != _press_var)
      return DGPoreConcFluxBC::computeQpOffDiagJacobian(jvar);
    else
    {
      return 0;
    }
}
