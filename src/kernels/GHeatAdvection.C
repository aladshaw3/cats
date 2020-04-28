/*!
 *  \file GHeatAdvection.h
 *    \brief Kernel for use with the corresponding DGHeatAdvection object
 *    \details This file creates a standard MOOSE kernel that is to be used in conjunction with DGHeatAdvection
 *            for the discontinous Galerkin formulation of advection in MOOSE. In order to complete the DG
 *            formulation of the heat advective physics, this kernel must be utilized with every variable that also uses
 *            the DGHeatAdvection kernel.
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

#include "GHeatAdvection.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", GHeatAdvection);

/*
template<>
InputParameters validParams<GHeatAdvection>()
{
    InputParameters params = validParams<GConcentrationAdvection>();
    params.addRequiredCoupledVar("porosity","Variable for the porosity of the domain/subdomain");
    return params;
}
 */

InputParameters GHeatAdvection::validParams()
{
    InputParameters params = GConcentrationAdvection::validParams();
    params.addRequiredCoupledVar("specific_heat","Variable for specific heat (J/kg/K)");
    params.addRequiredCoupledVar("porosity","Variable for porosity (-)");
    params.addRequiredCoupledVar("density","Variable for density (kg/m^3)");
    return params;
}

GHeatAdvection::GHeatAdvection(const InputParameters & parameters) :
GConcentrationAdvection(parameters),
_spec_heat(coupledValue("specific_heat")),
_spec_heat_var(coupled("specific_heat")),
_porosity(coupledValue("porosity")),
_porosity_var(coupled("porosity")),
_density(coupledValue("density")),
_density_var(coupled("density"))
{

}

Real GHeatAdvection::computeQpResidual()
{
    _velocity(0)=_ux[_qp];
    _velocity(1)=_uy[_qp];
    _velocity(2)=_uz[_qp];

    return GAdvection::computeQpResidual()*_spec_heat[_qp]*_porosity[_qp]*_density[_qp];
}

Real GHeatAdvection::computeQpJacobian()
{
    _velocity(0)=_ux[_qp];
    _velocity(1)=_uy[_qp];
    _velocity(2)=_uz[_qp];

    return GAdvection::computeQpJacobian()*_spec_heat[_qp]*_porosity[_qp]*_density[_qp];
}

Real GHeatAdvection::computeQpOffDiagJacobian(unsigned int jvar)
{
    _velocity(0)=_ux[_qp];
    _velocity(1)=_uy[_qp];
    _velocity(2)=_uz[_qp];

    if (jvar == _ux_var)
    {
        return -_u[_qp]*(_phi[_j][_qp]*_grad_test[_i][_qp](0))*_spec_heat[_qp]*_porosity[_qp]*_density[_qp];
    }

    if (jvar == _uy_var)
    {
        return -_u[_qp]*(_phi[_j][_qp]*_grad_test[_i][_qp](1))*_spec_heat[_qp]*_porosity[_qp]*_density[_qp];
    }

    if (jvar == _uz_var)
    {
        return -_u[_qp]*(_phi[_j][_qp]*_grad_test[_i][_qp](2))*_spec_heat[_qp]*_porosity[_qp]*_density[_qp];
    }

    if (jvar == _porosity_var)
    {
      return -_u[_qp]*(_velocity*_grad_test[_i][_qp])*_phi[_j][_qp]*_spec_heat[_qp]*_density[_qp];
    }
    
    if (jvar == _spec_heat_var)
    {
        return -_u[_qp]*(_velocity*_grad_test[_i][_qp])*_phi[_j][_qp]*_porosity[_qp]*_density[_qp];
    }
    
    if (jvar == _density_var)
    {
        return -_u[_qp]*(_velocity*_grad_test[_i][_qp])*_phi[_j][_qp]*_porosity[_qp]*_spec_heat[_qp];
    }

    return 0.0;
}

