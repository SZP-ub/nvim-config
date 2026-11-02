gcc 编译生成可执行程序通常分为四个阶段，每个阶段的生成物标志如下：

---

### 1. 预处理（Preprocessing）

- **命令**：`gcc -E main.c -o main.i`
- **生成物标志**：`.i` 文件（预处理后的源代码，包含所有头文件和宏展开）

---

### 2. 编译（Compilation）

- **命令**：`gcc -S main.i -o main.s`
- **生成物标志**：`.s` 文件（检查语法，汇编代码）

---

### 3. 汇编（Assembly）

- **命令**：`gcc -c main.s -o main.o`
- **生成物标志**：`.o` 文件（目标文件，机器码，但还不能直接运行）

---

### 4. 链接（Linking）

- **命令**：`gcc main.o -o main`
- **生成物标志**：可执行文件（如 `main` 或 `main.exe`）

---

**总结表：**

| 阶段   | 命令示例                | 生成物标志 |
| ------ | ----------------------- | ---------- |
| 预处理 | gcc -E main.c -o main.i | .i         |
| 编译   | gcc -S main.i -o main.s | .s         |
| 汇编   | gcc -c main.s -o main.o | .o         |
| 链接   | gcc main.o -o main      | 可执行文件 |

这些中间文件（`.i`、`.s`、`.o`）可以通过 gcc 的不同参数手动生成，通常只保留 `.o` 和最终的可执行文件。

# GDB 调试命令大全

以下是完整的 GDB 调试命令列表，包含**全称**、**缩写**及其**功能说明**，按调试流程分类整理：

## **使用提示：**

- 按 Tab 键自动补全命令

- 按 Enter 键重复执行上一条命令

- 使用 gdb -tui 启动文本界面模式

- 使用 layout src 在 GDB 内打开源码窗口

## 1. 启动与退出

| 命令                           | 缩写                         | 说明                           |
| ------------------------------ | ---------------------------- | ------------------------------ |
| `gdb [executable]`             | -                            | 启动 GDB 并加载可执行文件      |
| `quit`                         | `q`                          | 退出 GDB                       |
| `run [args/"args with space"]` | `r [args/"args with space"]` | 运行程序（可带命令行参数）     |
| `start`                        | -                            | 开始执行，停在 `main` 函数入口 |

## 2. 断点管理

| 命令                          | 缩写       | 说明                               |
| ----------------------------- | ---------- | ---------------------------------- |
| `break [file:]line/func`      | `b`        | 在行号/函数处设置断点              |
| `rbreak line/func`            | `rb`       | 模糊名函数处设置断点               |
| `break ... if [condition]`    | `b ... if` | 条件断点                           |
| `tbreak [location]`           | `tb`       | 设置临时断点（触发一次后自动删除） |
| `info breakpoints`            | `i b`      | 列出所有断点                       |
| `delete [breakpoint-id]`      | `d`        | 删除断点（不带参数则删除所有）     |
| `disable [breakpoint-id]`     | `dis`      | 禁用断点                           |
| `enable [breakpoint-id]`      | `en`       | 启用断点                           |
| `enable once [breakpoint-id]` | `en once`  | 启用断点一次，之后断电状态变成dis  |
| `clear [location]`            | -          | 删除某处的断点                     |

## 3. 执行控制

| 命令             | 缩写  | 说明                                 |
| ---------------- | ----- | ------------------------------------ |
| `continue`       | `c`   | 继续运行直到下一个断点/结束          |
| `next`           | `n`   | 单步执行（**跳过**函数调用）         |
| `step`           | `s`   | 单步执行（**进入**函数调用）         |
| `nexti`          | `ni`  | 单步执行一条**机器指令**（跳过函数） |
| `stepi`          | `si`  | 单步执行一条**机器指令**（进入函数） |
| `finish`         | `fin` | 执行完当前函数并暂停                 |
| `until [line]`   | `u`   | 执行到指定行（常用于跳出循环）       |
| `return [value]` | -     | 强制从当前函数返回（可指定返回值）   |

## 4. 查看数据

| 命令                        | 缩写               | 说明                                     |
| --------------------------- | ------------------ | ---------------------------------------- |
| `print [expression]`        | `p`                | 打印表达式值                             |
| `print /[fmt] [expr]`       | `p/x`, `p/d`       | 按格式打印（`x`:十六进制, `d`:十进制等） |
| `print namespace::var`      | `p namespace::var` | 打印命名空间里面的变量                   |
| `display [expression]`      | `disp`             | 每次暂停时自动打印表达式的值             |
| `info display`              | `i disp`           | 列出所有自动打印项                       |
| `undisplay [id]`            | -                  | 取消自动打印                             |
| `x/[num][fmt][size] [addr]` | -                  | 检查内存（例: `x/4xw 0x4000`）           |
| `info registers`            | `i r`              | 查看寄存器值                             |
| `info args`                 | `i a`              | 查看函数参数                             |
| `info locals`               | `i lo`             | 查看局部变量                             |

