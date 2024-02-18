/*!
 *  \file macaw.h macaw.cpp
 *	\brief MAtrix CAlculation Workspace
 *	\details This is a small C++ library that faciltates the use and construction of
 *		real matrices using vector objects. The MATRIX class is templated so that users
 *		are able to work with matrices of any type including, but not limited to: (i)
 *		doubles, (ii) ints, (iii) floats, and (iv) even other matrices! Routines and
 *		functions are defined for Dense matrix operations. As a result, we typically
 *		only use Column Matrices (or Vectors) when doing any actual simulations. However,
 *		the development of this class was integral to the development and testing of the
 *		Sparse matrix operators in lark.h.
 *
 *		While the primary goal of this object was to define how to operate on real matrices,
 *		we could extend this idea to complex matrices as well. For this, we could develop
 *		objects that represent imaginary and complex numbers and then create a MATRIX of
 *		those objects. For this reason, the matrix operations here are all templated to
 *		abstract away the specificity of the type of matrix being operated on.
 *
 *  \author Austin Ladshaw
 *	\date 01/07/2014
 *	\copyright This software was designed and built at the Georgia Institute
 *             of Technology by Austin Ladshaw for PhD research in the area
 *             of adsorption and surface science. Copyright (c) 2015, all
 *             rights reserved.
 */

#ifndef MACAW_HPP_
#define MACAW_HPP_

#include <stdio.h>   //Line to allow cout functionality
#include <math.h>    //Line added to allow usage of the pow (e, x) function
#include <iostream>  //Line to allow for read/write to the console using cpp functions
#include <fstream>   //Line to allow for read/write to and from .txt files
#include <stdlib.h>  //Line need to convert strings to doubles
#include <vector>    //Line needed to use dynamic arrays called vectors
#include <time.h>    //Line needed to display program runtime
#include <float.h>   //Line to allow use of machine precision constants
#include <string>    //Line to allow use of strings as a data type
#include <exception> //Line to allow use of try-catch statements
#include "error.h"

#ifndef M_PI
#define M_PI 3.14159265358979323846264338327950288 ///< Value of PI with double precision
#endif

/// Templated C++ MATRIX Class Object (click MATRIX to go to function definitions)
/** C++ templated class object containing many different functions, actions, and solver
  routines associated with Dense Matrices. Operator overloads are also provided to
  give the user a more natural way of operating matrices on other matrices or scalars.
  These operator overloads are especially useful for reducing the amount of code needed
  to be written when working with matrix-based problems. */
template <class T>
class MATRIX
{
public:
  // Generalized MATRIX Operations
  MATRIX(int rows, int columns); ///< Constructor for matrix with given number of rows and columns
  T & operator()(
      int i,
      int j); ///< Access operator for the matrix element at row i and column j (e.g., aij = A(i,j))
  T operator()(int i, int j)
      const; ///< Constant access operator for the the matrix element at row i and column j
  MATRIX(
      const MATRIX & M); ///< Copy constructor for constructing a matrix as a copy of another matrix
  MATRIX &
  operator=(const MATRIX & M); ///< Equals operator for setting one matrix equal to another matrix
  MATRIX();                    ///< Default constructor for creating an empty matrix
  ~MATRIX();                   ///< Default destructor for clearing out memory
  void set_size(int i,
                int j); ///< Function to set/change the size of a matrix to i rows and j columns
  void zeros();         ///< Function to set/change all values in a matrix to zeros
  void edit(
      int i,
      int j,
      T value); ///< Function to set/change the element of a matrix at row i and column j to given value
  int rows();      ///< Function to return the number of rows in a given matrix
  int columns();   ///< Function to return the number of columns in a matrix
  T determinate(); ///< Function to compute the determinate of a matrix and return that value
  T norm();        ///< Function to compute the L2-norm of a matrix and return that value
  T sum(); ///< Function to compute the sum of all elements in a matrix and return that value
  T inner_product(
      const MATRIX & x); ///< Function to compute the inner product between this matrix and matrix x
  MATRIX &
  cofactor(const MATRIX &
               M); ///< Function to convert this matrix to a cofactor matrix of the given matrix M
  MATRIX
  operator+(const MATRIX &
                M); ///< Operator to add this matrix and matrix M and return the new matrix result
  MATRIX operator-(
      const MATRIX &
          M); ///< Operator to subtract this matrix and matrix M and return the new matrix result
  MATRIX operator*(
      const T); ///< Operator to multiply this matrix by a scalar T return the new matrix result
  MATRIX operator/(
      const T); ///< Operator to divide this matrix by a scalar T and return the new matrix result
  MATRIX operator+(
      const T); ///< Operator to add this matrix to a scalar T and return the new matrix result
  MATRIX operator-(
      const T); ///< Operator to subtract this matrix to a scalar T and return the new matrix result
  MATRIX operator*(
      const MATRIX &
          M); ///< Operator to multiply this matrix and matrix M and return the new matrix result
  MATRIX outer_product(
      const MATRIX &
          M); ///< Operator to perform an outer product between this and M and return result
  MATRIX & transpose(
      const MATRIX & M); ///< Function to convert this matrix to the transpose of the given matrix M
  /// Function to convert this matrix into the result of the given matrix M transposed and multiplied by the other given matrix v
  MATRIX & transpose_multiply(const MATRIX & MT, const MATRIX & v);
  MATRIX &
  adjoint(const MATRIX & M); ///< Function to convert this matrix to the adjoint of the given matrix
  MATRIX &
  inverse(const MATRIX & M); ///< Function to convert this matrix to the inverse of the given matrix
  void Display(
      const std::string
          Name); ///< Function to display the contents of this matrix given a Name for the matrix

  // Specialized MATRIX Operations for 1-D FDM
  MATRIX & tridiagonalSolve(
      const MATRIX & A,
      const MATRIX & b); ///< Function to solve Ax=b for x if A is symmetric, tridiagonal (this->x)
  MATRIX & ladshawSolve(
      const MATRIX & A,
      const MATRIX &
          d); ///< Function to solve Ax=d for x if A is non-symmetric, tridiagonal (this->x)

  /// Function to fill in this matrix with coefficients A, B, and C to form a tridiagonal matrix
  /** This function fills in the diagonal elements of a square matrix with coefficient B, upper
    diagonal with C, and lower diagonal with A. The boolean will apply a transformation to those
    coefficients, if the problem happens to stem from 1-D diffusion in spherical coordinates. */
  MATRIX & tridiagonalFill(const T A, const T B, const T C, bool Spherical);

  /// Function to fill out this matrix with coefficients from a 3D Laplacian function
  /** This function will fill out the coefficients of the matrix with the coefficients that stem
    from discretizing a 3D Laplacian on a natural grid with 2nd order finite differences. */
  MATRIX & naturalLaplacian3D(int m);

  /// Function to fill out a column matrix with spherical specific boundary conditions
  /** This function will fille out a column matrix with zeros at all nodes expect for the node
    indicated. That node's value will be the product of the node id with the coeff and variable
    values given. */
  MATRIX & sphericalBCFill(int node, const T coeff, T variable);

  /// Function to set all values in a column matrix to a given constant
  MATRIX & ConstantICFill(const T IC);

  // Specialized MATRIX Operations for SKIMMER
  MATRIX & SolnTransform(
      const MATRIX & A,
      bool
          Forward); ///< Function to transform the values in a column matrix from cartesian to spherical coordinates

  /// Function to compute a spatial average of this column matrix in spherical coordinates
  /** This function is used to compute an average value of a variable, represented in this column
    matrix, by integrating over the domain of the sphere. (Assumes you have variable value at center
    node)

    \param radius radius of the sphere
    \param dr space between each node
    \param bound value of the variable at the boundary
    \param Dirichlet True if problem has a Dirichlet BC, False if Neumann*/
  T sphericalAvg(double radius, double dr, double bound, bool Dirichlet);

