cmake_minimum_required(VERSION 3.10)
project(nithya C)

add_library(nithya SHARED
    nithya/nithya_math.c
    nithya/nithya_planets.c
    nithya/nithya_panchang.c
)

target_include_directories(nithya PUBLIC nithya/include)
target_link_libraries(nithya m)