## 5. 堆栈与帧

| 命令          | 缩写  | 说明                   |
| ------------- | ----- | ---------------------- |
| `backtrace`   | `bt`  | 显示调用栈（堆栈回溯） |
| `frame [num]` | `f`   | 切换到指定堆栈帧       |
| `info frame`  | `i f` | 查看当前帧详细信息     |
| `up`          | -     | 切换到外层调用帧       |
| `down`        | -     | 切换到内层调用帧       |

## 6. 源码查看

| 命令                 | 缩写     | 说明                   |
| -------------------- | -------- | ---------------------- |
| `list`               | `l`      | 显示当前行附近的源码   |
| `list [line]`        | `l 20`   | 显示第 20 行附近的源码 |
| `list [function]`    | `l main` | 显示 `main` 函数源码   |
| `set listsize [num]` | -        | 设置每次显示的源码行数 |
| `show listsize`      | -        | 查看当前源码显示行数   |

## 7. 观察点（监控变量）

| 命令                  | 缩写   | 说明                     |
| --------------------- | ------ | ------------------------ |
| `watch [expression]`  | `wa`   | 当表达式**被写入**时暂停 |
| `rwatch [expression]` | `rw`   | 当表达式**被读取**时暂停 |
| `awatch [expression]` | `aw`   | 当表达式**被读写**时暂停 |
| `info watchpoints`    | `i wa` | 列出所有观察点           |

## 8. 线程调试

| 命令                       | 缩写   | 说明                           |
| -------------------------- | ------ | ------------------------------ |
| `info threads`             | `i th` | 列出所有线程                   |
| `thread [id]`              | `t`    | 切换到指定线程                 |
| `break ... thread [id]`    | -      | 在特定线程设置断点             |
| `set scheduler-locking on` | -      | 锁定其他线程（仅当前线程运行） |

## 9. 其他关键命令

| 命令                     | 缩写       | 说明                 |
| ------------------------ | ---------- | -------------------- |
| `help [command]`         | `h`        | 查看命令帮助文档     |
| `shell [cmd]`            | `!`        | 执行 Shell 命令      |
| `set var [name]=[value]` | -          | 修改变量值           |
| `disassemble [function]` | `disas`    | 反汇编函数或内存区域 |
| `break * [内存地址]`     | `b * []`   | 在地址处添加断点     |
| `show version`           | -          | 显示 GDB 版本信息    |
| `show args`              | -          | 显示调试程序的参数   |
| `info proc mappings`     | `i proc m` | 显示进程内存映射     |

## 常用调试场景示例

```gdb
# 1. 启动调试
gdb ./myapp
(gdb) run arg1 arg2

# 2. 条件断点
(gdb) b 45 if count > 100

# 3. 检查内存泄漏
(gdb) watch *0x7fffffffde30  # 监控地址写入

# 4. 多线程调试
(gdb) info threads
(gdb) thread 2   # 切换到线程2

# 5. 查看崩溃位置
(gdb) bt        # 崩溃后查看调用栈
(gdb) f 1       # 切换到上层帧
(gdb) p *ptr    # 检查空指针


```

在 GCC 编译时，`-lxxx` 用于链接名为 `libxxx.so` 或 `libxxx.a` 的库。  
`-lm` 就是链接 `libm.so`（数学库）。

常见库的链接参数如下：

| 库名称         | 链接参数    | 实际库文件名  | 说明         |
| -------------- | ----------- | ------------- | ------------ |
| 数学库         | `-lm`       | libm.so       | 数学函数     |
| pthread 线程库 | `-lpthread` | libpthread.so | POSIX 线程   |
| 动态链接库     | `-ldl`      | libdl.so      | 动态加载     |
| 标准C库        | `-lc`       | libc.so       | 默认自动链接 |
| 压缩库         | `-lz`       | libz.so       | zlib 压缩    |
| 网络库         | `-lnsl`     | libnsl.so     | 网络服务库   |
| m 库           | `-lm`       | libm.so       | 数学库       |
| X11 图形库     | `-lX11`     | libX11.so     | X Window系统 |
| SSL 库         | `-lssl`     | libssl.so     | OpenSSL      |
| 加密库         | `-lcrypto`  | libcrypto.so  | OpenSSL加密  |

**用法示例：**

```bash
gcc main.c -o main.out -lm -lpthread -ldl
```

**说明：**

- `-lxxx` 只需写 `xxx`，不用写 `lib` 前缀和 `.so` 后缀。
- 链接顺序有时很重要，建议把依赖库放在最后。

如需查询系统有哪些库，可以在 lib、lib 下查找 `libxxx.so` 文件。
