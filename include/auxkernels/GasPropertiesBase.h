/*!
 *  \file GasPropertiesBase.h
 *    \brief AuxKernel kernel to compute store information associated with calculation of gas properties
 *    \details This file is responsible for calculating storing and calculating a number of gas
 *              properties that will be used by other auxkernels that inherit from this base kernel.
 *
 *
 *  \author Austin Ladshaw
 *  \date 04/20/2020
 *  \copyright This kernel was designed and built at the Georgia Institute
 *             of Technology by Austin Ladshaw for PhD research in the area
 *             of adsorption and surface science and was developed for use
 *               by Idaho National Laboratory and Oak Ridge National Laboratory
 *               engineers and scientists. Portions Copyright (c) 2015, all
 *             rights reserved.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#pragma once

#include "AuxKernel.h"
#include "egret.h"

/// GasPropertiesBase class object inherits from Kernel object
/** This class object inherits from the Kernel object in the MOOSE framework.
    All public and protected members of this class are required function overrides.
    The kernel interfaces the set of non-linear variables to the kinetic theory of gases.  */
class GasPropertiesBase : public AuxKernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    GasPropertiesBase(const InputParameters & parameters);

protected:
    /// Helper function to evaluate setup all calculations
    void prepareEgret();

    /// Helper function to calculate all properties
    void calculateAllProperties();

    /// Required MOOSE function override
    /** This is the function that is called by the MOOSE framework when a calculation of the total
        system pressure is needed. You are required to override this function for any inherited
        AuxKernel. */
    virtual Real computeValue() override;

    std::vector<const VariableValue *> _gases;     ///< Pointer list to the coupled gas concentrations (mol/L)
    const VariableValue & _press;                  ///< Variable for the pressure (Pa)
    const VariableValue & _temp;                   ///< Variable for the temperature (K)

    const VariableValue & _velx;                   ///< Variable for the x velocity (m/s)
    const VariableValue & _vely;                   ///< Variable for the y velocity (m/s)
    const VariableValue & _velz;                   ///< Variable for the z velocity (m/s)

    const VariableValue & _char_len;                ///< Variable for the characteristic length (hydralic diameter) (m)

    std::vector<Real> _MW;                         ///< List of molecular weights (g/mol)
    std::vector<Real> _SuthTemp;                   ///< List of Sutherland's Reference Temperatures (K)
    std::vector<Real> _SuthConst;                  ///< List of Sutherland's Constants  (K)
    std::vector<Real> _SuthVis;                    ///< List of Sutherland's Viscosities    (g/cm/s)
    std::vector<Real> _SpecHeat;                   ///< List of Specific heats (J/g/K)

    std::vector<double> _mole_frac;                   ///< Store calculated molefractions

    const VariableValue & _carrier_gas;            ///< Variable for the carrier gas concentration (mol/m^3)
    Real _MW_cg;                                   ///< Molecular wieght for the carrier gas (g/mol)

    bool _is_ideal_gas;                            ///< Boolean to determine whether or not to consider gas ideal
    Real _total_conc;                              ///< Total molar concentration (mol/m^3)

    MIXED_GAS _egret_dat;                           ///< EGRET data structure

private:

};