  /// Function to compute a spatial average of this column matrix in spherical coordinates
  /** This function is used to compute an average value of a variable, represented in this column
    matrix, by integrating over the domain of the sphere. (Assumes you DO NOT have variable value at
    center node)

    \param radius radius of the sphere
    \param dr space between each node
    \param bound value of the variable at the boundary
    \param Dirichlet True if problem has a Dirichlet BC, False if Neumann*/
  T IntegralAvg(double radius, double dr, double bound, bool Dirichlet);

  /// Function to compute a spatial total of this column matrix in spherical coordinates
  /** This function is used to compute an average value of a variable, represented in this column
    matrix, by integrating over the domain of the sphere. (Assumes you DO NOT have variable value at
    center node)

    \param dr space between each node
    \param bound value of the variable at the boundary
    \param Dirichlet True if problem has a Dirichlet BC, False if Neumann*/
  T IntegralTotal(double dr, double bound, bool Dirichlet);

  // Specialized MATRIX Operations for 1-D Conservation Laws

  /// Function to fill in this matrix, in tridiagonal fashion, using the vectors of coefficients
  MATRIX & tridiagonalVectorFill(const std::vector<T> & A,
                                 const std::vector<T> & B,
                                 const std::vector<T> & C);

  /// Function to fill in a column matrix with the values of the given vector object
  MATRIX & columnVectorFill(const std::vector<T> & A);

  /// Function to project a column matrix solution in time based on older state vectors
  /** This function is used in finch.h to form MATRIX u_star. It uses the size of the current step
    and old step, dt and dt_old respectively, to form an approximation for the next state. The
    current state and olde state of the variables are passed as b and b_old respectively. */
  MATRIX &
  columnProjection(const MATRIX & b, const MATRIX & b_old, const double dt, const double dt_old);

  /// Function to fill in a column matrix with all zeros except at the given node
  /** Similar to sphericalBCFill, this function will set the values of all elements in the column
    matrix to zero except at the given node, where the value is set to the product of coeff and
    variable. This is often used to set BCs in finch.h or other related files/simulations. */
  MATRIX & dirichletBCFill(int node, const T coeff, T variable);

  // MATRIX operations for functions focused on Krylov, GMRES, and PJFNK methods

  /// Function to solve the system Dx=v for x given that D is diagonal (this->x)
  MATRIX & diagonalSolve(const MATRIX & D, const MATRIX & v);

  /// Function to solve the system Ux=v for x given that U is upper Triagular (this->x)
  MATRIX & upperTriangularSolve(const MATRIX & U, const MATRIX & v);

  /// Function to solve the system Lx=v for x given that L is lower Triagular (this->x)
  MATRIX & lowerTriangularSolve(const MATRIX & L, const MATRIX & v);

  /// Function to convert this square matrix to upper Triangular (assuming this is upper Hessenberg)
  /** During this transformation, a column vector (b) is also being transformed to represent the BCs
    in a linear system. This algorithm uses Givens Rotations to efficiently convert the upper
    Hessenberg matrix to an upper triangular matrix. */
  MATRIX & upperHessenberg2Triangular(MATRIX & b);

  /// Function to convert this square matrix to lower Triangular (assuming this is lower Hessenberg)
  /** During this transformation, a column vector (b) is also being transformed to represent the BCs
    in a linear system. This algorithm uses Givens Rotations to efficiently convert the lower
    Hessenberg matrix to an lower triangular matrix. */
  MATRIX & lowerHessenberg2Triangular(MATRIX & b);

  /// Function to solve the system Hx=v for x given that H is upper Hessenberg (this->x)
  MATRIX & upperHessenbergSolve(const MATRIX & H, const MATRIX & v);

  /// Function to solve the system Hx=v for x given that H is lower Hessenberg (this->x)
  MATRIX & lowerHessenbergSolve(const MATRIX & H, const MATRIX & v);

  /// Function to solve the system Mx=b using QR factorization for x given that M is invertable
  MATRIX & qrSolve(const MATRIX & M, const MATRIX & b);

  MATRIX & columnExtract(
      int j,
      const MATRIX &
          M); ///< Function to set this column matrix to the jth column of the given matrix M
  MATRIX & rowExtract(
      int i,
      const MATRIX & M); ///< Function to set this row matrix to the ith row of the given matrix M
  MATRIX & columnReplace(
      int j,
      const MATRIX & v); ///< Function to this matrices' jth column with the given column matrix v
  MATRIX &
  rowReplace(int i,
             const MATRIX & v); ///< Function to this matrices' ith row with the given row matrix v
  void rowShrink();             ///< Function to delete the last row of this matrix
  void columnShrink();          ///< Function to delete the last column of this matrix
  void rowExtend(const MATRIX & v); ///< Function to add the row matrix v to the end of this matrix
  void
  columnExtend(const MATRIX & v); ///< Function to add the column matrix v to the end of this matrix

protected:
  int num_rows;        ///< Number of rows of the matrix
  int num_cols;        ///< Number of columns of the matrix
  std::vector<T> Data; ///< Storage vector for the elements of the matrix
};

// Defined methods for the template class
template <class T>
MATRIX<T>::MATRIX(int rows, int columns) : num_rows(rows), num_cols(columns), Data(rows * columns)
{
}

// For setting values
template <class T>
T &
MATRIX<T>::operator()(int i, int j)
{
  if (i >= num_rows || j >= num_cols || i < 0 || j < 0)
  {
    mError(out_of_bounds);
    return Data[0];
  }
  else
    return Data[(i * num_cols) + j];
}

// For accessing values
template <class T>
T
MATRIX<T>::operator()(int i, int j) const
{
  if (i >= num_rows || j >= num_cols || i < 0 || j < 0)
  {
    mError(out_of_bounds);
    return Data[0];
  }
  else
  {
    return Data[(i * num_cols) + j];
  }
}

// For copying a matrix at initialization
template <class T>
MATRIX<T>::MATRIX(const MATRIX & M)
  : num_rows(M.num_rows), num_cols(M.num_cols), Data(M.num_rows * M.num_cols)
{
  for (int i = 0; i < num_rows; i++)
  {
    for (int j = 0; j < num_cols; j++)
    {
      Data[(i * num_cols) + j] = M.Data[(i * M.num_cols) + j];
    }
  }
}

// For setting one matrix equal to anther of same size
template <class T>
MATRIX<T> &
MATRIX<T>::operator=(const MATRIX & M)
{
  if (this == &M)
  {
    return *this;
  }
  else
  {
    if (num_rows != M.num_rows || num_cols != M.num_cols)
    {
      Data.clear();
      num_rows = M.num_rows;
      num_cols = M.num_cols;
      Data.resize(num_rows * num_cols);
    }
    for (int i = 0; i < num_rows; i++)
    {
      for (int j = 0; j < num_cols; j++)
      {
        Data[(i * num_cols) + j] = M.Data[(i * M.num_cols) + j];
      }
    }
    return *this;
  }
}

// Default Constructor
template <class T>
MATRIX<T>::MATRIX() : Data(1)
{
  num_cols = 1;
  num_rows = 1;
}

// Default Destructor
template <class T>
MATRIX<T>::~MATRIX()
{
  Data.clear();
}

// Allocate size
template <class T>
void
MATRIX<T>::set_size(int i, int j)
{
  if (i <= 0 || j <= 0)
  {
    mError(invalid_size);
    return;
  }
  num_rows = i;
  num_cols = j;
  Data.clear();
  Data.resize(i * j);
}

