# GDB 调试与 ELF 文件分析学习笔记

---

## 目录

1. ELF 文件结构分析
2. GDB 基础操作
3. 内存与变量调试
4. 程序流程控制
5. 源码定位与路径管理
6. 高级调试技巧

---

## 1. ELF 文件结构分析

### 1.1 `readelf` 命令详解

```bash
readelf -S cmd -W
```

**参数说明：**

- `readelf`：显示 ELF 格式文件的结构信息
- `-S`：显示节区表（Section Headers）
- `cmd`：要分析的 ELF 文件名
- `-W`：强制宽输出，防止长行被截断

### 1.2 输出格式解读

```
Section Headers:
  [Nr] Name              Type            Address          Off    Size   ES Flg Lk Inf Al
  [ 0]                   NULL            0000000000000000 000000 000000 00      0   0  0
  [ 1] .interp           PROGBITS        0000000000000238 000238 00001c 00   A  0   0  1
```

**各列含义：**
| 列名 | 含义 | 说明 |
| ------- | -------- | --------------------------- |
| Nr | 节区编号 | 从0开始的序号 |
| Name | 节区名称 | 如 `.text`, `.data`, `.bss` |
| Type | 节区类型 | `PROGBITS`, `NOBITS` 等 |
| Address | 内存地址 | 节区在内存中的加载地址 |
| Off | 文件偏移 | 节区在文件中的位置 |
| Size | 节区大小 | 以字节为单位 |
| ES | 条目大小 | Entry Size |
| Flg | 标志位 | A=可分配，W=可写，X=可执行 |
| Lk | 链接信息 | 相关节区编号 |
| Inf | 附加信息 | - |
| Al | 对齐方式 | 字节对齐 |

### 1.3 常用过滤技巧

```bash
# 只查看关键节区
readelf -S cmd -W | grep '\.text\|\.data\|\.bss'

# 查看可执行节区
readelf -S cmd -W | grep ' AX '
```

---

## 2. GDB 基础操作

### 2.1 启动与界面管理

```bash
# 启动调试
gdb -q cmd2                    # 安静模式启动
gdb cmd2 core                  # 加载core文件

# 清屏操作
shell clear                    # 或 !clear
Ctrl+L                         # 快捷键清屏
```

### 2.2 TUI 界面模式

```bash
# 布局切换
layout src                     # 源码窗口
layout split                   # 分割窗口（源码+汇编）
layout asm                     # 汇编窗口
layout regs                    # 寄存器窗口

# 控制命令
Ctrl+X, A                      # 开关 TUI 模式
Ctrl+X, o                      # 切换窗口焦点
tui disable                    # 禁用 TUI 模式
```

### 2.3 程序执行控制

```bash
# 基本执行
run                            # 运行程序
continue                       # 继续执行
step                           # 单步执行（进入函数）
next                           # 单步执行（不进入函数）
finish                         # 执行完当前函数

# 断点管理
break main                     # 在main函数设断点
break cmd.cc:25               # 在指定文件行设断点
info breakpoints              # 查看所有断点
delete 1                      # 删除1号断点
```

---

## 3. 内存与变量调试

### 3.1 变量查看与修改

```bash
# 查看变量
print a                        # 查看变量a
print /x a                     # 十六进制显示
print /d a                     # 十进制显示
print /t a                     # 二进制显示
print &a                       # 查看地址

# 修改变量
set var a = 0x12345678         # 修改变量值
set variable a = 100           # 完整语法
print a = 200                  # 赋值表达式
```

### 3.2 内存检查命令

```bash
# examine 内存命令格式
x /[n][f][u] address

# 参数说明
# n: 显示单元数量（默认1）
# f: 输出格式（x=十六进制, d=十进制, o=八进制, t=二进制, c=字符, s=字符串, i=指令）
# u: 单元大小（b=1字节, h=2字节, w=4字节, g=8字节）

# 实用示例
x /x &a                        # 十六进制查看变量a的内存
x /4x &a                       # 查看4个字（16字节）
x /s buf                       # 以字符串格式查看
x /i $pc                       # 查看当前指令
x /5i $pc                      # 查看5条指令
```

### 3.3 数组与指针调试

```bash
# 数组访问的三种方式
print buf                      # 显示完整数组内容
print &buf[0]                  # 第一个元素地址
print &buf                     # 整个数组地址

# 字符串调试
x /s buf                       # 数组名作为字符串
x /s &buf[0]                   # 第一个元素作为字符串
x /s str.c_str()               # C++ string内容
```

**重要概念对比：**
| 表达式 | 类型 | 含义 | 指针运算 |
| --------- | -------------- | -------------- | ---------------- |
| `buf` | `char*` | 指向第一个字符 | `+1` 移动1字符 |
| `&buf[0]` | `char*` | 第一个元素地址 | `+1` 移动1字符 |
| `&buf` | `char(*)[128]` | 整个数组地址 | `+1` 移动128字符 |

---

## 4. 程序流程控制

### 4.1 跳转与流程控制

```bash
# 程序计数器控制
print $pc                      # 查看当前指令地址
set $pc = address              # 修改程序计数器
p $pc = address                # 跳转到指定行

jump line_number               # 跳转到指定行
jump *address                  # 跳转到指定地址

# 函数返回控制
return                         # 立即从当前函数返回
return 42                      # 返回指定值
call function_name(args)       # 调用函数
```

### 4.2 观察点（Watchpoint）

```bash
# 设置观察点
watch variable_name            # 变量被写入时中断
rwatch variable_name           # 变量被读取时中断
awatch variable_name           # 变量被读写时中断

# 管理观察点
info watchpoints               # 查看所有观察点
delete watchpoint 1            # 删除观察点
```

---

## 5. 源码定位与路径管理

### 5.1 源码路径管理

```bash
# 查看源码信息
info source                    # 当前源文件信息,显示当前源文件的文件名、包含的行数、起止行号、以及 GDB 当前的源码搜索路径等信息。
show directories               # 源码搜索路径

# 路径管理
directory /path/to/source      # 添加源码搜索路径
dir /project/src               # 简写形式
directory                      # 重置为默认路径

# 源码查看
list                           # 显示当前位置源码
list main                      # 显示main函数
list file.c:10                # 显示指定文件行
```

