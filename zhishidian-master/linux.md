# Ubuntu 软件管理与常用命令笔记整理

---

## 一、软件包管理（apt）

Linux apt 命令
apt（Advanced Packaging Tool）是一个在 Debian 和 Ubuntu 中的 Shell 前端软件包管理器。

apt 命令提供了查找、安装、升级、删除某一个、一组甚至全部软件包的命令，而且命令简洁而又好记。

apt 命令执行需要超级管理员权限(root)。

apt 语法
apt \[options\] \[command\] \[package ...\]
options：可选，选项包括 -h（帮助），-y（当安装过程提示选择全部为"yes"），-q（不显示安装的过程）等等。
command：要进行的操作。
package：安装的包名。
apt 常用命令
列出所有可更新的软件清单命令：sudo apt update

升级软件包：sudo apt upgrade

列出可更新的软件包及版本信息：apt list --upgradable

升级软件包，升级前先删除需要更新软件包：sudo apt full-upgrade

安装指定的软件命令：sudo apt install <package_name>

安装多个软件包：sudo apt install <package_1> <package_2> <package_3>

更新指定的软件命令：sudo apt update <package_name>

显示软件包具体信息,例如：版本号，安装大小，依赖关系等等：sudo apt show <package_name>

删除软件包命令：sudo apt remove <package_name>

清理不再使用的依赖和库文件: sudo apt autoremove

移除软件包及配置文件: sudo apt purge <package_name>

查找软件包命令： sudo apt search <keyword>

列出所有已安装的包：apt list --installed

列出所有已安装的包的版本信息：apt list --all-versions

## 二、进程管理（ps）

### 2.1 ps 命令简介

`ps`（process status）用于查看当前系统进程状态，显示进程ID、所属用户、资源占用、启动时间、命令行等信息。

---

### 2.2 常用格式

```sh
ps [选项]
```

---

### 2.3 常用选项说明

| 选项      | 作用说明                                  |
| --------- | ----------------------------------------- |
| -e 或 -A  | 显示所有进程                              |
| -f        | 全格式显示（显示更多详细信息）            |
| -u 用户名 | 显示指定用户的进程                        |
| -x        | 显示没有控制终端的进程                    |
| -o        | 自定义显示输出的列                        |
| -l        | 显示更详细的进程信息                      |
| -p PID    | 显示指定 PID 的进程信息                   |
| -C 名称   | 按命令名称查找进程                        |
| aux       | BSD 风格，显示所有进程及详细信息（常用）  |
| -ef       | SysV 风格，显示所有进程及详细信息（常用） |

---

### 2.4 常用命令举例

1. **显示当前终端下的所有进程**

    ```sh
    ps
    ```

2. **显示所有进程（常用）**

    ```sh
    ps -ef
    # 或
    ps aux
    ```

3. **显示指定用户的进程**

    ```sh
    ps -u 用户名
    ```

4. **显示指定进程号的进程**

    ```sh
    ps -p 1234
    ```

5. **显示进程树结构**

    ```sh
    ps -ejH
    # 或
    ps axjf
    ```

6. **自定义显示内容**

    ```sh
    ps -eo pid,ppid,user,cmd,%mem,%cpu
    ```

7. **结合 grep 查找进程**
    ```sh
    ps -ef | grep nginx
    ```

---

### 2.5 输出字段常见含义

- **PID**：进程ID
- **PPID**：父进程ID
- **USER/UID**：进程所属用户
- **%CPU**：CPU 占用率
- **%MEM**：内存占用率
- **VSZ**：虚拟内存大小（KB）
- **RSS**：实际占用物理内存（KB）
- **TTY**：终端类型
- **STAT**：进程状态（S=sleep，R=running，Z=zombie）
- **START**：进程启动时间
- **TIME**：进程占用CPU时间
- **COMMAND/CMD**：启动进程的命令

---

### 2.6 进阶说明

- `ps` 只显示命令执行时的快照，不会实时刷新
- 实时监控进程请用 `top` 或 `htop`
- 可结合 `awk`、`grep` 等命令进行复杂筛选
- 查看手册：`man ps`

---

## 三、输出命令（echo）

### 3.1 基本语法

