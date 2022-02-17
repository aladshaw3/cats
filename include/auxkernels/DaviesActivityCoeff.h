/*!
 *  \file DaviesActivityCoeff.h
 *    \brief AuxKernel kernel to calculate an activity coefficient for an ion with Davies Equation
 *    \details This file is responsible for calculation of the activity coefficient of an
 *            ion in solution based on the Davies model. This kernel couples a variable for
 *            ionic strength with some Davies model parameters to produce the activity
 *            coefficient for an ion of a specific valence.
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

#pragma once

#include "AuxKernel.h"

/// DaviesActivityCoeff class object inherits from AuxKernel object
/** This class object creates an AuxKernel for use in the MOOSE framework. The AuxKernel will
    calculate an activity function based on Davies Model*/
class DaviesActivityCoeff : public AuxKernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    DaviesActivityCoeff(const InputParameters & parameters);

protected:
    /// Required MOOSE function override
    virtual Real computeValue() override;

    const VariableValue & _ionic_strength;                ///< Variable for the ionic strength (in M)
    const VariableValue & _temp;                          ///< Variable for the temperature (in K)
    Real _fitted_param;                                   ///< Value of the Davies Fitting parameter
    Real _dielec;                                         ///< Value for the dielectric constant of the media (water = 78.325)
    Real _charge;                                         ///< Value of the valence/charge of the ion

private:

};
