/*!
 *  \file SimpleFluidDispersion.h
 *    \brief AuxKernel kernel to calculate dispersion coefficients
 *    \details This file is responsible for calculating the dispersion coefficient
 *              for the domain given some simple properties. Calculation is based
 *              diffusivities that are corrected via an Arrhenius like
 *              expression from a reference diffusivity and reference temperature.
 *              User provides input units for specific parameters and provides
 *              desired unit basis of the calculation of dispersion.
 *
 *  \note Calculation can optionally involve a 'dispersivity' correction factor.
 *        Users must provide the length unit for the correction factor.
 *              Correction:   D = Dm * alpha*vel
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

#include "SimpleFluidDispersion.h"

registerMooseObject("catsApp", SimpleFluidDispersion);

InputParameters SimpleFluidDispersion::validParams()
{
    InputParameters params = SimpleFluidPropertiesBase::validParams();
    params.addParam< std::string >("output_length_unit","cm","Length units for dispersion on output");
    params.addParam< std::string >("output_time_unit","s","Time units for dispersion on output");
    params.addParam<bool>("include_dispersivity_correction",true,"If true, then the calculation includes a correction based on the 'dispersivity' parameter");
    params.addParam<bool>("include_porosity_correction",true,"If true, then the calculation includes a correction based on the 'effective_diffusivity_factor' parameter");

    return params;
}

SimpleFluidDispersion::SimpleFluidDispersion(const InputParameters & parameters) :
SimpleFluidPropertiesBase(parameters),
_output_length_unit(getParam<std::string >("output_length_unit")),
_output_time_unit(getParam<std::string >("output_time_unit")),
_includeDispersivityCorrection(getParam<bool>("include_dispersivity_correction")),
_includePorosityCorrection(getParam<bool>("include_porosity_correction"))
{

}

Real SimpleFluidDispersion::computeValue()
{
    Real D = 0;
    if (_includeDispersivityCorrection == true)
    {
        if (_includePorosityCorrection == true)
        {
            D = SimpleFluidPropertiesBase::effective_dispersion(_temperature[_qp], _macro_pore[_qp]);
        }
        else
        {
            D = SimpleFluidPropertiesBase::dispersion(_temperature[_qp]);
        }
    }
    else
    {
        if (_includePorosityCorrection == true)
        {
            D = SimpleFluidPropertiesBase::effective_molecular_diffusion(_temperature[_qp], _macro_pore[_qp]);
        }
        else
        {
            D = SimpleFluidPropertiesBase::molecular_diffusion(_temperature[_qp]);
        }
    }
    D = SimpleFluidPropertiesBase::length_conversion(D, _diff_length_unit, _output_length_unit);
    D = SimpleFluidPropertiesBase::length_conversion(D, _diff_length_unit, _output_length_unit);
    D = 1/SimpleFluidPropertiesBase::time_conversion(1/D, _diff_time_unit, _output_time_unit);
    return D;
}
