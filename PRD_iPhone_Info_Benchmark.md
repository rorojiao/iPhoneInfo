# iPhone 系统信息与3D性能测试工具 - 产品需求文档 (PRD)

## 文档信息
- **项目名称**: iPhone Info & Benchmark Tool
- **文档版本**: v1.0
- **创建日期**: 2026-01-10
- **产品经理**: Claude
- **目标用户**: 技术爱好者、开发者、硬件评测人员、普通用户

---

## 1. 产品概述

### 1.1 产品定位
一款专为iPhone设计的综合性系统信息查看和3D性能测试工具，集硬件监控、性能测试、数据对比于一体。

### 1.2 核心价值主张
- **全面性**: 一站式查看所有iOS系统信息和硬件参数
- **专业性**: 基于Metal API的精准3D性能测试
- **易用性**: 简洁直观的界面设计，无需技术背景即可理解
- **对比性**: 支持历史记录和设备间性能对比
- **实时性**: 实时监控系统状态和性能指标

### 1.3 目标用户画像
1. **技术爱好者** (40%): 关注硬件参数，喜欢性能测试和对比
2. **iOS开发者** (25%): 需要测试应用在不同设备上的性能表现
3. **评测人员** (20%): 需要专业的测试数据进行设备评测
4. **普通用户** (15%): 想了解自己的设备性能和系统状态

---

## 2. 竞品分析

### 2.1 竞品对比表

| 功能特性 | 本产品 | 3DMark | GFXBench | System Status | 安兔兔 |
|---------|-------|--------|----------|---------------|--------|
| 系统信息查看 | ✓ 全方位 | ✗ | ✓ 基础 | ✓ 丰富 | ✓ 丰富 |
| CPU测试 | ✓ Metal优化 | ✓ | ✓ | ✗ | ✓ |
| GPU 3D测试 | ✓ 多场景 | ✓ 专业 | ✓ 专业 | ✗ | ✓ |
| 内存测试 | ✓ 实时监控 | ✗ | ✗ | ✓ | ✓ |
| 电池健康 | ✓ 详细分析 | ✗ | ✗ | ✓ | ✓ |
| 实时监控 | ✓ 图表展示 | ✗ | ✗ | ✓ | ✓ |
| 中文界面 | ✓ | ✗ | ✗ | ✗ | ✓ |
| 历史对比 | ✓ | ✓ | ✓ | ✗ | ✓ |
| 云端排行 | ✓ | ✓ | ✗ | ✗ | ✓ |

### 2.2 竞品优势与不足

**3DMark**
- ✅ 优势: 行业标准、测试场景专业、跨平台对比
- ❌ 不足: 英文界面、功能单一（仅性能测试）、免费版功能受限

**GFXBench Metal**
- ✅ 优势: Metal API专项优化、长期稳定性测试
- ❌ 不足: 界面简陋、缺少系统信息、无中文支持

**System Status**
- ✅ 优势: 系统信息全面、实时监控
- ❌ 不足: 无3D性能测试、界面过时

**安兔兔评测**
- ✅ 优势: 中文界面、综合测试、云端排行
- ❌ 不足: 测试场景不够专业、广告较多

### 2.3 本产品差异化优势
1. **整合性**: 系统信息查看 + 专业3D性能测试 + 实时监控三位一体
2. **专业性**: 基于Metal的定制化测试场景，针对iOS优化
3. **本地化**: 完整中文界面和本地化服务
4. **透明性**: 开源测试场景，数据可信度高
5. **轻量化**: 无广告、无内购、专注于核心功能

---

## 3. 功能需求详细设计

### 3.1 功能架构图

```
iPhone Info & Benchmark Tool
├── 1. 系统信息模块
│   ├── 设备信息
│   ├── 硬件信息
│   ├── 系统信息
│   ├── 传感器信息
│   └── 网络信息
├── 2. 性能测试模块
│   ├── CPU性能测试
│   ├── GPU 3D测试
│   ├── 内存性能测试
│   ├── 存储性能测试
│   └── 综合评分
├── 3. 实时监控模块
│   ├── CPU监控
│   ├── 内存监控
│   ├── GPU监控
│   ├── 电池监控
│   └── 温度监控
├── 4. 数据对比模块
│   ├── 历史记录
│   ├── 设备对比
│   └── 云端排行
└── 5. 设置模块
    ├── 测试配置
    ├── 数据导出
    └── 主题设置
```

### 3.2 系统信息模块详细设计

#### 3.2.1 设备信息
- **设备型号**: (例: iPhone 15 Pro Max, A2849)
- **设备名称**: 用户自定义的设备名称
- **序列号**: 设备唯一序列号
- **IMEI**: 国际移动设备识别码
- **MEID**: 移动设备识别码
- **ECID**: 独有芯片ID
- **生产日期**: 基于序列号推算
- **激活状态**: 激活锁状态
- **保修状态**: 保修有效期查询
- **Apple ID**: 当前登录的Apple ID

