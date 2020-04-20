/*!
 *  \file macaw.h macaw.cpp
 *	\brief MAtrix CAlculation Workspace
 *  \author Austin Ladshaw
 *	\date 01/07/2014
 *	\copyright This software was designed and built at the Georgia Institute
 *             of Technology by Austin Ladshaw for PhD research in the area
 *             of adsorption and surface science. Copyright (c) 2015, all
 *             rights reserved.
 */

#include "macaw.h"

int MACAW_TESTS()
{
    int success = 0;
    
    //Test Lower Triangular solve (PASS)
    int rows, cols;
    rows = 5;
    cols = 5;
    Matrix<double> L(rows,cols);
    Matrix<double> v(rows,1);
    for (int i=0; i<rows; i++)
    {
        for (int j=0; j<=i; j++)
        {
            L.edit(i,j, i+j+1);
        }
        v.edit(i, 0, i+1);
    }
    L.Display("L");
    v.Display("v");
    Matrix<double> x;
    x.lowerTriangularSolve(L, v);
    x.Display("x");
    (L*x).Display("L*x=v=");
    
    //Test of Upper Triangular solve (PASS)
    Matrix<double> U(rows,cols);
    for (int i=rows-1; i>=0; i--)
    {
        for (int j=cols-1; j>=i; j--)
        {
            U.edit(i,j, i+j+1);
        }
    }
    U.Display("U");
    x.upperTriangularSolve(U, v);
    x.Display("x");
    (U*x).Display("U*x=v=");
    
    //Test row and column reductions
    U.rowShrink(); //(PASS)
    U.Display("U");
    U.columnShrink(); //(PASS - had to reinitialize matrix to work)
    U.Display("U");
    
    //Test Hessenberg Functions (PASS)
    Matrix<double> H(rows,cols);
    for (int i=rows-1; i>=0; i--)
    {
        for (int j=cols-1; j>=i; j--)
        {
            H.edit(i,j, i+j+1);
            if (i>=0 && i<rows-1)
            {
                //H.edit(i+1,j, i+j+1); //Matrix is singular!!!
                H.edit(i+1,j, i+i+1); //Note: changed j to i to prevent singularity
            }
        }
    }
    H.Display("H");
    v.Display("v");
    Matrix<double> H2, v2;
    H2 = H;
    v2 = v;
    H2.upperHessenberg2Triangular(v2);
    H2.Display("H2");
    v2.Display("v2");
    x.upperTriangularSolve(H2, v2);
    x.Display("x");
    (H*x).Display("should be v");
    
    Matrix<double> H3(rows,cols);
    H3.tridiagonalFill(-1, 2, -1, true);
    H3.Display("H3");
    Matrix<double> H4, v4;
    H4 = H3;
    v4 = v;
    H4.lowerHessenberg2Triangular(v4);
    H4.Display("H4");
    v4.Display("v4");
    x.lowerTriangularSolve(H4, v4);
    x.Display("x");
    x.ladshawSolve(H3, v);
    x.Display("x");
    
    x.upperHessenbergSolve(H, v);
    x.Display("x");
    (H*x).Display("v");
    
    x.lowerHessenbergSolve(H3, v);
    x.Display("x");
    (H3*x).Display("v");
    
    H.Display("H");
    H3.Display("H3");
    
    //Warning! Conversion of a Hessenberg to Triangular matrix may result in singularity!!!
    
    //Test the row and column extract and replace functions (PASS)
    Matrix<double> r, c;
    r.rowExtract(2, H3);
    r.Display("r");
    c.columnExtract(2, H3);
    c.Display("c");
    Matrix<double> H5;
    H5 = H3;
    H5.columnReplace(0, c);
    H5.Display("H5");
    H5.rowReplace(0, r);
    H5.Display("H5");
    H5.rowReplace(0, r.transpose(c));
    H5.Display("H5");
    
    //Test the column and row extension functions (PASS)
    Matrix<double> A(rows,cols);
    A.tridiagonalFill(-1, 2, -1, false);
    A.Display("A");
    Matrix<double> cex(rows,1);
    Matrix<double> rex(1,cols);
    cex.dirichletBCFill(rows-1, 2, 1);
    cex.Display("cex");
    rex.transpose(cex);
    rex.Display("rex");
    
    cex.set_size(rows+1, 1);
    cex.dirichletBCFill(rows, 1, 2);
    A.rowExtend(rex);
    A.Display("A");
    
    //Test of Upper Hessenberg non-square conversion (PASS)
    Matrix<double> HA;
    HA = A;
    HA.upperHessenberg2Triangular(cex);
    HA.Display("HA");
    
    HA.rowShrink();
    HA.Display("HA_Tri");
    
    A.columnExtend(cex);
    A.Display("A");
	
  	//Test of Diagonal Solver
  	Matrix<double> D(10,10), b(10,1);
  	D.tridiagonalFill(0, 2, 0, true);
  	D.Display("D");
  	b.ConstantICFill(1.0);
  	Matrix<double> xD;
  	xD.diagonalSolve(D, b);
  	xD.Display("x");
  	std::cout << "norm = " << (b - D*xD).norm() << std::endl;
	
	D = xD.outer_product(b);
	D.Display("D");
	
	std::vector<int> iv;
	iv.resize(3);
	for (int i=0; i<iv.size(); i++)
	{
		iv[i] = i;
	}
	
	Matrix<int> iv_test;
	iv_test.set_size((int)iv.size(), 1);
	iv_test.columnVectorFill(iv);
	iv_test.Display("iv");
	
	Matrix<std::string> s_test;
	s_test.set_size(3, 1);
	s_test.edit(0, 0, "Apple");
	s_test.edit(1, 0, "Pears");
	s_test.edit(2, 0, "Grapes");
	s_test.Display("List");
	
	std::cout << iv_test.inner_product(iv_test) << std::endl;
	
    return success;
}