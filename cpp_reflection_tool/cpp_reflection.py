#!/usr/bin/env python
# 
#
# Understanding CLang AST : http://clang.llvm.org/docs/IntroductionToTheClangAST.html
#
# Requirements
#
# 1. Install Clang :  Visit http://llvm.org/releases/download.html
#
# 2. pip install clang
#
# Note : Make sure that your Python runtime and Clang are same architecture
#
#Core
import os.path
import os
from sys import platform as _platform
import time
from string import Template
#Libclang
import clang.cindex

class Utility:
    @staticmethod
    def getCurrentTimeInMilliseconds():
        return int(round(time.time() * 1000))

    @staticmethod
    def pressAnyKey():
        if _platform == "linux" or _platform == "linux2":
            os.system('read -s -n 1 -p "Press any key to continue..."')
        elif _platform == "win32":
            os.system('pause')

class StopWatch:
    def __init__(self):
        self.startTime = 0
        self.endTime = 0

    def start(self):
        self.startTime = Utility.getCurrentTimeInMilliseconds()

    def stop(self):
        self.endTime = Utility.getCurrentTimeInMilliseconds()

    def elapsedTimeInMilliseconds(self):
        return self.endTime - self.startTime

class CppAstWalker:
    @staticmethod
    def isValidCppTranslationUnitFile(fileName):
        if fileName is not None:
            fileName = str(fileName)
            if fileName.endswith(".cpp") or fileName.endswith(".hpp"):
                if os.path.exists(fileName):
                    return True
        return False

    @staticmethod
    def trimClangNodeName(nodeName):
        ret = str(nodeName)
        ret = ret.split(".")[1]
        return ret

    @staticmethod
    def printASTNode(node, level, exit=False):
        for i in range(0, level):
            print '  ',
        if exit is True:
            print ("Exiting " + CppAstWalker.trimClangNodeName(node.kind))
        else:
            print CppAstWalker.trimClangNodeName(node.kind)

    def visitNode(self, node, level):
        CppAstWalker.printASTNode(node, level)

    def leaveNode(self,node, level):
        CppAstWalker.printASTNode(node, level, True)

    def walkAST(self, node, level):
        if node is not None:
            level = level + 1
            self.visitNode(node, level)
        # Recurse for children of this node
        for childNode in node.get_children():
            self.walkAST(childNode, level)
        self.leaveNode(node, level)
        level = level - 1
        
class MemberAccessSpecifier:
    private = 1
    public = 2
    protected = 3

    @staticmethod
    def getAccessSpecifierAsString(accessSpecifier):
        if accessSpecifier is MemberAccessSpecifier.private:
            return "private"
        if accessSpecifier is MemberAccessSpecifier.public:
            return "public"
        if accessSpecifier is MemberAccessSpecifier.protected:
            return "protected"

class Member:
    def __init__(self, name, type, accessSpecifier):
        self.access_specifier = accessSpecifier
        self.name = name
        self.type = type

class Class:
    def __init__(self, name):
        self.name = name
        self.members = []

    def addMember(self, name, type, accessSpecifier):
        member = Member(name, type, accessSpecifier)
        self.members.append(member)