**数据来源**: UIDevice, IOKit, 私有API (需企业证书)

#### 3.2.2 硬件信息
- **SoC信息**:
  - 芯片型号 (例: A17 Pro)
  - 架构 (ARM64)
  - 制程工艺 (3nm)
  - CPU核心数和频率
  - GPU核心数
  - 神经引擎核心数

- **显示信息**:
  - 屏幕尺寸 (对角线英寸)
  - 分辨率 (像素)
  - 像素密度 (PPI)
  - 刷新率 (60Hz/120Hz ProMotion)
  - 屏幕亮度范围
  - 屏幕类型 (OLED/LCD)
  - HDR支持 (Dolby Vision/HDR10)
  - 原彩显示状态

- **内存信息**:
  - 总内存容量 (GB)
  - 可用内存 (实时)
  - 已用内存 (实时)
  - 缓存占用
  - 压缩内存

- **存储信息**:
  - 总容量 (GB)
  - 已用空间
  - 可用空间
  - 系统占用
  - 媒体占用细分:
    - 照片
    - 视频
    - 音频
    - 应用
    - 其他

- **电池信息**:
  - 电池设计容量 (mAh)
  - 当前实际容量 (mAh)
  - 健康度百分比 (%)
  - 循环次数
  - 制造日期
  - 使用温度 (°C)
  - 电压 (V)
  - 电流 (mA)
  - 充电状态 (充电中/放电/充满)
  - 充电类型 (有线/无线/MagSafe)
  - 充电功率 (W)

- **摄像头信息**:
  - 后置摄像头列表:
    - 主摄: 传感器尺寸、像素、光圈、焦段
    - 超广角: 参数
    - 长焦: 参数、光学变焦倍数
    - LiDAR: 是否配备
  - 前置摄像头参数
  - 视频拍摄能力 (4K/60fps, ProRes等)
  - ProRAW支持

**数据来源**: IOKit, 私有API, sysctl

#### 3.2.3 系统信息
- **iOS版本**: (例: iOS 17.2)
- **Build版本**: (例: 21C62)
- **内核版本**: Darwin内核版本
- **启动时间**: 系统上次启动时间
- **运行时间**: 系统连续运行时长
- **越狱状态**: 检测是否越狱
- **安全区域**: 是否启用安全区域
- **设备语言**: 当前系统语言
- **时区设置**
- **可用更新**: 检测是否有iOS更新

#### 3.2.4 传感器信息
- **运动传感器**:
  - 加速度计 (三轴)
  - 陀螺仪 (三轴)
  - 磁力计 (指南针)
- **环境传感器**:
  - 气压计 (气压高度)
  - 光线传感器
  - 距离传感器
  - 温度传感器 (设备温度)
- **其他传感器**:
  - Face ID深度感应系统
  - LiDAR激光雷达 (如有)
  - U1超宽频芯片
  - NFC支持

**实时数据展示**: 以图表形式展示传感器实时数值

#### 3.2.5 网络信息
- **蜂窝网络**:
  - 运营商名称
  - 网络类型 (5G/4G/LTE/3G/2G)
  - 信号强度 (格数和dBm)
  - MCC/MNC码
  - SIM卡信息
  - IMSI
  - ICCID
  - 网络漫游状态

- **Wi-Fi**:
  - 连接状态
  - SSID (网络名称)
  - BSSID (路由器MAC)
  - 信号强度 (RSSI)
  - 频段 (2.4GHz/5GHz/6GHz)
  - 信道
  - 连接速度
  - IP地址
  - 子网掩码
  - 路由器地址
  - DNS地址

- **蓝牙**:
  - 版本 (蓝牙5.3等)
  - 状态 (开启/关闭)
  - 已连接设备列表

- **VPN状态**: 是否启用VPN

### 3.3 性能测试模块详细设计

#### 3.3.1 CPU性能测试

**测试场景设计**:

1. **单核性能测试**
   - 算法: 质数计算、斐波那契数列
   - 指标: 单线程运算速度 (得分)
   - 时长: ~30秒

2. **多核性能测试**
   - 算法: 并行矩阵运算、排序算法
   - 指标: 多线程并行处理能力 (得分)
   - 时长: ~30秒

3. **整数运算性能**
   - 算法: 大数运算、哈希计算
   - 指标: 整数运算吞吐量 (ops/s)

4. **浮点运算性能**
   - 算法: 科学计算、三角函数
   - 指标: 浮点运算性能 (FLOPS)

5. **加密性能**
   - 算法: AES加密/解密
   - 指标: 加密吞吐量 (MB/s)

**测试结果展示**:
- 单项得分
- 综合CPU得分
- 与其他设备对比图表
- 性能等级评定 (S/A/B/C/D)