// Reset all existing matrix entries to zero
template <class T>
void
MATRIX<T>::zeros()
{
  for (int n = 0; n < this->Data.size(); n++)
    this->Data[n] = 0;
}

// Add/Change an element to a sparse matrix
template <class T>
void
MATRIX<T>::edit(int i, int j, T value)
{
  if (i >= num_rows || j >= num_cols || i < 0 || j < 0)
  {
    mError(out_of_bounds);
    return;
  }
  this->Data[(i * this->num_cols) + j] = value;
}

// Function to return the number of rows in the matrix
template <class T>
int
MATRIX<T>::rows()
{
  return this->num_rows;
}

// Function to return the number of columns in the matrix
template <class T>
int
MATRIX<T>::columns()
{
  return this->num_cols;
}

// Function to determine the determinate of a matrix
template <class T>
T
MATRIX<T>::determinate()
{
  T det = 0;
  if (num_rows != num_cols)
  {
    mError(non_square_matrix);
    return 0.0;
  }
  else if (num_rows == 2)
  {
    return (Data[0] * Data[3]) - (Data[1] * Data[2]);
  }
  else if (num_rows == 1)
  {
    return Data[0];
  }
  else
  {
    int I = 0;
    int J = 0;
    for (int k = 0; k < num_cols; k++)
    {
      // Pivoting
      if (Data[k] == 0)
      {
        det = det + 0;
        break;
      }
      MATRIX<T> temp((num_rows - 1), (num_cols - 1));
      int r = 0;
      int c = 0;
      for (int i = 0; i < num_rows; i++)
      {
        for (int j = 0; j < num_cols; j++)
        {
          if (i != I && j != J)
          {
            temp(r, c) = Data[(i * num_cols) + j];
            if (c < (temp.num_cols) - 1)
              c++;
          }
        }
        c = 0;
        if (i != I)
        {
          if (r < (temp.num_rows) - 1)
            r++;
        }
      } // Filled out temp

      det = det + (pow(-1, k) * Data[(0 + k)] * temp.determinate());
      if (J < (num_cols - 1))
      {
        J++;
      }
      else
      {
        J = 0;
        I++;
      }
      temp.Data.clear();
    } // End of column loop

    return det;
  }
}

// Calculates the 2-Norm of a matrix or vector
template <class T>
T
MATRIX<T>::norm()
{
  T norm = 0;
  /*Note: if M is a vector, this returns the 2-Norm,
   else if M is a matrix it returns the
   Frobenius Norm of that matrix
   */

  for (int i = 0; i < num_rows; i++)
  {
    for (int j = 0; j < num_cols; j++)
    {
      norm = norm + pow(fabs(Data[(i * num_cols) + j]), 2.0);
    }
  }
  norm = sqrt(norm);
  return norm;
}

// Calcuates the sum of all entries
template <class T>
T
MATRIX<T>::sum()
{
  T sum = 0;
  for (int i = 0; i < num_rows; i++)
  {
    for (int j = 0; j < num_cols; j++)
    {
      sum = sum + Data[(i * num_cols) + j];
    }
  }
  return sum;
}

// Calculates the inner product of two vectors
template <class T>
T
MATRIX<T>::inner_product(const MATRIX & x)
{
  T prod = 0;
  if (x.num_cols != 1 || num_cols != 1)
  {
    mError(dim_mis_match);
    std::cout << "Inner Product can only be performed on vectors!" << std::endl;
    return prod;
  }
  else if (x.num_rows != num_rows)
  {
    mError(dim_mis_match);
    return prod;
  }
  else
  {
    for (int i = 0; i < x.num_rows; i++)
    {
      prod = prod + x.Data[(i * x.num_cols) + 0] * Data[(i * num_cols) + 0];
    }
  }
  return prod;
}

// Forming the cofactor of a square matrix
template <class T>
MATRIX<T> &
MATRIX<T>::cofactor(const MATRIX & M)
{
  if (this == &M)
  {
    mError(arg_matrix_same);
    return *this;
  }
  num_rows = M.num_rows;
  num_cols = M.num_cols;
  this->Data.resize(num_rows * num_cols);
  if (M.num_rows != M.num_cols)
  {
    mError(non_square_matrix);
    return *this;
  }
  else if (M.num_rows == 2)
  {
    this->Data[0] = M.Data[3];
    this->Data[1] = -M.Data[2];
    this->Data[2] = -M.Data[1];
    this->Data[3] = M.Data[0];
    return *this;
  }
  else if (M.num_rows == 1)
  {
    return *this;
  }
  else
  {
    int I = 0; // row index of cofactor
    int J = 0; // col index of cofactor
    // Loop for all elements in cofactor
    for (int k = 0; k < (M.num_rows * M.num_cols); k++)
    {
      MATRIX<T> temp((M.num_rows - 1), (M.num_cols - 1));

      int r = 0; // row index of temp
      int c = 0; // col index of temp

      // Loop for all rows of M
      for (int i = 0; i < M.num_rows; i++)
      {
        // Loop for all cols of M
        for (int j = 0; j < M.num_cols; j++)
        {
          if (i != I && j != J)
          {
            temp(r, c) = M.Data[(i * M.num_cols) + j];
            if (c < (temp.num_cols) - 1)
              c++;
          }
        }
        c = 0;
        if (i != I)
        {
          if (r < (temp.num_rows) - 1)
            r++;
        }
      }
      this->Data[(I * num_cols) + J] = pow(-1, (I + J)) * temp.determinate();
      if (J < (M.num_cols - 1))
      {
        J++;
      }
      else
      {
        J = 0;
        I++;
      }
      temp.Data.clear();
    }
    return *this;
  }
}

// MATRIX addition
template <class T>
MATRIX<T>
MATRIX<T>::operator+(const MATRIX & M)
{
  if (num_rows != M.num_rows && num_cols != M.num_cols)
  {
    mError(dim_mis_match);
    return *this;
  }
  else
  {
    MATRIX<T> temp(num_rows, num_cols);
    for (int i = 0; i < num_rows; i++)
    {
      for (int j = 0; j < num_cols; j++)
      {
        temp.Data[(i * num_cols) + j] =
            this->Data[(i * num_cols) + j] + M.Data[(i * M.num_cols) + j];
      }
    }
    return temp;
  }
}

// MATRIX subtraction
template <class T>
MATRIX<T>
MATRIX<T>::operator-(const MATRIX & M)
{
  if (num_rows != M.num_rows && num_cols != M.num_cols)
  {
    mError(dim_mis_match);
    return *this;
  }
  else
  {
    MATRIX<T> temp(num_rows, num_cols);
    for (int i = 0; i < num_rows; i++)
    {
      for (int j = 0; j < num_cols; j++)
      {
        temp.Data[(i * num_cols) + j] =
            this->Data[(i * num_cols) + j] - M.Data[(i * M.num_cols) + j];
      }
    }
    return temp;
  }
}

// MATRIX scalar multiplication
template <class T>
MATRIX<T>
MATRIX<T>::operator*(const T a)
{
  MATRIX<T> temp(num_rows, num_cols);
  for (int i = 0; i < num_rows; i++)
  {
    for (int j = 0; j < num_cols; j++)
    {
      temp.Data[(i * num_cols) + j] = a * this->Data[(i * num_cols) + j];
    }
  }
  return temp;
}

// MATRIX scalar division
template <class T>
MATRIX<T>
MATRIX<T>::operator/(const T a)
{
  MATRIX<T> temp(num_rows, num_cols);
  for (int i = 0; i < num_rows; i++)
  {
    for (int j = 0; j < num_cols; j++)
    {
      temp.Data[(i * num_cols) + j] = this->Data[(i * num_cols) + j] / a;
    }
  }
  return temp;
}

