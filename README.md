cmake_modules
=============

About
-----

This is a collection of CMake modules I use

How to use
----------

At the minimum, all you have to do is add a line like this near the top
of your root CMakeLists.txt file (but not before your project() call):

```CMake
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake_modules")
```
