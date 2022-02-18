/*!
 *  \file SimpleGasVolumeFractionToConcentration.h
 *    \brief AuxKernel kernel to calculate a gas concentration from a volume fraction
 *    \details This file is responsible for calculating the concentration of a gas
 *            species as a function of gas temperature and pressure. User's may
 *            provide volume fraction in %, ppm, or ppb. Then the gas concentration
 *            can be calculated in mol/L, mol/cm^3, mol/m^3, mol/mL, etc. (any of
 *            the available volumes in SimpleGasPropertiesBase).
 *
 *
 *  \author Austin Ladshaw
 *  \date 02/18/2022
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

 #include "SimpleGasVolumeFractionToConcentration.h"

 registerMooseObject("catsApp", SimpleGasVolumeFractionToConcentration);

 InputParameters SimpleGasVolumeFractionToConcentration::validParams()
 {
     InputParameters params = SimpleGasPropertiesBase::validParams();
     params.addParam< std::string >("output_volume_unit","L","Volume units for gas concentration on output");
     params.addParam< std::string >("input_volfrac_unit","ppm","Volume fraction units for gas concentration on input");
     params.addRequiredCoupledVar("volfrac","Volume fraction variable to convert to concentration");

     return params;
 }

 SimpleGasVolumeFractionToConcentration::SimpleGasVolumeFractionToConcentration(const InputParameters & parameters) :
 SimpleGasPropertiesBase(parameters),
 _output_volume_unit(getParam<std::string >("output_volume_unit")),
 _input_volfrac_unit(getParam<std::string >("input_volfrac_unit")),
 _volfrac(coupledValue("volfrac"))
 {

 }

 Real SimpleGasVolumeFractionToConcentration::computeValue()
 {
     Real y = SimpleGasPropertiesBase::volume_fraction_conversion(_volfrac[_qp], _input_volfrac_unit, "%")/100.0;
     // Conc in mol/L
     Real press = SimpleGasPropertiesBase::pressure_conversion(_pressure[_qp], _pressure_unit, "kPa");
     Real conc = press*y/Rstd/_temperature[_qp];
     conc = 1/SimpleGasPropertiesBase::volume_conversion(1/conc, "L", _output_volume_unit);
     return conc;
 }