// MATRIX scalar addition
template <class T>
MATRIX<T>
MATRIX<T>::operator+(const T a)
{
  MATRIX<T> temp(num_rows, num_cols);
  for (int i = 0; i < num_rows; i++)
  {
    for (int j = 0; j < num_cols; j++)
    {
      temp.Data[(i * num_cols) + j] = this->Data[(i * num_cols) + j] + a;
    }
  }
  return temp;
}

// MATRIX scalar subtraction
template <class T>
MATRIX<T>
MATRIX<T>::operator-(const T a)
{
  MATRIX<T> temp(num_rows, num_cols);
  for (int i = 0; i < num_rows; i++)
  {
    for (int j = 0; j < num_cols; j++)
    {
      temp.Data[(i * num_cols) + j] = this->Data[(i * num_cols) + j] - a;
    }
  }
  return temp;
}

// MATRIX  multiplication
template <class T>
MATRIX<T>
MATRIX<T>::operator*(const MATRIX & M)
{
  if (num_cols != M.num_rows)
  {
    mError(dim_mis_match);
    return *this;
  }
  else
  {
    MATRIX<T> temp(num_rows, M.num_cols);
    temp.num_rows = num_rows;
    temp.num_cols = M.num_cols;
    temp.Data.resize(num_rows * M.num_cols);

    for (int i = 0; i < num_rows; i++)
    {
      for (int k = 0; k < num_cols; k++)
      {
        for (int j = 0; j < M.num_cols; j++)
        {
          temp.Data[(i * temp.num_cols) + j] +=
              (this->Data[(i * num_cols) + k] * M.Data[(k * M.num_cols) + j]);
        }
      }
    }

    return temp;
  }
}

// Formation of new matrix from an outer product
template <class T>
MATRIX<T>
MATRIX<T>::outer_product(const MATRIX & M)
{
  if (this->num_cols != 1 || M.num_cols != 1)
  {
    mError(dim_mis_match);
    return *this;
  }
  if (this->num_rows != M.num_rows)
  {
    mError(dim_mis_match);
    return *this;
  }

  MATRIX<T> result(this->num_rows, M.num_rows);
  result.num_rows = this->num_rows;
  result.num_cols = M.num_rows;
  result.Data.resize(num_rows * M.num_rows);

  for (int i = 0; i < this->num_rows; i++)
  {
    for (int j = 0; j < M.num_rows; j++)
    {
      result.Data[(i * result.num_cols) + j] = this->Data[i] * M.Data[j];
    }
  }

  return result;
}

// Transpose of a matrix
template <class T>
MATRIX<T> &
MATRIX<T>::transpose(const MATRIX & M)
{
  if (this == &M)
  {
    mError(arg_matrix_same);
    return *this;
  }
  // A will be indexed by rows and cols
  this->set_size(M.num_cols, M.num_rows);

  for (int i = 0; i < num_rows; i++)
  {
    for (int j = 0; j < num_cols; j++)
    {
      this->Data[(i * num_cols) + j] = M.Data[(j * M.num_cols) + i];
    }
  }

  return *this;
}

// Transposes the matrix MT then multiplies by matrix v in one step
template <class T>
MATRIX<T> &
MATRIX<T>::transpose_multiply(const MATRIX & MT, const MATRIX & v)
{
  if (MT.num_rows != v.num_rows)
  {
    mError(dim_mis_match);
    return *this;
  }
  else if (this == &MT || this == &v)
  {
    mError(arg_matrix_same);
    return *this;
  }
  else
  {
    this->set_size(MT.num_cols, v.num_cols);
    int j = 0;
    for (int i = 0; i < num_rows; i++)
    {
      for (int J = 0; J < v.num_cols; J++)
      {
        this->Data[(i * num_cols) + J] = 0;
        j = 0;
        for (int I = 0; I < v.num_rows; I++)
        {
          this->Data[(i * num_cols) + J] =
              this->Data[(i * num_cols) + J] +
              (MT.Data[(j * MT.num_cols) + i] * v.Data[(I * v.num_cols) + J]);
          j++;
        }
      }
    }
  }
  return *this;
}

// Adjoint of a square matrix
template <class T>
MATRIX<T> &
MATRIX<T>::adjoint(const MATRIX & M)
{
  if (num_rows != num_cols)
  {
    mError(non_square_matrix);
    return *this;
  }
  else if (this == &M)
  {
    mError(arg_matrix_same);
    return *this;
  }
  else
  {
    this->set_size(M.num_rows, M.num_cols);
    this->transpose(this->cofactor(M));
    return *this;
  }
}

// Inverse of a square matrix
template <class T>
MATRIX<T> &
MATRIX<T>::inverse(const MATRIX & M)
{
  if (num_rows != num_cols)
  {
    mError(non_square_matrix);
    return *this;
  }
  else if (this == &M)
  {
    mError(arg_matrix_same);
    return *this;
  }
  else
  {
    this->set_size(M.num_rows, M.num_cols);
    double det_inv;
    MATRIX<T> A(M);
    det_inv = 1 / A.determinate();
    *this = this->adjoint(A) * det_inv;
    A.Data.clear();
    return *this;
  }
}

// Display MATRIX to console
template <class T>
void
MATRIX<T>::Display(const std::string Name)
{
  std::cout << Name << " = " << std::endl;
  if (num_rows == 0 || num_cols == 0)
  {
    mError(empty_matrix);
    return;
  }
  else
  {
    for (int i = 0; i < num_rows; i++)
    {
      std::cout << "\t";
      for (int j = 0; j < num_cols; j++)
      {
        std::cout << this->Data[(i * num_cols) + j] << "\t";
      }
      std::cout << std::endl;
    }
    std::cout << std::endl;
  }
}

// Function to solve the tridiagonal matrix using the Thomas Algorithm (only for symmetric matrix)
template <class T>
MATRIX<T> &
MATRIX<T>::tridiagonalSolve(const MATRIX & A, const MATRIX & b)
{
  if (this == &A || this == &b)
  {
    mError(arg_matrix_same);
    return *this;
  }
  // Solves the system Ax=b when A is a tridiagonal matrix
  this->set_size(b.num_rows, b.num_cols);

  // Check dimensions of A and b to ensure they will work out
  if (num_rows != A.num_cols || num_cols > 1)
  {
    mError(dim_mis_match);
    return *this;
  }
  // Check the values in A to ensure it is tridiagonal (Skipped)

  /*
   * solve for x (i.e. this)
   * a[i] -> 1 to n-1 (lower diag)
   * c[i] -> 0 to n-2 (upper diag)
   * b[i] -> 0 to n-1 (diag)
   * d[i] -> 0 to n-1 (column vector)
   * cp is c prime and dp is b prime (Ax=b)
   *
   * */
  std::vector<T> cp;
  cp.resize(num_rows - 1);
  std::vector<T> dp;
  dp.resize(num_rows);

  // Forward Sweep
  for (int i = 0; i < num_rows; i++)
  {
    if (i == 0)
    {
      cp[i] = A.Data[(i * A.num_cols) + i + 1] / A.Data[(i * A.num_cols) + i];
      dp[i] = b.Data[i] / A.Data[(i * A.num_cols) + i];
    }
    else if (i < (num_rows - 1))
    {
      cp[i] = A.Data[(i * A.num_cols) + i + 1] /
              (A.Data[(i * A.num_cols) + i] - (cp[(i - 1)] * A.Data[((i + 1) * A.num_cols) + i]));
      dp[i] = (b.Data[i] - (dp[(i - 1)] * A.Data[((i + 1) * A.num_cols) + i])) /
              (A.Data[(i * A.num_cols) + i] - (cp[(i - 1)] * A.Data[((i + 1) * A.num_cols) + i]));
    }
    else
    {
      dp[i] = (b.Data[i] - (dp[(i - 1)] * A.Data[(i * A.num_cols) + i - 1])) /
              (A.Data[(i * A.num_cols) + i] - (cp[(i - 1)] * A.Data[(i * A.num_cols) + i - 1]));
    }
  }

  // Reverse Sweep
  for (int i = (num_rows - 1); i >= 0; i--)
  {
    if (i == (num_rows - 1))
    {
      this->Data[(i * num_cols) + 0] = dp[i];
    }
    else
    {
      this->Data[(i * num_cols) + 0] = dp[i] - (cp[i] * this->Data[((i + 1) * num_cols) + 0]);
    }
  }
  cp.clear();
  dp.clear();

  return *this;
}

