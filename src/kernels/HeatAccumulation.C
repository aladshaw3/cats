/*!
 *  \file HeatAccumulation.h
 *    \brief Kernel to create a time derivative that is linearly dependent on specific heat, porosity, and density
 *    \details This file creates a standard MOOSE kernel that is to be used to coupled another
 *          set of MOOSE variables with the current variable. This is specifically to be used
 *          with temperature time derivatives.
 *
 *  \author Austin Ladshaw
 *    \date 04/28/2020
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

#include "HeatAccumulation.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", HeatAccumulation);

/*
template<>
InputParameters validParams<HeatAccumulation>()
{
    InputParameters params = validParams<CoefTimeDerivative>();
    params.addRequiredCoupledVar("coupled_coef","Variable coefficient for the time derivative");
    return params;
}
 */

InputParameters HeatAccumulation::validParams()
{
    InputParameters params = CoefTimeDerivative::validParams();
    params.addRequiredCoupledVar("specific_heat","Variable for specific heat (J/kg/K)");
    params.addRequiredCoupledVar("porosity","Variable for porosity (-)");
    params.addRequiredCoupledVar("density","Variable for density (kg/m^3)");
    return params;
}

HeatAccumulation::HeatAccumulation(const InputParameters & parameters) :
CoefTimeDerivative(parameters),
_spec_heat(coupledValue("specific_heat")),
_spec_heat_var(coupled("specific_heat")),
_porosity(coupledValue("porosity")),
_porosity_var(coupled("porosity")),
_density(coupledValue("density")),
_density_var(coupled("density"))
{

}

Real HeatAccumulation::computeQpResidual()
{
    _coef = _spec_heat[_qp]*_porosity[_qp]*_density[_qp];
    return CoefTimeDerivative::computeQpResidual();
}

Real HeatAccumulation::computeQpJacobian()
{
    _coef = _spec_heat[_qp]*_porosity[_qp]*_density[_qp];
    return CoefTimeDerivative::computeQpJacobian();
}

Real HeatAccumulation::computeQpOffDiagJacobian(unsigned int jvar)
{
    _coef = _spec_heat[_qp]*_porosity[_qp]*_density[_qp];
    if (jvar == _spec_heat_var)
    {
        return _phi[_j][_qp]*_porosity[_qp]*_density[_qp]*_test[_i][_qp] * _u_dot[_qp];
    }
    if (jvar == _porosity_var)
    {
        return _phi[_j][_qp]*_spec_heat[_qp]*_density[_qp]*_test[_i][_qp] * _u_dot[_qp];
    }
    if (jvar == _density_var)
    {
        return _phi[_j][_qp]*_porosity[_qp]*_spec_heat[_qp]*_test[_i][_qp] * _u_dot[_qp];
    }
    return 0.0;
}
