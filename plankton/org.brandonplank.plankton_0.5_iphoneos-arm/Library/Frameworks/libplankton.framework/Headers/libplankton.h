//
//  libplankton.h
//  libplankton
//
//  Created by Brandon Plank on 7/5/20.
//  Copyright © 2020 Brandon Plank. All rights reserved.
//

#import <Foundation/Foundation.h>
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

//! Project version number for libplankton.
FOUNDATION_EXPORT double libplanktonVersionNumber;

//! Project version string for libplankton.
FOUNDATION_EXPORT const unsigned char libplanktonVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <libplankton/PublicHeader.h>

//Kernel Functions
uint64_t Kernel_Execute(uint64_t addr, uint64_t x0, uint64_t x1, uint64_t x2, uint64_t x3, uint64_t x4, uint64_t x5, uint64_t x6);
//Reading
kern_return_t readFromkernel(task_t tfp0, uint64_t addr, void *data, size_t size);
uint64_t rf(uint64_t addr, mach_port_t port, uint64_t size);
size_t read_from_task(uint64_t addr, void *buf, size_t size, mach_port_t port);
uint64_t rk64(uint64_t addr);
size_t kernel_read(uint64_t addr, void *buf, size_t size);
//Writing
void write_what_where(uint64_t addr, uint64_t data, mach_port_t port);
size_t kernel_write(uint64_t addr, void *buf, size_t size);
bool wk64(uint64_t addr, uint64_t val);

//Plankton functions
int inittfp0(void);
int getTfp0(void);
void initEngine(void);
void give_info(void);
void gethexvals(const void* data, size_t size, uint64_t addr);
void quit(void);

//Pid & task finding
mach_port_t getPort(int pid);
int getPidOfProc(char nameofproc[128]);
uint64_t get_pid_of_proc(const char *process_name);

//Task control
void suspend(mach_port_t port);
void resume(mach_port_t port);

//Register control
void clear_register_vars(void);
void set_register(mach_port_t port, int thread_number, int register_num, uint64_t value, const char *other_registers);
void check_register(mach_port_t port, int thread_number, uint64_t value, int register_num, const char *other_registers);
void set_and_check_reg(mach_port_t port, int thread_number, uint64_t value, int register_num, const char *other_registers);
void regset(char reg[], uint64_t value, mach_port_t port, int thread_number);
void listreg(mach_port_t port, int thread_number);

void set_thread(mach_port_t port, int thread_number);
void get_thread(mach_port_t port, int thread_number);
void get_number_of_threads(mach_port_t port);

//Vars
uint64_t offset_options = 0;
uint64_t offset_cr_flags = 0;
uint64_t offset_zonemap=0;
uint64_t kernel_task_kaddr=0;
uint64_t kernel_task_offset_all_image_info_addr=0;
mach_port_t tfp0=0;
uint64_t kbase, kslide;
thread_act_port_array_t thread_list;
mach_msg_type_number_t thread_count;
// get threads in task
arm_thread_state64_t arm_state64;
mach_msg_type_number_t sc = ARM_THREAD_STATE64_COUNT;


