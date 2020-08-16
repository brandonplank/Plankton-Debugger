#ifndef you2_h
#define you2_h

#include <stdio.h>
#endif

#define RED_TEXT "\x1b[31m"
#define GREEN_TEXT "\x1b[32m"
#define BLUE_TEXT "\x1b[34m"
#define BOLD_TEXT "\033[1m"
#define SCANF_TEXT "%63[^\n]"
#define RESET_TEXT "\x1b[0m"

#define WARNING "["RED_TEXT"!"RESET_TEXT"]"
#define INFORMATION "["BLUE_TEXT"i"RESET_TEXT"]"
#define PROGRESS "["GREEN_TEXT"+"RESET_TEXT"]"
