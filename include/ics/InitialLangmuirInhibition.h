/*!
 *  \file InitialLangmuirInhibition.h
 *    \brief Initial Condition kernel for the Langmuir Inhibition variables
 *    \details This file creates an initial condition for a Langmuir Inhibition variable.
 *            i.e., R_IC = 1 + sum(i, K_i * coupled_variable_i)
 *                  where K_i = A*T^B*exp(-E/R/T)
 *
 *            T is a coupled temperature and coupled_variable_i are coupled concentrations
 *
 *  \author Austin Ladshaw
 *  \date 12/30/2020
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

#include "InitialCondition.h"

#ifndef Rstd
#define Rstd 8.3144621                        ///< Gas Constant in J/K/mol (or) L*kPa/K/mol (Standard Units)
#endif

/// InitialLangmuirInhibition class object inherits from InitialCondition object
/** This class object inherits from the InitialCondition object.
    All public and protected members of this class are required function overrides.
 */
class InitialLangmuirInhibition : public InitialCondition
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();
    
    /// Required constructor for BC objects in MOOSE
     InitialLangmuirInhibition(const InputParameters & parameters);

protected:
    /// Function to compute all langmuir coefficients from temperature
    void computeAllLangmuirCoeffs();

    /// Function to compute the i-th term in the Langmuir function
    Real computeLangmuirTerm(int i);
    
    /// Required function override for IC objects in MOOSE
    /** This function returns the value of the variable at point p in the mesh.*/
    virtual Real value(const Point & p) override;
    
    std::vector<Real> _langmuir_coef;                   ///< Langmuir Coefficients for the coupled variables (units are inverse concentration)
    std::vector<Real> _pre_exp;                         ///< Pre-exponential factors for Langmuir coefficients
    std::vector<Real> _beta;                            ///< Beta factors for the Langmuir coefficients
    std::vector<Real> _act_energy;                      ///< Activation energies for Langmuir coefficients
    std::vector<const VariableValue *> _coupled;        ///< Pointer list to the coupled gases (concentration units)
    std::vector<unsigned int> _coupled_vars;            ///< Indices for the concentration species in the system
    const VariableValue & _temp;                        ///< Coupled variable for temperature
    const unsigned int _temp_var;                       ///< Index for the coupled temperature variable

private:

};


