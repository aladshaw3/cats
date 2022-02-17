/*!
 *  \file InitialIonicStrength.h
 *    \brief This kernel calculates the initial ionic strength of a solution (in M)
 *    \details This file is responsible for calculation of the initial ionic strength of a
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

#pragma once

#include "InitialCondition.h"

/// InitialIonicStrength class object inherits from InitialCondition object
/** This class object inherits from the InitialCondition object.
    All public and protected members of this class are required function overrides. */
class InitialIonicStrength : public InitialCondition
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for BC objects in MOOSE
    InitialIonicStrength(const InputParameters & parameters);

protected:

    /// Required function override for IC objects in MOOSE
    /** This function returns the value of the variable at point p in the mesh.*/
    virtual Real value(const Point & p) override;

    std::vector<const VariableValue *> _ion_conc;           ///< Pointer list to the coupled ion concentrations (mol/L^3)
    std::vector<Real> _valence;                             ///< Valence list for corresponding ions
    Real _conv_factor;                                      ///< Conversion factor from mol/L^3 to moles/liter (where L is any length)

private:

};
