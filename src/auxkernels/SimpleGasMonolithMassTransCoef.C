/*!
 *  \file SimpleGasMonolithMassTransCoef.h
 *    \brief AuxKernel kernel to calculate mass transfer coefficient for a monolith
 *    \details This file is responsible for calculating the mass transfer coefficient
 *              for a monolith given some simple properties. Calculation is based
 *              off of the Reynolds, Schmidt, and Sherwood numbers for cylindrical
 *              channel spaces. Diffusivities are corrected via an Arrhenius like
 *              expression from a reference diffusivity and reference temperature.
 *              User provides input units for specific parameters and provides
 *              desired unit basis of the calculation of mass transfer.
 *
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

#include "SimpleGasMonolithMassTransCoef.h"

registerMooseObject("catsApp", SimpleGasMonolithMassTransCoef);

InputParameters SimpleGasMonolithMassTransCoef::validParams()
{
    InputParameters params = SimpleGasPropertiesBase::validParams();
    params.addParam< std::string >("output_length_unit","m","Length units for mass transfer on output");
    params.addParam< std::string >("output_time_unit","s","Time units for mass transfer on output");

    return params;
}

SimpleGasMonolithMassTransCoef::SimpleGasMonolithMassTransCoef(const InputParameters & parameters) :
SimpleGasPropertiesBase(parameters),
_output_length_unit(getParam<std::string >("output_length_unit")),
_output_time_unit(getParam<std::string >("output_time_unit"))
{

}

Real SimpleGasMonolithMassTransCoef::computeValue()
{
    // rho [g/cm^3]
    Real rho = _pressure[_qp]*1000/287.058/_temperature[_qp]*1000;
    rho = rho/100/100/100;
    // mu [g/cm/s]
    Real mu = 0.1458*pow(_temperature[_qp],1.5)/(110.4+_temperature[_qp])/10000;
    // Put velocity into cm/s and char length into cm
    Real v = SimpleGasPropertiesBase::length_conversion(_velocity[_qp], _velocity_length_unit, "cm");
    v = 1/SimpleGasPropertiesBase::time_conversion(1/v, _velocity_time_unit, "s");
    Real dh = SimpleGasPropertiesBase::length_conversion(_char_len[_qp], _char_len_unit, "cm");
    Real Re = rho*v*dh/mu;
    // Put diffusivity into cm^2/s
    Real Dm = _ref_diffusivity*exp(-887.5*((1/_temperature[_qp])-(1/_ref_diff_temp)));
    Dm = SimpleGasPropertiesBase::length_conversion(Dm, _diff_length_unit, "cm");
    Dm = SimpleGasPropertiesBase::length_conversion(Dm, _diff_length_unit, "cm");
    Dm = 1/SimpleGasPropertiesBase::time_conversion(1/Dm, _diff_time_unit, "s");
    Real Sc = mu/rho/Dm;
    Real Sh = (0.3+(0.62*sqrt(Re)*pow(Sc,0.33)*pow(1+pow(0.4/Sc,0.67),-0.25))*pow(1+pow(Re/282000,5.0/8.0),4.0/5.0));
    Real Deff = pow(_micro_pore[_qp],_eff_diff_factor)*Dm;

    // ends up in cm/s
    Real km = Sh*Deff/dh;
    km = SimpleGasPropertiesBase::length_conversion(km, "cm", _output_length_unit);
    km = 1/SimpleGasPropertiesBase::time_conversion(1/km, "s", _output_time_unit);

    return km;
}
