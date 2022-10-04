# STL_to_grayscale

Matlab-Function to convert a STL-File into a grayscale image.

# Contains:
    main function: stl2grayscale.m
    test files:    half_sphere_concave.stl, test_geometry.stl
    result files:  half_sphere_concave_grayscale.bmp, test_geometry_grayscale.bmp
  
# How to use:

Just copy your STL-file into the same folder where the main function stl2grayscale.m is and run in the command line of Matlab:

I=stl2grayscale('test_geometry.stl','grayscale_image.bmp',1048); 

In this case 'test_geometry.stl' is the name of the input file, 'grayscale_image.bmp' is the name of the output file and '1048' defines the maximum number of pixels. For more detailed explanations of the input parameters read the description in the main function. Also the matrix containing the grayscale data is returned in 'I'.

# Licencing

Copyright (c) 2022 Sebastian Bohm

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
