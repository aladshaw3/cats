/*!
 *  \file VectorMagnitude.h
 *    \brief AuxKernel kernel base to calculate the magnitude of a vector
 *    \details This file is responsible for calculating the magnitude of a
 *              vector given its component-wise terms. This will be useful
 *              in conjunction with other AuxKernels that rely on the magnitude
 *              of velocity, but do not explicitly couple with each component
 *              of velocity.
 *
 *
 *  \author Austin Ladshaw
 *  \date 02/24/2022
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#pragma once

#include "AuxKernel.h"

/// VectorMagnitude class object inherits from Kernel object
class VectorMagnitude : public AuxKernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    VectorMagnitude(const InputParameters & parameters);

protected:
    /// Calculation of the magnitude of velocity
    Real vector_magnitude(Real ux, Real uy, Real uz);

    /// Required MOOSE function override
    virtual Real computeValue() override;

    const VariableValue & _vec_x;                     ///< Variable for the vector in x
    const VariableValue & _vec_y;                     ///< Variable for the vector in y
    const VariableValue & _vec_z;                     ///< Variable for the vector in z

private:

};
