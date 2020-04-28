/*!
 *  \file HeatAccumulation.h
 *    \brief Kernel to create a time derivative that is linearly dependent on specific heat, porosity, and density
 *    \details This file creates a standard MOOSE kernel that is to be used to coupled another
 *          set of MOOSE variables with the current variable. This is specifically to be used
 *          with temperature time derivatives.
 *
 *  \author Austin Ladshaw
 *    \date 04/28/2020
 *    \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
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

#include "CoefTimeDerivative.h"

//class HeatAccumulation;

//template <>
//InputParameters validParams<HeatAccumulation>();

/// HeatAccumulation class object inherits from CoefTimeDerivative object
/**
 * Time derivative term multiplied by another variable as the coefficient.
 *  This will be useful for domains that have a pososity that varies in space
 *  and time.
 */
class HeatAccumulation : public CoefTimeDerivative
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();
    
    /// Required constructor for objects in MOOSE
    HeatAccumulation(const InputParameters & parameters);

protected:
    /// Required residual function for standard kernels in MOOSE
    /** This function returns a residual contribution for this object.*/
    virtual Real computeQpResidual() override;
    /// Required Jacobian function for standard kernels in MOOSE
    /** This function returns a Jacobian contribution for this object. The Jacobian being
        computed is the associated diagonal element in the overall Jacobian matrix for the
        system and is used in preconditioning of the linear sub-problem. */
    virtual Real computeQpJacobian() override;
    /// Not Required, but aids in the preconditioning step
    /** This function returns the off diagonal Jacobian contribution for this object. By
        returning a non-zero value we will hopefully improve the convergence rate for the
        cross coupling of the variables. */
    virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

    const VariableValue & _spec_heat;            ///< Coupled specific heat (J/kg/K)
    const unsigned int _spec_heat_var;           ///< Variable identification for specific heat
    const VariableValue & _porosity;             ///< Coupled porosity
    const unsigned int _porosity_var;            ///< Variable identification for porosity
    const VariableValue & _density;              ///< Coupled density (kg/m^3)
    const unsigned int _density_var;             ///< Variable identification for density
};

