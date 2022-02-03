/*!
 *  \file InitialActivity.h
 *    \brief Initial Condition kernel for an activity variable
 *    \details This file creates an initial condition kernel for evalulation of the
 *              initial state of an activity variable as a function of the initial
 *              states of concentration and an initial activity coefficient.
 *
 *  \author Austin Ladshaw
 *  \date 02/03/2022
 *  \copyright This kernel was designed and built at Oak Ridge National
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

#pragma once

#include "InitialCondition.h"

/// InitialActivity class object inherits from InitialCondition object
/** This class object inherits from the InitialCondition object.
    All public and protected members of this class are required function overrides. */
class InitialActivity : public InitialCondition
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for BC objects in MOOSE
    InitialActivity(const InputParameters & parameters);

protected:

    /// Required function override for IC objects in MOOSE
    /** This function returns the value of the variable at point p in the mesh.*/
    virtual Real value(const Point & p) override;

    const VariableValue & _gamma;          ///< Variable for activity coefficient
    const unsigned int _gamma_var;         ///< Variable identification for activity coefficent
    const VariableValue & _conc;           ///< Variable for concentration of species
    const unsigned int _conc_var;          ///< Variable identification for concentration
    const VariableValue & _ref_conc;       ///< Variable for reference/total concentration
    const unsigned int _ref_conc_var;      ///< Variable identification for reference concentration

private:

};
