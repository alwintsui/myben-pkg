# to build pyusqcd/_usqcd.so
if(CMAKE_VERSION VERSION_LESS 3.12)
  find_package(PythonLibs REQUIRED) # Deprecated since version 3.12
  find_package(PythonInterp REQUIRED)
else()
  find_package(Python3 COMPONENTS Interpreter Development NumPy)
  set(PYTHON_EXECUTABLE ${Python3_EXECUTABLE})
  set(PYTHON_INCLUDE_DIRS ${Python3_INCLUDE_DIRS})
  set(PYTHON_INCLUDE_DIR ${Python3_INCLUDE_DIR})
endif()

message(STATUS "PYTHON_EXECUTABLE = " ${PYTHON_EXECUTABLE})
message(STATUS "PYTHON_INCLUDE_DIRS = " ${PYTHON_INCLUDE_DIRS})
message(STATUS "Python3_NumPy_INCLUDE_DIRS = " ${Python3_NumPy_INCLUDE_DIRS})


if(NOT PYTHON_INCLUDE_DIR)
  execute_process(COMMAND ${PYTHON_EXECUTABLE} -c "import distutils.sysconfig; print(distutils.sysconfig.get_config_var('INCLUDEPY'))"
         OUTPUT_VARIABLE PYTHON_INCLUDE_DIR OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()

execute_process(COMMAND ${PYTHON_EXECUTABLE} -c "import distutils.sysconfig; print(distutils.sysconfig.get_config_var('LIBDIR'))"
         OUTPUT_VARIABLE PYTHON_LIB_DIR OUTPUT_STRIP_TRAILING_WHITESPACE)
execute_process(COMMAND ${PYTHON_EXECUTABLE} -c "import distutils.sysconfig; print(distutils.sysconfig.get_config_var('LDVERSION'))"
         OUTPUT_VARIABLE PYTHON_LIB_VER OUTPUT_STRIP_TRAILING_WHITESPACE)

message(STATUS "PYTHON_INCLUDE_DIR = " ${PYTHON_INCLUDE_DIR})
message(STATUS "PYTHON_LIB_DIR = " ${PYTHON_LIB_DIR})
message(STATUS "PYTHON_LIB_VER = " ${PYTHON_LIB_VER})

#import SWIG
FIND_PACKAGE(SWIG REQUIRED)
INCLUDE(${SWIG_USE_FILE})
message(STATUS "SWIG_USE_FILE = " ${SWIG_USE_FILE})


#skip $<$<COMPILE_LANGUAGE:CUDA>:/opt/local/cuda-12.5/include>
macro(filter_name_path result)
  foreach(path ${ARGN})
    if(NOT "${path}" MATCHES "^\\$<.*>$")
      list(APPEND ${result} "${path}")
    endif()
  endforeach()
endmacro()

macro(my_swig_add_library TARGET SWIG_SRC DEP_LIB)
  set_property(SOURCE ${SWIG_SRC} PROPERTY CPLUSPLUS ON)
  swig_add_library(${TARGET} LANGUAGE python SOURCES ${SWIG_SRC} OUTPUT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/pyusqcd OUTFILE_DIR ${CMAKE_CURRENT_BINARY_DIR})
  get_target_property(MY_SWIG_INCLUDE_DIRS ${DEP_LIB} INCLUDE_DIRECTORIES)
  if(NOT MY_SWIG_INCLUDE_DIRS)
    get_target_property(MY_SWIG_INCLUDE_DIRS ${DEP_LIB} INTERFACE_INCLUDE_DIRECTORIES)
  endif()
  filter_name_path(MY_SWIG_INCLUDE_DIRS_NET ${MY_SWIG_INCLUDE_DIRS})
  set_property(TARGET ${TARGET} PROPERTY SWIG_INCLUDE_DIRECTORIES ${MY_SWIG_INCLUDE_DIRS_NET} ${PROJECT_SOURCE_DIR}/src)
  #set_property(TARGET ${TARGET} PROPERTY SWIG_COMPILE_OPTIONS -relativeimport)
  set_property(TARGET ${TARGET} PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/pyusqcd)
  target_include_directories(${TARGET} PUBLIC ${PROJECT_SOURCE_DIR}/src ${PYTHON_INCLUDE_DIR})
  swig_link_libraries(${TARGET} ${DEP_LIB} python${PYTHON_LIB_VER})
  #set_target_properties(pylime PROPERTIES PREFIX ""  SUFFIX ".so" LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/pyusqcd")
endmacro()

my_swig_add_library(lime lime_api.i lime_api)
my_swig_add_library(chroma chroma_api.i chroma_api)

FIND_PACKAGE(XPathReader REQUIRED)
my_swig_add_library(xpathreader xpath_reader.i XPathReader::XPathReader)
swig_link_libraries(xpathreader XPathReader::xmlWriter)

FIND_PACKAGE(QUDA REQUIRED)
my_swig_add_library(quda quda_api.i QUDA::quda)

configure_file(setup.py.in ${CMAKE_CURRENT_SOURCE_DIR}/setup.py @ONLY)

#copy modules in pyusqcd to binary direcotry
#file(GLOB_RECURSE PYUSQCD_MODULES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} pyusqcd/*.py)
#foreach (MODFILE ${PYUSQCD_MODULES})
#configure_file(${MODFILE} ${CMAKE_CURRENT_BINARY_DIR}/${MODFILE} COPYONLY)
#endforeach(MODFILE)

install(CODE "execute_process(WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} COMMAND ${Python_EXECUTABLE} -m pip install .)")