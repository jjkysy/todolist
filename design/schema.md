# TodoList 应用数据库设计

## 用户表 (Users)
```sql
create table users (
  id          uuid primary key,
  email       string unique,
  password    string,  -- 经过哈希处理的密码
  name        string,
  inserted_at timestamp,
  updated_at  timestamp
)
```

## TodoList表 (Lists)
```sql
create table lists (
  id          uuid primary key,
  title       string,
  owner_id    uuid references users(id),  -- 创建者
  position    integer,  -- 用于排序
  inserted_at timestamp,
  updated_at  timestamp
)
```

## TodoItem表 (Items)
```sql
create table items (
  id          uuid primary key,
  content     string,
  completed   boolean default false,
  position    integer,  -- 用于拖拽排序
  list_id     uuid references lists(id),
  inserted_at timestamp,
  updated_at  timestamp
)
```

## 用户共享关系表 (UserListShares)
```sql
create table user_list_shares (
  id          uuid primary key,
  user_id     uuid references users(id),
  list_id     uuid references lists(id),
  inserted_at timestamp,
  updated_at  timestamp,
  UNIQUE(user_id, list_id)  -- 防止重复共享
)
```

## 字段说明

### Users表
- `id`: 用户唯一标识符
- `email`: 用户邮箱，用于登录
- `password`: 加密后的密码
- `name`: 用户显示名称

### Lists表
- `id`: 清单唯一标识符
- `title`: 清单标题
- `owner_id`: 创建者ID
- `position`: 清单排序位置

### Items表
- `id`: 待办事项唯一标识符
- `content`: 待办事项内容
- `completed`: 完成状态
- `position`: 项目在清单中的排序位置
- `list_id`: 所属清单ID

### UserListShares表
- `id`: 共享关系唯一标识符
- `user_id`: 被共享用户ID
- `list_id`: 被共享的清单ID

## 关系说明
1. 一个用户可以创建多个TodoList（Users 1:n Lists）
2. 一个TodoList可以包含多个TodoItem（Lists 1:n Items）
3. 一个TodoList可以被多个用户共享（Users n:m Lists，通过UserListShares关联）

## 注意事项
1. 使用UUID作为主键，提高安全性
2. position字段用于实现拖拽排序功能
3. 所有表都包含inserted_at和updated_at时间戳
4. 共享关系表确保同一清单不会重复共享给同一用户
