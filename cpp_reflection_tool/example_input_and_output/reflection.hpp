#ifndef _REFLECTION_HPP_
#define _REFLECTION_HPP_

#include <typeinfo>
#include <unordered_map>
#include <vector>
#include <string>

enum class AccessSpecifier { PRIVATE, PROTECTED, PUBLIC };

struct Member
{
  AccessSpecifier m_accessSpecifier;
  std::string m_name;
  std::string m_type;
};

using ReflectionContainer = std::unordered_map<std::string, std::vector<Member>>;

class Reflection
{
  public:

    static std::vector<std::string> GetClassNames()
    {
      std::vector<std::string> classes;
      for (auto& classData : m_members)
      {
        classes.push_back(classData.first);
      }
      return classes;
    }

    static std::vector<Member> GetMembers(const std::string& className)
    {
      std::vector<Member> ret;
      for (auto& classData : m_members)
      {
        if (classData.first == className)
        {
          ret = classData.second;
          break;
        }
      }
      return ret;
    }


  private :
    static ReflectionContainer m_members;
	  static std::vector<std::string> m_classes;
};

ReflectionContainer Reflection::m_members = 
{
  { "Foo " , {{ AccessSpecifier::PRIVATE, "m1 ", "int"}}},{ "Foo " , {{ AccessSpecifier::PUBLIC, "m2 ", "int"}}},{ "Foo " , {{ AccessSpecifier::PUBLIC, "f1 ", "method"}}},
};

std::vector<std::string> Reflection::m_classes = 
{ 
  "Foo" , 
};

#endif