### 5.2 搜索功能

```bash
# 代码搜索
search 正则表达式              # 向前搜索
reverse-search 正则表达式      # 向后搜索
```

### 5.3 路径问题排查案例

**问题现象：**

```bash
(gdb) list test.cc:9
warning: test.cc: 没有那个文件或目录
```

**排查步骤：**

```bash
(gdb) show directories         # 检查搜索路径
(gdb) info source             # 查看编译信息
(gdb) !pwd                    # 确认当前目录
(gdb) directory AAA/          # 添加子目录到搜索路径
```

---

## 6. 高级调试技巧

### 6.1 调用栈分析

```bash
# 调用栈查看
bt                             # 基本调用栈
bt full                        # 详细调用栈（含局部变量）
info frame                     # 当前栈帧详细信息
frame 1                        # 切换到指定栈帧
up                             # 向上一帧
down                           # 向下一帧
```

### 6.2 输出格式控制

```bash
# 显示控制
set print null-stop on         # 遇到\0停止打印
set print null-stop off        # 遇到\0继续打印（默认）
set print array on             # 启用数组格式化
set print array off            # 禁用数组格式化
set print pretty on            # 美化结构体输出
```

### 6.3 内存直接操作

```bash
# 内存修改
set {int}0x1234 = 88          # 直接修改内存地址值
set {char[6]}str = "hello"    # 修改字符串内容

# 类型转换
print (char*)0x7fffffffde00   # 类型转换为字符指针
print *(char*)0x7fffffffde00  # 解引用查看内容
```

### 6.4 运行时修改 vs 源码修改

**运行时修改优势：**

- 快速验证修复方案
- 动态测试不同参数
- 跳过错误代码段
- 模拟各种边界条件

**修改流程对比：**

```
传统方式: 修改源码 → 编译 → 运行 → 测试 → 重复
GDB方式: 运行 → 断点 → 实时修改 → 观察结果 → 确定方案 → 修改源码
```

### 6.5 Core Dump 调试

```bash
# 启用core dump
ulimit -c unlimited            # 允许生成core文件

# 检查core文件设置
cat /proc/sys/kernel/core_pattern

# 调试core文件
gdb program_name core          # 加载core文件调试
```

---

## 7. 实用调试场景

### 7.1 段错误调试

```bash
# 典型段错误：空指针解引用
char* ptr = nullptr;
memcpy(ptr, "abc", 3);         # 崩溃原因

# GDB调试流程
(gdb) run
Program received signal SIGSEGV, Segmentation fault.
(gdb) bt                       # 查看调用栈
(gdb) print ptr                # 检查指针值
$1 = 0x0                       # 确认是空指针
```

### 7.2 在线代码修改

```bash
# 不退出GDB修改代码
(gdb) shell vim source.c       # 编辑源文件
(gdb) shell make              # 重新编译
(gdb) file ./new_program      # 重新加载程序
(gdb) run                     # 继续调试
```

### 7.3 std::string 调试

```bash
# C++ string对象调试
print str                      # 查看完整string对象
x /s str.c_str()              # 查看字符串内容（正确方法）
print str.length()            # 查看字符串长度

# 错误示例
x /s str                      # 错误：Cannot convert to integer
x /s &str                     # 错误：显示对象内部数据
```

---

## 8. 常用命令速查表

| 分类         | 命令               | 功能                 |
| ------------ | ------------------ | -------------------- |
| **程序控制** | `run`              | 运行程序             |
|              | `continue`         | 继续执行             |
|              | `step`             | 单步进入             |
|              | `next`             | 单步跳过             |
| **断点**     | `break main`       | 设置断点             |
|              | `info breakpoints` | 查看断点             |
|              | `delete 1`         | 删除断点             |
| **变量**     | `print var`        | 查看变量             |
|              | `set var = value`  | 修改变量             |
|              | `info locals`      | 查看局部变量         |
| **内存**     | `x /x &var`        | 查看内存（十六进制） |
|              | `x /s address`     | 查看字符串           |
|              | `x /i $pc`         | 查看指令             |
| **调用栈**   | `bt`               | 查看调用栈           |
|              | `bt full`          | 详细调用栈           |
|              | `frame n`          | 切换栈帧             |
| **源码**     | `list`             | 显示源码             |
|              | `directory path`   | 添加源码路径         |
|              | `info source`      | 源文件信息           |

---

**注意事项：**

1. 调试时确保编译时添加 `-g` 选项生成调试信息
2. 运行时修改只在调试会话中有效，最终需要修改源码
3. 使用 `help command` 查看命令详细帮助
4. 善用Tab键补全命令和变量名
5. 复杂调试场景建议结合多种调试技巧综合使用

### 3. 使用第三方工具生成core文件

- 可以用 **procdump**（微软官方工具）监控进程并生成 dump 文件：
    ```
    procdump -e -ma your_program.exe
    ```
    这样程序崩溃时会在当前目录生成 dump 文件。

### 7.2 符号文件提取与管理

#### 提取符号文件

```bash
objcopy --only-keep-debug <input_elf> <output_sym>
strip --strip-debug <原文件> -o <新文件>
```

#### 分离与加载符号

```bash
objcopy --strip-debug myprogram
objcopy --add-gnu-debuglink=myprogram.sym myprogram
```

#### GDB 加载符号文件

```bash
file <executable_path>         # 加载可执行文件
info files                     # 显示已加载文件
add-symbol-file <debug_info_file> <load_address>
info symbol ADDRESS            # 显示符号信息
remove-symbol-file /path/to/my_program.sym
core-file <core file>          # 加载 core 文件
```

file <executable_path> #加载指定路径的可执行文件
info files #显示当前加载的可执行文件、符号表和core dump信息
add-symbol-file <debug_info_file> <load_address>
<debug_info_file>：包含调试信息的文件（如来到高符号的原始二进制）
<load_address>：程序加脱的基地址
info symbol ADDRESS # 显示所有已加的符号文件及其加载地址
remove-symbol-file /path/to/my_program.sym #删除符号文件
core-file <core file> #加载core文件

