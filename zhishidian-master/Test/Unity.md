# Unity 与 CMock 单元测试框架核心函数与用法笔记

---

## 一、Unity 单元测试框架

### 1.1 框架简介

Unity 是 C 语言中最流行的轻量级单元测试框架之一，适合嵌入式和通用 C 项目。

---

### 1.2 测试生命周期相关函数

- **`UNITY_BEGIN()`**
    - 初始化测试框架，必须在 `main()` 中最先调用。
    - 返回值通常用于 `main()` 的返回。

- **`UNITY_END()`**
    - 结束测试，输出测试总结。
    - 返回测试失败的数量。

- **`RUN_TEST(func)`**
    - 运行一个测试用例（即一个测试函数）。
    - 例：`RUN_TEST(test_add_contact);`

- **`setUp(void)`**
    - 测试夹具，每个测试用例运行前自动调用一次（可选实现）。
    - 用于初始化测试环境。

- **`tearDown(void)`**
    - 测试夹具，每个测试用例运行后自动调用一次（可选实现）。
    - 用于清理测试环境。

---

### 1.3 断言宏（Assertions）

Unity 提供了丰富的断言宏，用于判断测试结果是否符合预期。

#### 1.3.1 基本类型断言

- `TEST_ASSERT(condition)`  
  条件为真则通过(`condition>0`)，否则失败。
- `TEST_ASSERT_TRUE(condition)`  
  条件为真(`condition==1`)则通过。
- `TEST_ASSERT_FALSE(condition)`  
  条件为假则通过。
- `TEST_ASSERT_EQUAL_INT(expected, actual)`  
  比较两个整数是否相等。
- `TEST_ASSERT_EQUAL_UINT(expected, actual)`  
  比较两个无符号整数是否相等。
- `TEST_ASSERT_EQUAL_HEX8(expected, actual)`  
  比较两个8位十六进制数是否相等。
- `TEST_ASSERT_EQUAL_HEX16(expected, actual)`  
  比较两个16位十六进制数是否相等。
- `TEST_ASSERT_EQUAL_HEX32(expected, actual)`  
  比较两个32位十六进制数是否相等。

#### 1.3.2 字符串断言

- `TEST_ASSERT_EQUAL_STRING(expected, actual)`  
  比较两个字符串内容是否相等。
- `TEST_ASSERT_EQUAL_STRING_LEN(expected, actual, len)`  
  比较前 `len` 个字符是否相等。

#### 1.3.3 浮点数断言

- `TEST_ASSERT_FLOAT_WITHIN(delta, expected, actual)`  
  判断浮点数是否在误差范围内。
- `TEST_ASSERT_DOUBLE_WITHIN(delta, expected, actual)`  
  判断双精度浮点数是否在误差范围内。

#### 1.3.4 指针断言

- `TEST_ASSERT_NULL(pointer)`  
  判断指针是否为 NULL。
- `TEST_ASSERT_NOT_NULL(pointer)`  
  判断指针是否不为 NULL。

#### 1.3.5 数组断言

- `TEST_ASSERT_EQUAL_INT_ARRAY(expected, actual, num_elements)`  
  比较整数数组是否相等。
- `TEST_ASSERT_EQUAL_MEMORY(expected, actual, len)`  
  比较内存块内容是否相等。

---

### 1.4 其他常用宏

- `TEST_IGNORE()`  
  忽略当前测试用例。
- `TEST_FAIL()`  
  立即使当前测试失败。
- `TEST_MESSAGE("msg")`  
  输出一条消息到测试报告。
- `TEST_ASSERT_BITS(mask, expected, actual)`  
  按位比较。

---

### 1.5 典型测试用例结构

```c
#include "unity.h"

void setUp(void) {
    // 每个测试前运行
}

void tearDown(void) {
    // 每个测试后运行
}

void test_example(void) {
    TEST_ASSERT_EQUAL_INT(1, 1);
}

int main(void) {
    UNITY_BEGIN();
    RUN_TEST(test_example);
    return UNITY_END();
}
```

---

### 1.6 进阶用法