// Function to solve the tridiagonal matrix using the My Algorithm (works for any tridiagonal
// matrix)
template <class T>
MATRIX<T> &
MATRIX<T>::ladshawSolve(const MATRIX & A, const MATRIX & d)
{
  if (this == &A || this == &d)
  {
    mError(arg_matrix_same);
    return *this;
  }
  // Solves the system Ax=b when A is a tridiagonal matrix
  this->set_size(d.num_rows, d.num_cols);

  // Check dimensions of A and b to ensure they will work out
  if (num_rows != A.num_cols || num_cols > 1)
  {
    mError(dim_mis_match);
    return *this;
  }

  /*
   * solve for x (i.e. this)
   * a[i] -> 1 to n-1 (lower diag)
   * c[i] -> 0 to n-2 (upper diag)
   * b[i] -> 0 to n-1 (diag)
   * d[i] -> 0 to n-1 (column vector)
   * dp = d' ap = a' cp = c' dpp = d" app = a"
   *
   * */
  std::vector<T> cp;
  cp.resize(num_rows);
  std::vector<T> dp;
  dp.resize(num_rows);
  std::vector<T> ap;
  ap.resize(num_rows);
  std::vector<T> dpp;
  dpp.resize(num_rows);
  std::vector<T> app;
  app.resize(num_rows);

  // Forward Sweep
  for (int i = 0; i < num_rows; i++)
  {
    if (A.Data[(i * A.num_cols) + i] != 0.0)
    {
      if (i == 0)
      {
        ap[i] = 0.0;
        cp[i] = A.Data[(i * A.num_cols) + i + 1] / A.Data[(i * A.num_cols) + i];
      }
      else if (i == (num_rows - 1))
      {
        cp[i] = 0.0;
        ap[i] = A.Data[(i * A.num_cols) + i - 1] / A.Data[(i * A.num_cols) + i];
      }
      else
      {
        ap[i] = A.Data[(i * A.num_cols) + i - 1] / A.Data[(i * A.num_cols) + i];
        cp[i] = A.Data[(i * A.num_cols) + i + 1] / A.Data[(i * A.num_cols) + i];
      }
      dp[i] = d.Data[i] / A.Data[(i * A.num_cols) + i];
    }
    else
    {
      mError(unstable_matrix);
      mError(singular_matrix);
      ap[i] = 0.0;
      cp[i] = 0.0;
      dp[i] = 0.0;
      return *this;
    }
  }

  // Reverse Sweep
  for (int i = (num_rows - 1); i >= 0; i--)
  {
    if (i == (num_rows - 1))
    {
      dpp[i] = dp[i];
      app[i] = ap[i];
    }
    else if (i == 0)
    {
      dpp[i] = (dp[i] - (cp[i] * dpp[(i + 1)])) / (1 - (cp[i] * app[(i + 1)]));
      app[i] = 0;
    }
    else
    {
      dpp[i] = (dp[i] - (cp[i] * dpp[(i + 1)])) / (1 - (cp[i] * app[(i + 1)]));
      app[i] = ap[i] / (1 - (cp[i] * app[(i + 1)]));
    }
  }

  // Forward Sweep
  for (int i = 0; i < num_rows; i++)
  {
    if (i == 0)
      this->Data[(i * num_cols) + 0] = dpp[i];
    else
      this->Data[(i * num_cols) + 0] = dpp[i] - (app[i] * this->Data[((i - 1) * num_cols) + 0]);
  }
  cp.clear();
  dp.clear();
  ap.clear();
  dpp.clear();
  app.clear();

  return *this;
}

// Function to fill in a tridiagonal matrix with constant coefficients
template <class T>
MATRIX<T> &
MATRIX<T>::tridiagonalFill(const T A, const T B, const T C, bool Spherical)
{
  // Check for square matrix
  if (num_cols != num_rows)
  {
    mError(non_square_matrix);
    return *this;
  }

  // A = lower off diag, B = diag, C = upper off diag
  for (int i = 0; i < num_rows; i++)
  {
    for (int j = 0; j < num_cols; j++)
    {
      // Diagonals
      if (i == j)
      {
        if (Spherical == false)
          this->Data[(i * num_cols) + j] = B;
        else
          this->Data[(i * num_cols) + j] = B * (j + 1);
      }
      // Upper Off Diag
      else if (j == (i + 1))
      {
        if (Spherical == false)
          this->Data[(i * num_cols) + j] = C;
        else
          this->Data[(i * num_cols) + j] = C * (j + 1);
      }
      // Lower Off Diag
      else if (j == (i - 1))
      {
        if (Spherical == false)
          this->Data[(i * num_cols) + j] = A;
        else
          this->Data[(i * num_cols) + j] = A * (j + 1);
      }
      else
      {
        this->Data[(i * num_cols) + j] = 0;
      }
    }
  }

  return *this;
}

// Fill in a 3D Laplacian matrix with natural ordering of mesh size m
template <class T>
MATRIX<T> &
MATRIX<T>::naturalLaplacian3D(int m)
{
  int N = m * m * m;
  this->set_size(N, N);
  int r = m;
  int r2 = m * m;
  int r3 = r2;
  int r4 = 0;

  for (int i = 0; i < N; i++)
  {
    // If statements for tridiagonal portion
    this->edit(i, i, 6);
    if (i == 0)
    {
      this->edit(i, i + 1, -1);
    }
    else if (i == N - 1)
    {
      this->edit(i, i - 1, -1);
    }
    else if (i == r - 1)
    {
      this->edit(i, i - 1, -1);
    }
    else if (i == r)
    {
      this->edit(i, i + 1, -1);
      r = r + m;
    }
    else
    {
      this->edit(i, i - 1, -1);
      this->edit(i, i + 1, -1);
    }

    // If statements for 2nd diagonal bands
    if (i > m - 1)
    {
      if (i <= r3 - 1)
      {
        this->edit(i, i - m, -1);
      }
      else if (i > r3 - 1)
      {
        r4 = r4 + 1;
        if (r4 == m - 1)
        {
          r3 = r2;
          r4 = 0;
        }
      }
    }
    if (i <= N - m - 1 && i <= r2 - m - 1)
    {
      this->edit(i, i + m, -1);
    }
    if (i == r2 - 1)
    {
      r2 = r2 + (m * m);
    }

    // If statements for 3rd diagonal bands
    if (i > (m * m) - 1)
    {
      this->edit(i, i - (m * m), -1);
    }
    if (i <= N - (m * m) - 1)
    {
      this->edit(i, i + (m * m), -1);
    }
  }
  return *this;
}