readelf-h file.elf #查看ELF文件的头文件信息
objcopy--only-keep-debug <input_elf> <output_sym> #提取符号表到独立文件
strip --strip-debug <原文件> -o <新文件>

strip --only-keep-debug cmd_no_pie -o cmd_no_pie_strip
objcopy --strip-debug myprogram

gdbserver ipcport elt #目标机启动程序
target remote <hostport> #在远程调试时，需先通过target remote连接，再加驱远程文件file <debug Infofile>

## 附录：寄存器相关命令

```bash
info registers           # 显示通用寄存器（如 rax, rbx, rcx 等）
info all-registers       # 显示所有寄存器（含浮点、向量等）
info r rdi               # 查看第一个入参
info r rsi
info r rdx
info r rcx
info r r8
info r r9
info r eax               # 32位通用寄存器
info r rax               # 64位通用寄存器
info r rip               # 程序计数器
info r rsp               #栈顶寄存器
info r rbp               # 带基址寄存器（栈底寄存器）
```

````markdown
# GDB 常用命令与调试技巧整理

## 1. 动态加载共享库（.so 文件）及符号表关联

- 编译生成带调试信息的共享库：
    ```bash
    g++ -fPIC -shared -o libfunc.so func.cc -g
    ```
````

- 设置运行时库依赖路径：

    ```gdb
    set environment LD_LIBRARY_PATH=路径
    show environment LD_LIBRARY_PATH
    ```

- 查看当前加载的共享库及其符号状态：

    ```gdb
    info sharedlibrary
    ```

- 禁用/查看自动加载共享库：

    ```gdb
    set auto-solib-add off
    show auto-solib-add
    ```

- 手动加载共享库及符号：

    ```gdb
    sharedlibrary                # 加载所有已链接的共享库
    sharedlibrary libname.so     # 加载指定名称的共享库
    sharedlibrary /path/to/libname.so # 加载指定路径的共享库
    ```

- 加载调试符号文件：

    ```gdb
    add-symbol-file <debug_info_file> <load_address>
    # <debug_info_file>：包含调试信息的文件（如未剥离符号的原始二进制）
    # <load_address>：程序加载的基地址
    ```

- 加载 core 文件：

    ```gdb
    core-file <core file>
    ```

- 设置共享库搜索路径：
    ```gdb
    set solib-search-path /path1:/path2
    ```

## 2. 断点信息的保存与加载

- 保存断点信息：

    ```gdb
    save breakpoints breakpoints.gdb
    ```

- 加载断点文件：
    ```gdb
    source breakpoints.gdb
    ```

## 3. GDB 启动配置文件

- 用户目录下新建可信任路径：

    ```
    ~/.gdbinit
    add-auto-load-safe-path PATH
    ```

- 当前目录下存储命令：
    ```
    ./gdbinit
    ```

## 4. ptype 查看变量、类型、函数详细定义

- 查看变量、类型、结构体、类、枚举、数组等定义：

    ```gdb
    ptype <变量名>
    ptype <类型名>
    ptype <枚举类型>
    ptype <数组名>
    ptype <函数名>
    ```

- 启用/禁用对象打印及查看设置：

    ```gdb
    set print object on
    set print object off
    show print object
    ```

- 查看基类指针指向派生类对象的类型：

    ```gdb
    ptype <基类指针>
    ```

- 查看虚函数表：

    ```gdb
    info vtbl <指针变量>
    ```

- 显示模板类型及递归展开模板内部：

    ```gdb
    ptype my_vector
    ptype /r my_vector
    ```

- 显示类型的内存布局：
    ```gdb
    ptype /o <类型名或变量名>
    ```

## 5. layout 文本用户界面（TUI, Text User Interface）模式

- 启动时直接进入 TUI 模式：

    ```bash
    gdb -tui /your_program
    ```

- 常用布局命令：

    ```gdb
    layout src      # 显示源代码窗口
    layout asm      # 显示汇编代码窗口
    layout regs     # 显示寄存器窗口
    layout split    # 分屏显示源代码和汇编代码
    layout next     # 下一个布局
    layout prev     # 上一个布局
    ```

- 查看和切换窗口：

    ```gdb
    info win
    focus src/asm/regs   # 切换命令输入窗口
    ```

- 启用/禁用 TUI：

    ```gdb
    tui disable
    tui enable
    ```

- 快捷键切换 TUI 模式：
    ```
    Ctrl + x, a
    ```

---

````markdown
# GDB 外部命令与输出管理

## 1. 执行外部 Shell 命令

- 查看当前目录文件列表：
    ```gdb
    shell ls -l
    ! ls -l
    ```
````

- 查看配置文件内容：
    ```gdb
    shell cat config.txt
    ! cat config.txt
    ```

## 2. 执行管道（pipe）命令

- 结合过滤命令使用：

    ```gdb
    pipe | command | shell_filter
    ```

    ```gdb
    | command | shell_filter
    ```

- 例如，查看函数列表的最后 N 行：

    ```gdb
    pipe | i functions | tail -n <num>
    ```

    ```gdb
    | i functions | tail -n <num>
    ```

- 查看函数列表的前 N 行：

    ```gdb
    pipe | i functions | head -n <num>
    ```

    ```gdb
    | i functions | head -n <num>
    ```

## 3. 将 GDB 输出保存到文件

- 查看 logging 设置：

    ```gdb
    show logging
    ```

- 打开/关闭日志记录：

    ```gdb
    set logging on
    set logging off
    ```

- 设置日志文件名：

    ```gdb
    set logging file <文件名>
    ```

- 设置是否覆盖原有文件（默认追加）：
    ```gdb
    set logging overwrite on    # 覆盖原有文件
    set logging overwrite off   # 追加到原有文件
    ```

````markdown
# GDB 跳转执行与反向执行命令整理

## 1. jump 命令 —— 强制改变程序执行路径

- `jump` 命令会强制修改程序的执行流（即修改 `rip` 寄存器），让程序从指定位置继续执行，直到遇到断点或程序结束。

### 基本用法

```gdb
jump <location>         # 跳转到指定位置
j <location>            # jump 的缩写
jump 100                # 跳转到当前文件的第 100 行
jump main.c:50          # 跳转到 main.c 的第 50 行
jump *0x401000          # 跳转到 0x401000 地址（16进制）
jump LABEL              # 跳转到代码标签处
```
````