#### 3.3.2 GPU 3D性能测试

**测试场景设计** (基于Metal):

1. **基础场景: Manhattan 3.0**
   - 描述: 中等复杂度的3D场景
   - 特性: OpenGL ES 3.0级别渲染
   - 分辨率: 1080p/原生分辨率
   - 时长: 2.5分钟
   - 指标: 平均帧率 (FPS)

2. **进阶场景: Aztec Ruins**
   - 描述: 高复杂度场景
   - 特性: 高级着色、后期处理
   - 分辨率: 1080p/2K/原生
   - 时长: 2.5分钟
   - 指标: 平均帧率 (FPS)

3. **光线追踪场景: Solar Bay**
   - 描述: 实时光线追踪演示
   - 特性: Metal Ray Tracing
   - 分辨率: 可调
   - 时长: 2分钟
   - 指标: 平均帧率、光线追踪性能

4. **压力测试: Wild Life Extreme**
   - 描述: 高负载GPU压力测试
   - 特性: 大量几何体、复杂材质
   - 时长: 2分钟
   - 指标: 平均帧率、最低帧率、稳定性

5. **金属测试: Metal Benchmark**
   - 描述: Metal API专用测试
   - 特性: 计算着色器、 tessellation
   - 时长: 1分钟
   - 指标: Metal性能得分

**测试过程**:
- 实时显示帧率曲线
- 显示GPU温度和频率
- 显示当前场景信息
- 支持中断测试

**测试结果**:
- 各场景平均FPS
- 综合GPU得分
- 最低帧率（稳帧性能）
- 帧率稳定性评分
- 与同系列设备对比
- 设备温度变化曲线

#### 3.3.3 内存性能测试

**测试项目**:

1. **内存带宽测试**
   - 算法: 顺序读写大块内存
   - 指标: 带宽 (GB/s)

2. **内存延迟测试**
   - 算法: 随机访问测试
   - 指标: 平均延迟 (ns)

3. **内存拷贝性能**
   - 算法: memcpy性能
   - 指标: 拷贝速度 (GB/s)

**测试结果**: 内存性能得分

#### 3.3.4 存储性能测试

**测试项目**:

1. **顺序读取**
   - 块大小: 1MB
   - 指标: 读取速度 (MB/s)

2. **顺序写入**
   - 块大小: 1MB
   - 指标: 写入速度 (MB/s)

3. **随机读取**
   - 块大小: 4KB
   - 指标: IOPS

4. **随机写入**
   - 块大小: 4KB
   - 指标: IOPS

**测试结果**: 存储性能得分和等级评定

#### 3.3.5 综合评分系统

**评分算法**:
- CPU得分: 权重30%
- GPU得分: 权重40%
- 内存得分: 权重15%
- 存储得分: 权重15%
- **总分 = Σ(单项得分 × 权重)**

**等级评定**:
- S级: 总分前10%
- A级: 总分10%-30%
- B级: 总分30%-60%
- C级: 总分60%-90%
- D级: 总分后10%

### 3.4 实时监控模块详细设计

#### 3.4.1 CPU监控
- **实时CPU使用率**: 总体和各核心
- **CPU频率**: 实时频率变化
- **进程列表**: Top 10 CPU占用进程
- **CPU时间**: 用户态/内核态/空闲时间
- **更新频率**: 1秒

**展示方式**:
- 实时曲线图（最近1分钟）
- 当前百分比大数字显示
- 核心分布柱状图

#### 3.4.2 内存监控
- **内存使用率**: 已用/总计
- **内存分类**:
  - Wired (固定)
  - Active (活跃)
  - Inactive (非活跃)
  - Free (空闲)
- **压缩内存**: 压缩大小和压缩比
- **交换内存**: Swap使用情况
- **更新频率**: 1秒

**展示方式**:
- 饼图显示内存分布
- 实时使用曲线
- 各类型详细数值

#### 3.4.3 GPU监控
- **GPU使用率**: 实时占用
- **GPU频率**: 当前频率
- **显存使用**: 已用/总计
- **渲染统计**:
  - 三角形数量
  - 纹理加载
  - 着色器编译
- **更新频率**: 1秒

**展示方式**:
- 使用率仪表盘
- 实时曲线图
- 性能计数器

#### 3.4.4 电池监控
- **电量百分比**: 实时电量
- **电池温度** (°C)
- **电压** (V)
- **电流** (mA): 正值=充电，负值=放电
- **充电状态**: 充电/放电/充满
- **充电功率** (W)
- **预估剩余时间**: 基于当前消耗
- **电池健康**: 老化程度

**展示方式**:
- 电池动态图标
- 温度曲线图
- 充放电曲线
- 电压电流仪表

#### 3.4.5 温度监控
- **SoC温度** (CPU/GPU)
- **电池温度**
- **设备外壳温度**
- **温度历史**: 最近1小时曲线
- **温度警告**: 超过阈值提醒

