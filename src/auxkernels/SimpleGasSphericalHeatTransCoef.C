/*!
 *  \file SimpleGasSphericalHeatTransCoef.h
 *    \brief AuxKernel kernel to calculate heat transfer from spherical particles
 *    \details This file is responsible for calculating the heat transfer coefficient
 *              for spherical particles. The gas is assumed an ideal mixture of
 *              mostly O2 and N2. The hydraulic diameter used is the diameter
 *              of the spherical particles.
 *
 *            Ref: S. McAllister, J.Y. Chen, A. Carlos Fernandez-Pello, Fundamentals
 *                    of Combustion Processes. Springer, 2011. Ch. 8, p. 159.
 *
 *
 *  \author Austin Ladshaw
 *  \date 10/13/2021
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

#include "SimpleGasSphericalHeatTransCoef.h"

registerMooseObject("catsApp", SimpleGasSphericalHeatTransCoef);

InputParameters SimpleGasSphericalHeatTransCoef::validParams()
{
    InputParameters params = SimpleGasPropertiesBase::validParams();
    params.addParam< std::string >("output_energy_unit","kJ","Energy units for gas thermal conductivity on output");
    params.addParam< std::string >("output_length_unit","m","Length units for gas thermal conductivity on output");
    params.addParam< std::string >("output_time_unit","s","Time units for gas thermal conductivity on output");
    return params;
}

SimpleGasSphericalHeatTransCoef::SimpleGasSphericalHeatTransCoef(const InputParameters & parameters) :
SimpleGasPropertiesBase(parameters),
_output_energy_unit(getParam<std::string >("output_energy_unit")),
_output_length_unit(getParam<std::string >("output_length_unit")),
_output_time_unit(getParam<std::string >("output_time_unit"))
{

}

Real SimpleGasSphericalHeatTransCoef::computeValue()
{
    //Calculate Re = rho*v*dh/mu
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

    //Calculate Pr = cp*mu/Kg
    // cp [kJ/kg/K] ==> [J/g/K]
    Real Kc = 2.68588E-08;
    Real cmax = 0.3;
    Real cp = 1 + cmax*(Kc*pow(_temperature[_qp],2.5))/(1+Kc*pow(_temperature[_qp],2.5));
    cp = SimpleGasPropertiesBase::energy_conversion(cp, "kJ", "J");
    cp = 1/SimpleGasPropertiesBase::mass_conversion(1/cp, "kg", "g");
    // Kg [J/s/m/K] ==> [J/s/cm/K]
    Real Kg = 2.66E-04*pow(_temperature[_qp],0.805);
    Kg = 1/SimpleGasPropertiesBase::length_conversion(1/Kg, "m", "cm");
    Real Pr = cp*mu/Kg;

    //dh is currently in cm and so is Kg
    //Calculate Nu
    Real Nu = 2 + 0.4*pow(Re,0.5)*pow(Pr,1.0/3.0);
    //h [J/s/cm^2/K] = Kg * Nu / dh
    Real h = Kg*Nu/dh;

    h = SimpleGasPropertiesBase::energy_conversion(h, "J", _output_energy_unit);
    h = 1/SimpleGasPropertiesBase::length_conversion(1/h, "cm", _output_length_unit);
    h = 1/SimpleGasPropertiesBase::length_conversion(1/h, "cm", _output_length_unit);
    h = 1/SimpleGasPropertiesBase::time_conversion(1/h, "s", _output_time_unit);
    return h;
}