// Fill in the Dirichlet BC for spherical coordinates
template <class T>
MATRIX<T> &
MATRIX<T>::sphericalBCFill(int node, const T coeff, T variable)
{
  if (num_cols > 1)
  {
    mError(dim_mis_match);
    return *this;
  }
  else
  {
    for (int i = 0; i < num_rows; i++)
    {
      if (i == (node - 1))
      {
        this->Data[(i * num_cols) + 0] = (node + 1) * coeff * variable;
      }
      else
      {
        this->Data[(i * num_cols) + 0] = 0;
      }
    }
    return *this;
  }
}

// Fill in the Constant IC for each system
template <class T>
MATRIX<T> &
MATRIX<T>::ConstantICFill(const T IC)
{
  if (num_cols > 1)
  {
    mError(dim_mis_match);
    return *this;
  }
  else
  {
    for (int i = 0; i < num_rows; i++)
    {
      this->Data[(i * num_cols) + 0] = IC;
    }
    return *this;
  }
}

// Transform Solution Forward or Backward based on flag
template <class T>
MATRIX<T> &
MATRIX<T>::SolnTransform(const MATRIX & A, bool Forward)
{
  // Reverse Transform (i.e. q_tilde to q)
  // Forward Transform (i.e. q to q_tilde)
  if (num_cols > 1 || num_rows != A.num_rows)
  {
    mError(dim_mis_match);
    return *this;
  }
  else if (this == &A)
  {
    mError(arg_matrix_same);
    return *this;
  }
  else
  {
    for (int i = 0; i < num_rows; i++)
    {
      if (Forward == true)
        this->Data[(i * num_cols) + 0] = A.Data[(i * num_cols) + 0] * (i + 1);
      else
        this->Data[(i * num_cols) + 0] = A.Data[(i * num_cols) + 0] / (i + 1);
    }
    return *this;
  }
}

// Performs Integral average for spherical coordinates based on matrix data (not given center node)
template <class T>
T
MATRIX<T>::IntegralAvg(double radius, double dr, double bound, bool Dirichlet)
{
  T avg = 0;
  T sum = 0;
  if (num_cols > 1)
  {
    mError(dim_mis_match);
    return 0.0;
  }
  for (int i = 0; i < num_rows; i++)
  {
    if (i == 0)
    {
      // Extrapolation for interior node based on spherical symmetry
      T m, qom, qo;
      m = (this->Data[((i + 1) * num_cols) + 0] - this->Data[(i * num_cols) + 0]) / dr;
      qom = this->Data[(i * num_cols) + 0] - (m * dr);
      qo = (qom + this->Data[(i * num_cols) + 0]) / 2;
      // Prevent negative mass from bad extrapolation
      if (qo < 0)
        qo = 0;

      sum = sum + (((this->Data[(i * num_cols) + 0] + qo) / 2) * (pow((i + 1), 3) - pow(i, 3)));
    }
    else
    {
      sum = sum + (((this->Data[(i * num_cols) + 0] + this->Data[((i - 1) * num_cols) + 0]) / 2) *
                   (pow((i + 1), 3) - pow(i, 3)));
    }
  }
  // Last sum only needed if using Dirichlet BC at particle edge (if bound is 0, no further sums
  // added)
  if (Dirichlet == true)
    sum = sum + (((bound + this->Data[((num_rows - 1) * num_cols) + 0]) / 2) *
                 (pow((num_rows + 1), 3) - pow(num_rows, 3)));
  avg = (pow(dr, 3) * sum) / pow(radius, 3);
  return avg;
}

// Performs Integral average for spherical coordinates based on matrix data (given center node)
template <class T>
T
MATRIX<T>::sphericalAvg(double radius, double dr, double bound, bool Dirichlet)
{
  T avg = 0;
  T sum = 0;
  if (num_cols > 1)
  {
    mError(dim_mis_match);
    return 0.0;
  }
  for (int i = 1; i < num_rows; i++)
  {
    sum = sum + (((this->Data[(i * num_cols) + 0] + this->Data[((i - 1) * num_cols) + 0]) / 2) *
                 (pow((i), 3) - pow(i - 1, 3)));
  }
  // Last sum only needed if using Dirichlet BC at particle edge (if bound is 0, no further sums
  // added)
  if (Dirichlet == true)
    sum = sum + (((bound + this->Data[((num_rows - 1) * num_cols) + 0]) / 2) *
                 (pow((num_rows), 3) - pow(num_rows - 1, 3)));
  avg = (pow(dr, 3) * sum) / pow(radius, 3);
  return avg;
}

// Performs Integral total for spherical coordinates based on matrix data
template <class T>
T
MATRIX<T>::IntegralTotal(double dr, double bound, bool Dirichlet)
{
  T tot = 0;
  T sum = 0;
  if (num_cols > 1)
  {
    mError(dim_mis_match);
    return 0.0;
  }
  for (int i = 0; i < num_rows; i++)
  {
    if (i == 0)
    {
      T m, qom, qo;
      m = (this->Data[((i + 1) * num_cols) + 0] - this->Data[(i * num_cols) + 0]) / dr;
      qom = this->Data[(i * num_cols) + 0] - (m * dr);
      qo = (qom + this->Data[(i * num_cols) + 0]) / 2;
      // Prevent negative mass from bad extrapolation
      if (qo < 0)
        qo = 0;

      sum = sum + (((this->Data[(i * num_cols) + 0] + qo) / 2) * (pow((i + 1), 3) - pow(i, 3)));
    }
    else
    {
      sum = sum + (((this->Data[(i * num_cols) + 0] + this->Data[((i - 1) * num_cols) + 0]) / 2) *
                   (pow((i + 1), 3) - pow(i, 3)));
    }
  }
  // Last sum only needed if using Dirichlet BC at particle edge
  if (Dirichlet == true)
    sum = sum + (((bound + this->Data[((num_rows - 1) * num_cols) + 0]) / 2) *
                 (pow((num_rows + 1), 3) - pow(num_rows, 3)));
  tot = (4 * M_PI * pow(dr, 3) * sum) / 3;
  return tot;
}

// Function to fill in the tridiagonal matrix for 1-D Conservation Laws
template <class T>
MATRIX<T> &
MATRIX<T>::tridiagonalVectorFill(const std::vector<T> & A,
                                 const std::vector<T> & B,
                                 const std::vector<T> & C)
{
  // Check for square matrix
  if (num_cols != num_rows)
  {
    mError(non_square_matrix);
    return *this;
  }
  if (num_rows != A.size() || num_rows != B.size() || num_rows != C.size())
  {
    mError(matvec_mis_match);
    return *this;
  }

  // A = lower off diag, B = diag, C = upper off diag
  for (int i = 0; i < num_rows; i++)
  {
    // Diagonals
    this->Data[(i * num_cols) + i] = B[i];

    if (i == 0)
    {
      // Upper Diagonal
      this->Data[(i * num_cols) + (i + 1)] = C[i];
    }
    else if (i == num_rows - 1)
    {
      // Lower Diagonal
      this->Data[(i * num_cols) + (i - 1)] = A[i];
    }
    else
    {
      // Both
      this->Data[(i * num_cols) + (i + 1)] = C[i];
      this->Data[(i * num_cols) + (i - 1)] = A[i];
    }
  }

  return *this;
}

// Function to fill in a column matrix based on a vector of values
template <class T>
MATRIX<T> &
MATRIX<T>::columnVectorFill(const std::vector<T> & A)
{
  if (num_cols > 1)
  {
    mError(dim_mis_match);
    return *this;
  }
  if (num_rows != A.size())
  {
    mError(matvec_mis_match);
    return *this;
  }
  // Fill in column matrix based on vector of values
  for (int i = 0; i < num_rows; i++)
  {
    this->Data[(i * num_cols) + 0] = A[i];
  }
  return *this;
}

