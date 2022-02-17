/*!
 *  \file DGFlowMassFluxBC.h
 *	\brief Boundary Condition kernel for the flux of mass/density across a boundary of the domain
 *	\details This file creates a generic boundary condition kernel for the flux of matter accross
 *			a boundary. The flux is based on a velocity vector, as well as domain porosity, and is valid
 *			in all directions and all boundaries of a DG method. Since the DG method's flux boundary
 *			conditions are essitially the same for input and ouput boundaries, this kernel will check
 *			the sign of the flux normal to the boundary and determine automattically whether it is
 *			an output or input boundary, then apply the appropriate conditions.
 *
 *      User provides a variable for the inlet condition, thus, allowing the user to provide an
 *      inlet as a function of space-time or other non-linear relations through the Auxilary system.
 *
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic equations:
 *                    Theory and Implementation, SIAM, Houston, TX, 2008.
 *
 *
 *  \author Austin Ladshaw
 *	\date 01/14/2022
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "DGFlowMassFluxBC.h"

registerMooseObject("catsApp", DGFlowMassFluxBC);

InputParameters DGFlowMassFluxBC::validParams()
{
    InputParameters params = DGPoreConcFluxBC::validParams();
    params.addCoupledVar("input_var",0,"Variable for the inlet condition");
    return params;
}

DGFlowMassFluxBC::DGFlowMassFluxBC(const InputParameters & parameters) :
DGPoreConcFluxBC(parameters),
_input(coupledValue("input_var")),
_input_var(coupled("input_var"))
{

}

Real DGFlowMassFluxBC::computeQpResidual()
{
  _u_input = _input[_qp];
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

Real DGFlowMassFluxBC::computeQpJacobian()
{
  _u_input = _input[_qp];
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

Real DGFlowMassFluxBC::computeQpOffDiagJacobian(unsigned int jvar)
{
  _u_input = _input[_qp];
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

  if (jvar == _input_var)
  {
    //Output
    if ((_velocity)*_normals[_qp] > 0.0)
    {
      r += 0;
    }
    //Input
    else
    {
      r += _test[_i][_qp]*(_velocity*_normals[_qp])*_phi[_j][_qp]*_porosity[_qp];
    }
    return r;
  }

	return 0.0;
}
