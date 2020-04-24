/*!
 *  \file MicroscaleIntegralAvg.h
 *    \brief Custom auxkernel for integrating a series of microscale variables over the fictious microscale space
 *    \details This file creates a custom MOOSE kernel for the diffusion at the microscale
 *              of a fictious mesh. Generally this kernel is to be used in conjunction with other
 *              Microscale kernels for mass transfer, time derivatives on the microscale, or reactions.
 *
 *  \author Austin Ladshaw
 *    \date 04/16/2020
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

#include "MicroscaleIntegralTotal.h"


/// MicroscaleIntegralAvg class object forward declaration
//class MicroscaleIntegralAvg;

//template<>
//InputParameters validParams<MicroscaleIntegralAvg>();

/// MicroscaleIntegralAvg class inherits from MicroscaleIntegralTotal
/** This class object creates an MicroscaleIntegralTotal for use in the MOOSE framework. The AuxKernel will
    calculate the integral result of all variables in the microscale. */
class MicroscaleIntegralAvg : public MicroscaleIntegralTotal
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();
    
    /// Standard MOOSE public constructor
    MicroscaleIntegralAvg(const InputParameters & parameters);
    
protected:
    /// Required MOOSE function override
    /** This is the function that is called by the MOOSE framework when a calculation of the total
        system pressure is needed. You are required to override this function for any inherited
        AuxKernel. */
    virtual Real computeValue() override;
    
private:
    
};

