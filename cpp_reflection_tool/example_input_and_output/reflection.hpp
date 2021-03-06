#ifndef _REFLECTION_HPP_
#define _REFLECTION_HPP_

#include <vector>
#include <string>

enum class AccessSpecifier { PRIVATE, PROTECTED, PUBLIC };

struct Member
{
  std::string m_className;
  AccessSpecifier m_accessSpecifier;
  std::string m_name;
  std::string m_type;
};

class Reflection
{
public:

  static std::vector<std::string> GetClassNames()
  {
    std::vector<std::string> classes;
    for (auto& classData : m_classes)
    {
      classes.push_back(classData);
    }
    return classes;
  }

  static std::vector<Member>  GetMembers(const std::string& className)
  {
    std::vector<Member> ret;
    auto length = className.length();
    for (auto& classData : m_members)
    {
      if (className.compare(0, length, classData.m_className, 0, length) == 0)
      {
        ret.push_back(classData);
      }
    }
    return ret;
  }

private:
  static std::vector<Member> m_members;
  static std::vector<std::string> m_classes;
};

std::vector<Member> Reflection::m_members =
{
  { "Foo" , AccessSpecifier::PRIVATE, "m1 ", "int"},{ "Foo" , AccessSpecifier::PUBLIC, "m2 ", "int"},{ "Foo" , AccessSpecifier::PUBLIC, "f1 ", "method"},
};

std::vector<std::string> Reflection::m_classes =
{
  "Foo" , 
};

#endif