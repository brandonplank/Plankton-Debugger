#include <Foundation/Foundation.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <termios.h>
#include <mach/mach.h>
#include <mach/error.h>
#include <mach/mach_types.h>
#include <mach/mach_host.h>
#include <getopt.h>
#include <sys/event.h>
#include <sys/queue.h>
#include <sys/param.h>
#include <sys/sysctl.h>
#include <sys/types.h>
#include <sys/proc.h>
#include <ctype.h>

#include <libplankton/libplankton.h>

void attach(mach_port_t port);

void runAttach(){
    printf("Enter process to attach to >> ");
    int pid;
    char process[128];
    scanf("%s",*&process);
    printf("\x1b[0m");
    pid = getPidOfProc(process);
    if (pid == 0){
        printf("plankton does not currently support kernel debugging.\n");
        return;
    }
    printf("[+] Attaching to PID %d...\n",pid);

    mach_port_t port;
    kern_return_t kr;

    if(pid == 0){
        port = tfp0;
    } else if ((kr = task_for_pid(mach_task_self(), pid, &port)) != KERN_SUCCESS){
        printf("[!] Error!\n");
               
        printf("[!] Call to task_for_pid() with PID %d failed.\n",pid);
               
        return;
    }
    printf("[+] Got task port 0x%x for PID %d\n",port,pid);
    printf("[+] Attached PID %d\n",pid);
    attach(port);
}

void plankton(){
    while (1){
        char input[64];
        printf("\033[1m<plankton> \x1b[0m");
        scanf(" %63[^\n]",input);
        // split input into individual words (to determine command, arguments etc.
        char cmd[9][20]={0};
        int i, j, k;
        j=0;
        k=0;
        for(i=0; i < strlen(input); i++){
            if(input[i] == ' '){
                if(input[i+1] != ' '){
                    cmd[k][j]='\0';
                    j=0;
                    k++;
                }
                continue;
            }
            else{
                //copy other characters
                cmd[k][j++] = input[i];
            }
        }
        cmd[k][j]='\0';
        //
        if (strcmp(cmd[0],"help")==0){
            printf("\n\033[1m   help\x1b[0m  - prints this help message\n");
            printf("\033[1m   rk <address> <size>\x1b[0m  -  reads specified amount of bytes from specified address of the live kernel\n");
            printf("\033[1m   wk <address> <data>\x1b[0m  -  writes specified data to specified address of the live kernel\n");
            printf("\033[1m   attach\x1b[0m  -  attaches to the name or pid of a process\n");
            printf("\033[1m   kexecute <arg1|arg2|arg3|arg4|arg5|arg6|arg7|arg8>\x1b[0m  -  Call kernel functions\n");
            printf("\033[1m   off\x1b[0m  -  prints the kernel task port, Kernel Base, and Kernel Slide\n");
            printf("\033[1m   q\x1b[0m  -  quit plankton\n\n");
        }else if (strcmp(cmd[0],"q")==0){
            quit();
        }else if (strcmp(cmd[0],"off")==0){
            give_info();
        }else if (strcmp(cmd[0], "rk")==0){
            uint64_t value = strtoull(cmd[1], NULL, 0);
            size_t size = (size_t)strtoull(cmd[2],NULL,0);
            uint64_t livekerneladdr = kbase + kslide;
            if(value == livekerneladdr){
                printf("[!] Due to an issue with plankton, you are not able to read the live kernel base, as it kernel panics the device.\n");
                return;
            }
            if(value <= 0){
                printf("[!] The address cannot be 0 or less than 0.\n");
                return;
            }
            if ((int)cmd[2] <= 0){
                printf("[!] The size cannot be 0 or less than 0.\n");
                return;
            }
            printf("[+] Reading 0x%016llx\n", value);
            readFromkernel(tfp0, value, NULL, size);
        }else if (strcmp(cmd[0], "wk")==0){
            uint64_t arg1 = strtoull(cmd[1], NULL, 0);
            uint64_t arg2 = strtoull(cmd[2], NULL, 0);
            printf("[+] Writing 0x%016llx to 0x%016llx\n", arg1, arg2);
            wk64(arg1, arg2);
        } else if (strcmp(cmd[0], "attach")==0){
            runAttach();
        } else if (strcmp(cmd[0], "kexecute")==0){
                   uint64_t one = strtoull(cmd[1], NULL, 0);
                   uint64_t two = strtoull(cmd[2], NULL, 0);
                   uint64_t three = strtoull(cmd[3], NULL, 0);
                   uint64_t four = strtoull(cmd[4], NULL, 0);
                   uint64_t five = strtoull(cmd[5], NULL, 0);
                   uint64_t six = strtoull(cmd[6], NULL, 0);
                   uint64_t seven = strtoull(cmd[7], NULL, 0);
                   uint64_t eight = strtoull(cmd[8], NULL, 0);
            printf("[*] Executing 0x%016llx with arguments 0x%016llx 0x%016llx 0x%016llx 0x%016llx 0x%016llx 0x%016llx 0x%016llx\n", one, two, three, four, five, six, seven, eight);
                   Kernel_Execute(one, two, three, four, five, six, seven, eight);
               } else{
            printf("[!] Invalid command, run help for a help message.\n");
        }
    }
}

