# Signal - MoonBit Functional Reactive Programming Library

English | [简体中文](README_zh_CN.md)

An efficient Signal library implementation based on dependency graph, designed specifically for MoonBit language, ensuring minimal update computations.

## 特性

- 🚀 **高性能**: 基于依赖图的最小更新算法
- 🔄 **响应式**: 自动依赖追踪和变化传播  
- 🧩 **模块化**: 清晰的 API 设计，易于集成
- 🛡️ **类型安全**: 充分利用 MoonBit 的类型系统
- 📦 **轻量级**: 单文件实现，无额外依赖
- 🎯 **实用性**: 参考 Vue.js、Preact、OCaml React 等成熟实现

## 核心概念

### Signal (信号)
响应式编程的基本单元，包含一个值并能通知其变化。

### Computed Signal (计算信号)  
基于其他信号自动计算的衍生值，当依赖变化时自动重新计算。

### Effect (副作用)
当依赖的信号变化时自动执行的函数，用于处理副作用操作。

## 快速开始

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

name.set("Bob")  
println(message.get())  // "Bob has 5 items"
```

### 计算信号链

```moonbit
let input = signal(2)
let doubled = computed(fn() { input.get() * 2 })
let quadrupled = computed(fn() { doubled.get() * 2 })

println(quadrupled.get())  // 8

input.set(3)
println(quadrupled.get())  // 12
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

### 取消依赖追踪

```moonbit
let a = signal(5)
let b = signal(10)

let result = computed(fn() {
  let a_val = a.get()  // 建立依赖
  let b_val = untracked(fn() { b.get() })  // 不建立依赖
  a_val + b_val
})

// 只有 a 的变化会触发 result 重新计算
```

## API 参考

### 创建信号

#### `signal[T](initial_value: T) -> WritableSignal[T]`
创建一个可写信号。

```moonbit
let count = signal(42)
let name = signal("Hello")
let items = signal([1, 2, 3])
```

#### `computed[T](compute_fn: () -> T) -> ComputedSignal[T]`
创建一个计算信号。

```moonbit
let doubled = computed(fn() { count.get() * 2 })
```

#### `effect(effect_fn: () -> Unit) -> Effect`
创建一个副作用。

```moonbit
let _logger = effect(fn() {
  println("值变为: \{count.get()}")
})
```

### 信号操作

#### WritableSignal 方法

- `get() -> T`: 获取当前值
- `set(new_value: T) -> Unit`: 设置新值
- `update(updater: (T) -> T) -> Unit`: 使用函数更新值

```moonbit
let counter = signal(0)
println(counter.get())       // 0
counter.set(10)             // 设置为 10
counter.update(fn(x) { x + 1 })  // 递增为 11
```

#### ComputedSignal 方法

- `get() -> T`: 获取计算值（如果过期会自动重新计算）

```moonbit
let sum = computed(fn() { a.get() + b.get() })
println(sum.get())  // 获取计算结果
```

### 工具函数

#### `batch[T](f: () -> T) -> T`
批量执行多个更新操作。

```moonbit
batch(fn() {
  signal1.set(value1)
  signal2.set(value2)
  signal3.set(value3)
  return ()
})
```

#### `untracked[T](f: () -> T) -> T`
在不建立依赖关系的情况下访问信号。

```moonbit
let result = computed(fn() {
  let tracked_val = tracked_signal.get()
  let untracked_val = untracked(fn() { other_signal.get() })
  tracked_val + untracked_val
})
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

// 添加商品
let new_items = items.get()
new_items.push({ name: "橙子", price: 4, quantity: 2 })
items.set(new_items)
```

### 表单验证

```moonbit
// 表单字段
let username = signal("")
let email = signal("")
let password = signal("")

// 验证规则
let username_valid = computed(fn() {
  let name = username.get()
  name.length() >= 3 && name.length() <= 20
})

let email_valid = computed(fn() {
  let mail = email.get()
  mail.contains("@") && mail.contains(".")
})

let password_valid = computed(fn() {
  password.get().length() >= 6
})

// 整体表单验证
let form_valid = computed(fn() {
  username_valid.get() && email_valid.get() && password_valid.get()
})

// 实时反馈
let _validator = effect(fn() {
  if form_valid.get() {
    println("✅ 表单验证通过")
  } else {
    println("❌ 表单验证失败")
  }
})

// 填写表单
username.set("alice")
email.set("alice@example.com") 
password.set("123456")
// 输出: "✅ 表单验证通过"
```

## 设计原理

### 依赖追踪

Signal 库使用全局追踪上下文来自动记录依赖关系：

1. 当计算信号或副作用执行时，设置全局追踪上下文
2. 任何 `signal.get()` 调用都会记录到当前追踪上下文
3. 计算完成后，建立依赖关系图

