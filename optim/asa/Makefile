#***********************************************************************
# ASAMIN --- MATLAB Gateway to Lester Ingber's Adaptive Simulated
# Annealing (ASA) Software
# 
# Copyright (c) 1999-2008  Shinichi Sakata.  All Rights Reserved.
#***********************************************************************
# $Id: Makefile,v 1.39 2011/02/18 16:49:47 ssakata Exp $
#
CFLAGS = -O4 -fPIC -ansi -pthread -fexceptions -m32 -g
#CFLAGS = -O3 -g -Wall
#CFLAGS = -g
LDFLAGS = -O4 
#LDLIBS = -ldl
#LDFLAGS = -O3 -g -Wall -Zexe
#LDFLAGS = -g
#DEBUGFLAG =
DEBUGFLAG = -DDEBUG
DEFINES = \
  -DUSER_ACCEPTANCE_TEST=TRUE \
  -DUSER_ASA_OUT=TRUE \
  $(DEBUGFLAG)
CC=gcc
MEX=mex -v -g
#MEX=cmex
#
TARGET = asamin.mexglx

$(TARGET): asamin.c asamin.h asa.c asa.h asa_usr_asa.h 
	$(MEX) $(DEFINES) asamin.c asa.c -ll -lm COPTIMFLAGS="-O 4" LDOPTIMFLAGS="-O 4"

clean:
	rm -rf *.o asatest[12].log $(TARGET)

new: clean $(TARGET)

package:
	cd ..; \
	tar cvf - \
                asamin/Makefile \
                asamin/LICENSE \
                asamin/README \
                asamin/asamin.c \
                asamin/asamin.h \
                asamin/asamin.m \
                asamin/asatest.m \
                asamin/test_cost_func1.m \
                asamin/test_cost_func2.m \
                | gzip -c - > asamin/asamin.tar.gz
