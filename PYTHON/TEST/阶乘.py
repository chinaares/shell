#!/usr/bin/python
# -*- coding: UTF-8 -*-
import os


def ff(n):
    """阶乘"""
    if n == 1:
        return 1
    else:
        return n * ff(n-1)

print ff(5)


def power(x, n):
    """幂"""
    if n == 0:
        return 1
    else:
        return x * power(x, n-1)
print power(2, 3)
