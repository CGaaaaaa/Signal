// Signal 库使用示例

// === 基本用法示例 ===

///|
pub fn example_basic_usage() -> Unit {
  println("=== 基本用法示例 ===")

  // 创建可写信号
  let count = signal(0)
  let name = signal("Alice")

  // 创建计算信号
  let message = computed(fn() { "\{name.get()} has \{count.get()} items" })
  println(message.get()) // "Alice has 0 items"

  // 更新信号值
  count.set(5)
  println(message.get()) // "Alice has 5 items"
  name.set("Bob")
  println(message.get()) // "Bob has 5 items"
}

// === 计算器示例 ===

///|
pub fn example_calculator() -> Unit {
  println("\n=== 计算器示例 ===")
  let a = signal(10)
  let b = signal(5)
  let operation = signal("+")
  let result = computed(fn() {
    let op = operation.get()
    let x = a.get()
    let y = b.get()
    match op {
      "+" => x + y
      "-" => x - y
      "*" => x * y
      "/" => if y != 0 { x / y } else { 0 }
      _ => 0
    }
  })
  println(
    "a=\{a.get()}, b=\{b.get()}, op=\{operation.get()} => result=\{result.get()}",
  )
  operation.set("*")
  println(
    "a=\{a.get()}, b=\{b.get()}, op=\{operation.get()} => result=\{result.get()}",
  )
  a.set(20)
  println(
    "a=\{a.get()}, b=\{b.get()}, op=\{operation.get()} => result=\{result.get()}",
  )
}

// === 购物车示例 ===

///|
priv struct Item {
  name : String
  price : Int
  quantity : Int
} derive(Eq)

///|
pub fn example_shopping_cart() -> Unit {
  println("\n=== 购物车示例 ===")
  let items = signal([
    { name: "苹果", price: 5, quantity: 3 },
    { name: "香蕉", price: 3, quantity: 5 },
    { name: "橙子", price: 4, quantity: 2 },
  ])
  let discount_rate = signal(0) // 折扣率 (0-100)

  // 计算总价
  let subtotal = computed(fn() {
    let item_list = items.get()
    let mut total = 0
    for item in item_list {
      total = total + item.price * item.quantity
    }
    total
  })

  // 计算折扣后价格
  let total = computed(fn() {
    let sub = subtotal.get()
    let discount = discount_rate.get()
    sub - sub * discount / 100
  })
  println("小计: \{subtotal.get()}")
  println("总计: \{total.get()}")

  // 应用10%折扣
  discount_rate.set(10)
  println("应用10%折扣后:")
  println("小计: \{subtotal.get()}")
  println("总计: \{total.get()}")

  // 增加一个商品
  let new_items = items.get()
  new_items.push({ name: "葡萄", price: 8, quantity: 1 })
  items.set(new_items)
  println("增加葡萄后:")
  println("小计: \{subtotal.get()}")
  println("总计: \{total.get()}")
}

// === 状态机示例 ===

///|
priv enum AppState {
  Loading
  Ready(String)
  Error(String)
} derive(Eq)

///|
pub fn example_state_machine() -> Unit {
  println("\n=== 状态机示例 ===")
  let current_state = signal(Loading)

  // 根据状态计算UI消息
  let ui_message = computed(fn() {
    match current_state.get() {
      Loading => "正在加载..."
      Ready(data) => "数据已就绪: \{data}"
      Error(msg) => "错误: \{msg}"
    }
  })

  // 根据状态计算是否可以执行操作
  let can_perform_action = computed(fn() {
    match current_state.get() {
      Ready(_) => true
      _ => false
    }
  })
  println(ui_message.get())
  println("可以执行操作: \{can_perform_action.get()}")

  // 状态转换
  current_state.set(Ready("用户数据"))
  println(ui_message.get())
  println("可以执行操作: \{can_perform_action.get()}")
  current_state.set(Error("网络连接失败"))
  println(ui_message.get())
  println("可以执行操作: \{can_perform_action.get()}")
}

// === 表单验证示例 ===

///|
pub fn example_form_validation() -> Unit {
  println("\n=== 表单验证示例 ===")
  let username = signal("")
  let email = signal("")
  let password = signal("")

  // 用户名验证
  let username_valid = computed(fn() {
    let name = username.get()
    name.length() >= 3 && name.length() <= 20
  })

  // 邮箱验证（简化版）
  let email_valid = computed(fn() {
    let mail = email.get()
    mail.contains("@") && mail.contains(".")
  })

  // 密码验证
  let password_valid = computed(fn() {
    let pwd = password.get()
    pwd.length() >= 6
  })

  // 整体表单验证
  let form_valid = computed(fn() {
    username_valid.get() && email_valid.get() && password_valid.get()
  })
  fn show_validation_status() {
    println("用户名: '\{username.get()}' - 有效: \{username_valid.get()}")
    println("邮箱: '\{email.get()}' - 有效: \{email_valid.get()}")
    println("密码: '\{password.get()}' - 有效: \{password_valid.get()}")
    println("表单整体有效: \{form_valid.get()}")
    println("---")
  }

  show_validation_status()
  username.set("alice")
  show_validation_status()
  email.set("alice@example.com")
  show_validation_status()
  password.set("123456")
  show_validation_status()
}

// === 计数器与副作用示例 ===

///|
pub fn example_counter_with_effects() -> Unit {
  println("\n=== 计数器与副作用示例 ===")
  let counter = signal(0)
  let log_messages : Ref[Array[String]] = { val: [] }

  // 创建副作用来记录计数器变化
  let _logger = effect(fn() {
    let count = counter.get()
    let message = "计数器更新为: \{count}"
    log_messages.val.push(message)
    println(message)
  })

  // 创建另一个副作用来检查偶数
  let _even_checker = effect(fn() {
    let count = counter.get()
    if count % 2 == 0 && count > 0 {
      println("达到偶数: \{count}")
    }
  })

  // 递增计数器
  for i = 1; i < 6; i = i + 1 {
    counter.set(i)
  }
  println("日志消息数量: \{log_messages.val.length()}")
}

// === 批量更新示例 ===

///|
pub fn example_batch_updates() -> Unit {
  println("\n=== 批量更新示例 ===")
  let x = signal(1)
  let y = signal(2)
  let compute_count : Ref[Int] = { val: 0 }
  let sum = computed(fn() {
    compute_count.val = compute_count.val + 1
    let result = x.get() + y.get()
    println("计算和: \{x.get()} + \{y.get()} = \{result}")
    result
  })
  println("初始值: \{sum.get()}")
  println("计算次数: \{compute_count.val}")
  println("\n分别更新 x 和 y:")
  x.set(10)
  y.set(20)
  println("最终值: \{sum.get()}")
  println("计算次数: \{compute_count.val}")
  println("\n使用批量更新:")
  compute_count.val = 0
  batch(fn() {
    x.set(100)
    y.set(200)
    return ()
  })
  println("最终值: \{sum.get()}")
  println("计算次数: \{compute_count.val}")
}

// === 主示例运行函数 ===

///|
pub fn run_all_examples() -> Unit {
  example_basic_usage()
  example_calculator()
  example_shopping_cart()
  example_state_machine()
  example_form_validation()
  example_counter_with_effects()
  example_batch_updates()
}
