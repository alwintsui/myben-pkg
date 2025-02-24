//directors="1"
%module (docstring="Chroma C++ wrapper in Python, May. 2025, Shun Xu <xushun@sccas.cn>") chroma
%{
#include "chroma_api.h"

#define SWIG_FILE_WITH_INIT

%}

%warnfilter(305, 325, 389, 401, 451, 462, 503);
//Warning 389: operator[] ignored (consider using %extend)
//Warning 451: Setting a const char * variable may leak memory.
//Warning 325: Nested union not currently supported (union_int_float_t,Param ignored)
//Warning 462: Unable to set dimensionless array variable
//Warning 305: Bad constant value (ignored).
//Warning 503: Can't wrap 'operator double*' unless renamed to a valid identifier.
//Warning 401: Nothing known about base class 'std::enable_shared_from_this< MechSlot >'. Ignored.

#ifdef SWIGPYTHON

//defined before %include file headers
%rename(__assign__) *::operator=;
//disable in wlc_types.h

%include "typemaps.i"
%include "factory.i"
//string,vector,map,pair
%include "stl.i" 
/* instantiate the required template specializations */
namespace std {
    %template(char_vector)   vector<char>;
}

//%include "numpy.i" //included in hup.i
%include "std_iostream.i"
%include "file.i"
FILE *fopen(char *, char *);
int fclose(FILE *);
unsigned fread(void *ptr, unsigned size, unsigned nobj, FILE *);
unsigned fwrite(void *ptr, unsigned size, unsigned nobj, FILE *);
int feof(FILE *stream);

%include "io/gauge_io.h"
%include "io/qprop_io.h"
%include "io/eigen_io.h"
%include "io/param_io.h"
%include "io/xml_group_reader.h"
%include "chroma_api.h"

%inline %{
/*test the word byte of machine*/

 bool fok(FILE *s) {return s!=NULL;}

%}

%init %{
 //   import_array(); //for numpy
%}

#endif /* SWIGPYTHON */
//http://swig.org/Doc1.3/SWIGPlus.html#SWIGPlus_nn12
