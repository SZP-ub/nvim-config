## 一、为什么要封装？

C 语言不是面向对象语言，但我们可以用结构体+函数指针的方式，**模拟面向对象的“类”**。这样做的好处是：

- 让数据和操作方法绑定在一起，代码更清晰。
- 方便管理和扩展，减少全局变量和重复代码。

---

## 二、封装的内容

一般包括三部分：

1. **数据结构**  
   用结构体保存数据，比如数组、长度等。

2. **操作函数**  
   用函数实现对数据的各种操作，比如创建、添加、删除、查找等。

3. **管理结构体（类似“类”）**  
   用结构体把数据指针和操作函数指针封装在一起。

---

## 三、示例：封装一个“学生列表”

### 1. 数据结构

```c
#define MAX_STUDENTS 100

typedef struct {
    int id;
    char name[32];
    int score;
} Student;

typedef struct {
    Student students[MAX_STUDENTS];
    int count;
} StudentList;
```

### 2. 操作函数

```c
StudentList* create_student_list();
int add_student(StudentList* list, int id, const char* name, int score);
int remove_student(StudentList* list, int id);
Student* find_student(StudentList* list, int id);
void print_students(StudentList* list);
```

### 3. 管理结构体（“类”）

```c
typedef struct {
    StudentList* list;
    StudentList* (*create)();
    int (*add)(StudentList*, int, const char*, int);
    int (*remove)(StudentList*, int);
    Student* (*find)(StudentList*, int);
    void (*print)(StudentList*);
} StudentManager;
```

### 4. 操作函数实现（部分）

```c
StudentList* create_student_list() {
    StudentList* list = (StudentList*)malloc(sizeof(StudentList));
    if (list) list->count = 0;
    return list;
}

int add_student(StudentList* list, int id, const char* name, int score) {
    if (list->count >= MAX_STUDENTS) return 0;
    list->students[list->count].id = id;
    strncpy(list->students[list->count].name, name, 31);
    list->students[list->count].score = score;
    list->count++;
    return 1;
}

Student* find_student(StudentList* list, int id) {
    for (int i = 0; i < list->count; ++i) {
        if (list->students[i].id == id) return &list->students[i];
    }
    return NULL;
}

void print_students(StudentList* list) {
    for (int i = 0; i < list->count; ++i) {
        printf("ID:%d Name:%s Score:%d\n", list->students[i].id, list->students[i].name, list->students[i].score);
    }
}
```

### 5. 初始化管理结构体

```c
void init_student_manager(StudentManager* manager) {
    manager->list = NULL;
    manager->create = create_student_list;
    manager->add = add_student;
    manager->remove = remove_student;
    manager->find = find_student;
    manager->print = print_students;
}
```

### 6. 使用示例

```c
int main() {
    StudentManager manager;
    init_student_manager(&manager);

    manager.list = manager.create();
    manager.add(manager.list, 1, "Alice", 90);
    manager.add(manager.list, 2, "Bob", 85);

    manager.print(manager.list);

    Student* stu = manager.find(manager.list, 1);
    if (stu) printf("Found: %s\n", stu->name);

    free(manager.list);
    return 0;
}
```

---

## 四、总结与建议

- **数据结构**只负责存储数据。
- **操作函数**只负责操作数据结构，不要用全局变量。
- **管理结构体**把数据和操作函数指针封装在一起，方便统一管理和调用。
- 初始化时，把函数指针和数据指针都设置好。
- 使用时，优先通过管理结构体调用操作函数。

---

## 五、你需要注意的点

- 指针初始化要小心，避免野指针和内存泄漏。
- 函数指针类型要和实现一致。
- 操作函数参数建议都传数据结构指针，方便复用。
- 封装结构体不直接操作数据，只做“管理者”。

---

这样你就可以用 C 模拟面向对象的风格，代码更清晰、易维护！如果还有疑问，欢迎继续提问！
