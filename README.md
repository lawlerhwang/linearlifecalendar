# Linear Life Calendar - macOS 日历应用

基于 SwiftUI 和 EventKit 的 macOS 日历应用，保持原有 React 应用的外观设计，同时提供原生 macOS 体验。

## 功能特性

### 核心功能
- **年视图**: 线性年度概览，显示全年事件分布
- **月视图**: 传统月历视图，便于查看月度安排
- **事件管理**: 创建、查看、删除日历事件
- **iCloud 集成**: 自动同步 iCloud 日历事件
- **多日历支持**: 支持系统中的所有日历源

### 界面特色
- **中文本地化**: 完整的中文界面和日期格式
- **macOS 风格**: 原生 macOS 设计语言
- **响应式布局**: 适配不同窗口尺寸
- **拖拽选择**: 支持拖拽创建多日事件
- **键盘快捷键**: 标准 macOS 快捷键支持

## 项目结构

```
LinearLifeCalendar/
├── LinearLifeCalendar.xcodeproj/     # Xcode 项目文件
└── LinearLifeCalendar/
    ├── LinearLifeCalendarApp.swift   # 应用入口
    ├── ContentView.swift             # 主视图控制器
    ├── Models/
    │   └── CalendarEvent.swift       # 事件数据模型
    ├── Views/
    │   ├── YearView.swift           # 年视图组件
    │   ├── MonthView.swift          # 月视图组件
    │   ├── CreateEventView.swift    # 创建事件视图
    │   └── EventDetailView.swift    # 事件详情视图
    ├── Managers/
    │   └── CalendarManager.swift    # 日历数据管理器
    ├── Extensions/
    │   └── DateExtensions.swift     # 日期扩展工具
    ├── LinearLifeCalendar.entitlements  # 应用权限配置
    └── Info.plist                   # 应用信息配置
```

## 技术架构

### 核心技术栈
- **SwiftUI**: 现代声明式 UI 框架
- **EventKit**: 系统日历数据访问
- **Combine**: 响应式数据绑定
- **Foundation**: 基础数据处理

### 设计模式
- **MVVM**: Model-View-ViewModel 架构
- **ObservableObject**: 响应式状态管理
- **Environment Objects**: 依赖注入
- **Async/Await**: 现代异步编程

## 开发环境要求

- **Xcode**: 15.0 或更高版本
- **macOS**: 14.0 或更高版本
- **Swift**: 5.9 或更高版本

## 安装和运行

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd LinearLifeCalendar
   ```

2. **打开项目**
   ```bash
   open LinearLifeCalendar.xcodeproj
   ```

3. **配置签名**
   - 在 Xcode 中选择项目
   - 修改 Bundle Identifier
   - 配置开发者账号签名

4. **运行应用**
   - 选择目标设备（Mac）
   - 点击运行按钮或按 Cmd+R

## 权限配置

应用需要以下系统权限：

- **日历访问权限**: 读取和修改系统日历
- **沙盒权限**: macOS 应用沙盒安全要求

权限配置在 `LinearLifeCalendar.entitlements` 文件中定义。

## iOS 迁移准备

代码结构已考虑 iOS 迁移需求：

### 共享组件
- `CalendarEvent.swift` - 跨平台数据模型
- `CalendarManager.swift` - 核心业务逻辑
- `DateExtensions.swift` - 通用日期工具

### 平台特定
- UI 组件使用 SwiftUI，天然支持跨平台
- 使用 `#if os(macOS)` 条件编译处理平台差异
- 布局适配使用 Size Classes 和环境值

### 迁移步骤
1. 创建 iOS 目标
2. 共享核心代码文件
3. 调整 UI 布局适配移动端
4. 处理平台特定交互（触摸 vs 鼠标）

## 自定义和扩展

### 添加新视图类型
1. 在 `ViewType` 枚举中添加新类型
2. 创建对应的 SwiftUI 视图组件
3. 在 `ContentView` 中添加视图切换逻辑

### 扩展事件功能
1. 修改 `CalendarEvent` 模型添加新属性
2. 更新 `CalendarManager` 处理新功能
3. 调整 UI 组件显示新信息

### 集成其他日历服务
1. 扩展 `CalendarManager` 支持新的数据源
2. 实现相应的数据同步逻辑
3. 添加用户配置界面

## 性能优化

- **懒加载**: 使用 `LazyVGrid` 和 `LazyVStack` 优化大数据集渲染
- **数据缓存**: `CalendarManager` 实现事件数据缓存
- **异步加载**: 使用 `async/await` 避免 UI 阻塞
- **内存管理**: 合理使用 `@State` 和 `@StateObject` 管理状态

## 故障排除

### 常见问题

1. **日历权限被拒绝**
   - 检查系统偏好设置 > 安全性与隐私 > 日历
   - 确保应用已获得访问权限

2. **事件不显示**
   - 确认 iCloud 日历同步已开启
   - 检查网络连接状态
   - 重启应用重新加载数据

3. **编译错误**
   - 确认 Xcode 版本符合要求
   - 检查 Bundle Identifier 配置
   - 验证开发者证书有效性

## 贡献指南

欢迎提交 Issue 和 Pull Request 来改进项目：

1. Fork 项目仓库
2. 创建功能分支
3. 提交代码更改
4. 创建 Pull Request

## 许可证

本项目采用 MIT 许可证，详见 LICENSE 文件。