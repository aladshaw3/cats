/*!
 *  \file AuxPostprocessorValue.h
 *    \brief AuxKernel kernel to set an Auxilary variable value to that of a Postprocessor
 *    \details This file is responsible for setting the value of a given Auxilary
 *            variable to that of a Postprocessor. The purpose of this simple Auxilary
 *            system is to allow for other Kernels/AuxKernels/BCs to couple with
 *            Postprocessor within CATS by first converting those Postprocessors to
 *            an equivalent AuxVariable.
 *
 *
 *  \author Austin Ladshaw
 *  \date 01/18/2022
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

#include "AuxPostprocessorValue.h"

registerMooseObject("catsApp", AuxPostprocessorValue);

InputParameters AuxPostprocessorValue::validParams()
{
    InputParameters params = AuxKernel::validParams();
    params.addRequiredParam<PostprocessorName>("postprocessor","Name of the postprocessor variable");
    return params;
}

AuxPostprocessorValue::AuxPostprocessorValue(const InputParameters & parameters) :
AuxKernel(parameters),
_post_val(getPostprocessorValue("postprocessor"))
{

}

Real AuxPostprocessorValue::computeValue()
{
    return _post_val;
}