**展示方式**:
- 温度计动画
- 热力曲线图
- 温度分布图

### 3.5 数据对比模块详细设计

#### 3.5.1 历史记录
- **测试历史**: 保存所有测试记录
- **数据存储**: 本地SQLite数据库
- **记录内容**:
  - 测试时间戳
  - iOS版本
  - 各项测试得分
  - 设备温度
  - 完整测试数据
- **查看方式**:
  - 时间线视图
  - 列表视图
  - 性能趋势图
- **导出功能**:
  - CSV格式
  - JSON格式
  - PDF报告

#### 3.5.2 设备对比
- **本地对比**: 同一设备不同时期对比
- **跨设备对比**:
  - 添加其他设备的测试记录
  - 并排展示各项数据
  - 优势/劣势分析
- **图表对比**:
  - 雷达图 (综合能力)
  - 柱状图 (单项对比)
  - 折线图 (性能趋势)

#### 3.5.3 云端排行
- **排行榜类型**:
  - 总分排行
  - CPU排行
  - GPU排行
  - 同型号排行
- **筛选条件**:
  - 设备型号
  - iOS版本
  - 测试场景
- **用户数据上传**:
  - 可选匿名上传
  - 数据脱敏处理
  - 上传测试结果
- **查看全球排名**: 百分比显示超越的用户

### 3.6 设置模块详细设计

#### 3.6.1 测试配置
- **测试场景选择**:
  - 快速测试 (基础项目)
  - 完整测试 (所有项目)
  - 自定义测试 (自选项目)
- **测试参数调整**:
  - 测试时长
  - 测试分辨率
  - 抗锯齿级别
- **后台运行**: 是否允许后台测试
- **电池管理**: 低电量时是否自动停止

#### 3.6.2 数据管理
- **数据导出**:
  - 导出所有历史记录
  - 导出格式选择
- **数据备份**: iCloud备份
- **数据清除**: 清除历史数据
- **隐私设置**:
  - 云端上传开关
  - 匿名上传选项

#### 3.6.3 显示设置
- **主题选择**:
  - 浅色模式
  - 深色模式
  - 跟随系统
- **图表样式**: 颜色方案
- **小数位数**: 精度设置
- **单位系统**: 公制/英制

#### 3.6.4 关于
- **应用版本**
- **开发者信息**
- **开源协议**
- **用户协议**
- **隐私政策**
- **检查更新**

---

## 4. 用户体验设计

### 4.1 信息架构

```
底部Tab导航:
├── 首页 (系统信息总览)
├── 测试 (性能测试)
├── 监控 (实时监控)
├── 对比 (历史与排行)
└── 设置 (配置与选项)
```

### 4.2 核心用户流程

#### 流程1: 查看系统信息
1. 打开App → 首页展示系统信息总览
2. 滚动查看各类信息
3. 点击分类查看详细信息
4. 可展开/收起详细信息

#### 流程2: 运行性能测试
1. 切换到"测试"标签页
2. 选择测试类型 (快速/完整/自定义)
3. 点击"开始测试"按钮
4. 显示测试进度和实时数据
5. 测试完成后展示结果
6. 可选择保存/分享/对比

#### 流程3: 实时监控
1. 切换到"监控"标签页
2. 显示所有监控项
3. 查看实时曲线图
4. 可切换监控项视图

#### 流程4: 查看历史对比
1. 切换到"对比"标签页
2. 查看历史记录列表
3. 选择记录查看详情
4. 查看性能趋势图
5. 查看云端排名

### 4.3 界面设计原则

1. **信息密度**: 适中，避免信息过载
2. **视觉层次**: 清晰的信息层级
3. **数据可视化**: 优先使用图表展示数据
4. **交互反馈**: 明确的操作反馈
5. **一致性**: 统一的设计语言
6. **响应式**: 适配不同iPhone屏幕尺寸

### 4.4 关键界面示意

#### 4.4.1 首页 (系统信息)
```
┌─────────────────────────────┐
│ iPhone 15 Pro Max    [设置] │
│ iOS 17.2  健康度: 98%       │
├─────────────────────────────┤
│ [设备] [硬件] [系统]        │
├─────────────────────────────┤
│ 📱 设备信息                 │
│   型号: A2849               │
│   芯片: A17 Pro (3nm)       │
│   内存: 8GB                 │
│   存储: 256GB (180GB可用)   │
│                             │
│ 🔋 电池                     │
│   ████████░░ 82%           │
│   健康度: 98% | 循环: 23次  │
│                             │
│ 📺 显示                     │
│   6.7" OLED 2796x1290 460PPI│
│   ProMotion 120Hz           │
│                             │
│ 📷 摄像头                   │
│   主摄 48MP | 超广 12MP     │
│   长焦 12MP 5x光学变焦      │
│                             │
│ [展开更多信息...]           │
└─────────────────────────────┘
```

