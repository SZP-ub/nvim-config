1. ```makefile
   .DEFAULT_GOAL = target_name 链接更改目标
   ```

2. ```makefile
   .PHONY: clean #伪目标，每次make时都会更新
   ```

3. ```makefile
   | 依赖 ＃不会自动更新目标文件
   ```

4. ```makefile
   .ONESHELL: #在同一个shell中执行命令
   ```

5. ```makefile
   @ 命令 ＃不会打印这条命令本身但是会执行这条命令。
   ```

6. ```makefile
   .SILENT:对象  ＃不打印命令本身
   ```

7. 错误处理
   `-` #忽略错误继续执行剩余命令

8. ```makefile
   变量定义方式：
   #<变量名> = <变量值> <变量名> := <变量值> <变量名> ::= <变量值>
   使用方式：
   # $(<变量名>) 或者 ${<变量名>}
   ```

9. ```makefile

    #多行变量定义

    define <value_name> =

    endef
   ```

10. ```makefile
    #变量替换引用
    语法：
    $(var: a=b) #将变量var的值当中的每一项结尾a替换为b
    ```

11. ```makefile
    #指定值不会覆盖默认值
    override <value_name>
    ```

12. ```makefile
    #自动变量
    $@：① 本条规则的目标名；② 如果目标是归档文件的成员，则为归档文件名；③ 在多目标的模式规则中，为导致本条规则方法执行的那个目标名；
    $<：本条规则的第一个依赖名称
    $?：依赖中修改时间晚于目标文件修改时间的所有文件名，以空格隔开
    $^：所有依赖文件名，文件名不会重复，不包含order-only依赖
    $+：类似上一个，表示所有依赖文件名，包括重复的文件名
    $|：所有order-only依赖文件名
    $*：（简单理解）目标文件名的主干部分（即不包括后缀名）
    $%：如果目标不是归档文件，则为空；如果目标是归档文件成员，则为对应的成员文件名

    #以下变量对应上述变量，D为对应变量所在的目录，结尾不带/，F为对应变量除去目录部分的文件名
    $（@D）
    $（@F）
    $（*D）
    $（*F）
    $（%D）
    $（%F）
    $（<D）
    $（<F）
    $（^D）
    $（^F）
    $（+D）
    $（+F）
    $（?D）
    $（?F）
    ```

13. ```makefile
    #二次展开
    VAR1 = main.cpp
    .SECONDEXPANSION:
    all: $$(VAR1)
        @echo $^
    VAR1 = hello.cpp
    ```

14. ```makefile
    #wildcard
    作用：用于获取匹配某个模式的所有文件名（字符串列表）。
    $(wildcard *.cpp)
    表示当前目录下所有 .cpp 文件的列表
    ```

15. ```makefile
    #patsubst
    作用：模式替换函数。可以把一组字符串中的某个模式批量替换成另一个模式。
    $(patsubst %.cpp, %.o, $(wildcard *.cpp))
        第一个参数：要被替换掉的模式（如 %.cpp）
        第二个参数：要替换成的模式（如 %.o）
        第三个参数：输入的字符串列表
        例子：
        假如 $(wildcard *.cpp) 展开为 main.cpp sudoku.cpp,
        那么结果就是 main.o sudoku.o。
    ```
