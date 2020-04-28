/*!
 *  \file AuxAvgLinearVelocity.h
 *    \brief Auxillary kernel to calculate the average linear velocity in a column based on flow rate and porosity
 *    \details This file is responsible for calculating the value of an auxvariable
 *              according to the standard expression for superficial velocity, then
 *              update that estimate based on a porosity of the column. The end
 *              result will be an average linear velocity within that column.
 *
 *  \note This method only gives the magnitude of the velocity (not the vector components)
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

/// AuxAvgLinearVelocity class inherits from AuxKernel
/** This class object creates an AuxKernel for use in the MOOSE framework. The AuxKernel will
    calculate the new values for the auxvariable based on linear changes with time. */
class AuxAvgLinearVelocity : public AuxKernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();
    
    /// Standard MOOSE public constructor
    AuxAvgLinearVelocity(const InputParameters & parameters);
    
protected:
    /// Required MOOSE function override
    /** This is the function that is called by the MOOSE framework when a calculation of the total
        system pressure is needed. You are required to override this function for any inherited
        AuxKernel. */
    virtual Real computeValue() override;
    
private:
    const VariableValue & _flow_rate;                ///< Variable for the flow rate (m^3/s)
    const unsigned int _flow_rate_var;               ///< Variable identification for the flow rate
    const VariableValue & _xsec_area;                ///< Variable for the cross-sectional area (m^2)
    const unsigned int _xsec_area_var;               ///< Variable identification for the cross-sectional area
    const VariableValue & _porosity;                ///< Variable for the porosity
    const unsigned int _porosity_var;               ///< Variable identification for the porosity
    
};