- **分组测试**：可以通过不同的测试文件组织不同模块的测试。
- **自定义断言**：可以自己实现断言宏，增强可读性。
- **Mock 支持**：Unity 可与 CMock 配合进行接口模拟。

## 二、CMock 框架

### 2.1 CMock 简介

CMock 是 ThrowTheSwitch 团队为 C 语言开发的自动化 Mock 框架，常与 Unity 单元测试框架配合使用。它可以自动为你的接口生成“假实现”（mock），用于隔离被测模块，验证接口调用次数、参数和返回值等。

---

### 2.2 CMock 的基本使用流程

#### 2.2.1 安装 CMock

```sh
gem install cmock
```

#### 2.2.2 编写接口头文件

假设你有如下接口需要 mock：

```c
// foo.h
#ifndef FOO_H
#define FOO_H

int foo_add(int a, int b);
void foo_notify(const char* msg);

#endif
```

#### 2.2.3 生成 Mock 文件

在命令行运行：

```sh
cmock foo.h
```

会生成 `mock_foo.h` 和 `mock_foo.c`。

#### 2.2.4 在测试代码中包含 Mock

```c
#include "unity.h"
#include "mock_foo.h" // 由 CMock 生成

void setUp(void) {
    mock_foo_Init();
}
void tearDown(void) {
    mock_foo_Verify();
    mock_foo_Destroy();
}

void test_should_call_foo_add(void) {
    foo_add_ExpectAndReturn(1, 2, 3); // 期望参数1,2，返回3
    int result = foo_add(1, 2);       // 实际调用
    TEST_ASSERT_EQUAL_INT(3, result); // 断言返回值
}

void test_should_notify(void) {
    foo_notify_Expect("hello"); // 期望参数"hello"
    foo_notify("hello");
}

int main(void) {
    UNITY_BEGIN();
    RUN_TEST(test_should_call_foo_add);
    RUN_TEST(test_should_notify);
    return UNITY_END();
}
```

#### 2.2.5 编译并运行

```sh
gcc test_foo.c mock_foo.c unity.c -I. -o test.out
./test.out
```

---

### 2.3 CMock 生成的常用函数/宏

假设你 mock 的函数为 `int foo_add(int a, int b);`，CMock 会自动生成如下 mock 函数和宏：

#### 2.3.1 初始化与销毁

- `mock_foo_Init();`  
  初始化 mock 状态（通常在 `setUp()` 里调用）

- `mock_foo_Verify();`  
  检查所有期望是否都被满足（通常在 `tearDown()` 里调用）

- `mock_foo_Destroy();`  
  清理 mock 状态（通常在 `tearDown()` 里调用）

#### 2.3.2 期望设置与断言

- `foo_add_ExpectAndReturn(a, b, ret);`  
  期望 `foo_add` 被调用一次，参数为 `a`、`b`，返回值为 `ret`

- `foo_add_ExpectAnyArgsAndReturn(ret);`  
  期望 `foo_add` 被调用一次，参数任意，返回值为 `ret`

- `foo_add_IgnoreAndReturn(ret);`  
  忽略所有参数，任何调用都返回 `ret`

- `foo_add_StubWithCallback(callback_func);`  
  用自定义回调函数替换 mock 行为

- `foo_add_Expect(a, b);`  
  期望被调用一次，参数为 `a`、`b`，无返回值（适用于 void 函数）

- `foo_add_ExpectAnyArgs();`  
  期望被调用一次，参数任意，无返回值

---

### 2.4 CMock 的典型用法场景

- **接口隔离**：测试某个模块时，mock 掉它依赖的外部接口。
- **参数验证**：验证被测代码是否以正确参数调用了接口。
- **调用次数验证**：验证接口被调用的次数。
- **返回值控制**：模拟接口的各种返回值，测试被测代码的不同分支。

---

### 2.5 CMock 进阶用法

- **回调函数**：可以用 `StubWithCallback` 实现更复杂的 mock 行为。
- **多次调用**：可以多次设置 `ExpectAndReturn`，模拟多次调用的不同返回。
- **结构体参数**：CMock 支持结构体参数的比较和断言。

---

（内容已合并、检查、调整，结构清晰，层次分明，未删除或省略原有内容）