#### 4.4.2 测试页面
```
┌─────────────────────────────┐
│      性能测试               │
├─────────────────────────────┤
│ 选择测试类型:               │
│ ○ 快速测试 (~2分钟)         │
│ ● 完整测试 (~10分钟)        │
│ ○ 自定义                    │
├─────────────────────────────┤
│ 测试项目:                   │
│ ✓ CPU 单核测试              │
│ ✓ CPU 多核测试              │
│ ✓ GPU Manhattan             │
│ ✓ GPU Aztec Ruins           │
│ ✓ 内存测试                  │
│ ✓ 存储测试                  │
├─────────────────────────────┤
│  电池: 82% | 温度: 36°C     │
│                              │
│    [ 开始测试 ]             │
│                              │
│  预计耗时: 约10分钟          │
│  建议充电使用以获得最佳结果  │
└─────────────────────────────┘

测试中:
┌─────────────────────────────┐
│      测试进行中...          │
│      CPU 单核测试           │
├─────────────────────────────┤
│ 进度: ████████░░ 80%       │
│ 剩余时间: 约1分钟           │
├─────────────────────────────┤
│ 实时数据:                   │
│  FPS: 58.3                  │
│  温度: 38°C                 │
│  频率: 3.78GHz              │
├─────────────────────────────┤
│     [ 暂停 ] [ 停止 ]      │
└─────────────────────────────┘

测试结果:
┌─────────────────────────────┐
│      测试完成!              │
├─────────────────────────────┤
│ 综合得分: 12,345            │
│ 等级: A (超越82%用户)       │
├─────────────────────────────┤
│ CPU: ████░░░░ 8,234        │
│ GPU: ██████░░ 15,678       │
│ 内存: ███░░░░░ 6,789       │
│ 存储: ████░░░░ 9,456       │
├─────────────────────────────┤
│ [保存] [分享] [对比] [详情] │
└─────────────────────────────┘
```

#### 4.4.3 监控页面
```
┌─────────────────────────────┐
│      实时监控               │
│      刷新间隔: 1秒          │
├─────────────────────────────┤
│ CPU      内存      GPU      │
│ 45%      62%      38%      │
│ [仪表盘] [仪表盘] [仪表盘]  │
├─────────────────────────────┤
│ CPU使用率趋势               │
│  80% ┤     ╱╲               │
│  60% ┤   ╱  ╲╱╲             │
│  40% ┤ ╱      ╲ ╱___        │
│  20% ┤╱              ╲       │
│   0% └────────────────      │
│      60s 45s 30s 15s Now    │
├─────────────────────────────┤
│ 电池: 80% | 温度: 37°C      │
│ 电压: 3.87V | 电流: -450mA  │
└─────────────────────────────┘
```

### 4.5 动画与交互

1. **页面切换**: 平滑的转场动画
2. **数据加载**: 骨架屏 + 渐进式加载
3. **测试进度**: 流畅的进度条动画
4. **数据刷新**: 定时自动刷新，带刷新指示
5. **手势支持**: 下拉刷新，侧滑返回
6. **触觉反馈**: 重要操作提供震动反馈

---

## 5. 技术实现方案

### 5.1 技术栈选择

#### 5.1.1 开发语言与框架
- **语言**: Swift 5.9+
- **UI框架**: SwiftUI (主流) + UIKit (复杂场景)
- **最低支持**: iOS 15.0+
- **目标版本**: iOS 17.0+

#### 5.1.2 主要框架

1. **Metal**: GPU 3D测试核心
   - MetalKit
   - Metal Performance Shaders
   - Metal Ray Tracing (A17+)

2. **系统信息获取**:
   - UIKit (UIDevice)
   - IOKit (硬件信息)
   - sysctl (系统参数)
   - Core Foundation (电池、网络)

3. **数据存储**:
   - CoreData (历史记录)
   - UserDefaults (设置)

4. **网络**:
   - URLSession (云端排行)

5. **图表**:
   - Swift Charts (iOS 16+)
   - Core Graphics (自定义图表)

6. **后台任务**:
   - Background Tasks

### 5.2 系统信息获取技术方案

#### 5.2.1 设备基本信息
```swift
// 使用UIDevice
let device = UIDevice.current
let name = device.name
let model = device.model
let systemVersion = device.systemVersion
```

#### 5.2.2 硬件信息获取
```swift
// 使用sysctl获取CPU信息
var size: Int = 0
sysctlbyname("hw.machine", nil, &size, nil, 0)
var machine = [CChar](repeating: 0, count: size)
sysctlbyname("hw.machine", &machine, &size, nil, 0)
let model = String(cString: machine)

// 使用IOKit获取电池详细信息
// 需要额外权限或企业证书
```

