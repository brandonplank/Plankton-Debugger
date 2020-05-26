#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main()
{
    if (geteuid() != 0) {
        printf("Run this as root!\n");
        return 1;
    }

    char *commands[2] = {"chown root:wheel /usr/bin/plankton", "chmod 6755 /usr/bin/plankton"};

    for (int i = 0; i < 2; i++) {
        int status = system(commands[i]);
        if (WEXITSTATUS(status) != 0) {
            printf("Error in command: \"%s\"\n", commands[i]);
            return WEXITSTATUS(status);
        }
    }
    return 0;
}
