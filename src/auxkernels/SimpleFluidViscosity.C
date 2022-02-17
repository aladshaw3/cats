/*!
 *  \file SimpleFluidViscosity.h
 *    \brief AuxKernel kernel to calculate viscosity of a liquid (default = water)
 *    \details This file is responsible for calculating the viscosity of a liquid by
 *            using an emperical relationship (see SimpleFluidPropertiesBase for
 *            more details). User can specify if they want a pressure unit basis
 *            or a mass unit basis on output.
 *
 *            Pressure Basis:   [Pressure * Time]
 *            Mass Basis:       [Mass / Length / Time]
 *
 *
 *  \author Austin Ladshaw
 *  \date 12/13/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "SimpleFluidViscosity.h"

registerMooseObject("catsApp", SimpleFluidViscosity);

InputParameters SimpleFluidViscosity::validParams()
{
    InputParameters params = SimpleFluidPropertiesBase::validParams();
    params.addParam< std::string >("output_length_unit","m","Length units for fluid viscosity on output");
    params.addParam< std::string >("output_mass_unit","kg","Mass units for fluid viscosity on output");
    params.addParam< std::string >("output_time_unit","s","Time units for fluid viscosity on output");

    params.addParam< std::string >("output_pressure_unit","kPa","Pressure units for fluid viscosity on output");

    MooseEnum unitBasis("pressure mass", "pressure");
    params.addParam<MooseEnum>("unit_basis", unitBasis, "Unit basis options: pressure, mass");

    return params;
}

SimpleFluidViscosity::SimpleFluidViscosity(const InputParameters & parameters) :
SimpleFluidPropertiesBase(parameters),
_output_length_unit(getParam<std::string >("output_length_unit")),
_output_mass_unit(getParam<std::string >("output_mass_unit")),
_output_time_unit(getParam<std::string >("output_time_unit")),
_output_pressure_unit(getParam<std::string >("output_pressure_unit")),
_output_basis(getParam<MooseEnum>("unit_basis"))
{

}

Real SimpleFluidViscosity::computeValue()
{
    Real mu = SimpleFluidPropertiesBase::fluid_viscosity(_temperature[_qp]);
    switch (_output_basis)
  	{
  		//pressure
  		case 0:
  			mu = SimpleFluidPropertiesBase::pressure_conversion(mu, _mu_pressure_unit, _output_pressure_unit);
        mu = SimpleFluidPropertiesBase::time_conversion(mu, _mu_time_unit, _output_time_unit);
  			break;

  		//mass
  		case 1:
        mu = SimpleFluidPropertiesBase::pressure_conversion(mu, _mu_pressure_unit, "mPa");
        mu = SimpleFluidPropertiesBase::time_conversion(mu, _mu_time_unit, "s");
        // 1 mPa*s = 1 g/m/s
        mu = 1/SimpleFluidPropertiesBase::length_conversion(1/mu, "m", _output_length_unit);
        mu = 1/SimpleFluidPropertiesBase::time_conversion(1/mu, "s", _output_time_unit);
        mu = SimpleFluidPropertiesBase::mass_conversion(mu, "g", _output_mass_unit);
  			break;
  	}
    return mu;
}
