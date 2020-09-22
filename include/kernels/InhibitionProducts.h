/*!
 *  \file InhibitionProducts.h
 *  \brief Kernel for creating a function which computes the product of a list of inhibition variables
 *  \details This file creates a standard MOOSE kernel for the coupling a set of non-linear inhibition variables
 *            to create a generic function whose resolution is the products of those variables raised to specific
 *            powers. The intent of this is to create more complex inhibition terms for heterogenous reactions.
 *            The residual for this kernel is as follows
 *                      Res = - prod(R_i, p_i)
 *                      where R_i is the i-th inhibition term and p_i is the power for that term
 *
 *  \note This should be used in conjunction with a Reaction kernel inside of the
 *        input file to enfore that the inhibition variable value equals this function. The reason it is
 *        done in this fashion is so that it will be more modular in how the inhibition variable R could
 *        be represented if multiple instances of these objects are necessary to define its behavior
 *
 *        Reaction kernel ==>     Res(R) = R*test
 *        Inhibition Products ==> Res(R) = -InhibitionProducts*test
 *
 *  \author Austin Ladshaw
 *  \date 09/22/2020
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

#include "Kernel.h"

/// InhibitionProducts class object inherits from Kernel object
/** This class object inherits from the Kernel object in the MOOSE framework.
    All public and protected members of this class are required function overrides.
    The kernel interfaces the set of non-linear variables to create a kernel for a
    reaction or chemical mechanism. */
class InhibitionProducts : public Kernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();
    
    /// Required constructor for objects in MOOSE
     InhibitionProducts(const InputParameters & parameters);

protected:
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

    std::vector<Real> _power;                            ///< Inhibition term list powers
    std::vector<const VariableValue *> _inhibition;      ///< Pointer list to the coupled inhibitions
    std::vector<unsigned int> _inhibition_vars;          ///< Indices for the coupled reactants
    
private:

};



