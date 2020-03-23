/*!
 *  \file DGPoreConcFluxStepwiseBC.h
 *    \brief Boundary Condition kernel for the flux  across a boundary of the domain with stepwise inputs
 *    \details This file creates a generic boundary condition kernel for the flux of matter accross
 *            a boundary. The flux is based on a velocity vector, as well as domain porosity, and is valid
 *            in all directions and all boundaries of a DG method. Since the DG method's flux boundary
 *            conditions are essitially the same for input and ouput boundaries, this kernel will check
 *            the sign of the flux normal to the boundary and determine automattically whether it is
 *            an output or input boundary, then apply the appropriate conditions.
 *            
 *           Stepwise inputs are determined from a list of input values and times at which those input
 *            values are to occur. Optionally, users can also provide a list of "ramp up" times that are
 *            used to create a smoother transition instead of abrupt change in inputs.
 *
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic equations:
 *                    Theory and Implementation, SIAM, Houston, TX, 2008.
 *
 *
 *  \author Austin Ladshaw
 *    \date 03/19/2020
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

#include "DGPoreConcFluxBC.h"

/// DGPoreConcFluxStepwiseBC class object forward declaration
class DGPoreConcFluxStepwiseBC;

template<>
InputParameters validParams<DGPoreConcFluxStepwiseBC>();

/// DGPoreConcFluxStepwiseBC class object inherits from DGPoreConcFluxBC object
/** This class object inherits from the DGPoreConcFluxBC object.
    All public and protected members of this class are required function overrides.
    The flux BC uses the velocity in the system to apply a boundary
    condition based on whether or not material is leaving or entering the boundary. */
class DGPoreConcFluxStepwiseBC : public DGPoreConcFluxBC
{
public:
    /// Required constructor for BC objects in MOOSE
    DGPoreConcFluxStepwiseBC(const InputParameters & parameters);

protected:
    /// Function  to update the _u_input value based on given time
    Real newInputValue(Real time);
    
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

    std::vector<Real> _input_vals;         ///< Values for _u_input that update at corresponding times
    std::vector<Real> _input_times;        ///< Values for determining when to change _u_input
    std::vector<Real> _time_spans;         ///< Amount of time it take to change to new input value
    std::vector<Real> _slopes;             ///< Slopes between each subsequent u_input
    int index;                             ///< Index variable to keep track of location in vectors

private:

};