#### 5.2.3 内存信息
```swift
// 使用func_host_stats
var stats = vm_statistics64()
let count = MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size
let result = withUnsafeMutablePointer(to: &stats) {
    $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
        host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
    }
}
```

#### 5.2.4 电池信息
```swift
// 使用UIDevice (基础信息)
UIDevice.current.isBatteryMonitoringEnabled = true
let level = UIDevice.current.batteryLevel
let state = UIDevice.current.batteryState

// 使用IOKit (详细信息，需要权限)
// 获取电池循环次数、设计容量、实际容量等
```

#### 5.2.5 网络信息
```swift
// 使用Network framework
import Network
let monitor = NWPathMonitor()
monitor.pathUpdateHandler = { path in
    if path.status == .satisfied {
        // 已连接
    }
}
```

### 5.3 Metal 3D测试实现方案

#### 5.3.1 测试场景架构

```swift
// Metal测试基类
protocol MetalBenchmark {
    var name: String { get }
    var duration: TimeInterval { get }

    func setup(view: MTKView) throws
    func update(deltaTime: Float)
    func draw(view: MTKView)
    func cleanup()

    func getScore() -> BenchmarkScore
}

struct BenchmarkScore {
    let averageFPS: Float
    let minFPS: Float
    let frameCount: Int
    let totalTime: TimeInterval
    let score: Int
}
```

#### 5.3.2 Manhattan场景实现

```swift
class ManhattanBenchmark: MetalBenchmark {
    let name = "Manhattan 3.0"
    let duration: TimeInterval = 150.0 // 2.5分钟

    private var device: MTLDevice
    private var commandQueue: MTLCommandQueue
    private var pipelineState: MTLRenderPipelineState
    private var vertexBuffer: MTLBuffer
    private var frameCount: Int = 0
    private var startTime: Date?
    private var fpsValues: [Float] = []

    init(device: MTLDevice) throws {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        // 加载着色器、创建渲染管线...
    }

    func update(deltaTime: Float) {
        // 更新场景
    }

    func draw(view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        // 渲染命令
        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()

        // 记录FPS
        frameCount += 1
        if let start = startTime {
            let elapsed = Date().timeIntervalSince(start)
            let fps = Float(frameCount) / Float(elapsed)
            fpsValues.append(fps)
        }
    }

    func getScore() -> BenchmarkScore {
        let avgFPS = fpsValues.reduce(0, +) / Float(fpsValues.count)
        let minFPS = fpsValues.min() ?? 0
        let totalTime = Date().timeIntervalSince(startTime ?? Date())
        let score = Int(avgFPS * 100)

        return BenchmarkScore(
            averageFPS: avgFPS,
            minFPS: minFPS,
            frameCount: frameCount,
            totalTime: totalTime,
            score: score
        )
    }
}
```

#### 5.3.3 Aztec Ruins高负载场景

```swift
class AztecBenchmark: MetalBenchmark {
    // 更复杂的几何体和材质
    // 包含高级光照和后处理效果
    // 使用Metal Performance Shaders优化
}
```

#### 5.3.4 光线追踪测试 (A17+)

```swift
class RayTracingBenchmark: MetalBenchmark {
    // 使用Metal Ray Tracing
    // Acceleration Structure
    // Intersection Functions
    // 需要A17 Pro或更高版本
}
```

### 5.4 CPU测试实现方案

```swift
class CPUBenchmark {
    // 单核测试
    func singleCoreTest() -> Int {
        let start = Date()
        var count = 0
        let operations = 10_000_000

        for _ in 0..<operations {
            // 质数计算
            if isPrime(count) {
                // 计数
            }
            count += 1
        }

        let elapsed = Date().timeIntervalSince(start)
        let score = Int(Double(operations) / elapsed)
        return score
    }

    // 多核测试
    func multiCoreTest() -> Int {
        let queue = DispatchQueue.global(qos: .userInitiated)
        let group = DispatchGroup()
        var scores: [Int] = []

        for _ in 0..<ProcessInfo.processInfo.processorCount {
            group.enter()
            queue.async {
                let score = self.singleCoreTest()
                DispatchQueue.main.async {
                    scores.append(score)
                    group.leave()
                }
            }
        }

        group.wait()
        return scores.reduce(0, +)
    }

    private func isPrime(_ n: Int) -> Bool {
        if n <= 1 { return false }
        if n <= 3 { return true }
        if n % 2 == 0 || n % 3 == 0 { return false }
        var i = 5
        while i * i <= n {
            if n % i == 0 || n % (i + 2) == 0 { return false }
            i += 6
        }
        return true
    }
}
```

### 5.5 实时监控实现方案

