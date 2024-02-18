/*!
 *  \file error.h error.cpp
 *	\brief All error types are defined here
 *	\details This file defines all the different errors that may occur in any simulation
 *			in any file. Those errors are recognized by an enum with is then passed through
 *			to the error.cpp file that customizes the error message to the console. A macro will
 *			also print out the file name and line number where the error occured.
 *  \author Austin Ladshaw
 *	\date 04/28/2014
 *	\copyright This software was designed and built at the Georgia Institute
 *             of Technology by Austin Ladshaw for PhD research in the area
 *             of adsorption and surface science. Copyright (c) 2015, all
 *             rights reserved.
 */

#ifndef ERROR_HPP_
#define ERROR_HPP_

#include <iostream> //Line to allow for read/write to the console using cpp functions

#ifndef mError
#define mError(i)                                                                                  \
  {                                                                                                \
    error(i);                                                                                      \
    std::cout << "Source: " << __FILE__ << "\nLine: " << __LINE__ << std::endl;                    \
  }
#endif

/// List of names for error type
typedef enum
{
  generic_error,
  file_dne,
  indexing_error,
  magpie_reverse_error,
  simulation_fail,
  invalid_components,
  invalid_boolean,
  invalid_molefraction,
  invalid_gas_sum,
  invalid_solid_sum,
  scenario_fail,
  out_of_bounds,
  non_square_matrix,
  dim_mis_match,
  empty_matrix,
  opt_no_support,
  invalid_fraction,
  ortho_check_fail,
  unstable_matrix,
  no_diffusion,
  negative_mass,
  negative_time,
  matvec_mis_match,
  arg_matrix_same,
  singular_matrix,
  matrix_too_small,
  invalid_size,
  nullptr_func,
  invalid_norm,
  vector_out_of_bounds,
  zero_vector,
  tensor_out_of_bounds,
  non_real_edge,
  nullptr_error,
  invalid_atom,
  invalid_proton,
  invalid_neutron,
  invalid_electron,
  invalid_valence,
  string_parse_error,
  unregistered_name,
  rxn_rate_error,
  invalid_species,
  duplicate_variable,
  missing_information,
  invalid_type,
  key_not_found,
  anchor_alias_dne,
  initial_error,
  not_a_token,
  read_error,
  invalid_console_input,
  explicit_invalid,
  distribution_impossible,
  invalid_isotope
} error_type;

/// Error function customizes output message based on flag
/** This error function is reference in the error.cpp file, but is not called by any other
  file. Instead, all other files call the mError(i) macro that expands into this error
  function call plus prints out the file name and line number where the error occured. */
void error(int flag);

#endif
