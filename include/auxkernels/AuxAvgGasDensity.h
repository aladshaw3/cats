/*!
 *  \file AuxAvgGasDensity.h
 *    \brief Auxillary kernel to calculate the average gas density given reference pressures, temperatures, and gas species
 *    \details This file is responsible for calculating the value of an auxvariable
 *              according to the ideal gas law to estimate an average gas density.
 *              The calculate of the density is basically the same as GasDensity.h, except
 *              we explicitly remove the coupling with velocities and other non-essential
 *              parameters. This can then be used later in conjunction with other AuxKernels
 *              and variables to approximate velocity changes caused by density variations.
 *
 *  \author Austin Ladshaw
 *  \date 04/28/2020
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

#pragma once

#include "AuxKernel.h"
#include "egret.h"

/// AuxAvgGasDensity class inherits from AuxKernel
/** This class object creates an AuxKernel for use in the MOOSE framework. The AuxKernel will
    calculate the new values for the auxvariable based on linear changes with time. */
class AuxAvgGasDensity : public AuxKernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();
    
    /// Standard MOOSE public constructor
    AuxAvgGasDensity(const InputParameters & parameters);
    
protected:
    /// Helper function for molefractions
    void calculateMolefractions();
    
    /// Required MOOSE function override
    /** This is the function that is called by the MOOSE framework when a calculation of the total
        system pressure is needed. You are required to override this function for any inherited
        AuxKernel. */
    virtual Real computeValue() override;
    
private:
    std::vector<const VariableValue *> _gases;     ///< Pointer list to the coupled gas concentrations (mol/L)
    std::vector<unsigned int> _gases_vars;         ///< Indices for the coupled gas concentrations
    const VariableValue & _press;                  ///< Variable for the pressure (Pa)
    const unsigned int _press_var;                 ///< Variable identification for the pressure
    const VariableValue & _temp;                   ///< Variable for the temperature (K)
    const unsigned int _temp_var;                  ///< Variable identification for the temperature
    
    std::vector<Real> _MW;                         ///< List of molecular weights (g/mol)
    std::vector<double> _mole_frac;                ///< Store calculated molefractions
    Real _avg_MW;                                  ///< Average molecular weight (g/mol)
        
};


