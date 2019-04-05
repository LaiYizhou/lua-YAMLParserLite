# lua-YAMLParserLite
A LITE yaml parser， that can parse yaml to lua table when I work with unity3d

将 YAML 格式数据解析成 Lua中的table，个人用于Unity3D的开发，且目前用于解析服务器发送过来的数据

### 1. 概述

目前用于解析服务器发送过来的数据，it's so lite

所以，*很多功能都不支持，比如，yaml文件开头跳过、类型转换、#注释等*

支持的功能 详见【题外话I：YAML概述】部分

### 2. 建议用法

```lua
local str = [[
  Animal:
    - Dog
    - Cat
    - Goldfish
  Fruits:
    - Banana
    - Apple
]]

local yaml = require("../YAMLParserLite") -- 按路径require YAMLParserLite.lua 文件即可
local tb = yaml.parse(str) -- 自此，解析成功，存入tb
```

### 3. 备注

1. 更多YAML相关知识详见，YAML官方文档：<https://yaml.org/spec/1.2/spec.html>
2. 参考：<https://github.com/peposso/lua-tinyyaml>

---

### * 题外话I: YAML概述

YAML（发音 /ˈjæməl/ ）是一个配表格式，本质上可以认为：**就是一个字符串**

简单来说，其中包括**三种数据格式**：

- scalar：纯量，即单个的、不可分割的、基础的值
- sequence：即数组
- map: 键值对

所以，按照上述三种数据格式的组合，可以组合出多种配表格式，用于不同场景

- **第1种：单个纯量**

  比如，字符串、布尔值、整数、浮点数、Null、时间、日期等

  注：本代码目前只支持解析前5种，详见方法` parse_scalar() `

- **第2种：包含纯量 的数组**

  比如，玩家可到达的地图，有：Beijing、Tokyo、London

  yaml格式为

  ```yaml
  - Beijing
  - Tokyo
  - London
  ```

  或者

  ```yaml
  [ Beijing, Tokyo, London]
  ```

- **第3种：包含数组 的数组**

  yaml格式为

  ```yaml
  - [ Dog, Cat, Goldfish]
  - [ Banana, Apple]
  ```

  或者

  ```yaml
  -
    - Dog
    - Cat
    - Goldfish
  -
    - Banana
    - Apple
  ```

- **第4种：Key是纯量、Value是纯量 的Map**

  比如， 玩家拥有道具的名称和对应数目

  yaml格式为

  ```yaml
  speed_up: 3
  cool_down: 4
  ```

  或者

  ```yaml
  { speed_up: 3, cool_down: 4 }
  ```

- **第5种：包含Map 的数组**

  比如，玩家的若干好友信息

  yaml格式为

  ```yaml
  - 
    name: A
    age: 25
  -
    name: B
    age: 27
  ```

  或者

  ```yaml
  - { name = "A", age = 25 }
  - { name = "B", age = 27 }
  ```

- **第6种：Key是纯量、Value是数组 的Map**

  yaml格式为

  ```yaml
  Animal:
    - Dog
    - Cat
    - Goldfish
  Fruits:
    - Banana
    - Apple
  ```

  或者

  ```yaml
  Animal: [ Dog, Cat, Goldfish ]
  Fruits: [ Banana, Apple ]
  ```

- **第7种：Key是纯量、Value是Map 的Map**

  比如，好友赠送的道具包

  yaml格式为

  ```yaml
  Friend1: { speed_up: 3, cool_down: 4 }
  Friend2: { speed_up: 1 }
  ```

### * 题外话II: Lua Table概述

主要提及一下Lua中Table的Key，其中Value自然可以是Lua中支持的各种类型

而Key通常为数字或者字符串，且用 `[]` 包起来

比如

```lua
local tb1 = 
{
  [-1] = 1,
  [0] = 0,
  [1] = 23,
}
```

或者

```lua
local tb2 = 
{
  ["dog"] = 12,
  ["cat"] = 30,
}
```

对于字符串作Key的情况，可以简写，即去掉 `[]` 和 `""` ，即：

```lua
local tb3 = 
{
  dog = 12,
  cat = 30,
}
```

所以，综上可以get一点：**当一个数字没有带 `[]` 和 `""` 的时候，该数字会被视为字符串**

```lua
local tb4 = { -1 = 1, 0 = 0, 1 = 23 }
```

等价于

```lua
local tb5 = { ["-1"] = 1, ["0"] = 0, ["1"] = 23 }
```

而**不等价上述的 `tb1`**

