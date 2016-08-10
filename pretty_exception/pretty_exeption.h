/*
    pretty_exception : Provides macros to throw exceptions with
        1. File, line number and function name information
        2. Callstack information
        3. Colored console output
        4. It can send trace messages :
                - For Linux , we are tracing to syslog , they can be seen via tail -f /var/log/messages
                - For Windows , traces can be seen with Microsoft`s DbgView : https://technet.microsoft.com/en-us/sysinternals/debugview.aspx?f=255&MSPPError=-2147217396
        5. Exception messages in message boxes ( Windows only )
    Target plaforms :
                        Linux and GCC
                        Windows and MSVC
    std::exception support : provides macros to throw as 
            
                        std::runtime_error
                        std::invalid_arg
                        std::logic_error
                        std::length_error
    Use example :
                            ...
                            void foo()
                            {
                                ...
                                THROW_PRETTY_RUNTIME_EXCEPTION("Runtime exception message")
                                ...
                            }
    This code is public domain : https://en.wikipedia.org/wiki/Public_domain
    Coded by Akin Ocal ( Blog : nativecoding.wordpress.com )
*/
#ifndef _PRETTY_EXCEPTION_H_
#define _PRETTY_EXCEPTION_H_

// Operating system check
#if (! defined(__linux__)) && (! defined(_WIN32) )
#error "Pretty exception is supported for Linux and Windows systems"
#endif

// Compiler check
#if (! defined(__GNUC__ )) && (! defined(_MSC_VER) )
#error "Pretty exception is supported for GCC and MSVC"
#endif

// Flags to control console outputting and msgbox outputting ( applies only to Windows )
#define PRETTY_EXCEPTION_CONSOLE_OUTPUT 1
#define PRETTY_EXCEPTION_TRACE_OUTPUT 1
#define PRETTY_EXCEPTION_MESSAGE_BOX_OUTPUT 0

#include <exception>
#include <string>
#include <cstdarg>
#include <iostream>
#include <cstddef>
#include <array>
#include <string>
#include <type_traits>
#include <cassert>
#include <sstream>
#include <vector>
#include <memory>
#include <cstdlib>

#if __linux__
#define NEW_LINE "\n"
#include <errno.h>
#include <string.h>
#include <execinfo.h>
#include <syslog.h>
#include <unistd.h>
#elif _WIN32

#define NEW_LINE "\r\n"

#if defined(_MSC_VER)

#pragma warning(disable:4996) // _CRT_SECURE_NO_WARNINGS

#ifndef __func__
#if _MSC_VER < 1900 // pre-MSVC2015 are not fully compliant with C99
#define __func__ __FUNCTION__

#endif

#endif

#endif

#include <windows.h>
#include <Dbghelp.h>
#pragma comment(lib, "Dbghelp.lib")
#endif

namespace pretty_exception
{
    
enum class ConsoleColor // FG:foreground
{
    FG_DEFAULT,
    FG_RED,
    FG_GREEN,
    FG_BLUE
};

#ifdef __linux__
    inline std::string getAnsiColorCode(ConsoleColor color)
    {
        std::string ret;
        switch (color)
        {
        case ConsoleColor::FG_DEFAULT:
            ret = "\033[0;31m";
            break;

        case ConsoleColor::FG_RED:
            ret = "\033[0;31m";
            break;

        case ConsoleColor::FG_GREEN:
            ret = "\033[0;32m";
            break;

        case ConsoleColor::FG_BLUE:
            ret = "\033[0;34m";
            break;

        default:
            break;
        }
        return ret;
    }
#elif _WIN32
class SymbolHandler
{
public:
    explicit SymbolHandler(HANDLE process) : m_process{ process }
    {
        SymInitialize(m_process, nullptr, TRUE);
    }