class CppReflectionSourceGenerator(CppAstWalker):
    def __init__(self):
        self.targetTranslationUnits = []
        # If the line below fails , set Clang library path with clang.cindex.Config.set_library_path
        self.libClangIndex = clang.cindex.Index.create()
        self.stopWatch = StopWatch()
        self.classes = []
        self.currentAccessSpecifier = MemberAccessSpecifier.private
        self.output = ""
        self.indentation = 0

    def visitNode(self, node, level):
        #CppAstWalker.printASTNode(node, level)
        if node.kind is clang.cindex.CursorKind.CLASS_DECL:
            newClass = Class(node.spelling)
            self.classes.append(newClass)
        if node.kind is clang.cindex.CursorKind.CXX_ACCESS_SPEC_DECL:
            if node.access_specifier.name is "PRIVATE":
                self.currentAccessSpecifier = MemberAccessSpecifier.private
            if node.access_specifier.name is "PUBLIC":
                self.currentAccessSpecifier = MemberAccessSpecifier.public
            if node.access_specifier.name is "PROTECTED":
                self.currentAccessSpecifier.name = MemberAccessSpecifier.protected
        if node.kind is clang.cindex.CursorKind.FIELD_DECL:
            classCount = len(self.classes)
            name = node.spelling
            type = node.type.spelling
            self.classes[classCount-1].addMember(name, type, self.currentAccessSpecifier)
        if node.kind is clang.cindex.CursorKind.CXX_METHOD:
            classCount = len(self.classes)
            name = node.spelling
            type = "method"
            self.classes[classCount - 1].addMember(name, type, self.currentAccessSpecifier)

    def setInput(self, fileOrPath):
        self.targetTranslationUnits = []
        if CppAstWalker.isValidCppTranslationUnitFile(fileOrPath):
            self.targetTranslationUnits.append(fileOrPath)
        else:
            if fileOrPath.endswith("\\") is not True :
                fileOrPath = fileOrPath + "\\"
            for entries in os.walk(fileOrPath):
                files = str(entries[2])
                files = files.split(',')
                for file in files:
                    file = str(file)
                    file = file.translate(None, " \/'[]")
                    file = fileOrPath + "\\" + file
                    if CppAstWalker.isValidCppTranslationUnitFile(file):
                        self.targetTranslationUnits.append(file)

    def appendLineToOutput(self, input):
        count = 0
        while count < self.indentation:
            self.output += "\t"
        self.output += input
        self.appendNewlineToOutput()

    def appendNewlineToOutput(self):
        self.output += "\n"

    def generateSource(self):
        membersCode = ""
        classesCode = ""

        for classEntry in self.classes:
            currentClassName = classEntry.name
            classesCode = classesCode + "\"" + currentClassName +"\" , "
            for memberEntry in classEntry.members:
                memberTemplate = Template("{ \"$CLASS_NAME \" , {{ AccessSpecifier::$ACCESS_SPECIFIER, \"$MEMBER_NAME \", \"$MEMBER_TYPE\"}}},")
                memberCode = memberTemplate.substitute(CLASS_NAME = currentClassName ,ACCESS_SPECIFIER=MemberAccessSpecifier.getAccessSpecifierAsString(memberEntry.access_specifier).upper(), MEMBER_NAME=memberEntry.name, MEMBER_TYPE=memberEntry.type )
                membersCode = membersCode + memberCode
        with open('reflection.template', 'r') as templateFile:
            self.output = templateFile.read()
            t = Template(self.output)
            self.output = t.substitute(MEMBERS=membersCode, CLASSES=classesCode)

    def build(self):
        if self.getTargetTranslationUnitNumber() > 0:
            self.classes = []
            self.stopWatch.start()
            for targetTranslationUnitFile in self.targetTranslationUnits:
                translationUnit = self.libClangIndex.parse(targetTranslationUnitFile)
                rootNode = translationUnit.cursor
                self.currentTranslationUnit = targetTranslationUnitFile
                self.walkAST(rootNode, 0)
            self.generateSource()
            self.stopWatch.stop()

    def saveAsAFile(self, fileName):
        file = open(fileName, 'w')
        file.write(self.output)

    def getTargetTranslationUnitNumber(self):
        return len(self.targetTranslationUnits)

    def getLastBuildTime(self):
        return self.stopWatch.elapsedTimeInMilliseconds()

def main():
    try:
        reflectionSourceGenerator = CppReflectionSourceGenerator()
        while True:
            file_or_path = raw_input('Enter a file name or path : ')
            reflectionSourceGenerator.setInput(file_or_path)
            tuNumber = reflectionSourceGenerator.getTargetTranslationUnitNumber()
            if tuNumber > 0:
                print("Number of translation units found : " + str(tuNumber))
                break
            continue
        reflectionSourceGenerator.build()
        print("Scan took : " + str(reflectionSourceGenerator.getLastBuildTime()) + " milliseconds")
        reflectionSourceGenerator.saveAsAFile("reflection.hpp")
        Utility.pressAnyKey()
    except ValueError as err:
        print(err.args)

#Entry point
if __name__ == "__main__":
   main()