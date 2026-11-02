# Git 与 Dotfiles 配置管理笔记（结构化清晰版）

---

## 一、nvim 配置与 dotfiles 的 Git 管理方案

### 1.1 nvim 配置的多种 Git 管理方式

#### 1.1.1 直接在 nvim 配置文件夹使用 Git 管理

- 初始化本地仓库并推送到远程：

    ```sh
    cd ~/.config/nvim
    git init
    git add .
    git commit -m "初始化 nvim 配置"
    git remote add origin git@github.com:yourname/nvim-config.git
    git push -u origin master
    git push -u origin master --force  # 强制推送，覆盖远程仓库内容
    ```

    > 这样可以方便同步和备份 nvim 配置。以后有更改继续 `add`、`commit`、`push` 即可。

#### 1.1.2 使用本地裸仓库作为“远程仓库”

- 适合本地多项目协作、备份或测试，无需联网。

    ```sh
    mkdir ~/my-nvim-config-remote.git
    cd ~/my-nvim-config-remote.git
    git init --bare

    cd ~/.config/nvim
    git remote add origin ~/my-nvim-config-remote.git
    git push -u origin master
    ```

#### 1.1.3 多目录统一管理的脚本同步方案

- 假设你要同步 nvim 配置和 ultisnips：

    ```bash
    #!/bin/bash
    find ~/nvim-config -mindepth 1 -maxdepth 1 ! -name ".git" ! -name "sync.sh" -exec rm -rf {} +
    cp -r ~/.config/nvim ~/nvim-config/nvim
    cp -r ~/.config/coc/ultisnips ~/nvim-config/ultisnips
    echo "同步完成！"
    ```

- 使用方法：

    ```sh
    chmod +x ~/nvim-config/sync.sh
    cd ~/nvim-config
    ./sync.sh
    git add .
    git commit -m "同步 nvim 配置和 ultisnips"
    git push
    ```

#### 1.1.4 使用 Git 子模块统一管理多个配置仓库

- 适合分别维护 nvim 和 ultisnips 两个独立仓库：

    ```sh
    mkdir ~/nvim-config
    cd ~/nvim-config
    git init
    git remote add origin <主仓库地址>

    git submodule add git@github.com:yourname/nvim.git nvim
    git submodule add git@github.com:yourname/ultisnips.git ultisnips

    git add .
    git commit -m "添加 nvim 和 ultisnips 子模块"
    git push -u origin master
    ```

- 克隆时递归拉取子模块：

    ```sh
    git clone --recurse-submodules <主仓库地址>
    ```

- 子模块更新：

    ```sh
    git submodule update --init --recursive
    ```

#### 1.1.5 用分支管理不同内容（不推荐）

- 可以将 ultisnips 作为 nvim.git 的一个分支：

    ```sh
    cd ~/.config/coc/ultisnips
    git init
    git remote add origin git@github.com:yourname/nvim.git
    git checkout -b ultisnips
    git add .
    git commit -m "ultisnips 代码片段"
    git push -u origin ultisnips
    ```

    > 缺点：分支内容完全独立，不能在同一工作区同时看到 nvim 配置和 ultisnips。

---

## 二、yadm 管理 dotfiles

### 2.1 yadm 安装与初始化

- 安装方式：
    - Ubuntu/Debian: `sudo apt install yadm`
    - Arch: `sudo pacman -S yadm`
    - macOS: `brew install yadm`
    - 通用脚本：

        ```sh
        curl -fLo ~/.local/bin/yadm https://github.com/TheLocehiliosan/yadm/raw/master/yadm
        chmod +x ~/.local/bin/yadm
        ```

- 初始化与添加 dotfiles：

    ```sh
    yadm init
    yadm add ~/.bashrc
    yadm add ~/.config/starship.toml
    yadm commit -m "Add my dotfiles"
    yadm remote add origin <远程仓库地址>
    yadm push -u origin master
    ```

- 新设备同步：

    ```sh
    yadm clone <远程仓库地址>
    ```

### 2.2 yadm 下只删除远端仓库的文件但保留本地文件的方法

#### 2.2.1 确认 nvim 是否被 yadm 跟踪

```sh
yadm ls-files | grep nvim
```

如果没有输出，说明 yadm 没有跟踪这个目录或文件。

#### 2.2.2 如果被跟踪，正确执行删除

假设你的 nvim 目录实际在 `.config/nvim`，应执行：

```sh
yadm rm -r --cached .config/nvim
```

这样只会从 yadm 仓库中移除，不会删除本地文件。

#### 2.2.3 如果没有被跟踪

- 你无需做任何操作，yadm 仓库远端本来就没有这个目录。

