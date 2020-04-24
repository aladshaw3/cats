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

#include "MicroscaleIntegralAvg.h"

registerMooseObject("catsApp", MicroscaleIntegralAvg);

/*
template<>
InputParameters validParams<MicroscaleIntegralAvg>()
{
    InputParameters params = validParams<MicroscaleIntegralTotal>();
    
    return params;
}
 */

InputParameters MicroscaleIntegralAvg::validParams()
{
    InputParameters params = MicroscaleIntegralTotal::validParams();
    
    return params;
}

MicroscaleIntegralAvg::MicroscaleIntegralAvg(const InputParameters & parameters) :
MicroscaleIntegralTotal(parameters)
{

}

Real MicroscaleIntegralAvg::computeValue()
{
    Real uT = MicroscaleIntegralTotal::computeIntegral();
    Real uAvg = 0;
    if (_coord_id == 0)
    {
        uAvg = uT/_space_factor/_total_length;
    }
    else if (_coord_id == 1)
    {
        uAvg = uT/_space_factor/M_PI/_total_length/_total_length;
    }
    else
    {
        uAvg = uT/(4.0/3.0)/M_PI/_total_length/_total_length/_total_length;
    }
    return uAvg;
}

