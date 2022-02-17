/*!
 *  \file SimpleGasEffectiveKnudsenDiffusivity.h
 *    \brief AuxKernel kernel to calculate Knudsen diffusion coefficients in microscale
 *    \details This file is responsible for calculating the pore diffusivity
 *              for the microscale given some simple properties. Calculation is based
 *              diffusivities that are corrected via an Arrhenius like
 *              expression from a reference diffusivity and reference temperature.
 *              User provides input units for specific parameters and provides
 *              desired unit basis of the calculation of diffusivity. This calculation
 *              also includes an average pore size variable and the molecular weight
 *              of the species of interest. Molecular weight must be given in g/mol.
 *              The pore radius must be given as the characteristic_length in this
 *              kernel. This convention reduces the need for any additional variables.
 *
 *  \note This kernel calculates an effective Knudsen diffusivity which would commonly
 *        be directly applied to the MicroscaleVariableDiffusion kernels. Depending on
 *        how your volume basis for the microscale balance is defined, this will give
 *        you diffusivity on a per microscale volume basis or per total volume basis.
 *
 *
 *  \author Austin Ladshaw
 *  \date 09/16/2021
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "SimpleGasEffectiveKnudsenDiffusivity.h"

registerMooseObject("catsApp", SimpleGasEffectiveKnudsenDiffusivity);

InputParameters SimpleGasEffectiveKnudsenDiffusivity::validParams()
{
    InputParameters params = SimpleGasPropertiesBase::validParams();
    params.addParam< std::string >("output_length_unit","m","Length units for mass transfer on output");
    params.addParam< std::string >("output_time_unit","s","Time units for mass transfer on output");
    params.addParam<Real>("molar_weight",28.97,"Molecular weight of the gas-species of interest (g/mol)");
    params.addParam<bool>("per_solids_volume",true,"If true, then ratio is in units of solid area per solid volume. If false, then ratio is in solids volume per total volume ");
    return params;
}

SimpleGasEffectiveKnudsenDiffusivity::SimpleGasEffectiveKnudsenDiffusivity(const InputParameters & parameters) :
SimpleGasPropertiesBase(parameters),
_output_length_unit(getParam<std::string >("output_length_unit")),
_output_time_unit(getParam<std::string >("output_time_unit")),
_molar_weight(getParam<Real>("molar_weight")),
_PerSolidsVolume(getParam<bool>("per_solids_volume"))
{

}

Real SimpleGasEffectiveKnudsenDiffusivity::computeValue()
{
    // Put diffusivity into cm^2/s
    Real Dm = _ref_diffusivity*exp(-887.5*((1/_temperature[_qp])-(1/_ref_diff_temp)));
    Dm = SimpleGasPropertiesBase::length_conversion(Dm, _diff_length_unit, "cm");
    Dm = SimpleGasPropertiesBase::length_conversion(Dm, _diff_length_unit, "cm");
    Dm = 1/SimpleGasPropertiesBase::time_conversion(1/Dm, _diff_time_unit, "s");

    Real Dp = pow(_micro_pore[_qp],_eff_diff_factor)*Dm;
    // ends up in cm^2/s

    //Take given char_length and convert to cm to get Dk in cm^2/s
    Real rp = SimpleGasPropertiesBase::length_conversion(_char_len[_qp], _char_len_unit, "cm");
    Real Dk = 9700.0*rp*sqrt(_temperature[_qp]/_molar_weight);

    //Calculate Deff in cm^2/s
    Real Deff = 1/((1/Dk)+(1/Dp));
    //Convert to desired units
    Deff = SimpleGasPropertiesBase::length_conversion(Deff, "cm", _output_length_unit);
    Deff = SimpleGasPropertiesBase::length_conversion(Deff, "cm", _output_length_unit);
    Deff = 1/SimpleGasPropertiesBase::time_conversion(1/Deff, "s", _output_time_unit);

    if (_PerSolidsVolume == true)
      return Deff*_micro_pore[_qp];
    else
      return Deff*_micro_pore[_qp]*(1.0-_macro_pore[_qp]);
}