```sh
echo [选项] [字符串]
```

---

### 3.2 常见用法

#### 3.2.1 输出普通文本

```sh
echo Hello, world!
```

#### 3.2.2 输出变量内容

```sh
name="Alice"
echo $name
```

#### 3.2.3 输出多行文本和转义字符

- 默认不解析转义字符，需加 `-e` 选项

```sh
echo -e "第一行\n第二行\t缩进"
```

常用转义字符：

- `\n`：换行
- `\t`：制表符（Tab）
- `\\`：反斜杠
- `\"`：双引号

#### 3.2.4 不换行输出

```sh
echo -n "请输入内容："
```

#### 3.2.5 输出带特殊字符的内容

```sh
echo "路径：/usr/local/bin"
echo '$HOME'   # 输出 $HOME 字符串本身
```

---

### 3.3 常用选项

| 选项 | 作用说明                     |
| ---- | ---------------------------- |
| -e   | 启用转义字符（如 \n、\t 等） |
| -n   | 输出后不换行                 |
| -E   | 禁用转义字符（默认行为）     |

---

### 3.4 示例

```sh
# 输出当前用户和主目录
echo -e "用户:\t$USER\n主目录:\t$HOME"

# 输出带引号的字符串
echo "\"Hello, world!\""

# 输出环境变量 PATH
echo $PATH

# 输出多行内容到文件
echo -e "line1\nline2" > file.txt
```

---

### 3.5 注意事项

- `echo` 在不同 shell（如 bash、zsh）下行为可能略有差异
- 复杂格式化输出建议用 `printf`
- 查看帮助：
    ```sh
    man echo
    help echo
    ```

---

## 四、补充说明

- `ps` 只显示快照，实时监控用 `top` 或 `htop`
- `echo` 适合简单输出，复杂格式建议用 `printf`
- 所有命令均可通过 `man 命令名` 查看详细帮助

你可以按照以下步骤将虚拟机共享文件夹中的字体安装到 Ubuntu 系统中：

### 1. 找到共享文件夹中的字体文件

假设你的字体文件（如 `.ttf` 或 `.otf`）在 `/mnt/hgfs/share/fonts`（具体路径根据你的虚拟机和共享设置而定）。

### 2. 复制字体到本地字体目录

#### 安装到当前用户（推荐）

```bash
mkdir -p ~/.local/share/fonts
cp /mnt/hgfs/share/fonts/*.ttf ~/.local/share/fonts/
```

#### 安装到系统所有用户

```bash
sudo mkdir -p /usr/local/share/fonts
sudo cp /mnt/hgfs/share/fonts/*.ttf /usr/local/share/fonts/
```

### 3. 刷新字体缓存

```bash
fc-cache -fv
```

### 4. 检查字体是否安装成功

可以在应用（如 LibreOffice、GIMP）中查看字体是否可用，或用命令行：

```bash
fc-list | grep <字体名>
```

---

**注意：**

- 路径 `/mnt/hgfs/share/fonts` 仅为示例，请根据你的实际共享文件夹路径替换。
- 支持的字体格式包括 `.ttf`、`.otf` 等。

这样就可以在 Ubuntu 中使用共享文件夹里的字体了。

你遇到的报错是：

```
fuse: bad mount point `/mnt/hgfs`: No such file or directory
```

**原因：**
你要挂载到的目录 `/mnt/hgfs` 不存在。

---

### 解决方法

echo ".host://mnt/hgfs fuse.vmhgfs-fuse defaults,allow_other,uid=$s（id -u），gid=$（id -g） " | sudo tee -a /etc/fstab

1. **先创建挂载点目录：**

    ```bash
    sudo mkdir -p /mnt/hgfs
    ```

2. **再重新挂载：**
    ```bash
    sudo mount -a
    ```

---

如果你用的是 VMware 虚拟机，确保已经在虚拟机设置里添加了共享文件夹，并且安装了 `open-vm-tools` 和 `open-vm-tools-desktop`：

```bash
sudo apt update
sudo apt install open-vm-tools open-vm-tools-desktop
```

---

**总结：**
先创建 `/mnt/hgfs` 目录，再挂载即可解决该问题。
