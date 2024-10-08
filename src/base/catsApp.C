#include "catsApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
catsApp::validParams()
{
  InputParameters params = MooseApp::validParams();

  return params;
}

catsApp::catsApp(InputParameters parameters) : MooseApp(parameters)
{
  catsApp::registerAll(_factory, _action_factory, _syntax);
}

catsApp::~catsApp() {}

void
catsApp::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  ModulesApp::registerAllObjects<catsApp>(f, af, syntax);
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