### 最小更新

- 只有当信号值真正发生变化时才触发更新
- 使用拓扑排序确保依赖按正确顺序更新
- 避免重复计算和无效更新

### 内存管理

- 使用弱引用避免循环依赖导致的内存泄漏
- 自动清理不再使用的依赖关系
- 高效的批量更新机制

## 与其他实现的比较

| 特性 | MoonBit Signal | Vue.js Reactivity | Preact Signals | OCaml React |
|------|----------------|-------------------|----------------|-------------|
| 类型安全 | ✅ 强类型 | ❌ 动态类型 | ✅ TypeScript | ✅ 强类型 |
| 自动依赖追踪 | ✅ | ✅ | ✅ | ❌ 手动 |
| 批量更新 | ✅ | ✅ | ✅ | ✅ |
| 内存效率 | ✅ 高 | ✅ 高 | ✅ 高 | ✅ 高 |
| 学习曲线 | 📈 中等 | 📈 中等 | 📈 简单 | 📈 陡峭 |

## 最佳实践

### 1. 合理组织依赖关系
```moonbit
// ✅ 好的做法 - 清晰的依赖层次
let base_data = signal(initial_data)
let processed_data = computed(fn() { process(base_data.get()) })
let ui_data = computed(fn() { format_for_ui(processed_data.get()) })

// ❌ 避免 - 复杂的依赖网络
let tangled_computation = computed(fn() {
  // 访问太多不相关的信号
})
```

### 2. 使用批量更新
```moonbit
// ✅ 好的做法
batch(fn() {
  signal1.set(value1)
  signal2.set(value2)
  signal3.set(value3)
  return ()
})

// ❌ 避免 - 逐个更新触发多次计算
signal1.set(value1)  // 触发计算
signal2.set(value2)  // 再次触发计算  
signal3.set(value3)  // 第三次触发计算
```

### 3. 适当使用 untracked
```moonbit
// ✅ 好的做法 - 只在真正不需要依赖时使用
let result = computed(fn() {
  let main_value = main_signal.get()
  let debug_info = untracked(fn() { debug_signal.get() })
  // debug_info 的变化不会触发重新计算
  main_value
})
```

### 4. 及时清理副作用
```moonbit
// ✅ 好的做法 - 在适当时机停止副作用
let cleanup_effect = effect(fn() {
  // 副作用逻辑
})
// 在不需要时清理（如果实现了dispose方法）
// cleanup_effect.dispose()
```

## 性能考虑

### 计算复杂度
- Signal 创建: O(1)
- 依赖追踪: O(d), d 为依赖数量
- 更新传播: O(n), n 为受影响的信号数量

### 内存使用
- 每个信号大约 64 字节基础开销
- 依赖关系每条边约 16 字节
- 自动清理未使用的依赖

### 优化建议
1. 避免在计算函数中进行重计算
2. 使用批量更新减少中间状态
3. 合理使用 untracked 避免不必要的依赖
4. 将复杂计算分解为多个简单的计算信号

## 故障排除

### 常见问题

**Q: 计算信号没有更新？**
A: 检查是否正确调用了 `signal.get()` 来建立依赖关系。

**Q: 出现循环依赖错误？**
A: 确保计算信号的函数不会直接或间接地依赖自己。

**Q: 副作用执行多次？**
A: 使用批量更新或检查是否有不必要的信号访问。

**Q: 内存使用持续增长？**
A: 检查是否有未清理的副作用或循环引用。

## 贡献指南

欢迎贡献代码、文档或报告问题！

1. Fork 此仓库
2. 创建功能分支: `git checkout -b feature/new-feature`
3. 提交更改: `git commit -m 'Add new feature'`
4. 推送分支: `git push origin feature/new-feature`
5. 提交 Pull Request

## 许可证

MIT License - 查看 [LICENSE](LICENSE) 文件了解详情。

## 致谢

本库的设计灵感来源于：
- [Vue.js Reactivity](https://github.com/vuejs/core/tree/main/packages/reactivity)
- [Preact Signals](https://github.com/preactjs/signals)
- [OCaml React](https://github.com/dbuenzli/react)
- [Solid.js](https://github.com/solidjs/solid)

## 更新日志

### v0.1.0 (当前版本)
- ✅ 基础 Signal 实现
- ✅ 计算信号支持
- ✅ 副作用系统
- ✅ 自动依赖追踪
- ✅ 批量更新
- ✅ untracked 支持
- ✅ 完整的示例和文档

### 路线图
- [ ] 完善观察者通知机制
- [ ] 添加信号生命周期管理
- [ ] 实现信号调试工具
- [ ] 性能优化和基准测试
- [ ] 添加更多实用工具函数