### 相关说明

- `endbr64`：间接分支目标，标记合法分支目标（通常与控制流保护相关）。
- 跳转到函数序言（如栈帧设置、变量初始化）或函数尾声（恢复寄存器、恢复栈指针、返回）时要特别小心。

### 使用 jump 的注意事项

1. **避免跨越对象构造**
   跳转可能导致对象未正确构造或析构，造成未定义行为。
2. **避免跨越函数边界**
   跳转到不同函数或跨越函数边界可能导致栈混乱或程序崩溃。

---

## 2. 反向执行（Reverse Execution）

反向执行允许程序回溯到之前的状态，便于调试和定位问题。

### 启用与停止记录

```gdb
record         # 开始记录执行历史
record stop    # 停止记录
```

### 反向执行常用命令

- 反向执行下一行（不进入函数）：
    ```gdb
    reverse-next      # 简写：rn
    ```
- 反向单步执行（进入函数）：
    ```gdb
    reverse-step      # 简写：rs
    ```
- 反向继续执行，直到上一个断点或程序开始：
    ```gdb
    reverse-continue  # 简写：rc
    ```
- 反向执行到函数调用点：
    ```gdb
    reverse-finish
    ```

---

````markdown
## GDB 调用函数与符号表相关操作

### 1. GDB 中调用函数的常用命令

- **直接调用函数，自动推导返回类型**
    ```gdb
    p my_function(1, 2)
    ```
````

- **调用无返回值函数**

    ```gdb
    call my_void_function()
    ```

- **查看函数原型**

    ```gdb
    ptype my_func(int)
    ```

- **显式指定返回类型调用**

    ```gdb
    p (int)my_function(1, 2)
    ```

- **显式指定 void 类型调用**

    ```gdb
    call (void)my_void_function()
    ```

- **调用库函数或标准函数**

    ```gdb
    call strcpy($str, "hello")
    call sizeof("hello")
    call printf("world\n")
    ```

- **调用函数指针**

    ```gdb
    p ((int (*)(int, int))add)(1, 2)
    ```

- **调用对象的成员函数**
    ```gdb
    call my_obj->member_func(10)
    ```

---

### 2. ELF 符号表与调试信息

- **查看 ELF 文件符号表**

    ```bash
    readelf -s file         # 或 readelf --symbols file
    ```

- **符号表无返回值信息说明**
    - `.symtab`：符号表（Symbol Table），记录函数、变量等符号信息，但不包含函数返回值类型。

- **C++ 符号名解码**

    ```bash
    c++filt _Z11print_test2i
    # 输出：print_test2(int)
    ```

- **导出调试信息到文本**
    ```bash
    readelf --debug-dump=info elf > elf.txt
    ```

---

**说明：**

- `p` 和 `call` 都可用于调用函数，`p` 会显示返回值，`call` 适合无返回值或只需执行副作用的函数。
- `ptype` 可用于查看函数、变量、类型的详细定义。
- 使用 `readelf` 和 `c++filt` 可辅助分析 ELF 文件和 C++ 符号。

# GDB 多线程调试常用命令笔记

## 线程管理

- `info threads`
  列出所有线程（不包括已执行完成的线程，不显示历史线程），当前线程前有 `*` 标记。

- `thread`
  显示当前线程的 ID 和状态。

- `thread <ID>`
  切换到指定线程（ID 为 `info threads` 输出的编号）。
  例：`thread 3` 切换到线程3。

- `thread name <Name>`
  为当前线程设置线程名（需支持 `pthread_setname_np`）。

- `thread find <Name>`
  根据线程名等属性查找对应线程。

## 调用栈与变量查看

- `bt`
  查看当前线程的调用栈信息。

- `bt full`
  查看完整调用栈及所有局部变量。

- `frame <N>`
  切换到指定的调用帧（如 `frame 2`）。

- `info locals`
  查看当前帧的局部变量。

## 线程批量操作

- `thread apply <ID> <command>`
  对指定线程执行命令。
  例：`thread apply 1 bt` 查看线程1的调用栈。

- `thread apply all <command>`
  对所有线程执行命令。
  例：`thread apply all bt` 显示所有线程的调用栈。

## 断点与调度控制

- `break <location> thread <ID>`
  仅在指定线程触发断点。

- `set scheduler-locking on|off|step`
  控制线程调度方式：
    - `on`：单线程执行（其他线程暂停）
    - `off`：多线程并发（默认）
    - `step`：仅当前线程单步执行

- `set print thread-events on`
  启用线程事件打印。

## 操作系统级线程控制

- `kill -STOP <pid>`
  暂停指定线程（用线程的系统级 PID）。

- `kill -CONT <pid>`
  恢复指定线程。

## 线程断点与暂停说明

- 当某个线程触发断点时，GDB 会尝试暂停所有线程。
- 对于正在执行 CPU 指令的线程，GDB 可以立即暂停它们。
- 对于已进入内核阻塞的系统调用（如 `sleep`、`read`、`wait` 等），GDB 无法直接中断这些调用，线程会继续运行直到从内核态返回用户态，此时 GDB 才能捕获并暂停线

````markdown
# 成果物输出工程化与调试实践

## 可执行文件调试信息处理

- 剥离调试信息但保留在 `.debug` 段
    ```sh
    strip -g program -o program_s
    ```
````

- 分离调试信息到独立文件

    ```sh
    objcopy --only-keep-debug program program.debug
    ```

- 完全剥离调试信息（文件显示为 stripped）
    ```sh
    objcopy --strip-all program program_o_all
    strip --strip-all program -o program_s_all
    ```

---

## GDB 调试相关命令

- 显式指定符号文件和可执行文件

    ```sh
    gdb -q -symbol=program --exec=program_s
    gdb -q -s program -e program_s
    ```

- 交互模式下加载符号和可执行文件

    ```sh
    gdb -q program_s
    (gdb) symbol-file program
    (gdb) file program
    ```

- 结合 gdbserver 远程调试

    ```sh
    gdb -q --symbol=program --exec=program_s
    (gdb) target remote server:port
    ```