void attach(mach_port_t port){
    while (1){
        char input[64];
        printf("\033[1m<plankton pid> \x1b[0m");
        scanf(" %63[^\n]",input);
        // split input into individual words (to determine command, arguments etc)
        char cmd[5][20]={0};
        int i, j, k;
        j=0;
        k=0;
        for(i=0; i < strlen(input); i++){
            if(input[i] == ' '){
                if(input[i+1] != ' '){
                    cmd[k][j]='\0';
                    j=0;
                    k++;
                }
                continue;
            }
            else{
                //copy other characters
                cmd[k][j++] = input[i];
            }
        }
        cmd[k][j]='\0';
        //
        if (strcmp(cmd[0],"help")==0){
            printf("\n\033[1m   help\x1b[0m  - prints this help message\n");
            printf("\033[1m   registers\x1b[0m  -  lists all of the registers of the given pid on the main thread\n");
            printf("\033[1m   suspend\x1b[0m  -  suspends the current process being debugged\n");
            printf("\033[1m   resume\x1b[0m  -  resumes the current process being debugged\n");
            printf("\033[1m   regset <register> <value>\x1b[0m  -  displays the current state of the registers in the program being debugged\n");
            printf("\033[1m   read <address> <size>\x1b[0m  -  reads specified amount of bytes from specified address\n");
            printf("\033[1m   write <data> <address>\x1b[0m  -  writes specified data to specified address\n");
            printf("\033[1m   b\x1b[0m  -  goes back to the main session\n");
            printf("\033[1m   q\x1b[0m  -  quit plankton\n\n");
        }else if (strcmp(cmd[0],"q")==0){
            quit();
        }else if (strcmp(cmd[0], "registers")==0){
            int thread_number = 0;
            // get threads in task
            get_number_of_threads(port);
            printf("Enter the thread to attach to >> ");
            scanf("%d",&thread_number);
            printf("\x1b[0m");
            listreg(port, thread_number);
        }else if (strcmp(cmd[0], "b")==0){
            plankton();
        }else if (strcmp(cmd[0], "suspend")==0){
            suspend(port);
        }else if (strcmp(cmd[0], "resume")==0){
            resume(port);
        }else if (strcmp(cmd[0], "regset")==0){
            uint64_t value = (int)strtol(cmd[2],NULL,16);
            int thread_number = 0;
            get_number_of_threads(port);
            clear_register_vars();
            printf("Enter the thread to attach to >> ");
            scanf("%d",&thread_number);
            printf("\x1b[0m");
            regset(cmd[1],value,port, thread_number);
        }else if (strcmp(cmd[0], "write")==0){
            uint64_t addr = (int)strtol(cmd[1],NULL,16);
            uint64_t data = (int)strtol(cmd[2],NULL,16);
            write_what_where(addr,data,port);
        }else if (strcmp(cmd[0], "read")==0){
            uint64_t addr = (int)strtol(cmd[1],NULL,16);
            size_t size = (int)strtol(cmd[2],NULL,16);
            rf(addr,port, size);
        } else{
            printf("[!] Invalid command, run help for a help message.\n");
        }
    }
}

int main(int argc, const char **argv, const char **envp) {
    if (getuid() != 0) {
        setuid(0);
    }

    if (getgid() != 0) {
        setgid(0);
    }

    if (getuid() != 0 || geteuid() != 0 || getgid() != 0) {
        NSString *error = @"";
        if (getuid() != 0 || geteuid() != 0){
            error = [error stringByAppendingString:@"Can't set uid as 0.\n"];
        }
        if (getgid() != 0){
            error = [error stringByAppendingString:@"Can't set gid as 0.\n"];
        }
        printf("%s", [error UTF8String]);
        return 1;
    }
    initEngine();
    tfp0 = getTfp0();
    printf("[+] Starting plankton by Brandon Plank\n[i] This is a beta, so expect more features!\n");
    give_info();
    plankton();
    return 1;
}
