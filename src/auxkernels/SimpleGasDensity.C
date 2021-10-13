/*!
 *  \file SimpleGasDensity.h
 *    \brief AuxKernel kernel to calculate density of air
 *    \details This file is responsible for calculating the density of air by
 *            assuming an ideal gas of mostly O2 and N2 (i.e., standard air)
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

#include "SimpleGasDensity.h"

registerMooseObject("catsApp", SimpleGasDensity);

InputParameters SimpleGasDensity::validParams()
{
    InputParameters params = SimpleGasPropertiesBase::validParams();
    params.addParam< std::string >("output_length_unit","m","Length units for gas density on output");
    params.addParam< std::string >("output_mass_unit","kg","Mass units for gas density on output");

    return params;
}

SimpleGasDensity::SimpleGasDensity(const InputParameters & parameters) :
SimpleGasPropertiesBase(parameters),
_output_length_unit(getParam<std::string >("output_length_unit")),
_output_mass_unit(getParam<std::string >("output_mass_unit"))
{

}

Real SimpleGasDensity::computeValue()
{
    // rho [g/cm^3]
    Real rho = _pressure[_qp]*1000/287.058/_temperature[_qp]*1000;
    rho = rho/100/100/100;
    rho = 1/SimpleGasPropertiesBase::length_conversion(1/rho, "cm", _output_length_unit);
    rho = 1/SimpleGasPropertiesBase::length_conversion(1/rho, "cm", _output_length_unit);
    rho = 1/SimpleGasPropertiesBase::length_conversion(1/rho, "cm", _output_length_unit);
    rho = SimpleGasPropertiesBase::mass_conversion(rho, "g", _output_mass_unit);
    return rho;
}
