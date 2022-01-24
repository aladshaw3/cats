/*!
 *  \file AuxFirstOrderRecycleBC.h
 *    \brief AuxKernel kernel to set the value of a BC auxillary variable from a postprocessor
 *    \details This file is responsible for setting the value of a given Auxilary
 *            variable to that of a Postprocessor at the outlet of a domain according to
 *            a rate of recycle from the outlet of the domain back to the inlet of the domain.
 *            The mathematical description of this conditions is as follows:
 *
 *                dC_in/dt = R*(C_out - C_in)
 *                    where R = recycle rate (per time)
 *                          C_in is the auxillary variable used at the inlet boundary
 *                          C_out is the postprocessor value at the outlet boundary
 *
 *
 *  \author Austin Ladshaw
 *  \date 01/24/2022
 *	\copyright This kernel was designed and built at Oak Ridge National
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

#include "AuxKernel.h"

/// AuxFirstOrderRecycleBC class object inherits from AuxKernel object
/** This class object inherits from the Kernel object in the MOOSE framework.
    All public and protected members of this class are required function overrides.  */
class AuxFirstOrderRecycleBC : public AuxKernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    AuxFirstOrderRecycleBC(const InputParameters & parameters);

protected:

    /// Required MOOSE function override
    /** This is the function that is called by the MOOSE framework when a calculation of the total
        system pressure is needed. You are required to override this function for any inherited
        AuxKernel. */
    virtual Real computeValue() override;

    const PostprocessorValue & _u_out;     ///< Postprocessor value for the outlet boundary
    const VariableValue & _recycle_rate;   ///< Rate of recycle (per time)
    const VariableValue & _u_old;          ///< Value of this variable's old state 


private:

};