- 指定源代码路径
    ```sh
    gdb -q --symbol=program --exec=program_s --directory=PATH
    ```

---

## 符号与调试信息段

- 查看符号表内容

    ```sh
    readelf --symbols demo_s
    ```

- 主要信息段说明
    - `.symtab`：包含完整的符号信息，用于编译、链接和调试
    - `.dynsym`：包含动态链接所需的最小符号集，用于程序运行时解析外部符号
    - `.debug`：存储详细的调试元数据，支持源码级调试；`.symtab` 支持链接器和调试器快速定位符号

- 调试符号信息存放于 `.debug_*` 信息段中，符号表信息存放于 `.sym*` 信息段中

---

## 其他说明

1. 读各个 debug 段信息
2. 体积因素：占用空间 + OTA 升级
3. 逆向工程与合规约束

在 Vim 中比较两个文件（即使用 diff 功能），常用方法如下：

### 1. 直接在命令行打开

```sh
vim -d file1 file2
```

或

```sh
vimdiff file1 file2
```

### 2. 在 Vim 已打开的情况下

假设你已经打开了第一个文件，可以输入：

```vim
:vert diffsplit file2
```

或

```vim
:diffsplit file2
```

- `:diffsplit` 水平分屏比较
- `:vert diffsplit` 垂直分屏比较

### 3. 退出 diff 模式

在 Vim 中输入：

```vim
:diffthis
```

或

```vim
:diffoff
```

来开启或关闭当前窗口的 diff 模式。

---

**总结：**

- 推荐直接用 `vim -d file1 file2` 或 `vimdiff file1 file2`
- 也可以用 `:diffsplit` 或 `:vert diffsplit`
- `:diffthis` 用于让当前窗口进入 diff 模式，通常配合分屏使用

如需详细操作步骤请告知！

你按下 `Ctrl+Z` 后，GDB 进程被**挂起（暂停）**，进入后台，终端显示 `[1]+  已停止               gdb -q`。

---

### 恢复方法

在终端输入：

```sh
fg
```

即可让 GDB 回到前台，继续之前的调试内容。

---

### 说明

- `Ctrl+Z` 会把当前前台进程挂起并放到后台。
- 用 `fg` 恢复到前台即可继续操作，无需重启 GDB。

是的，GDB 的 `record`（如 `record full`）命令**有保存步数的限制**，类似 Word 的撤销（Ctrl+Z）功能。

### 具体说明

- GDB 会为每一步保存程序状态（快照），用于 `reverse-continue`、`reverse-step` 等逆向调试。
- **默认最多保存 200000 步（条指令）**，超过后最早的记录会被丢弃（即“环形缓冲区”）。
- 你可以通过如下命令查看和设置最大步数：

    ```gdb
    show record full stop-at-limit
    show record full insn-max
    set record full insn-max 500000   # 例如设置为50万步
    ```

- 如果回退超过最大步数，最早的历史记录就无法再回退。

---

**总结：**
GDB 的 `record` 功能有步数上限，默认20万步，可手动调整。超过上限后，最早的记录会被覆盖，无法无限制回退。

在 Vim 中，`s` 和 `S` 的原始功能如下：

- `s`（substitute）：**删除光标所在字符，并进入插入模式**。
  等价于 `cl`（change one character）。

- `S`（大写 S）：**删除光标所在行的内容，并进入插入模式**。
  等价于 `cc`（change whole line）。

举例说明：

- 按下 `s`，当前字符被删除，光标处于插入模式，可以直接输入新内容。
- 按下 `S`，当前行内容被清空，光标处于插入模式，可以直接输入新行内容。

你的理解基本正确，下面详细说明：

### GDB 调试时常见的文件类型

1. **可执行文件（.exe 或无扩展名）**
    - 这是编译生成的程序文件，可以包含或不包含调试信息（.debug 段）。
    - 如果去掉了 .debug 段，文件体积会变小，但不包含符号和源码信息。

2. **符号文件（.sym 或 .debug）**
    - 这是专门存放调试信息的文件，通常通过 `objcopy --only-keep-debug` 生成。
    - 可以用 `objcopy --add-gnu-debuglink=xxx.sym xxx.exe` 关联符号文件和可执行文件。

3. **源代码文件（.c, .cpp, .cc, .h 等）**
    - 不是必须的，但如果你想在 GDB 中单步源码、查看源码行，**需要有源文件**。
    - 没有源文件时，GDB 只能显示汇编级别的调试信息。

### 结论

- **最少需要可执行文件和符号文件**，这样可以进行符号级调试（如变量名、函数名、堆栈等）。
- **如果需要源码级调试（如单步源码、查看源码行），还需要源文件。**
- 没有源文件时，GDB 只能进行汇编级调试。

---

**总结：**
GDB 调试时，最少需要可执行文件和符号文件。
如果想源码级调试，还需要源文件。

````markdown
# 远程调试 GDB/gdbserver 实用笔记

---

## 1. 安装 gdbserver

```sh
sudo apt-get install gdbserver
```
````

---

## 2. 目标环境（远程主机/被调试端）

- **调试已运行的进程：**
    ```sh
    gdbserver <IP>:12345 --attach <PID>
    ```
- **启动并调试新进程：**
    ```sh
    gdbserver <IP>:12345 ./program [args]
    ```

---

## 3. 开发环境（本地/调试端）

### 3.1 启动 GDB 并加载程序

```sh
gdb ./program
```

### 3.2 在 GDB 内部建立远程连接

```gdb
(gdb) target remote <IP>:12345
```

### 3.3 加载 ELF 符号表

```gdb
(gdb) file program
(gdb) add-symbol-file /path/program.debug 0x400000
```

### 3.4 源码路径和文件系统映射

- 查看源文件信息：
    ```gdb
    (gdb) linfo source
    ```
- 映射远程与本地源码路径：
    ```gdb
    (gdb) set substitute-path /home/remote/src /home/local/src
    ```

### 3.5 源码目录管理

- 查看当前目录列表：
    ```gdb
    (gdb) show directories
    ```
- 清空所有已设置的路径：
    ```gdb
    (gdb) directory
    ```
- 替换为全新路径：
    ```gdb
    (gdb) directory /new/path
    ```

