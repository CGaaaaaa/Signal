# Signal - MoonBit 函数式响应编程库

[English](README.md) | 简体中文

一个高效的、基于依赖图的 Signal 库实现，专为 MoonBit 语言设计，保证最小更新计算次数。

## 特性

- 🚀 **高性能**: 基于依赖图的最小更新算法
- 🔄 **响应式**: 自动依赖追踪和变化传播  
- 🧩 **模块化**: 清晰的 API 设计，易于集成
- 🛡️ **类型安全**: 充分利用 MoonBit 的类型系统
- 📦 **轻量级**: 单文件实现，无额外依赖
- 🎯 **实用性**: 参考 Vue.js、Preact、OCaml React 等成熟实现

## 快速开始

### 安装

```bash
moon add signal
```

### 基本用法

```moonbit
// 创建可写信号
let count = signal(0)
let name = signal("Alice")

// 创建计算信号
let message = computed(fn() {
  "\{name.get()} has \{count.get()} items"
})

println(message.get())  // "Alice has 0 items"

// 更新信号值
count.set(5)
println(message.get())  // "Alice has 5 items"
```

### 副作用

```moonbit
let counter = signal(0)

// 创建副作用来响应变化
let _effect = effect(fn() {
  println("计数器值: \{counter.get()}")
})

counter.set(1)  // 输出: "计数器值: 1" 
counter.set(2)  // 输出: "计数器值: 2"
```

### 批量更新

```moonbit
let x = signal(1)
let y = signal(2)
let sum = computed(fn() { x.get() + y.get() })

// 批量更新避免中间计算
batch(fn() {
  x.set(10)
  y.set(20)
  return ()
})

println(sum.get())  // 30
```

## 完整示例

### 购物车应用

```moonbit
struct Item {
  name: String
  price: Int
  quantity: Int
}

// 创建信号
let items = signal([
  { name: "苹果", price: 5, quantity: 3 },
  { name: "香蕉", price: 3, quantity: 5 }
])

let discount_rate = signal(0)  // 折扣率 0-100

// 计算小计
let subtotal = computed(fn() {
  let item_list = items.get()
  let total = 0
  for item in item_list {
    total = total + item.price * item.quantity
  }
  total
})

// 计算总计（含折扣）
let total = computed(fn() {
  let sub = subtotal.get()
  let discount = discount_rate.get()
  sub - (sub * discount / 100)
})

// 监听价格变化
let _price_watcher = effect(fn() {
  println("当前总价: ¥\{total.get()}")
})

// 应用折扣
discount_rate.set(10)  // 10% 折扣
```

## API 参考

### 创建信号

- `signal[T](initial_value: T) -> WritableSignal[T]` - 创建可写信号
- `computed[T](compute_fn: () -> T) -> ComputedSignal[T]` - 创建计算信号
- `effect(effect_fn: () -> Unit) -> Effect` - 创建副作用

### 信号操作

**WritableSignal 方法:**
- `get() -> T` - 获取当前值
- `set(new_value: T) -> Unit` - 设置新值
- `update(updater: (T) -> T) -> Unit` - 使用函数更新值

**ComputedSignal 方法:**
- `get() -> T` - 获取计算值（自动重新计算）

### 工具函数

- `batch[T](f: () -> T) -> T` - 批量执行更新操作
- `untracked[T](f: () -> T) -> T` - 不建立依赖关系的访问

## 设计原理

### 依赖追踪

Signal 库使用全局追踪上下文自动记录依赖关系，当信号值变化时，只会重新计算真正受影响的信号，保证最小更新。

### 与其他实现的比较

| 特性 | MoonBit Signal | Vue.js | Preact | OCaml React |
|------|----------------|--------|--------|-------------|
| 类型安全 | ✅ 强类型 | ❌ 动态 | ✅ TS | ✅ 强类型 |
| 自动依赖 | ✅ | ✅ | ✅ | ❌ |
| 批量更新 | ✅ | ✅ | ✅ | ✅ |
| 学习曲线 | 📈 中等 | 📈 中等 | 📈 简单 | 📈 陡峭 |

## 最佳实践

1. **合理组织依赖关系** - 保持清晰的依赖层次
2. **使用批量更新** - 避免多次中间计算
3. **适当使用 untracked** - 在不需要依赖时使用
4. **及时清理副作用** - 防止内存泄漏

## 贡献

欢迎贡献代码、文档或报告问题！请查看 [CONTRIBUTING.md](.github/CONTRIBUTING.md) 了解详情。

## 许可证

MIT License - 查看 [LICENSE](LICENSE) 文件了解详情。

## 致谢

本库的设计灵感来源于：
- [Vue.js Reactivity](https://github.com/vuejs/core/tree/main/packages/reactivity)
- [Preact Signals](https://github.com/preactjs/signals)
- [OCaml React](https://github.com/dbuenzli/react)
- [Solid.js](https://github.com/solidjs/solid)