```swift
class SystemMonitor: ObservableObject {
    @Published var cpuUsage: Double = 0
    @Published var memoryUsage: Double = 0
    @Published var gpuUsage: Double = 0
    @Published var batteryLevel: Float = 0
    @Published var temperature: Double = 0

    private var timer: Timer?

    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateMetrics()
        }
    }

    private func updateMetrics() {
        // CPU使用率
        self.cpuUsage = getCPUUsage()

        // 内存使用率
        self.memoryUsage = getMemoryUsage()

        // GPU使用率 (需要Metal counters)
        self.gpuUsage = getGPUUsage()

        // 电池
        self.batteryLevel = UIDevice.current.batteryLevel

        // 温度 (需要IOKit)
        self.temperature = getTemperature()
    }

    private func getCPUUsage() -> Double {
        var totalUsageOfCPU: Double = 0
        var threadsList: thread_act_array_t?
        var threadsCount = mach_msg_type_number_t(0)
        let threadsResult = withUnsafeMutablePointer(to: &threadsList) {
            return $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_threads(mach_task_self_, $0, &threadsCount)
            }
        }

        if threadsResult == KERN_SUCCESS, let threadsList = threadsList {
            for index in 0..<threadsCount {
                var threadInfo = thread_basic_info()
                var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
                let infoResult = withUnsafeMutablePointer(to: &threadInfo) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                        thread_info(threadsList[Int(index)], THREAD_BASIC_INFO, $0, &threadInfoCount)
                    }
                }

                if infoResult == KERN_SUCCESS {
                    let threadBasicInfo = threadInfo as thread_basic_info
                    if threadBasicInfo.flags & TH_FLAGS_IDLE == 0 {
                        totalUsageOfCPU += (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE)) * 100.0
                    }
                }
            }

            vm_deallocate(mach_task_self_, vm_address_t(UInt(bitPattern: threadsList)), vm_size_t(Int(threadsCount) * MemoryLayout<thread_t>.stride))
        }

        return totalUsageOfCPU
    }
}
```

### 5.6 数据存储方案

```swift
// CoreData模型
struct BenchmarkResult: Codable {
    let id: UUID
    let date: Date
    let deviceModel: String
    let iosVersion: String

    let cpuScore: Int
    let gpuScore: Int
    let memoryScore: Int
    let storageScore: Int
    let totalScore: Int

    let temperature: Double
    let batteryLevel: Float

    let details: [String: AnyCodable]
}

// CoreData Stack
class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "iPhoneInfo")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("CoreData error: \(error)")
            }
        }
    }
}
```

### 5.7 云端排行实现

```swift
struct CloudService {
    static let shared = CloudService()
    private let baseURL = "https://api.iphoneinfo.example.com"

    func uploadScore(_ result: BenchmarkResult) async throws {
        let request = ScoreUploadRequest(
            deviceId: getAnonymousDeviceID(),
            deviceModel: result.deviceModel,
            iosVersion: result.iosVersion,
            scores: ScoreData(
                cpu: result.cpuScore,
                gpu: result.gpuScore,
                memory: result.memoryScore,
                storage: result.storageScore,
                total: result.totalScore
            )
        )

        var urlRequest = URLRequest(url: URL(string: "\(baseURL)/scores")!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (_, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw UploadError.networkError
        }
    }

    func getLeaderboard(deviceModel: String? = nil, limit: Int = 100) async throws -> [LeaderboardEntry] {
        var urlComponents = URLComponents(string: "\(baseURL)/leaderboard")!
        var queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
        if let model = deviceModel {
            queryItems.append(URLQueryItem(name: "model", value: model))
        }
        urlComponents.queryItems = queryItems

        let (data, _) = try await URLSession.shared.data(from: urlComponents.url!)
        return try JSONDecoder().decode([LeaderboardEntry].self, from: data)
    }

    private func getAnonymousDeviceID() -> String {
        let key = "anonymousDeviceID"
        if let id = UserDefaults.standard.string(forKey: key) {
            return id
        }
        let newID = UUID().uuid8
        UserDefaults.standard.set(newID, forKey: key)
        return newID
    }
}
```

---

## 6. 开发计划

### 6.1 开发阶段

#### Phase 1: 基础框架 (2周)
- [ ] 项目初始化
- [ ] UI框架搭建
- [ ] 底层架构设计
- [ ] 数据模型定义

#### Phase 2: 系统信息模块 (3周)
- [ ] 设备信息获取
- [ ] 硬件信息获取
- [ ] 系统信息获取
- [ ] 传感器信息获取
- [ ] 网络信息获取
- [ ] 信息展示UI

#### Phase 3: 性能测试模块 (4周)
- [ ] CPU测试实现
- [ ] Metal GPU测试框架
- [ ] Manhattan场景
- [ ] Aztec Ruins场景
- [ ] 内存/存储测试
- [ ] 测试结果展示

#### Phase 4: 实时监控模块 (2周)
- [ ] CPU/内存监控
- [ ] GPU监控
- [ ] 电池/温度监控
- [ ] 图表组件开发

