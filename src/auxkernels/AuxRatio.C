/*!
 *  \file AuxRatio.h
 *    \brief Auxillary kernel to calculate a value based on a ratio of other values
 *    \details This file is responsible for calculating the value of an auxvariable
 *              according to the ratio of a set of coupled variables for the denominator
 *              and numerator.
 *
 *  \author Austin Ladshaw
 *  \date 06/24/2022
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

 #include "AuxRatio.h"

 registerMooseObject("catsApp", AuxRatio);

 InputParameters AuxRatio::validParams()
 {
     InputParameters params = AuxKernel::validParams();
     params.addRequiredCoupledVar("numerator_vars","List of variables for the numerator (top)");
     params.addRequiredCoupledVar("denominator_vars","List of variables for the denominator (bottom)");

     return params;
 }

 AuxRatio::AuxRatio(const InputParameters & parameters) :
 AuxKernel(parameters)
 {
     unsigned int n = coupledComponents("numerator_vars");
     _numerator.resize(n);

     unsigned int m = coupledComponents("denominator_vars");
     _denominator.resize(m);

     if (n < 1)
     {
         moose::internal::mooseErrorRaw("Must provide at least 1 numerator variable");
     }

     if (m < 1)
     {
         moose::internal::mooseErrorRaw("Must provide at least 1 denominator variable");
     }

     for (unsigned int i = 0; i<_numerator.size(); ++i)
     {
         _numerator[i] = &coupledValue("numerator_vars",i);
     }

     for (unsigned int i = 0; i<_denominator.size(); ++i)
     {
         _denominator[i] = &coupledValue("denominator_vars",i);
     }
 }

 Real AuxRatio::computeValue()
 {
     Real top = 0.0;
     for (unsigned int i = 0; i<_numerator.size(); ++i)
     {
         top += (*_numerator[i])[_qp];
     }

     Real bot = 0.0;
     for (unsigned int i = 0; i<_denominator.size(); ++i)
     {
         bot += (*_denominator[i])[_qp];
     }
     return top/bot;
 }
