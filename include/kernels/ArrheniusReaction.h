/*!
 *  \file ArrheniusReaction.h
 *  \brief Kernel for creating an Arrhenius reaction coupled with temperature
 *  \details This file creates a standard MOOSE kernel for the coupling a set of non-linear variables to
 *            create an Arrhenius reaction coupled with temperature. This kernel has a list of reactants
 *            and a list of products, with corresponding lists for stoichiometric coefficients.
 *            The residual for this kernel is as follows
 *                      Res = - a*kf*prod(C_i, v_i) + a*kr*prod(C_j, v_j)
 *                      where a = scaling parameter, kf = forward rate, kr = reverse rate,
 *                      v_i's = stoichiometry, and C_i's = chemical species concentrations
 *                      kf = Af * T^Bf * exp(-Ef/R/T)
 *                      kr = Ar * T^Br * exp(-Er/R/T)
 *
 *
 *  \author Austin Ladshaw
 *  \date 03/31/2020
 *  \copyright This kernel was designed and built at Oak Ridge National
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

#include "ConstReaction.h"

#ifndef Rstd
#define Rstd 8.3144621                        ///< Gas Constant in J/K/mol (or) L*kPa/K/mol (Standard Units)
#endif

/// This macro calculates the natural log of the dimensionless isotherm parameter
#ifndef lnKo
#define lnKo(H,S,T)    -( H / ( Rstd * T ) ) + ( S / Rstd )
#endif

/// ArrheniusReaction class object forward declarationss
class ArrheniusReaction;

template<>
InputParameters validParams<ArrheniusReaction>();

/// ArrheniusReaction class object inherits from ConstReaction object
/** This class object inherits from the Kernel object in the MOOSE framework.
    All public and protected members of this class are required function overrides.
    The kernel interfaces the set of non-linear variables to create a kernel for an
    Arrhenius reaction. */
class ArrheniusReaction : public ConstReaction
{
public:
    /// Required constructor for objects in MOOSE
    ArrheniusReaction(const InputParameters & parameters);

protected:
    ///  Function to compute the equilibrium constant
    void calculateRateConstants();
    
    /// Required residual function for standard kernels in MOOSE
    /** This function returns a residual contribution for this object.*/
    virtual Real computeQpResidual();

    /// Required Jacobian function for standard kernels in MOOSE
    /** This function returns a Jacobian contribution for this object. The Jacobian being
     computed is the associated diagonal element in the overall Jacobian matrix for the
     system and is used in preconditioning of the linear sub-problem. */
    virtual Real computeQpJacobian();

    /// Not Required, but aids in the preconditioning step
    /** This function returns the off diagonal Jacobian contribution for this object. By
     returning a non-zero value we will hopefully improve the convergence rate for the
     cross coupling of the variables. */
    virtual Real computeQpOffDiagJacobian(unsigned int jvar);

    Real _act_energy_for;                           ///< Activation energy forward (J/mol)
    Real _act_energy_rev;                           ///< Activation energy reverse (J/mol)
    Real _pre_exp_for;                              ///< Pre-exponential factor forward (same units as kf)
    Real _pre_exp_rev;                              ///< Pre-exponential factor reverse (same units as kr)
    Real _beta_for;                                 ///< Temperature exponential forward (-)
    Real _beta_rev;                                 ///< Temperature exponential reverse (-)
    const VariableValue & _temp;                    ///< Coupled temperature variable (K)
    const unsigned int _temp_var;                   ///< Variable identification for temperature
   
private:

};




