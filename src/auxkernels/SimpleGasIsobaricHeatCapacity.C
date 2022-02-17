/*!
 *  \file SimpleGasIsobaricHeatCapacity.h
 *    \brief AuxKernel kernel to calculate heat capacity (at constant pressure) of air
 *    \details This file is responsible for calculating the isobaric heat capacity
 *            of air assuming that the air is an ideal gas composed primarily of
 *            N2 and O2. An emperical formula is used to calculate this heat
 *            capacity as a function of gas temperature. This estimate is good
 *            between 1 to 20 bar of pressure (up to ~ 20 atm) and between
 *            -50 and 1600 oC for standard air.
 *
 *            Ref: Engineering ToolBox, (2004). Air - Specific Heat vs. Temperature
 *                    and Constant Pressure. [online] Available at: https://www.
 *                    engineeringtoolbox.com/air-specific-heat-capacity-d_705.html
 *                    [Accessed 13 Oct. 2021].
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

#include "SimpleGasIsobaricHeatCapacity.h"

registerMooseObject("catsApp", SimpleGasIsobaricHeatCapacity);

InputParameters SimpleGasIsobaricHeatCapacity::validParams()
{
    InputParameters params = SimpleGasPropertiesBase::validParams();
    params.addParam< std::string >("output_energy_unit","kJ","Energy units for gas heat capacity on output");
    params.addParam< std::string >("output_mass_unit","kg","Mass units for gas heat capacity on output");

    return params;
}

SimpleGasIsobaricHeatCapacity::SimpleGasIsobaricHeatCapacity(const InputParameters & parameters) :
SimpleGasPropertiesBase(parameters),
_output_energy_unit(getParam<std::string >("output_energy_unit")),
_output_mass_unit(getParam<std::string >("output_mass_unit"))
{

}

Real SimpleGasIsobaricHeatCapacity::computeValue()
{
    // cp [kJ/kg/K]
    Real Kc = 2.68588E-08;
    Real cmax = 0.3;
    Real cp = 1 + cmax*(Kc*pow(_temperature[_qp],2.5))/(1+Kc*pow(_temperature[_qp],2.5));
    cp = SimpleGasPropertiesBase::energy_conversion(cp, "kJ", _output_energy_unit);
    cp = 1/SimpleGasPropertiesBase::mass_conversion(1/cp, "kg", _output_mass_unit);
    return cp;
}