#### 2.2.4 提交并推送

```sh
yadm commit -m "remove nvim from yadm repo"
yadm push
```

#### 2.2.5 防止再次被跟踪（可选）

把 `.config/nvim/` 加入 `~/.yadmignore` 文件：

```sh
echo ".config/nvim/" >> ~/.yadmignore
yadm add ~/.yadmignore
yadm commit -m "ignore nvim folder"
yadm push
```

#### 2.2.6 总结

- 路径要写对（通常是 `.config/nvim`）。
- 用 `yadm rm -r --cached 路径`，只影响仓库，不删本地。
- `.yadmignore` 可防止再次被跟踪。

---

## 三、Git 状态符号、常用命令与 .gitignore

### 3.1 starship git 状态符号及消除方法

| 符号 | 含义                       | 如何消除（常用 git 命令）                    |
| ---- | -------------------------- | -------------------------------------------- |
| `?`  | 未跟踪文件（untracked）    | `git add <文件>` 或 `git clean -f`           |
| `+`  | 已暂存未提交（staged）     | `git commit` 或 `git reset <文件>`           |
| `!`  | 已修改未暂存（unstaged）   | `git add <文件>` 或 `git checkout -- <文件>` |
| `↑`  | 本地分支领先远程（ahead）  | `git push`                                   |
| `↓`  | 本地分支落后远程（behind） | `git pull`                                   |
| `*`  | 合并冲突（conflicted）     | 解决冲突后 `git add <文件>`，再 `git commit` |

- 例：`[+?]` 表示有已暂存未提交和未跟踪文件；`[!]` 表示有已修改未暂存文件。

### 3.2 常用操作命令

- 查看状态：`git status`
- 添加所有更改：`git add .`
- 提交：`git commit -m "说明"`
- 推送：`git push`
- 忽略文件：编辑 `.gitignore`
- 放弃更改：
    - 取消暂存：`git reset`
    - 放弃工作区更改：`git checkout -- <文件>`

### 3.3 .gitignore 的使用

- 在项目根目录新建 `.gitignore`，每行写一个要忽略的文件或目录。
- 例：

    ```
    *.log
    build/
    *.tmp
    ```

- 已被跟踪的文件需先 `git rm --cached 文件名`，再写入 `.gitignore`。

---

## 四、Git 文件与变更内容查看

### 4.1 查看已暂存（已 add）但未提交的内容

```sh
git diff --cached <文件夹路径>
# 或
git diff --staged <文件夹路径>
```

- 不加路径则查看所有已暂存内容：

    ```sh
    git diff --cached
    ```

### 4.2 查看已暂存的文件列表

```sh
git diff --cached --name-only <文件夹路径>
```

### 4.3 查看当前仓库所有被 Git 跟踪的文件

```sh
git ls-files
```

- 只看某个文件夹下被跟踪的文件：

    ```sh
    git ls-files <文件夹路径>
    ```

---

## 五、nvimdiff 与 Git 合并冲突处理

### 5.1 nvimdiff 基本用法

- 对比两个文件：

    ```sh
    nvim -d file1 file2
    ```

### 5.2 配合 git mergetool 使用

- 设置 nvimdiff 为合并工具：

    ```sh
    git config --global merge.tool nvimdiff
    git config --global mergetool.nvimdiff.cmd 'nvim -d $LOCAL $REMOTE $MERGED -c "wincmd l"'
    ```

- 遇到冲突时：

    ```sh
    git mergetool
    ```

- 在 nvimdiff 中用 `]c`/`[c` 跳转冲突块，`:diffget LOCAL`/`:diffget REMOTE` 选择内容，编辑合并结果，保存退出。

---

## 六、Git 稀疏检出（只下载仓库部分文件）

### 6.1 稀疏检出命令详解

1. 克隆仓库但不检出文件内容：

    ```sh
    git clone --filter=blob:none --no-checkout https://github.com/username/repo.git
    ```

    - `--filter=blob:none`：只下载提交历史和目录结构，不下载文件内容。
    - `--no-checkout`：不自动检出文件。

2. 进入仓库目录：

    ```sh
    cd repo
    ```

3. 初始化稀疏检出（cone 模式）：

    ```sh
    git sparse-checkout init --cone
    ```

4. 设置只检出某个文件：

    ```sh
    git sparse-checkout set coc-settings.json
    ```

5. 检出文件到工作区：

    ```sh
    git checkout
    ```

    > 此时只会下载并显示 `coc-settings.json`，其他文件不会出现在本地目录。

---

## 七、Pandoc 转 PDF 中文乱码问题解决

### 7.1 问题描述与原因

