/*!
 *  \file DGPoreConcFluxBC.h
 *	\brief Boundary Condition kernel for the flux of concentration/density across a boundary of the domain
 *	\details This file creates a generic boundary condition kernel for the flux of matter accross
 *			a boundary. The flux is based on a velocity vector, as well as domain porosity, and is valid
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
 *	\date 03/09/2020
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
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

#include "DGPoreConcFluxBC.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", DGPoreConcFluxBC);

/*
template<>
InputParameters validParams<DGPoreConcFluxBC>()
{
	InputParameters params = validParams<DGConcentrationFluxBC>();
	params.addRequiredCoupledVar("porosity","Variable for the porosity of the domain/subdomain");
	return params;
}
 */

InputParameters DGPoreConcFluxBC::validParams()
{
    InputParameters params = DGConcentrationFluxBC::validParams();
    params.addRequiredCoupledVar("porosity","Variable for the porosity of the domain/subdomain");
    return params;
}

DGPoreConcFluxBC::DGPoreConcFluxBC(const InputParameters & parameters) :
DGConcentrationFluxBC(parameters),
_porosity(coupledValue("porosity")),
_porosity_var(coupled("porosity"))
{

}

Real DGPoreConcFluxBC::computeQpResidual()
{
	_velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

	Real r = 0;

	//Output
	if ((_velocity)*_normals[_qp] > 0.0)
	{
		r += _test[_i][_qp]*(_velocity*_normals[_qp])*_u[_qp]*_porosity[_qp];
	}
	//Input
	else
	{
		r += _test[_i][_qp]*(_velocity*_normals[_qp])*_u_input*_porosity[_qp];
	}

	return r;
}

Real DGPoreConcFluxBC::computeQpJacobian()
{
	_velocity(0)=_ux[_qp];
	_velocity(1)=_uy[_qp];
	_velocity(2)=_uz[_qp];

	Real r = 0;

	//Output
	if ((_velocity)*_normals[_qp] > 0.0)
	{
		r += _test[_i][_qp]*(_velocity*_normals[_qp])*_phi[_j][_qp]*_porosity[_qp];
	}
	//Input
	else
	{
		r += 0.0;
	}

	return r;
}

Real DGPoreConcFluxBC::computeQpOffDiagJacobian(unsigned int jvar)
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
			r += _test[_i][_qp]*_u[_qp]*(_phi[_j][_qp]*_normals[_qp](0))*_porosity[_qp];
		}
		//Input
		else
		{
			r += _test[_i][_qp]*_u_input*(_phi[_j][_qp]*_normals[_qp](0))*_porosity[_qp];
		}
		return r;
	}

	if (jvar == _uy_var)
	{
		//Output
		if ((_velocity)*_normals[_qp] > 0.0)
		{
			r += _test[_i][_qp]*_u[_qp]*(_phi[_j][_qp]*_normals[_qp](1))*_porosity[_qp];
		}
		//Input
		else
		{
			r += _test[_i][_qp]*_u_input*(_phi[_j][_qp]*_normals[_qp](1))*_porosity[_qp];
		}
		return r;
	}

	if (jvar == _uz_var)
	{
		//Output
		if ((_velocity)*_normals[_qp] > 0.0)
		{
			r += _test[_i][_qp]*_u[_qp]*(_phi[_j][_qp]*_normals[_qp](2))*_porosity[_qp];
		}
		//Input
		else
		{
			r += _test[_i][_qp]*_u_input*(_phi[_j][_qp]*_normals[_qp](2))*_porosity[_qp];
		}
		return r;
	}

  if (jvar == _porosity_var)
  {
    //Output
    if ((_velocity)*_normals[_qp] > 0.0)
    {
      r += _test[_i][_qp]*_u[_qp]*(_velocity*_normals[_qp])*_phi[_j][_qp];
    }
    //Input
    else
    {
      r += _test[_i][_qp]*_u_input*(_velocity*_normals[_qp])*_phi[_j][_qp];
    }
    return r;
  }

	return 0.0;
}
