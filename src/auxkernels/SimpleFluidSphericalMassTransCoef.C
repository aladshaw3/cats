/*!
 *  \file SimpleFluidSphericalMassTransCoef.h
 *    \brief AuxKernel kernel to calculate mass transfer coefficient for a sphere
 *    \details This file is responsible for calculating the mass transfer coefficient
 *              for spherical domains given some simple properties. Calculation is based
 *              off of the Reynolds, Schmidt, and Sherwood numbers for spherical
 *              surfaces. Diffusivities are corrected via an Arrhenius like
 *              expression from a reference diffusivity and reference temperature.
 *              User provides input units for specific parameters and provides
 *              desired unit basis of the calculation of mass transfer.
 *
 *
 *  \author Austin Ladshaw
 *  \date 02/24/2022
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

 #include "SimpleFluidSphericalMassTransCoef.h"

 registerMooseObject("catsApp", SimpleFluidSphericalMassTransCoef);

 InputParameters SimpleFluidSphericalMassTransCoef::validParams()
 {
     InputParameters params = SimpleFluidPropertiesBase::validParams();
     params.addParam< std::string >("output_length_unit","m","Length units for mass transfer on output");
     params.addParam< std::string >("output_time_unit","s","Time units for mass transfer on output");

     return params;
 }

 SimpleFluidSphericalMassTransCoef::SimpleFluidSphericalMassTransCoef(const InputParameters & parameters) :
 SimpleFluidPropertiesBase(parameters),
 _output_length_unit(getParam<std::string >("output_length_unit")),
 _output_time_unit(getParam<std::string >("output_time_unit"))
 {

 }

 Real SimpleFluidSphericalMassTransCoef::computeValue()
 {
     Real Re = SimpleFluidPropertiesBase::reynolds_number();
     Real Sc = SimpleFluidPropertiesBase::schmidt_number();
     Real Sh = (2+(0.4*sqrt(Re)+0.06*pow(Re,0.67))*pow(Sc,0.4));

     Real L = SimpleFluidPropertiesBase::length_conversion(_char_len[_qp], _char_len_unit, _output_length_unit);

     Real Deff = SimpleFluidPropertiesBase::effective_molecular_diffusion(_temperature[_qp], _macro_pore[_qp]);
     Deff = SimpleFluidPropertiesBase::length_conversion(Deff, _diff_length_unit, _output_length_unit);
     Deff = SimpleFluidPropertiesBase::length_conversion(Deff, _diff_length_unit, _output_length_unit);
     Deff = 1/SimpleFluidPropertiesBase::time_conversion(1/Deff, _diff_time_unit, _output_time_unit);

     Real km = Sh*Deff/L;
     km = SimpleFluidPropertiesBase::length_conversion(km, "cm", _output_length_unit);
     km = 1/SimpleFluidPropertiesBase::time_conversion(1/km, "s", _output_time_unit);
     return km;
 }