---

## 4. SSH 端口转发（隧道加密调试通信）

- 基本端口转发：
    ```sh
    ssh -L 12345:targethost:12345 user@target
    ```
- 指定本地和目标 IP：
    ```sh
    ssh -L <local_ip>:12345:<target_ip>:12345 user@target
    ```
- 后台+无交互运行：
    ```sh
    ssh -fN -L <localip>:12344:<target_ip>:12346 user@target
    ```

### GDB 连接示例

```gdb
(gdb) target remote localhost:12345
```

---

## 5. 网络端口与进程监控

- 查看端口占用：

    ```sh
    lsof -i :12345
    netstat -an | grep 12345
    ```

    - `netstat -an`：显示所有网络连接和监听端口
    - `-a`：显示所有连接和监听端口
    - `-n`：以数字方式显示地址和端口
    - `| grep 12345`：筛选出包含 12345 的行

- 监控 SSH 进程：

    ```sh
    ps -aux | grep -w ssh
    ```

- 关闭指定进程（假设 PID 为 1234）：
    ```sh
    kill -9 1234
    ```

---

### 1. 添加调试符号

- `add-symbol-file`：用于在运行时加载额外的符号文件（常用于动态库或内核模块）。
- `symbol-file`：用于加载可执行文件或符号文件（通常在启动 GDB 时使用）。
- `directory`：**不是添加符号文件**，而是添加源码搜索路径。

---

### 2. 添加源码路径

- `directory` 命令用于**添加/指定源码文件的搜索路径**，让 GDB 能找到源文件进行源码级调试。
- 你可以多次用 `directory` 添加多个路径。

**示例：**

```
directory /path/to/source
```

---

### 3. 其他相关命令

- GDB 没有专门“添加源码文件”的命令，只能通过 `directory` 指定源码所在的目录。
- 源码文件本身不需要“加载”，只要路径正确，GDB 会自动查找和显示。

---

**总结：**

- 添加调试符号用 `add-symbol-file`、`symbol-file`。
- 添加源码路径只能用 `directory`。
- 只要源码路径正确，GDB 会自动显示源码内容。

函数栈

i r rbp #显示寄存器rbp的当前值
P /x $rbp #以指定格式打印寄存器的值 /x十六进制输出
x/1xg $rbp #查看rbp寄存器所指向的内存地址中的内容

push %rbp # rsp-8 #保存上一层函数的基址指针 （%rbp） 到栈中
pop %rbp #从当前rsp指向的线中弹栈到rbp中 # rsp+8

push %rbp #3步，进入新函数常规操作
mov %rsp.%rbp
sub $0x10，%rsp

callq #保存返回地址到栈-> #将返回地址（64位，8字节）压入栈

# rsp = rsp - 8

#跳转到目标函数

leaveq #mov %rbp，%rsp；恢复rsp为rbp的值（即栈顶回到进入函数时的位置）

# pop %rbp；从栈中弹出保存的rbp值，恢复调用者的rbp

retq #从当前rsp指向的栈中弹栈到pc中 # rsp+8

add $0x10，%rsp #leaveq只能恢复函数入口时的栈状态，无法处理调用过程中额外的压栈操作，栈平衡机制

栈帧（StackFrame）的核心概念：在程序运行时，每个函数调用会在栈上创建一个独立的栈帧，用于存储：
1、函数的局部变量
2、返回地址（调用者下一条指令的地址）
3、前一个栈帧的基址（rbp 寄存器的值）
4、超过最大寄存器数量限制的入参等关健信息

endbr64：这是IntelCET（Control-flowEnforcementTechnology）的指令，用于防范控制流劫持攻击（如ROP），仅在启用CET的系统上出现，本质是一个待殊的NOP指令

    				栈

rbp 0x12345678 => 0x11223344

局部变量内存布局：栈上变量的具体地址分配可能依赖于编译器的实现细节、优化策略和栈的当前状态。而不依于它们在源代码中的定义顺序，并非“压栈”和“弹栈”操作。
栈对齐要求（Aignment）：栈指针必须16字节对齐

反汇编-disassemble

这条 GDB 命令和输出的含义如下：

---

### 命令部分

- `x /1xg $rsp`
    - `x`：examine，查看内存内容
    - `/1`：显示 1 个单元
    - `x`：以十六进制格式显示
    - `g`：每个单元为 8 字节（giant word，64 位）
    - `$rsp`：以当前栈顶指针寄存器 rsp 的值为地址

### 输出部分

- `0x7fffffffdea0:`
  要查看的内存地址（即当前 $rsp 的值）

- `0x00007fffffffdf90`
  该地址存储的 8 字节内容（通常是下一个栈帧的 rbp 或返回地址）

---

### 总结

- 你查看了当前栈顶（$rsp）指向的 8 字节内容。
- 地址 `0x7fffffffdea0` 处的值是 `0x00007fffffffdf90`。
- 这通常是保存的上一个 rbp 值或返回地址，具体要结合函数调用现场分析。

如需进一步解释栈帧结构或该值的具体含义，请补充上下文！

这两个数是典型的64位十六进制地址，常见于C/C++程序的指针或内存地址打印。

### 构成分析

- `0x`：表示十六进制数的前缀。
- `00007fffffffdef0`
- `00007fffffffdeb0`

每个数字（0-9，a-f）代表4位二进制，16进制一位=4位二进制，64位地址共16位十六进制数。

### 数值比较

直接比较即可，十六进制从高位到低位依次比较：

- `0x00007fffffffdef0`
- `0x00007fffffffdeb0`

从左往右看，前面都一样，直到最后两位：

- `def0` > `deb0`
  因为 `f` (15) > `b` (11)

所以：

```
0x00007fffffffdef0 > 0x00007fffffffdeb0
```

### 总结

- 两个数都是64位十六进制数，常见于内存地址。
- 比较时从高位到低位逐位比较，前面相同则看后面。
- `0x00007fffffffdef0` 比 `0x00007fffffffdeb0` 大。
- 是的，十六进制的进位规则如下：

- 每一位的取值范围是0-9和a-f（或A-F），共16种。
- 当某一位达到f（即15）再加1时，该位变为0，向左一位进1。
- 进位方向是从右往左。

