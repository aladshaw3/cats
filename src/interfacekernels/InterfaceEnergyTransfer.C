/*!
 *  \file InterfaceEnergyTransfer.h
 *  \brief Interface Kernel for creating an exchange of energy across a physical boundary
 *  \details This file creates an iterface kernel for the coupling a pair of energy variables in different
 *            subdomains across a boundary designated as a side-set in the mesh. The variables are
 *            coupled from by their respective phase energies through a heat transfer coefficient
 *            and a contact area fraction (in the case of multiple phases in contact):
 *                  Res = test * h * fa * (Tu - Tv)
 *                          where Tu = master temperature variable in master domain
 *                          and Tv = neighbor temperature variable in the adjacent subdomain
 *                          h = heat transfer coefficient
 *                          fa = area fraction of contact between phases
 *
 *  \note Only need 1 interface kernel for both non-linear variables that are coupled to handle transfer in both domains
 *
 *
 *  \author Austin Ladshaw
 *  \date 05/05/2020
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

#include "InterfaceEnergyTransfer.h"

registerMooseObject("catsApp", InterfaceEnergyTransfer);

InputParameters InterfaceEnergyTransfer::validParams()
{
    InputParameters params = InterfaceKernel::validParams();
    params.addRequiredCoupledVar("transfer_coef","Variable for heat transfer coefficient (W/m^2/K)");
    params.addRequiredCoupledVar("master_temp","Variable for the master temperature (K)");
    params.addRequiredCoupledVar("neighbor_temp","Variable for the neighbor temperature (K)");
    params.addRequiredCoupledVar("area_frac","Variable for contact area fraction (or volume fraction) (-)");
    return params;
}

InterfaceEnergyTransfer::InterfaceEnergyTransfer(const InputParameters & parameters)
  : InterfaceKernel(parameters),
_h(coupledValue("transfer_coef")),
_h_var(coupled("transfer_coef")),

_Tu(coupledValue("master_temp")),
_Tu_var(coupled("master_temp")),

_Tv_moose_var(dynamic_cast<MooseVariable &>(*getVar("neighbor_temp", 0))),
_Tv(_Tv_moose_var.slnNeighbor()),
_Tv_var(coupled("neighbor_temp")),

_areafrac(coupledValue("area_frac")),
_areafrac_var(coupled("area_frac"))
{
}

Real InterfaceEnergyTransfer::computeQpResidual(Moose::DGResidualType type)
{
    Real r = 0;
    switch (type)
    {
            // Move all the terms to the LHS to get residual, for master domain
            // Residual = km*(u - v)
            // Weak form for master domain is: (test, h*fa*(Tu - Tv) )
        case Moose::Element:
            r = _test[_i][_qp] * _h[_qp] * _areafrac[_qp] * (_Tu[_qp] - _Tv[_qp]);
            break;

            // Similarly, weak form for slave domain is: -(test, h*fa*(Tu - Tv)),
            // flip the sign because the direction is opposite.
        case Moose::Neighbor:
            r = -_test_neighbor[_i][_qp] * _h[_qp] * _areafrac[_qp] * (_Tu[_qp] - _Tv[_qp]);
            break;
    }
    return r;
}

Real InterfaceEnergyTransfer::computeQpJacobian(Moose::DGJacobianType /* type */)
{
    return 0.0;
}

Real InterfaceEnergyTransfer::computeQpOffDiagJacobian(Moose::DGJacobianType type, unsigned int jvar)
{
    Real jac = 0.0;
    
    if (jvar == _Tu_var || jvar == _Tv_var)
    {
        switch (type)
        {
            case Moose::ElementElement:
                jac = _test[_i][_qp] * _h[_qp] * _areafrac[_qp] * _phi[_j][_qp];
                break;
        
            case Moose::NeighborNeighbor:
                jac = -_test_neighbor[_i][_qp] * -_h[_qp] * _areafrac[_qp] * _phi_neighbor[_j][_qp];
                break;
        
            case Moose::NeighborElement:
                jac = -_test_neighbor[_i][_qp] * _h[_qp] * _areafrac[_qp] * _phi[_j][_qp];
                break;
        
            case Moose::ElementNeighbor:
                jac = _test[_i][_qp] * -_h[_qp] * _areafrac[_qp] * _phi_neighbor[_j][_qp];
                break;
        }
        return jac;
    }
    
    if (jvar == _h_var)
    {
        switch (type)
        {
            case Moose::ElementElement:
                jac = _test[_i][_qp] * _phi[_j][_qp] * _areafrac[_qp]  * (_Tu[_qp] - _Tv[_qp]);
                break;
        
            case Moose::NeighborNeighbor:
                jac = -_test_neighbor[_i][_qp] * _phi[_j][_qp] * _areafrac[_qp]  * (_Tu[_qp] - _Tv[_qp]);
                break;
        
            case Moose::NeighborElement:
                jac = -_test_neighbor[_i][_qp] * _phi[_j][_qp] * _areafrac[_qp]  * (_Tu[_qp] - _Tv[_qp]);
                break;
        
            case Moose::ElementNeighbor:
                jac = _test[_i][_qp] * _phi[_j][_qp] * _areafrac[_qp]  * (_Tu[_qp] - _Tv[_qp]);
                break;
        }
        return jac;
    }
    
    if (jvar == _areafrac_var)
    {
        switch (type)
        {
            case Moose::ElementElement:
                jac = _test[_i][_qp] * _phi[_j][_qp] * _h[_qp]  * (_Tu[_qp] - _Tv[_qp]);
                break;
        
            case Moose::NeighborNeighbor:
                jac = -_test_neighbor[_i][_qp] * _phi[_j][_qp] * _h[_qp]  * (_Tu[_qp] - _Tv[_qp]);
                break;
        
            case Moose::NeighborElement:
                jac = -_test_neighbor[_i][_qp] * _phi[_j][_qp] * _h[_qp]  * (_Tu[_qp] - _Tv[_qp]);
                break;
        
            case Moose::ElementNeighbor:
                jac = _test[_i][_qp] * _phi[_j][_qp] * _h[_qp]  * (_Tu[_qp] - _Tv[_qp]);
                break;
        }
        return jac;
    }
    
    return 0.0;
}
