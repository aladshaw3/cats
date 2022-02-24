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

 #include "VectorMagnitude.h"

 registerMooseObject("catsApp", VectorMagnitude);

 InputParameters VectorMagnitude::validParams()
 {
     InputParameters params = AuxKernel::validParams();
     params.addCoupledVar("ux",0.0,"Variable for vector in x");
     params.addCoupledVar("uy",0.0,"Variable for vector in y");
     params.addCoupledVar("uz",0.0,"Variable for vector in z");

     return params;
 }

 VectorMagnitude::VectorMagnitude(const InputParameters & parameters) :
 AuxKernel(parameters),
 _vec_x(coupledValue("ux")),
 _vec_y(coupledValue("uy")),
 _vec_z(coupledValue("uz"))
 {

 }

 Real VectorMagnitude::vector_magnitude(Real ux, Real uy, Real uz)
 {
     return std::sqrt(ux*ux + uy*uy + uz*uz);
 }

 Real VectorMagnitude::computeValue()
 {
     return vector_magnitude(_vec_x[_qp], _vec_y[_qp], _vec_z[_qp]);
 }