// Function to perform a column projection based on previous time series info
template <class T>
MATRIX<T> &
MATRIX<T>::columnProjection(const MATRIX & b,
                            const MATRIX & b_old,
                            const double dt,
                            const double dt_old)
{
  if (b.num_cols > 1 || b_old.num_cols > 1 || b.num_rows != b_old.num_rows)
  {
    mError(dim_mis_match);
    return *this;
  }
  if (this == &b || this == &b_old)
  {
    mError(arg_matrix_same);
    return *this;
  }
  this->set_size(b.num_rows, b.num_cols);
  double dtm1 = dt_old;
  if (dtm1 == 0.0)
    dtm1 = dt;
  for (int i = 0; i < num_rows; i++)
  {
    this->Data[(i * num_cols) + 0] = b(i, 0) + ((dt / (2.0 * dtm1)) * (b(i, 0) - b_old(i, 0)));
    // Note: This function does not check for negative mass
  }
  return *this;
}

// Fill in the Dirichlet BC for non-spherical coordinates
template <class T>
MATRIX<T> &
MATRIX<T>::dirichletBCFill(int node, const T coeff, T variable)
{
  if (num_cols > 1)
  {
    mError(dim_mis_match);
    return *this;
  }
  else
  {
    for (int i = 0; i < num_rows; i++)
    {
      if (i == node)
      {
        this->Data[(i * num_cols) + 0] = coeff * variable;
      }
      else
      {
        this->Data[(i * num_cols) + 0] = 0;
      }
    }
    return *this;
  }
}

// Directly solve a Diagonal linear system
template <class T>
MATRIX<T> &
MATRIX<T>::diagonalSolve(const MATRIX & D, const MATRIX & v)
{
  if (this == &D || this == &v)
  {
    mError(arg_matrix_same);
    return *this;
  }
  // Solves the system Dx=v when D is a diagonal matrix
  this->set_size(v.num_rows, v.num_cols);

  // Check dimensions of U and v to ensure they will work out
  if (num_rows != D.num_cols || num_cols > 1)
  {
    mError(dim_mis_match);
    return *this;
  }

  // Loop over the diagonals
  for (int i = 0; i < D.num_rows; i++)
  {
    if (D.Data[(i * D.num_cols) + i] != 0.0)
    {
      this->Data[i] = v.Data[i] / D.Data[(i * D.num_cols) + i];
    }
    else
    {
      mError(singular_matrix);
      return *this;
    }
  }
  return *this;
}

// Directly solve an upper triangular linear system
template <class T>
MATRIX<T> &
MATRIX<T>::upperTriangularSolve(const MATRIX & U, const MATRIX & v)
{
  if (this == &U || this == &v)
  {
    mError(arg_matrix_same);
    return *this;
  }
  // Solves the system Ux=v when U is an upper triangular matrix
  this->set_size(v.num_rows, v.num_cols);

  // Check dimensions of U and v to ensure they will work out
  if (num_rows != U.num_cols || num_cols > 1)
  {
    mError(dim_mis_match);
    return *this;
  }

  T sum;
  for (int i = U.num_rows - 1; i >= 0; i--)
  {
    sum = 0.0;
    for (int j = U.num_cols - 1; j > i; j--)
    {
      sum = sum + U.Data[(i * U.num_cols) + j] * this->Data[j];
    }
    if (U.Data[(i * U.num_cols) + i] == 0.0)
    {
      mError(singular_matrix);
      return *this;
    }
    else
    {
      this->Data[i] = (v.Data[i] - sum) / U.Data[(i * U.num_cols) + i];
    }
  }

  return *this;
}

// Directly solve a lower triangular linear system
template <class T>
MATRIX<T> &
MATRIX<T>::lowerTriangularSolve(const MATRIX & L, const MATRIX & v)
{
  if (this == &L || this == &v)
  {
    mError(arg_matrix_same);
    return *this;
  }
  // Solves the system Lx=v when L is an lower triangular matrix
  this->set_size(v.num_rows, v.num_cols);

  // Check dimensions of U and v to ensure they will work out
  if (num_rows != L.num_cols || num_cols > 1)
  {
    mError(dim_mis_match);
    return *this;
  }

  T sum;
  for (int i = 0; i < L.num_rows; i++)
  {
    sum = 0.0;
    for (int j = 0; j < i; j++)
    {
      sum = sum + L.Data[(i * L.num_cols) + j] * this->Data[j];
    }
    if (L.Data[(i * L.num_cols) + i] == 0.0)
    {
      mError(singular_matrix);
      return *this;
    }
    else
    {
      this->Data[i] = (v.Data[i] - sum) / L.Data[(i * L.num_cols) + i];
    }
  }

  return *this;
}

// Function to convert an upper Hessenberg to upper triangular matrix while editing matrix b
template <class T>
MATRIX<T> &
MATRIX<T>::upperHessenberg2Triangular(MATRIX & b)
{
  if (this->num_rows < 2 || this->num_cols < 2)
  {
    mError(matrix_too_small);
    return *this;
  }
  if (this == &b)
  {
    mError(arg_matrix_same);
    return *this;
  }
  if (this->num_rows != b.num_rows || b.num_cols > 1)
  {
    mError(dim_mis_match);
    return *this;
  }
  T s, c;
  T value_i, value_ip1;
  // Loop from top to bottow editing this and b
  for (int i = 0; i < this->num_rows - 1; i++)
  {
    s = this->Data[((i + 1) * this->num_cols) + i] /
        sqrt(pow(this->Data[(i * this->num_cols) + i], 2.0) +
             pow(this->Data[((i + 1) * this->num_cols) + i], 2.0));
    c = this->Data[(i * this->num_cols) + i] /
        sqrt(pow(this->Data[(i * this->num_cols) + i], 2.0) +
             pow(this->Data[((i + 1) * this->num_cols) + i], 2.0));

    if (isnan(s) || isnan(c))
    {
      mError(singular_matrix);
      return *this;
    }

    value_i = ((b.Data[i] * c) + (b.Data[i + 1] * s));
    value_ip1 = (-(b.Data[i] * s) + (b.Data[i + 1] * c));
    b.Data[i] = value_i;
    b.Data[i + 1] = value_ip1;

    for (int j = i; j < this->num_cols; j++)
    {
      value_i =
          ((this->Data[(i * this->num_cols) + j] * c) + (Data[((i + 1) * this->num_cols) + j] * s));
      value_ip1 = (-(this->Data[(i * this->num_cols) + j] * s) +
                   (Data[((i + 1) * this->num_cols) + j] * c));
      this->Data[(i * this->num_cols) + j] = value_i;
      this->Data[((i + 1) * this->num_cols) + j] = value_ip1;
    }
  }
  return *this;
}

// Function to convert an lower Hessenberg to lower triangular matrix while editing matrix b
template <class T>
MATRIX<T> &
MATRIX<T>::lowerHessenberg2Triangular(MATRIX & b)
{
  if (this->num_rows < 2 || this->num_cols < 2)
  {
    mError(matrix_too_small);
    return *this;
  }
  if (this == &b)
  {
    mError(arg_matrix_same);
    return *this;
  }
  if (this->num_rows != b.num_rows || b.num_cols > 1)
  {
    mError(dim_mis_match);
    return *this;
  }
  T s, c;
  T value_i, value_ip1;
  // Loop from bottom to top editing this and b
  for (int i = this->num_rows - 1; i > 0; i--)
  {
    s = this->Data[((i - 1) * this->num_cols) + i] /
        sqrt(pow(this->Data[(i * this->num_cols) + i], 2.0) +
             pow(this->Data[((i - 1) * this->num_cols) + i], 2.0));
    c = this->Data[(i * this->num_cols) + i] /
        sqrt(pow(this->Data[(i * this->num_cols) + i], 2.0) +
             pow(this->Data[((i - 1) * this->num_cols) + i], 2.0));

    if (isnan(s) || isnan(c))
    {
      mError(singular_matrix);
      return *this;
    }

    value_i = ((b.Data[i] * c) + (b.Data[i - 1] * s));
    value_ip1 = (-(b.Data[i] * s) + (b.Data[i - 1] * c));
    b.Data[i] = value_i;
    b.Data[i - 1] = value_ip1;

    for (int j = i; j >= 0; j--)
    {
      value_i =
          ((this->Data[(i * this->num_cols) + j] * c) + (Data[((i - 1) * this->num_cols) + j] * s));
      value_ip1 = (-(this->Data[(i * this->num_cols) + j] * s) +
                   (Data[((i - 1) * this->num_cols) + j] * c));
      this->Data[(i * this->num_cols) + j] = value_i;
      this->Data[((i - 1) * this->num_cols) + j] = value_ip1;
    }
  }
  return *this;
}

