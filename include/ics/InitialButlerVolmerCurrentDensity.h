/*!
 *  \file InitialButlerVolmerCurrentDensity.h
 *    \brief Initial Condition kernel for a Butler-Volmer current density variable
 *    \details This file creates an initial condition kernel for evalulation of the
 *              initial state of the Butler-Volmer current density induced by a
 *              kinetics expression. Each current density variable will need an
 *              instance of this kernel. All the parameters should match those
 *              in the full system kernel for the given current density variable.
 *              The purpose of this kernel is to properly initialize the highly
 *              non-linear electrochemistry problem.
 *
 *  \author Austin Ladshaw
 *  \date 12/09/2021
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

/// InitialButlerVolmerCurrentDensity class object inherits from InitialCondition object
/** This class object inherits from the InitialCondition object.
    All public and protected members of this class are required function overrides. */
class InitialButlerVolmerCurrentDensity : public InitialCondition
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for BC objects in MOOSE
    InitialButlerVolmerCurrentDensity(const InputParameters & parameters);

protected:

    /// Required function override for IC objects in MOOSE
    /** This function returns the value of the variable at point p in the mesh.*/
    virtual Real value(const Point & p) override;

    const VariableValue & _rate;      ///< Variable for reaction rate (mol/area/time)
    const unsigned int _rate_var;     ///< Variable identification for reaction rate
    const VariableValue & _specarea;      ///< Variable for specific area (m^-1) [area/volume]
    const unsigned int _specarea_var;     ///< Variable identification for specific area

    Real _n;                                            ///< Number of electrons transferred (default = 1)
    Real _faraday;                                      ///< Value of Faraday's Constant (default = 96485.3 C/mol)

private:

};
