/*!
 *  \file InitialInhibitionProducts.h
 *    \brief Initial Condition kernel for an Inhibition product variable
 *    \details This file creates an initial condition for an Inhibition Product variable.
 *            The value for this kernel is as follows
 *                      R_IC = - prod(R_i, p_i)
 *                      where R_i is the i-th inhibition term and p_i is the power for that term
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

#pragma once

#include "InitialCondition.h"

/// InitialInhibitionProducts class object inherits from InitialCondition object
/** This class object inherits from the InitialCondition object.
    All public and protected members of this class are required function overrides.
 */
class InitialInhibitionProducts : public InitialCondition
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for BC objects in MOOSE
    InitialInhibitionProducts(const InputParameters & parameters);

protected:
    /// Required function override for IC objects in MOOSE
    /** This function returns the value of the variable at point p in the mesh.*/
    virtual Real value(const Point & p) override;

    std::vector<Real> _power;                            ///< Inhibition term list powers
    std::vector<const VariableValue *> _inhibition;      ///< Pointer list to the coupled inhibitions
    std::vector<unsigned int> _inhibition_vars;          ///< Indices for the coupled reactants

private:

};