    ~SymbolHandler()
    {
        SymCleanup(m_process);
    }

private:
    HANDLE m_process;
};
#endif

const static std::size_t    MAX_CONSOLE_MESSAGE_LENGTH = 1024;
const static std::size_t    EXCEPTION_CALLSTACK_DEPTH = 16;
const static ConsoleColor   EXCEPTION_CONSOLE_FOREGROUND_COLOR = ConsoleColor::FG_RED;
const static std::size_t    MAX_FRAME_NUMBER = 128;
const static std::size_t    DEFAULT_FRAME_NUMBER = 32;
const static std::size_t    MAX_SYMBOL_LENGTH = 255;
const static std::size_t    MAX_TRACE_MESSAGE_LENGTH = 1024;

struct ConsoleColorNode
{
    ConsoleColor color;
    int value;
};

const std::array<ConsoleColorNode, 4> NATIVE_CONSOLE_COLORS =
{
    //DO POD INITIALISATION
    {
#ifdef __linux__
        // https://en.wikipedia.org/wiki/ANSI_escape_code#graphics
        ConsoleColor::FG_DEFAULT, 0,
        ConsoleColor::FG_RED, 31,
        ConsoleColor::FG_GREEN, 32,
        ConsoleColor::FG_BLUE, 34
#elif _WIN32
        ConsoleColor::FG_DEFAULT, 0,
        ConsoleColor::FG_RED, FOREGROUND_RED,
        ConsoleColor::FG_GREEN, FOREGROUND_GREEN,
        ConsoleColor::FG_BLUE, FOREGROUND_BLUE,
#endif
    }
};

inline void consoleOutputWithColor(ConsoleColor foregroundColor, const char* message, ...)
{
    char buffer[MAX_CONSOLE_MESSAGE_LENGTH] = { (char)NULL };
    auto fgIndex = static_cast<std::underlying_type<ConsoleColor>::type>(foregroundColor);
    auto foreGroundColorCode = NATIVE_CONSOLE_COLORS[fgIndex].value;

    va_list args;
    va_start(args, message);
    vsnprintf(buffer, MAX_CONSOLE_MESSAGE_LENGTH, message, args);
    va_end(args);
#ifdef _WIN32
    HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
    auto setConsoleAttribute = [&hConsole](int code){ SetConsoleTextAttribute(hConsole, code);  };

    if (foregroundColor != ConsoleColor::FG_DEFAULT)
    {
        setConsoleAttribute(foreGroundColorCode | FOREGROUND_INTENSITY);
    }
    FlushConsoleInputBuffer(hConsole);
    std::cout << buffer << std::endl;
    SetConsoleTextAttribute(hConsole, 15); //set back to black background and white text
#elif __linux__
    std::cout << getAnsiColorCode(foregroundColor) << buffer << "\033[0m" << std::endl;
#endif
}

inline void trace(const char* message, ...)
{
    char buffer[MAX_TRACE_MESSAGE_LENGTH] = { (char)NULL };
    va_list args;
    va_start(args, message);
    vsnprintf(buffer, MAX_TRACE_MESSAGE_LENGTH, message, args);
    va_end(args);

#ifdef _WIN32
    OutputDebugStringA(buffer);
    OutputDebugStringA(NEW_LINE);
#elif __linux__
    openlog("slog", LOG_PID | LOG_CONS, LOG_USER);
    syslog(LOG_INFO, buffer);
    closelog();
#endif
}

inline std::vector<std::string> getCallStack(int frameNumber = DEFAULT_FRAME_NUMBER)
{
    assert(MAX_FRAME_NUMBER >= frameNumber);
    std::vector<std::string> ret;
    ret.reserve(frameNumber);
#ifdef __linux__
    void *frames[MAX_FRAME_NUMBER];
    int frameCount{ 0 };
    char **messages = (char **)nullptr;

    frameCount = backtrace(frames, frameNumber);
    messages = backtrace_symbols(frames, frameCount);

    //Rather then zero we are starting from 1 to exclude call to this function
    for (unsigned short i{ 1 }; i < frameCount; ++i)
    {
        std::stringstream currentFrame;
        currentFrame << frameCount - i << " : " << messages[i];
        ret.push_back(currentFrame.str());
    }
#elif _WIN32
    HANDLE process;
    process = GetCurrentProcess();
    SymbolHandler symbolHandler{ process };

    std::unique_ptr<SYMBOL_INFO, decltype(free)*> symbol{ (SYMBOL_INFO *)calloc(sizeof(SYMBOL_INFO) + (MAX_SYMBOL_LENGTH + 1)* sizeof(char), 1), std::free };

    symbol->MaxNameLen = MAX_SYMBOL_LENGTH;
    symbol->SizeOfStruct = sizeof(SYMBOL_INFO);

    void* stack[MAX_FRAME_NUMBER];
    auto frameCount = CaptureStackBackTrace(1, frameNumber, stack, nullptr);

    //Rather then zero we are starting from 1 to exclude call to this function
    for (unsigned short i{ 1 }; i < frameCount; ++i)
    {
        SymFromAddr(process, (DWORD64)(stack[i]), 0, symbol.get());
        std::stringstream currentFrame;
        currentFrame << frameCount - i << " : " << symbol->Name << " - " << symbol->Address;
        ret.push_back(currentFrame.str());
    }
#endif
    return ret;
}

inline std::string getCallstackAsString(int frameNumber = DEFAULT_FRAME_NUMBER)
{
    std::string ret;
    auto callstack = getCallStack(frameNumber);
    for (auto& frame : callstack)
    {
        ret += frame;
        ret += NEW_LINE;
    }
    return ret;
}

#if PRETTY_EXCEPTION_CONSOLE_OUTPUT
#define OUTPUT_EXCEPTION_TO_CONSOLE(message) pretty_exception::consoleOutputWithColor(pretty_exception::EXCEPTION_CONSOLE_FOREGROUND_COLOR, message)
#else
#define OUTPUT_EXCEPTION_TO_CONSOLE(message)
#endif

#if PRETTY_EXCEPTION_TRACE_OUTPUT
#define TRACE_EXCEPTION(message) pretty_exception::trace(message)
#else
#define TRACE_EXCEPTION(message)
#endif

#if PRETTY_EXCEPTION_MESSAGE_BOX_OUTPUT
#if _WIN32
#include <windows.h>
#define OUTPUT_EXCEPTION_TO_MESSAGE_BOX(message) ::MessageBoxA(nullptr, message, MB_OK, MB_ICONERROR)
#endif
#endif

#ifndef OUTPUT_EXCEPTION_TO_MESSAGE_BOX
#define OUTPUT_EXCEPTION_TO_MESSAGE_BOX
#endif

// For throwing exceptions with messages that contain the file name and the line number info
// We could use boost::exception , however in that we have to catch boost::exception class

// Implemented this "pretty_exception" macro using macro indirection in order to stick with
// std::runtime_error or std::logic_error also to have colored outputs
// Additionaly we have file, line number and callstack information

// Note for MSVC : std::exception implementation of Microsoft has an overloaded constructor
// but this is not standard. Therefore using std::runtime_error

// Macro technique used : http://stackoverflow.com/questions/19343205/c-concatenating-file-and-line-macros
// and http://stackoverflow.com/questions/2670816/how-can-i-use-the-compile-time-constant-line-in-a-string
// Putting a single # before a macro causes it to be changed into a string of its value, instead of its bare value.
// Putting a double ## between two tokens causes them to be concatenated into a single token.
#define STRINGIFY_DETAIL(x) #x
#define STRINGIFY(x) STRINGIFY_DETAIL(x)

#define THROW_PRETTY_EXCEPTION(msg, exceptionType, exceptionTypeAsStringLiteral)  \
      do  {     \
                                    { \
                std::string message =  std::string("Exception type : ") + exceptionTypeAsStringLiteral + NEW_LINE + NEW_LINE; \
                message +=  std::string("Message : ") + std::string(msg) + NEW_LINE + NEW_LINE; \
                message += "File : " __FILE__ "Line : " STRINGIFY(__LINE__) NEW_LINE NEW_LINE; \
                message += "Callstack : " NEW_LINE NEW_LINE; \
                message += pretty_exception::getCallstackAsString(pretty_exception::EXCEPTION_CALLSTACK_DEPTH); \
                message += NEW_LINE NEW_LINE; \
                OUTPUT_EXCEPTION_TO_CONSOLE(message.c_str()); \
                TRACE_EXCEPTION(message.c_str());           \
                OUTPUT_EXCEPTION_TO_MESSAGE_BOX(message.c_str()); \
                throw exceptionType(message.c_str()); \
                        } \
                    }while(0);

#define THROW_PRETTY_RUNTIME_EXCEPTION(msg) THROW_PRETTY_EXCEPTION(msg, std::runtime_error , "std::runtime_error")
#define THROW_PRETTY_LOGICAL_EXCEPTION(msg) THROW_PRETTY_EXCEPTION(msg, std::logic_error , "std::logic_error")
#define THROW_PRETTY_INVALID_ARG_EXCEPTION(msg) THROW_PRETTY_EXCEPTION(msg, std::invalid_argument, "std::invalid_argument")
#define THROW_PRETTY_LENGTH_EXCEPTION(msg) THROW_PRETTY_EXCEPTION(msg, std::length_error, "std::length_error")

} // end of namespace

#endif