- 报错：`! LaTeX Error: Unicode character 与 (U+4E0E) not set up for use with LaTeX.`
- 原因：Pandoc 默认用 LaTeX 生成 PDF，但 LaTeX 没有正确配置中文字体支持。

### 7.2 解决方法

- **方法一：指定中文支持模板（推荐）**
    - 安装中文字体（如 Noto Sans CJK）：

        ```sh
        sudo apt install fonts-noto-cjk
        ```

    - 转 PDF 时指定字体：

        ```sh
        pandoc git.md -o git.pdf --pdf-engine=xelatex -V mainfont="Noto Sans CJK SC"
        ```

- **方法二：用 typst 引擎（新版本 Pandoc 支持）**

    ```sh
    pandoc git.md -o git.pdf --pdf-engine=typst
    ```

- **方法三：先转 HTML，再打印为 PDF**

    ```sh
    pandoc git.md -o git.html
    # 用浏览器打开 git.html，打印为 PDF
    ```

---

## 八、GitHub SSH 配置与使用

### 8.1 生成 SSH 密钥

```sh
ssh-keygen -t ed25519 -C "your_email@example.com"
```

- 按提示回车，密钥会生成在 `~/.ssh/id_ed25519` 和 `~/.ssh/id_ed25519.pub`。

### 8.2 查看公钥内容

```sh
cat ~/.ssh/id_ed25519.pub
```

- 复制输出的内容。

### 8.3 添加公钥到 GitHub

1. 登录 [GitHub](https://github.com)。
2. 右上角头像 → **Settings** → **SSH and GPG keys** → **New SSH key**。
3. 粘贴刚才复制的公钥，保存。

### 8.4 测试 SSH 连接

```sh
ssh -T git@github.com
```

- 首次会提示 `Are you sure you want to continue connecting`，输入 `yes`，看到 `Hi your_username!` 就成功了。

### 8.5 使用 SSH 地址克隆仓库

```sh
git clone git@github.com:username/repo.git
```

- 如有多账号或特殊端口，可配置 `~/.ssh/config`，具体可参考 [GitHub 官方文档](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)。

---

## 九、常见问题与解决

### 9.1 断开本地仓库与远程仓库连接

- 你可以通过以下命令将本地仓库与远程仓库断开连接（即移除远程仓库的配置）：

    ```bash
    git remote remove origin
    ```

- 执行后，本地仓库就不会再关联到原来的远程仓库了。如果你有多个远程（比如 `upstream`），可以用 `git remote -v` 查看所有远程，然后用同样的命令移除对应的远程名即可。

### 9.2 Git 仓库文件变更与恢复

- 你图中显示的是**Git 仓库中的文件变更状态**，不是“仓库”本身。你可能想问的是：
    - **如何删除这些文件的变更？**
    - **如何删除整个 Git 仓库？**

#### 9.2.1 删除这些文件的变更（恢复到上次提交状态）

如果你只是想**放弃所有未提交的更改**，可以执行：

```bash
git restore .
```

如果还想把未跟踪（新建但未 add）的文件也删除（比如 `lua/keymaps.lua`），可以再执行：

```bash
git clean -fd
```

#### 9.2.2 删除整个 Git 仓库

如果你想**彻底删除这个 Git 仓库**（包括所有版本记录），可以直接删除 `.git` 文件夹：

```bash
rm -rf .git
```

这样，这个目录就变成普通文件夹了，不再是 Git 仓库。

> **注意：**
>
> - 删除操作不可恢复，请谨慎操作！
> - 如果你只想撤销本地更改，建议用第1种方法。
> - 如果你要删除的是整个仓库（包括所有历史），用第2种方法。

### 9.3 git/yadm 只删除远程仓库文件但保留本地文件

#### 9.3.1 git 操作

1. **从索引中移除 nvim 文件夹（不删本地文件）**

    ```sh
    git rm -r --cached nvim
    ```

2. **提交更改**

    ```sh
    git commit -m "remove nvim folder from remote but keep local"
    ```

3. **推送到远程仓库**

    ```sh
    git push origin master
    ```

    > 如果你用的是其他分支，把 `master` 换成你的分支名。

4. **（可选）防止再次被跟踪**  
   把 `nvim/` 加入 `.gitignore` 文件：

    ```sh
    echo "nvim/" >> .gitignore
    git add .gitignore
    git commit -m "ignore nvim folder"
    git push origin master
    ```

    这样，远程仓库的 nvim 文件夹会被删除，本地文件不会被删除。

#### 9.3.2 yadm 操作

- 参考**二、yadm 管理 dotfiles**中的 2.2 节。
