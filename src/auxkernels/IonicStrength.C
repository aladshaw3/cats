/*!
 *  \file IonicStrength.h
 *    \brief AuxKernel kernel to calculate the ionic strength of a solution (in M)
 *    \details This file is responsible for calculation of the ionic strength of a
 *              solution. The ionic strength should always be calculated in moles/L
 *              (or M). To facilitate this need, a conversion factor arg is provided
 *              that allows the user to apply a common conversion factor to make this
 *              caculation end up in the correct units.
 *
 *              For instance, if the coupled concentrations are in moles/cm^3, then
 *              the conversion factor would be 1000 cm^3/L.
 *
 *
 *  \author Austin Ladshaw
 *  \date 02/09/2022
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "IonicStrength.h"

registerMooseObject("catsApp", IonicStrength);

InputParameters IonicStrength::validParams()
{
    InputParameters params = AuxKernel::validParams();
    params.addRequiredCoupledVar("ion_conc","List of names of the ion concentration variables (mol/L^3)");
    params.addParam< std::vector<Real> >("ion_valence","List of valences for coupled ion concentrations");
    params.addParam< Real >("conversion_factor",1,"Conversion factor for 'ion_conc' to get ionic strength in M [default=1 M/M]");
    return params;
}

IonicStrength::IonicStrength(const InputParameters & parameters) :
AuxKernel(parameters),
_valence(getParam<std::vector<Real> >("ion_valence")),
_conv_factor(getParam<Real>("conversion_factor"))
{
    unsigned int c = coupledComponents("ion_conc");
    _ion_conc.resize(c);

    //Check lists to ensure they are of same size
    if (_ion_conc.size() != _valence.size())
    {
        moose::internal::mooseErrorRaw("User is required to provide list of ion concentration variables of the same length as list of ion valences.");
    }

    //Grab the variables
    for (unsigned int i = 0; i<_ion_conc.size(); ++i)
    {
        _ion_conc[i] = &coupledValue("ion_conc",i);
    }
}

Real IonicStrength::computeValue()
{
    Real sum = 0.0;
    for (unsigned int i = 0; i<_ion_conc.size(); ++i)
    {
        if ((*_ion_conc[i])[_qp] > 0.0)
          sum = sum + _valence[i]*_valence[i]*(*_ion_conc[i])[_qp];
    }

    return 0.5*_conv_factor*sum;
}
