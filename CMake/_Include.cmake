include(_Configure)
configure_init(${CMAKE_BINARY_DIR}/mem_config.h)

if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
    include(CTest)
endif()

include(CMakePushCheckState)
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

macro(make_have_identifier NAME ID)
    string(MAKE_C_IDENTIFIER ${NAME} _make_have_identifier)
    string(TOUPPER ${_make_have_identifier} _make_have_identifier)
    set(${ID} HAVE_${_make_have_identifier})
endmacro()

include(CheckCCompilerFlag)
macro(check_flag FLAG HAVE)
    configure_define(${HAVE})
    check_c_compiler_flag("${FLAG}" ${HAVE})
endmacro()
include(CheckCXXCompilerFlag)
macro(check_cxx_flag FLAG HAVE)
    configure_define(${HAVE})
    check_cxx_compiler_flag("${FLAG}" ${HAVE})
endmacro()
include(CheckSymbolExists)
macro(check_symbol NAME HEADER)
    make_have_identifier(${NAME} HAVE)
    configure_define(${HAVE})
    cmake_push_check_state()
    if(${ARGC} GREATER 1)
        string(APPEND CMAKE_REQUIRED_FLAGS " ${ARGV2}")
    endif()
    check_symbol_exists(${NAME} ${HEADER} ${HAVE})
    cmake_pop_check_state()
endmacro()
include(CheckCXXSymbolExists)
macro(check_cxx_symbol NAME HEADER)
    make_have_identifier(${NAME} HAVE)
    configure_define(${HAVE})
    cmake_push_check_state()
    if(${ARGC} GREATER 1)
        string(APPEND CMAKE_REQUIRED_FLAGS " ${ARGN}")
    endif()
    check_cxx_symbol_exists(${NAME} ${HEADER} ${HAVE})
    cmake_pop_check_state()
endmacro()
include(CheckIncludeFile)
macro(check_include HEADER)
    make_have_identifier(${HEADER} HAVE)
    configure_define(${HAVE})
    cmake_push_check_state()
    if(${ARGC} GREATER 1)
        string(APPEND CMAKE_REQUIRED_FLAGS " ${ARGN}")
    endif()
    check_include_file(${HEADER} ${HAVE})
    cmake_pop_check_state()
endmacro()
include(CheckIncludeFileCXX)
macro(check_cxx_include HEADER)
    make_have_identifier(${HEADER} HAVE)
    configure_define(${HAVE})
    cmake_push_check_state()
    if(${ARGC} GREATER 1)
        string(APPEND CMAKE_REQUIRED_FLAGS " ${ARGN}")
    endif()
    check_include_file_cxx(${HEADER} ${HAVE})
    cmake_pop_check_state()
endmacro()
include(CheckTypeSize)
macro(check_type TYPE)
    make_have_identifier(${TYPE} HAVE)
    configure_define(${HAVE})
    cmake_push_check_state()
    if(${ARGC} GREATER 1)
        list(APPEND CMAKE_EXTRA_INCLUDE_FILES ${ARGN})
    endif()
    check_type_size(${TYPE} ${HAVE})
    cmake_pop_check_state()
endmacro()
include(CheckCSourceCompiles)
macro(check_c_source SOURCE HAVE)
    configure_define(${HAVE})
    check_c_source_compiles("${SOURCE}" ${HAVE})
endmacro()
include(CheckCXXSourceCompiles)
macro(check_cxx_source SOURCE HAVE)
    configure_define(${HAVE})
    check_cxx_source_compiles("${SOURCE}" ${HAVE})
endmacro()

include(CheckBacktrace)
include(CheckByteswap)
include(CheckDependency)
include(CheckDtrace)
include(CheckPkgconf)
include(CheckDebug)
include(CheckThreads)
include(CheckVisibility)
include(InstallPublicHeaders)

## sasl
configure_define_01(LIBMEMCACHED_WITH_SASL_SUPPORT)
if(ENABLE_SASL)
    check_dependency(LIBSASL sasl2)
    if(HAVE_LIBSASL)
        set(LIBMEMCACHED_WITH_SASL_SUPPORT 1)
    endif()
endif()

## hashes
configure_set(HAVE_FNV64_HASH ${ENABLE_HASH_FNV64})
configure_set(HAVE_MURMUR_HASH ${ENABLE_HASH_MURMUR})
configure_set(HAVE_HSIEH_HASH ${ENABLE_HASH_HSIEH})

check_include(alloca.h)
check_include(arpa/inet.h)
check_include(dlfcn.h)
check_include(netdb.h)
check_include(poll.h)
check_include(strings.h)
check_include(sys/socket.h)
check_include(sys/time.h)
check_include(sys/un.h)
check_include(unistd.h)

if(WIN32)
    check_include(io.h)
    check_include(winsock2.h)
    check_include(ws2tcpip.h)
endif()

check_type(in_port_t netinet/in.h)

check_cxx_symbol(abi::__cxa_demangle cxxabi.h)
check_symbol(fcntl fcntl.h)
check_symbol(htonll arpa/inet.h)
check_symbol(MSG_DONTWAIT sys/socket.h)
check_symbol(MSG_MORE sys/socket.h)
check_symbol(MSG_NOSIGNAL sys/socket.h)
check_symbol(SO_RCVTIMEO sys/socket.h)
check_symbol(SO_SNDTIMEO sys/socket.h)
check_symbol(setenv stdlib.h)
check_symbol(strerror_r string.h)
check_c_source("
        #include <string.h>
        int main() {
            char x;
            return *strerror_r(0, &x, 1);
        }"
        HAVE_STRERROR_R_CHAR_P
)