#### Phase 5: 数据对比模块 (2周)
- [ ] 历史记录存储
- [ ] 对比功能实现
- [ ] 云端API对接

#### Phase 6: 优化与测试 (2周)
- [ ] 性能优化
- [ ] UI优化
- [ ] 测试与修复
- [ ] 文档完善

### 6.2 里程碑

| 里程碑 | 目标 | 时间 |
|--------|------|------|
| M1 | 基础框架完成 | Week 2 |
| M2 | 系统信息模块完成 | Week 5 |
| M3 | GPU测试核心完成 | Week 7 |
| M4 | 所有测试完成 | Week 9 |
| M5 | 实时监控完成 | Week 11 |
| M6 | Beta版本发布 | Week 13 |
| M7 | 正式版本发布 | Week 15 |

---

## 7. 非功能性需求

### 7.1 性能要求
- 应用启动时间 < 1秒
- 系统信息加载 < 2秒
- 测试过程流畅，帧率稳定
- 内存占用 < 200MB
- 安装包大小 < 50MB

### 7.2 可靠性要求
- 应用崩溃率 < 0.1%
- 测试结果准确性误差 < 5%
- 数据持久化可靠性 100%

### 7.3 安全性要求
- 所有网络通信使用HTTPS
- 用户数据匿名化处理
- 不收集敏感个人信息
- 符合App Store审核规范

### 7.4 兼容性要求
- 支持iOS 15.0+
- 支持iPhone 12及以上所有机型
- 适配不同屏幕尺寸
- 支持深色模式

### 7.5 可维护性要求
- 代码结构清晰
- 充分的代码注释
- 完善的错误处理
- 日志记录机制

---

## 8. 风险与限制

### 8.1 技术风险

| 风险 | 影响 | 应对措施 |
|------|------|----------|
| iOS限制导致某些信息无法获取 | 中 | 使用公开API，必要时引导用户 |
| Metal测试在不同设备表现差异大 | 中 | 充分测试，设备适配 |
| 企业证书获取困难 | 高 | 尽量使用公开API |
| App Store审核不通过 | 高 | 严格遵守审核规范 |

### 8.2 业务风险

| 风险 | 影响 | 应对措施 |
|------|------|----------|
| 竞品抄袭 | 低 | 快速迭代，建立护城河 |
| 用户量不足 | 中 | 社区运营，口碑传播 |
| 云端成本过高 | 中 | 限制上传频率，使用CDN |

### 8.3 法律与合规风险

| 风险 | 影响 | 应对措施 |
|------|------|----------|
| 隐私政策不合规 | 高 | 聘请法律顾问审核 |
| 使用私有API导致下架 | 高 | 避免使用私有API |
| 数据安全事件 | 高 | 加密存储，定期审计 |

---

## 9. 成功指标

### 9.1 产品指标
- **用户量**: 首月10万，半年50万
- **留存率**: 次日留存 > 40%，7日留存 > 20%
- **使用频次**: DAU/MAU > 0.3
- **评分**: App Store评分 > 4.5

### 9.2 功能指标
- **测试完成率**: > 80%
- **数据上传率**: > 60%
- **崩溃率**: < 0.1%
- **加载速度**: 首屏 < 1秒

### 9.3 业务指标
- **NPS**: > 50
- **推荐率**: > 70%
- **社区活跃度**: 日发帖 > 100

---

## 10. 附录

### 10.1 参考资料
- [Metal Programming Guide](https://developer.apple.com/metal/)
- [Metal Performance Shaders](https://developer.apple.com/documentation/metalperformanceshaders)
- [3DMark Technical Guide](https://benchmarks.ul.com/whitepapers)
- [GFXBench Methodology](https://gfxbench.com/about.html)

### 10.2 术语表
- **FPS**: Frames Per Second，每秒帧数
- **SoC**: System on Chip，系统级芯片
- **PPI**: Pixels Per Inch，每英寸像素数
- **ProMotion**: Apple的高刷新率屏幕技术
- **LiDAR**: Light Detection and Ranging，激光雷达
- **Metal**: Apple的图形和计算API

### 10.3 设备支持列表

| 设备系列 | 支持情况 | 功能限制 |
|---------|---------|----------|
| iPhone 15系列 | ✅ 完全支持 | 无 |
| iPhone 14系列 | ✅ 完全支持 | 无光线追踪 |
| iPhone 13系列 | ✅ 完全支持 | 无光线追踪 |
| iPhone 12系列 | ✅ 完全支持 | 无光线追踪 |
| iPhone 11系列 | ⚠️ 部分支持 | 5G测试限制 |
| iPhone X系列 | ⚠️ 部分支持 | 性能限制 |

---

**文档结束**

本文档将作为产品开发的指导性文件，所有功能实现应以本文档为准。如有疑问或需要调整，请及时沟通更新。
