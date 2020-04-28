/*!
 *  \file DGHeatFluxBC.h
 *    \brief Boundary Condition kernel for the flux of heat across a boundary of the domain
 *    \details This file creates a generic boundary condition kernel for the flux of heat accross
 *            a boundary. The flux is based on a velocity vector, porosity, specific heat, and density. It is valid
 *            in all directions and all boundaries of a DG method. Since the DG method's flux boundary
 *            conditions are essitially the same for input and ouput boundaries, this kernel will check
 *            the sign of the flux normal to the boundary and determine automattically whether it is
 *            an output or input boundary, then apply the appropriate conditions.
 *
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic equations:
 *                    Theory and Implementation, SIAM, Houston, TX, 2008.
 *
 *
 *  \author Austin Ladshaw
 *    \date 04/28/2020
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

#include "DGConcentrationFluxBC.h"

/// DGHeatFluxBC class object forward declaration
//class DGHeatFluxBC;

//template<>
//InputParameters validParams<DGHeatFluxBC>();

/// DGHeatFluxBC class object inherits from IntegratedBC object
/** This class object inherits from the IntegratedBC object.
    All public and protected members of this class are required function overrides.
    The flux BC uses the velocity in the system to apply a boundary
    condition based on whether or not material is leaving or entering the boundary. */
class DGHeatFluxBC : public DGConcentrationFluxBC
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();
    
    /// Required constructor for BC objects in MOOSE
    DGHeatFluxBC(const InputParameters & parameters);

protected:
    /// Required function override for BC objects in MOOSE
    /** This function returns a residual contribution for this object.*/
    virtual Real computeQpResidual() override;

    /// Required function override for BC objects in MOOSE
    /** This function returns a Jacobian contribution for this object. The Jacobian being
        computed is the associated diagonal element in the overall Jacobian matrix for the
        system and is used in preconditioning of the linear sub-problem. */
    virtual Real computeQpJacobian() override;

    /// Not Required, but aids in the preconditioning step
    /** This function returns the off diagonal Jacobian contribution for this object. By
        returning a non-zero value we will hopefully improve the convergence rate for the
        cross coupling of the variables. */
    virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

    const VariableValue & _spec_heat;            ///< Coupled specific heat (J/kg/K)
    const unsigned int _spec_heat_var;           ///< Variable identification for specific heat
    const VariableValue & _porosity;             ///< Porosity variable
    const unsigned int _porosity_var;            ///< Variable identification for porosity
    const VariableValue & _density;              ///< Coupled density (kg/m^3)
    const unsigned int _density_var;             ///< Variable identification for density

private:

};