**举例说明：**

- `...de9` + 1 = `...dea`
- `...def` + 1 = `...df0`（f变0，向左进1）
- `...dff` + 1 = `...e00`（右两位f都变0，左边进1）

**总结：**
十六进制进位和十进制类似，只是逢16进1，且每位用0-9、a-f表示，从右往左进位。

下面是 Ubuntu 上临时修改 ptrace_scope 的最小命令（先查看，临时设为 0，示例保存并恢复原值）。

```bash
# 查看当前值
cat /proc/sys/kernel/yama/ptrace_scope

# 临时设置为 0（立即生效，重启后失效）
sudo sysctl -w kernel.yama.ptrace_scope=0
# 或等价
echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope

# 推荐：保存原值以便稍后恢复
orig=$(cat /proc/sys/kernel/yama/ptrace_scope)
sudo sysctl -w kernel.yama.ptrace_scope=0

# 调试完成后恢复
echo "$orig" | sudo tee /proc/sys/kernel/yama/ptrace_scope
```

注意：将 ptrace_scope 设为 0 会降低安全限制，调试完成后建议恢复原值。

GitHub Copilot

简短回答

- 可以用你给出的 dump_list 在 Unity 的 C 单元测试里输出；Unity 并不禁止在测试中使用 printf，但要注意格式、可读性、与 CI 日志解析的兼容性。下面给出推荐格式、注意项和示例实现。

要点（要注意的事项）

- 输出必须可读且可被脚本 grep：每行最好有固定前缀（如 "dump:"），便于自动定位。
- 不要改变被测数据结构（dump 函数应只读）。
- 对可能为 NULL 的指针作防护检查，避免在 dump 本身崩溃。
- 输出地址使用 %p，整型用 %d 或 %ld（与类型匹配）。
- 在需要及时查看输出时 flush stdout（fflush(stdout)）。
- CI/自动化环境可能会过滤标准输出，若被过滤请改用 Unity 定制输出接口或测试框架的日志接口（但多数情况 printf 足够）。
- 输出不要太大，长链表可限制最大节点数或打印前后若干节点。

推荐的输出字段（每个节点）

- 索引（index）
- 节点地址（%p）
- value（根据类型，%d/%ld/%s）
- next 指针（%p）
- 可选：是否为 head/tail 标记、list->cnt

示例实现（放进测试文件，临时调试用）

````c
```c
// filepath: tests/test_linked_list.c
// ...existing code...
static void dump_list(const LinkedList* list) {
    if (!list) {
        printf("dump: list = NULL\n");
        fflush(stdout);
        return;
    }
    printf("dump: cnt = %d\n", list->cnt);
    const Node* p = list->head;
    int idx = 0;
    /* 为防日志过长，限制输出最多 100 个节点 */
    while (p && idx < 100) {
        printf("dump: idx=%02d addr=%p value=%d next=%p%s\n",
               idx, (void*)p, p->value, (void*)p->next,
               (p == list->head) ? " <-HEAD" : "");
        p = p->next;
        ++idx;
    }
    if (p) printf("dump: ... (more nodes, truncated)\n");
    fflush(stdout);
}
```
````

其他 Unity 相关输出说明（简短）

- Unity 自带断言宏会在失败时打印文件/行/信息；没有统一的“dump helper”，所以自定义 printf 函数是常见做法。
- 如果你需要把输出整合到 Unity 的日志输出机制，可查阅你使用的 Unity 版本中是否暴露了 UnityPrint/UNITY_OUTPUT_CHAR 等接口（不同版本差异较大），但通常直接 printf 足够。

如果需要

- 我可以给出针对你项目中节点类型（例如 value 为 long/char\*）的格式化实现，或把 dump 输出改成机器可解析的 JSON/CSV 格式以便自动断言。

GitHub Copilot

简短概念总结

- dump：普通术语，泛指把程序内部状态（结构体字段、指针、计数器、内存片段等）“打印/导出”出来以便调试。不是单一工具或语言特性，常由用户自己写的辅助函数（如你那个 dump_list）或调试器命令产生。
- throw：C++ 语言的异常语句（throw expr）。它触发语言运行时的异常机制（抛出对象、栈展开/清理、寻找 catch），这一机制由编译器/运行时库实现（不是 GDB 特有）。
- 二者不同类：dump 是主动的状态输出；throw 是程序控制流/错误处理机制。GDB 能拦截 throw 事件并在抛出点停下来，从而让你做 dump 或查看栈/变量。

C++ 异常（底层与 GDB）

- 实现：大多数 Unix x86*64 平台遵循 Itanium C++ ABI。抛出时会调用运行时函数（典型实现名为 **cxa_throw），签名大致为：
  void **cxa_throw(void *thrown*exception, std::type_info \_tinfo, void (\_dest)(void*));
  MSVC 平台用不同的运行时函数（如 \_CxxThrowException）。
- 栈展开/清理：由 libgcc/运行时提供的 unwinder（基于 ELF 中的 DWARF EH 表）完成，调用析构函数并跳转到合适的 catch。
- GDB 如何捕捉：GDB 可以在异常抛出/被捕获时停下来（命令 catch throw / catch catch）。实现上 GDB 要么在运行时异常函数（如 \_\_cxa_throw）上设置断点，要么通过符号表/ABI 知道何处发生异常事件从而设置断点。
- 常用 GDB 命令：

    ```

    ```

```bash
# 在 C++ 抛出处停止（如果 GDB 支持）
(gdb) catch throw

# 或直接在运行时抛出函数上断点（通用方法）
(gdb) break __cxa_throw
(gdb) run

# 运行时停止后查看异常对象和调用栈
(gdb) bt
(gdb) info locals
(gdb) print *(std::type_info *)$arg2   # 仅示例，平台寄存器/ABI 约定不同
```

````

C 语言的“类似”机制
- C 没有语言级异常和 throw。可用于“异常风格”处理的手段有：
  - 返回错误码（最常见）。
  - setjmp/longjmp：非本地跳转，绕过栈展开（不会自动调用析构/清理）。
  - signals（SIGSEGV、SIGABRT 等）：运行时或库函数可用 raise/abort 触发，GDB 可用 catch signal 或 handle 命令拦截。
  - 主动在关键错误点调用 abort/exit，自行打印 dump。
