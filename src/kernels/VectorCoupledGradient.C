#include "VectorCoupledGradient.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", VectorCoupledGradient);

InputParameters VectorCoupledGradient::validParams()
{
    InputParameters params = Kernel::validParams();
    params.addRequiredCoupledVar("coupled","Variable that we couple the gradient to");
    params.addParam<Real>("vx",0, "x-component of vector");
    params.addParam<Real>("vy",0,"y-component of vector");
    params.addParam<Real>("vz",0,"z-component of vector");
    return params;
}

VectorCoupledGradient::VectorCoupledGradient(const InputParameters & parameters) :
Kernel(parameters),
_vx(getParam<Real>("vx")),
_vy(getParam<Real>("vy")),
_vz(getParam<Real>("vz")),
_coupled_grad(coupledGradient("coupled")),
_coupled_var(coupled("coupled"))
{
  _vec(0)=_vx;
	_vec(1)=_vy;
	_vec(2)=_vz;
}

Real VectorCoupledGradient::computeQpResidual()
{
    return _test[_i][_qp]*(_vec*_coupled_grad[_qp]);
}

Real VectorCoupledGradient::computeQpJacobian()
{
    return 0.0;
}

Real VectorCoupledGradient::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _coupled_var)
  {
      return _test[_i][_qp]*(_vec*_grad_phi[_j][_qp]);
  }
  return 0.0;
}
