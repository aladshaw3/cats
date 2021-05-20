/*!
 *  \file DGConcentrationFluxBC.h
 *	\brief Boundary Condition kernel for the flux of concentration/density across a boundary of the domain
 *	\details This file creates a generic boundary condition kernel for the flux of matter accross
 *			a boundary. The flux is based on a velocity vector and is valid
 *			in all directions and all boundaries of a DG method. Since the DG method's flux boundary
 *			conditions are essitially the same for input and ouput boundaries, this kernel will check
 *			the sign of the flux normal to the boundary and determine automattically whether it is
 *			an output or input boundary, then apply the appropriate conditions.
 *
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic equations:
 *                    Theory and Implementation, SIAM, Houston, TX, 2008.
 *
 *
 *  \author Austin Ladshaw
 *	\date 07/12/2018
 *	\copyright This kernel was designed and built at the Georgia Institute
 *             of Technology by Austin Ladshaw for PhD research in the area
 *             of radioactive particle transport and settling following a
 *			   nuclear event. It was developed for the US DOD under DTRA
 *			   project No. 14-24-FRCWMD-BAA. Portions Copyright (c) 2018, all
 *             rights reserved.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
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

#include "DGConcentrationFluxBC.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", DGConcentrationFluxBC);

InputParameters DGConcentrationFluxBC::validParams()
{
    InputParameters params = DGFluxBC::validParams();
    params.addRequiredCoupledVar("ux","Variable for velocity in x-direction");
    params.addRequiredCoupledVar("uy","Variable for velocity in y-direction");
    params.addRequiredCoupledVar("uz","Variable for velocity in z-direction");
    return params;
}

DGConcentrationFluxBC::DGConcentrationFluxBC(const InputParameters & parameters) :
DGFluxBC(parameters),
_ux(coupledValue("ux")),
_uy(coupledValue("uy")),
_uz(coupledValue("uz")),
_ux_var(coupled("ux")),
_uy_var(coupled("uy")),
_uz_var(coupled("uz"))
{

}

Real DGConcentrationFluxBC::computeQpResidual()
{
	_velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

	Real r = 0;

	//Output
	if ((_velocity)*_normals[_qp] > 0.0)
	{
		r += _test[_i][_qp]*(_velocity*_normals[_qp])*_u[_qp];
	}
	//Input
	else
	{
		r += _test[_i][_qp]*(_velocity*_normals[_qp])*_u_input;
	}

	return r;
}

Real DGConcentrationFluxBC::computeQpJacobian()
{
	_velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

	Real r = 0;

	//Output
	if ((_velocity)*_normals[_qp] > 0.0)
	{
		r += _test[_i][_qp]*(_velocity*_normals[_qp])*_phi[_j][_qp];
	}
	//Input
	else
	{
		r += 0.0;
	}

	return r;
}

Real DGConcentrationFluxBC::computeQpOffDiagJacobian(unsigned int jvar)
{
	_velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

	Real r = 0;

	if (jvar == _ux_var)
	{
		//Output
		if ((_velocity)*_normals[_qp] > 0.0)
		{
			r += _test[_i][_qp]*_u[_qp]*(_phi[_j][_qp]*_normals[_qp](0));
		}
		//Input
		else
		{
			r += _test[_i][_qp]*_u_input*(_phi[_j][_qp]*_normals[_qp](0));
		}
		return r;
	}

	if (jvar == _uy_var)
	{
		//Output
		if ((_velocity)*_normals[_qp] > 0.0)
		{
			r += _test[_i][_qp]*_u[_qp]*(_phi[_j][_qp]*_normals[_qp](1));
		}
		//Input
		else
		{
			r += _test[_i][_qp]*_u_input*(_phi[_j][_qp]*_normals[_qp](1));
		}
		return r;
	}

	if (jvar == _uz_var)
	{
		//Output
		if ((_velocity)*_normals[_qp] > 0.0)
		{
			r += _test[_i][_qp]*_u[_qp]*(_phi[_j][_qp]*_normals[_qp](2));
		}
		//Input
		else
		{
			r += _test[_i][_qp]*_u_input*(_phi[_j][_qp]*_normals[_qp](2));
		}
		return r;
	}

	return 0.0;
}
