```sh
ffmpeg -i input.mp4 -vf fps=1 output_%03d.jpg
```

**说明：**

- `-i input.mp4`：输入视频文件。
- `-vf fps=1`：每秒提取一帧（即每秒一张图片）。
- `output_%03d.jpg`：输出图片文件名，自动编号（如 output_001.jpg、output_002.jpg ...）。

---

如果你要指定输出图片格式或路径，可以修改 `output_%03d.jpg` 为你需要的名称和目录。

**注意：**  
需要先安装 ffmpeg，Ubuntu 下安装命令：

```sh
sudo apt install ffmpeg
```

---

如需其他帧率或格式，欢迎补充需求。
