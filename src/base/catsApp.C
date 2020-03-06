#include "catsApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
catsApp::validParams()
{
  InputParameters params = MooseApp::validParams();

  // Do not use legacy DirichletBC, that is, set DirichletBC default for preset = true
  params.set<bool>("use_legacy_dirichlet_bc") = false;

  return params;
}

catsApp::catsApp(InputParameters parameters) : MooseApp(parameters)
{
  catsApp::registerAll(_factory, _action_factory, _syntax);
}

catsApp::~catsApp() {}

void
catsApp::registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ModulesApp::registerAll(f, af, s);
  Registry::registerObjectsTo(f, {"catsApp"});
  Registry::registerActionsTo(af, {"catsApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
catsApp::registerApps()
{
  registerApp(catsApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
catsApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  catsApp::registerAll(f, af, s);
}
extern "C" void
catsApp__registerApps()
{
  catsApp::registerApps();
}