- GDB 捕获 C 的方式通常是：catch signal SIGSEGV、break abort、break raise、或在你关心的函数名上设置断点。
  ```
```bash
(gdb) catch signal SIGSEGV
(gdb) break abort
(gdb) run
# 停下后查看：
(gdb) bt
(gdb) info registers
(gdb) x/32bx $rsp    # 查看栈内存
```
````

dump 与 GDB 的关系（如何协作）

- dump（自定义打印）通常在程序运行的任意点显式调用，用于输出易读的状态（结构体成员、索引、地址）。
- 在 GDB 中你可以：
    - 在某断点处手动使用 print/ptype/x 命令查看内存/变量。
    - 使用 catch throw 等断点在异常发生处停住，然后用 print/Backtrace/dump helper 打印状态。
    - 把 dump 函数写到程序里（像你的 dump_list），在需要时调用，或在 GDB 中用 call dump_list(list) 直接触发。
- GDB 也支持更高级的“pretty-printers”（Python 编写），用于格式化复杂对象（例如 C++ STL 容器）。这比简单 printf 更强大但要写 Python 插件。

实用建议（针对你当前工作流）

- 如果你想在 C++ 异常抛出时自动查看链表/状态：
    1. 在 gdb 中启用抛出断点： (gdb) catch throw 或 break \_\_cxa_throw
    2. 运行程序，抛出时 GDB 停下，执行 call dump_list(list) 或用 print/ptype 检查变量。
- 对 C 程序：把关键点（出错/删除/分配）前后加 dump 函数调用；用 GDB 的 signal/函数断点拦截异常情形。
- 若需自动化日志便于 CI，设计 dump 输出行前缀（如 "DUMP:"）或输出 JSON/CSV，便于脚本解析断言。

示例：在 GDB 中调用你已有的 dump_list（无需改变代码）

````gdb
```bash
# 在 gdb 已停止于感兴趣的断点后：
(gdb) call dump_list(list)
# 或把输出与格式化打印混用：
(gdb) print list->cnt
(gdb) x/5gx list->head   # 按机器字打印指针链等
```
````

总结

- dump = 自定义/调试用的状态打印，语言无关；throw = C++ 的语言/运行时异常机制，两者性质不同。GDB 提供对 throw 的捕获机制，也能作为触发点去调用 dump/查看状态。C 没有 throw，但可以用 signals、长跳或断点在关键函数处结合 dump 做类似的调试流程。

需要我给出一组针对你当前可执行文件的具体 gdb 命令（例如如何在抛出处停下并自动调用 dump_list）吗？

GitHub Copilot

下面给出通过 DIC 观测到的“断裂过程中缺口顶端水平应变 ε_x（或 ε_xx）随时间/加载的典型变化规律与要点”，简明、可操作，便于后续数据提取与判读。

主要变化阶段（定性描述）

- 弹性阶段（初始线性增长）
    - 随着外加载荷或位移线性增加，缺口顶端及周围的水平应变逐渐、均匀上升，场分布平滑。
- 起裂前的应变集中期（非线性加速）
    - 在接近起裂时，顶端局部应变出现明显加速增长，集中带宽减小，应变梯度增大。
    - ε_x_max（缺口顶端的最大水平应变）从线性趋势偏离，呈超线性上升。
- 裂缝起始瞬间（峰值或突变）
    - 起裂瞬间 ε_x_max 达到峰值或出现突跃；与载荷—位移曲线上的起裂载荷/位移同步或略先。
- 裂缝扩展期（顶端应变迁移与局部降低）
    - 裂缝向前扩展时，原缺口顶端处 ε_x 降低（因局部释放），而新的裂尖前方出现应变集中，ε_x_max 位置随裂缝前移。
    - 峰值可能出现多次脉动，取决于扩展的稳定/不稳定性（逐步扩展：波动；不稳定贯通：单次大峰并迅速下降）。
- 断后残余期（残余应变场）
    - 破坏后残余水平应变场较原始高，裂缝两侧出现塑性/摩擦变形带，ε_x 在裂缝附近保持正的残余值。

空间分布规律（关于距离 r 的变化）

- 起裂前近场呈高梯度分布，远场渐近平滑；在弹性断裂力学近似下，裂尖应变场具有近似 r^(-1/2) 的强度增长趋势（实际土/黄土等非线性材料会偏离该理论）。
- 应变局部化带宽与材料内在尺度（颗粒/孔隙）和 DIC 空间分辨率相关，湿度、密实度会影响带宽与峰值高度。

与加载/时间的定量关系（提取与分析建议）

- 常用曲线：ε_x_max(t)、ε_x_max vs 载荷、ε_x(x)（沿裂缝轴线）在若干时刻的剖面图。
- 起裂判别：选用 ε_x_max 的二阶导数或增长率阈值（例如短时斜率显著增加）可作为起裂前兆。
- 裂缝速度：通过连续帧中 ε_x_max 位置的前移速率估算裂尖扩展速度。
- 稳定性分析：观察 ε_x_max 在起裂前后是否平滑过渡（稳定扩展）或突降（不稳定断裂）。

数据质量与限制（必读）

- DIC 只能提供可视表面场；内部场需结合断面或 CT 验证。
- 空间/时间分辨率、子集大小、滤波与噪声会影响 ε_x 的绝对值与峰值高度；应报告相关系数/残差并进行不确定度估计。
- 对软土/黄土类样本，材料非线性、塑性流动与颗粒破碎会导致偏离线性弹性断裂力学的表现，应以经验/统计结果为主，结合微观分析解释机理。

可直接提取的诊断量（建议监测字段）

- ε_x_max(t)、ε_x_max 对应的载荷/位移、ε_x(x) 在一系列时刻的剖面、应变集中带宽、裂尖位置随时间的曲线、相关系数/噪声指标、裂缝速度估计。

如需，我可给出针对三点弯曲实验的 DIC 后处理步骤（如何从图像序列自动提取 ε_x_max(t) 与裂尖位置）、推荐子集/步长参数或示例脚本。