// Function to solve Hx=v when H is upper Hessenberg
template <class T>
MATRIX<T> &
MATRIX<T>::upperHessenbergSolve(const MATRIX & H, const MATRIX & v)
{
  if (this == &H || this == &v)
  {
    mError(arg_matrix_same);
    return *this;
  }
  MATRIX<T> U(H), b(v);
  U.upperHessenberg2Triangular(b);
  this->upperTriangularSolve(U, b);
  U.Data.clear();
  b.Data.clear();
  return *this;
}

// Function to solve Hx=v when H is lower Hessenberg
template <class T>
MATRIX<T> &
MATRIX<T>::lowerHessenbergSolve(const MATRIX & H, const MATRIX & v)
{
  if (this == &H || this == &v)
  {
    mError(arg_matrix_same);
    return *this;
  }
  MATRIX<T> L(H), b(v);
  L.lowerHessenberg2Triangular(b);
  this->lowerTriangularSolve(L, b);
  L.Data.clear();
  b.Data.clear();
  return *this;
}

// Function to solve Mx=b using QR factorization
template <class T>
MATRIX<T> &
MATRIX<T>::qrSolve(const MATRIX & M, const MATRIX & b)
{
  // Check for errors
  if (this == &M || this == &b)
  {
    mError(arg_matrix_same);
    return *this;
  }
  if (M.num_rows != M.num_cols)
  {
    mError(non_square_matrix);
    return *this;
  }
  if (M.num_rows != b.num_rows || b.num_cols > 1)
  {
    mError(dim_mis_match);
    return *this;
  }

  // Setup temporary variables
  double alpha;
  MATRIX<T> w, U, R(M), Qt_b(b);
  w.set_size(this->num_rows, 1);
  U.set_size(this->num_rows, this->num_rows);

  // Loop over the columns of R
  for (int j = 0; j < R.num_cols - 1; j++)
  {
    w.columnExtract(j, R);
    for (int i = 0; i < j; i++)
      w.Data[i] = 0.0;
    if (w.Data[j] < 0.0)
      alpha = w.norm();
    else
      alpha = -w.norm();
    w.Data[j] = w.Data[j] - alpha;
    w = (w / w.norm());
    U = w.outer_product(w) * -2.0;
    for (int i = 0; i < U.num_rows; i++)
      U.Data[(i * U.num_cols) + i] = 1.0 + U.Data[(i * U.num_cols) + i];

    R = U * R;
    Qt_b = U * Qt_b;
  }
  this->upperTriangularSolve(R, Qt_b);

  return *this;
}

// Function to extract a column matrix 'this' from a full matrix M
template <class T>
MATRIX<T> &
MATRIX<T>::columnExtract(int j, const MATRIX & M)
{
  if (this == &M)
  {
    mError(arg_matrix_same);
    return *this;
  }
  if (this->rows() != M.num_rows)
  {
    this->set_size(M.num_rows, 1);
  }

  for (int i = 0; i < M.num_rows; i++)
  {
    this->Data[(i * this->num_cols) + 0] = M.Data[(i * M.num_cols) + j];
  }
  return *this;
}

// Function to extract a row matrix 'this' from a full matrix M
template <class T>
MATRIX<T> &
MATRIX<T>::rowExtract(int i, const MATRIX & M)
{
  if (this == &M)
  {
    mError(arg_matrix_same);
    return *this;
  }
  if (this->columns() != M.num_cols)
  {
    this->set_size(1, M.num_cols);
  }

  for (int j = 0; j < M.num_cols; j++)
  {
    this->Data[j] = M.Data[(i * M.num_cols) + j];
  }
  return *this;
}

// Function to replace an existing column of 'this' with the column matrix v
template <class T>
MATRIX<T> &
MATRIX<T>::columnReplace(int j, const MATRIX & v)
{
  if (this->num_rows != v.num_rows)
  {
    mError(matvec_mis_match) return *this;
  }
  if (this == &v)
  {
    mError(arg_matrix_same);
    return *this;
  }
  for (int i = 0; i < this->num_rows; i++)
  {
    this->Data[(i * this->num_cols) + j] = v.Data[i];
  }
  return *this;
}

// Function to replace an existing column of 'this' with the column matrix v
template <class T>
MATRIX<T> &
MATRIX<T>::rowReplace(int i, const MATRIX & v)
{
  if (this->num_cols != v.num_cols)
  {
    mError(matvec_mis_match) return *this;
  }
  if (this == &v)
  {
    mError(arg_matrix_same);
    return *this;
  }
  for (int j = 0; j < this->num_cols; j++)
  {
    this->Data[(i * this->num_cols) + j] = v.Data[j];
  }
  return *this;
}

// Function to reduce the number of rows in the matrix by neglecting the last row
template <class T>
void
MATRIX<T>::rowShrink()
{
  /*
   Note: because of how the matrix data is stored, this is the only line
   needed to complete this operation. However, this does not actually remove
   any data. It instead just instructs all other functions to neglect data
   in the last row of the full matrix.
   */
  this->num_rows--;
}

// Function to reduce the number of columns in the matrix by neglecting the last column
template <class T>
void
MATRIX<T>::columnShrink()
{
  // Here we must force a reinitialization of the data because of how it is stored
  MATRIX<T> temp(*this);
  this->set_size(temp.num_rows, temp.num_cols - 1);
  for (int i = 0; i < this->num_rows; i++)
  {
    for (int j = 0; j < this->num_cols; j++)
    {
      this->edit(i, j, temp(i, j));
    }
  }
  temp.Data.clear();
}

// Function to add another row to the end of an existing matrix
template <class T>
void
MATRIX<T>::rowExtend(const MATRIX & v)
{
  if (this->num_cols != v.num_cols)
  {
    mError(matvec_mis_match) return;
  }
  for (int j = 0; j < v.num_cols; j++)
  {
    this->Data.push_back(v(0, j));
  }
  this->num_rows++;
}

// Function to add another column to the end of an existing matrix
template <class T>
void
MATRIX<T>::columnExtend(const MATRIX & v)
{
  if (this->num_rows != v.num_rows)
  {
    mError(matvec_mis_match) return;
  }
  MATRIX<T> temp(*this);
  this->set_size(temp.num_rows, temp.num_cols + 1);
  for (int i = 0; i < this->num_rows; i++)
  {
    for (int j = 0; j < this->num_cols; j++)
    {
      if (j < this->num_cols - 1)
        this->edit(i, j, temp(i, j));
      else
        this->edit(i, j, v(i, 0));
    }
  }
}

/// Function to run the MACAW tests
/** This function is callable from the UI and is used to run several
  algorithm tests for the MATRIX objects. This test should never
  report any errors. */
int MACAW_TESTS();

#endif
