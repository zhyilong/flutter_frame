# 小型电商后台系统架构文档

> 本文档描述了一个小型电商后台系统的完整架构设计，包含整体架构图、模块划分、技术选型、数据库设计和分阶段实现路线。

---

## 目录

1. [系统概述](#1-系统概述)
2. [整体架构图](#2-整体架构图)
3. [技术栈选型](#3-技术栈选型)
4. [模块划分与职责](#4-模块划分与职责)
5. [数据库设计](#5-数据库设计)
6. [API 设计](#6-api-设计)
7. [项目目录结构](#7-项目目录结构)
8. [实现路线](#8-实现路线)
9. [开发规范](#9-开发规范)

---

## 1. 系统概述

### 1.1 系统定位

一个面向中小型商家的电商后台管理系统，支持：
- 商品管理（增删改查、上下架）
- 订单管理（下单、支付、发货、退款）
- 用户管理（会员、地址）
- 营销活动（优惠券、满减、秒杀）
- 数据统计（销售、用户、商品分析）

### 1.2 系统特点

| 特点 | 说明 |
|------|------|
| 轻量级 | 单体架构优先，快速上线 |
| 可扩展 | 模块化设计，便于扩展 |
| 易维护 | 清晰分层，代码规范 |
| 高可用 | 基础缓存、容错设计 |

---

## 2. 整体架构图

### 2.1 系统架构图

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              用户层 (Clients)                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│  │   Web 管理后台 │  │   移动端 App  │  │   小程序商城   │  │   H5 商城    │       │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘       │
└─────────┼────────────────┼────────────────┼────────────────┼───────────────┘
          │                │                │                │
          └────────────────┴────────┬───────┴────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                             网关层 (API Gateway)                             │
│  ┌───────────────────────────────────────────────────────────────────────┐ │
│  │                        Kong / Nginx + Lua                              │ │
│  │  • 路由转发    • 负载均衡    • 限流熔断    • 认证鉴权    • 日志记录    │ │
│  └───────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
                                   │
          ┌────────────────────────┼────────────────────────┐
          │                        │                        │
          ▼                        ▼                        ▼
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│   用户服务        │  │   商品服务        │  │   订单服务        │
│  (User Service)   │  │ (Product Service) │  │ (Order Service)   │
│                  │  │                  │  │                  │
│  • 注册登录       │  │  • 商品管理       │  │  • 订单创建       │
│  • 权限管理       │  │  • 分类管理       │  │  • 支付处理       │
│  • 地址管理       │  │  • 库存管理       │  │  • 物流发货       │
└────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘
         │                     │                     │
         │         ┌──────────┴──────────┐          │
         │         │                     │          │
         ▼         ▼                     ▼          ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              数据层 (Data Layer)                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│  │   MySQL     │  │    Redis    │  │   MinIO     │  │    ES       │       │
│  │  主数据库    │  │   缓存层    │  │   文件存储   │  │  搜索引擎   │       │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘       │
└─────────────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                             基础设施层 (Infrastructure)                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│  │  Docker     │  │   K8s       │  │   CI/CD      │  │  日志收集    │       │
│  │  容器化     │  │  编排       │  │  自动化部署   │  │  ELK        │       │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘       │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 请求处理流程

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                              请求处理流程图                                   │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐ │
│   │  请求发起 │ ──▶│  网关路由 │ ──▶│  限流熔断 │ ──▶│  认证鉴权 │ ──▶│  业务处理 │ │
│   └─────────┘    └─────────┘    └─────────┘    └─────────┘    └────┬────┘ │
│                                                                    │        │
│   ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐         │        │
│   │  返回结果 │ ◀──│  响应封装 │ ◀──│  日志记录 │ ◀──│  数据校验 │ ◀────┘        │
│   └─────────┘    └─────────┘    └─────────┘    └─────────┘                  │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. 技术栈选型

### 3.1 后端技术栈

| 层级 | 技术方案 | 理由 |
|------|----------|------|
| **语言** | Go 1.21+ | 高并发、性能好、生态丰富、学习成本低 |
| **框架** | Gin / Fiber | 轻量、性能高、中间件丰富 |
| **ORM** | GORM | Go 生态主流、功能完善 |
| **缓存** | Redis 7.0 | 内存数据库、支持多种数据结构 |
| **数据库** | MySQL 8.0 | 成熟稳定、事务支持完善 |
| **消息队列** | RabbitMQ | 可靠、简单易用 |
| **搜索引擎** | Elasticsearch | 全文搜索、数据分析 |
| **对象存储** | MinIO | S3兼容、私有部署 |
| **配置中心** | Nacos / etcd | 配置管理、服务发现 |
| **链路追踪** | Jaeger | 分布式追踪 |

### 3.2 DevOps 技术栈

| 类别 | 技术方案 |
|------|----------|
| **容器化** | Docker |
| **编排** | Kubernetes / Docker Compose |
| **CI/CD** | Jenkins / GitLab CI |
| **日志** | ELK (Elasticsearch + Logstash + Kibana) |
| **监控** | Prometheus + Grafana |
| **网关** | Kong / Nginx |

### 3.3 技术选型理由

```
┌─────────────────────────────────────────────────────────────────────┐
│                           技术选型决策树                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│                        是否需要高并发？                               │
│                      ┌─────┴─────┐                                 │
│                      ▼           ▼                                  │
│                    Yes          No                                  │
│                      │           │                                  │
│           ┌──────────┴──┐     ┌──┴──────────┐                      │
│           │ Go / Rust   │     │ Java / PHP  │                      │
│           │ 高性能语言   │     │ 快速开发    │                      │
│           └──────────────┘     └─────────────┘                      │
│                                                                     │
│                        团队规模如何？                                │
│                      ┌─────┴─────┐                                 │
│                      ▼           ▼                                  │
│                    小团队          大团队                            │
│                      │           │                                  │
│           ┌──────────┴──┐     ┌──┴──────────┐                      │
│           │ 单体 / 拆分   │     │ 微服务架构  │                      │
│           │ 快速迭代     │     │ 独立部署    │                      │
│           └──────────────┘     └─────────────┘                      │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 4. 模块划分与职责

### 4.1 微服务模块划分

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              服务模块划分                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        基础服务层                                      │   │
│  │  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐           │   │
│  │  │  用户服务  │ │  认证服务  │ │  通知服务  │ │  文件服务  │           │   │
│  │  │  User     │ │  Auth     │ │  Notify   │ │  File     │           │   │
│  │  └───────────┘ └───────────┘ └───────────┘ └───────────┘           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                     │
│                                    ▼                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        业务服务层                                      │   │
│  │  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐           │   │
│  │  │  商品服务  │ │  订单服务  │ │  支付服务  │ │  营销服务  │           │   │
│  │  │  Product  │ │  Order    │ │  Pay      │ │  Marketing│           │   │
│  │  └───────────┘ └───────────┘ └───────────┘ └───────────┘           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                     │
│                                    ▼                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        数据服务层                                      │   │
│  │  ┌───────────┐ ┌───────────┐ ┌───────────┐                          │   │
│  │  │  数据统计  │ │  推荐服务  │ │  搜索服务  │                          │   │
│  │  │  Stats    │ │  Recommend│ │  Search   │                          │   │
│  │  └───────────┘ └───────────┘ └───────────┘                          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 各模块详细职责

#### 4.2.1 用户服务 (User Service)

**位置**: `service/user/`

**职责**:
- 用户注册、登录、登出
- 会员等级管理
- 用户地址管理
- 权限与角色管理

**核心接口**:

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/user/register` | POST | 用户注册 |
| `/api/user/login` | POST | 用户登录 |
| `/api/user/info` | GET | 获取用户信息 |
| `/api/user/address` | CRUD | 收货地址管理 |
| `/api/admin/user/list` | GET | 用户列表(管理端) |

#### 4.2.2 认证服务 (Auth Service)

**位置**: `service/auth/`

**职责**:
- Token 生成与验证
- 第三方登录(OAuth)
- 权限验证
- 刷新令牌

**核心接口**:

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/auth/token` | POST | 获取Token |
| `/api/auth/refresh` | POST | 刷新Token |
| `/api/auth/verify` | POST | 验证Token |
| `/oauth/:provider` | GET | 第三方登录 |

#### 4.2.3 商品服务 (Product Service)

**位置**: `service/product/`

**职责**:
- 商品增删改查
- 商品分类管理
- SKU 规格管理
- 库存管理
- 商品搜索与推荐

**核心接口**:

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/product/list` | GET | 商品列表 |
| `/api/product/detail/:id` | GET | 商品详情 |
| `/api/product/create` | POST | 创建商品 |
| `/api/product/update` | PUT | 更新商品 |
| `/api/product/delete` | DELETE | 删除商品 |
| `/api/product/category` | CRUD | 分类管理 |

#### 4.2.4 订单服务 (Order Service)

**位置**: `service/order/`

**职责**:
- 订单创建与查询
- 订单状态流转
- 订单取消与退款
- 物流信息管理

**核心接口**:

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/order/create` | POST | 创建订单 |
| `/api/order/list` | GET | 订单列表 |
| `/api/order/detail/:id` | GET | 订单详情 |
| `/api/order/cancel/:id` | POST | 取消订单 |
| `/api/order/refund/:id` | POST | 申请退款 |
| `/api/order/express/:id` | PUT | 更新物流 |

#### 4.2.5 支付服务 (Pay Service)

**位置**: `service/pay/`

**职责**:
- 支付通道集成
- 支付订单创建
- 支付回调处理
- 对账清算

**核心接口**:

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/pay/create` | POST | 创建支付订单 |
| `/api/pay/query/:id` | GET | 查询支付状态 |
| `/api/pay/notify/:channel` | POST | 支付回调 |
| `/api/pay/refund` | POST | 退款申请 |

#### 4.2.6 营销服务 (Marketing Service)

**位置**: `service/marketing/`

**职责**:
- 优惠券管理
- 满减活动
- 秒杀活动
- 积分管理

**核心接口**:

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/coupon/list` | GET | 优惠券列表 |
| `/api/coupon/create` | POST | 创建优惠券 |
| `/api/coupon/claim` | POST | 领取优惠券 |
| `/api/seckill/list` | GET | 秒杀活动 |
| `/api/seckill/detail/:id` | GET | 秒杀详情 |

### 4.3 模块间调用关系

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            模块调用依赖图                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│                              ┌──────────┐                                   │
│                              │   客户端  │                                   │
│                              └────┬─────┘                                   │
│                                   │                                         │
│                                   ▼                                         │
│                          ┌──────────────┐                                   │
│                          │  API Gateway │                                   │
│                          └──────┬───────┘                                   │
│                                 │                                           │
│           ┌─────────────────────┼─────────────────────┐                    │
│           │                     │                     │                     │
│           ▼                     ▼                     ▼                     │
│    ┌─────────────┐       ┌─────────────┐       ┌─────────────┐             │
│    │   用户服务   │       │   订单服务   │       │   商品服务   │             │
│    └──────┬──────┘       └──────┬──────┘       └─────────────┘             │
│           │                     │                                         │
│           │                     │ 调用用户服务验证用户                       │
│           │                     │                                         │
│           │         ┌───────────┴───────────┐                              │
│           │         │                       │                              │
│           │         ▼                       ▼                              │
│           │   ┌─────────────┐       ┌─────────────┐                       │
│           │   │   支付服务   │       │   营销服务   │                       │
│           │   └─────────────┘       └─────────────┘                       │
│           │                                                           │
│           │ 调用认证服务验证 Token                                        │
│           ▼                                                           │
│    ┌─────────────┐                                                    │
│    │   认证服务   │                                                    │
│    └─────────────┘                                                    │
│                                                                              │
│  调用规则：                                                               │
│  • 上游服务调用下游服务                                                   │
│  • 同级服务间禁止直接调用，通过消息队列解耦                               │
│  • 跨服务调用通过 RPC 或 HTTP                                             │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. 数据库设计

### 5.1 数据库架构

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              数据库架构                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐         │
│  │   user_db       │    │   product_db    │    │   order_db      │         │
│  │   (用户库)       │    │   (商品库)       │    │   (订单库)       │         │
│  │                 │    │                 │    │                 │         │
│  │  • users        │    │  • products     │    │  • orders       │         │
│  │  • addresses    │    │  • categories  │    │  • order_items  │         │
│  │  • roles        │    │  • SKUs        │    │  • payments     │         │
│  │  • permissions  │    │  • specs       │    │  • refunds      │         │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘         │
│                                                                              │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐         │
│  │   marketing_db   │    │   config_db     │    │   stats_db      │         │
│  │   (营销库)       │    │   (配置库)      │    │   (统计库)       │         │
│  │                 │    │                 │    │                 │         │
│  │  • coupons      │    │  • banners     │    │  • daily_stats  │         │
│  │  • seckill      │    │  • configs    │    │  • user_behavior│         │
│  │  • activities   │    │  • dicts       │    │  • product_stats│         │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘         │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.2 核心表结构

#### 5.2.1 用户表 (users)

```sql
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `password` varchar(255) NOT NULL COMMENT '密码(加密)',
  `nickname` varchar(100) DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(500) DEFAULT NULL COMMENT '头像URL',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `gender` tinyint DEFAULT 0 COMMENT '性别: 0-未知, 1-男, 2-女',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用, 1-正常',
  `level` int NOT NULL DEFAULT 1 COMMENT '会员等级',
  `points` int NOT NULL DEFAULT 0 COMMENT '积分',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_phone` (`phone`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';
```

#### 5.2.2 商品表 (products)

```sql
CREATE TABLE `products` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '商品ID',
  `category_id` bigint unsigned NOT NULL COMMENT '分类ID',
  `name` varchar(200) NOT NULL COMMENT '商品名称',
  `subtitle` varchar(500) DEFAULT NULL COMMENT '副标题',
  `description` text COMMENT '商品描述',
  `cover_image` varchar(500) NOT NULL COMMENT '封面图',
  `images` json DEFAULT NULL COMMENT '图片列表',
  `price` decimal(10,2) NOT NULL COMMENT '售价',
  `original_price` decimal(10,2) NOT NULL COMMENT '原价',
  `cost` decimal(10,2) DEFAULT NULL COMMENT '成本价',
  `stock` int NOT NULL DEFAULT 0 COMMENT '库存',
  `sold_count` int NOT NULL DEFAULT 0 COMMENT '销量',
  `view_count` int NOT NULL DEFAULT 0 COMMENT '浏览量',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0-下架, 1-上架',
  `is_hot` tinyint DEFAULT 0 COMMENT '是否热门',
  `is_new` tinyint DEFAULT 0 COMMENT '是否新品',
  `sort` int DEFAULT 0 COMMENT '排序',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_category` (`category_id`),
  KEY `idx_status` (`status`),
  KEY `idx_sold` (`sold_count`),
  KEY `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品表';
```

#### 5.2.3 订单表 (orders)

```sql
CREATE TABLE `orders` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `order_no` varchar(32) NOT NULL COMMENT '订单号',
  `user_id` bigint unsigned NOT NULL COMMENT '用户ID',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态: 0-待支付, 1-已支付, 2-待发货, 3-已发货, 4-已完成, 5-已取消, 6-已退款',
  `total_amount` decimal(10,2) NOT NULL COMMENT '商品总额',
  `discount_amount` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '优惠金额',
  `freight_amount` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '运费',
  `pay_amount` decimal(10,2) NOT NULL COMMENT '实付金额',
  `pay_time` datetime DEFAULT NULL COMMENT '支付时间',
  `ship_time` datetime DEFAULT NULL COMMENT '发货时间',
  `receive_time` datetime DEFAULT NULL COMMENT '收货时间',
  `receiver_name` varchar(50) NOT NULL COMMENT '收货人',
  `receiver_phone` varchar(20) NOT NULL COMMENT '联系电话',
  `receiver_address` varchar(500) NOT NULL COMMENT '收货地址',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_user` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';
```

#### 5.2.4 订单商品表 (order_items)

```sql
CREATE TABLE `order_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `order_id` bigint unsigned NOT NULL COMMENT '订单ID',
  `product_id` bigint unsigned NOT NULL COMMENT '商品ID',
  `sku_id` bigint unsigned DEFAULT NULL COMMENT 'SKU ID',
  `product_name` varchar(200) NOT NULL COMMENT '商品名称(快照)',
  `cover_image` varchar(500) NOT NULL COMMENT '商品图片(快照)',
  `price` decimal(10,2) NOT NULL COMMENT '单价(快照)',
  `quantity` int NOT NULL COMMENT '数量',
  `specs` json DEFAULT NULL COMMENT '规格(快照)',
  `subtotal` decimal(10,2) NOT NULL COMMENT '小计',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_order` (`order_id`),
  KEY `idx_product` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单商品表';
```

#### 5.2.5 优惠券表 (coupons)

```sql
CREATE TABLE `coupons` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '优惠券ID',
  `name` varchar(100) NOT NULL COMMENT '名称',
  `type` tinyint NOT NULL COMMENT '类型: 1-满减券, 2-折扣券, 3-兑换券',
  `amount` decimal(10,2) DEFAULT NULL COMMENT '优惠金额/折扣率',
  `min_amount` decimal(10,2) DEFAULT NULL COMMENT '满减门槛',
  `total_count` int NOT NULL COMMENT '发放总数',
  `remain_count` int NOT NULL COMMENT '剩余数量',
  `per_limit` int NOT NULL DEFAULT 1 COMMENT '每人限领',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime NOT NULL COMMENT '结束时间',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用, 1-启用',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_time` (`start_time`, `end_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='优惠券表';
```

#### 5.2.6 用户优惠券表 (user_coupons)

```sql
CREATE TABLE `user_coupons` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `user_id` bigint unsigned NOT NULL COMMENT '用户ID',
  `coupon_id` bigint unsigned NOT NULL COMMENT '优惠券ID',
  `order_id` bigint unsigned DEFAULT NULL COMMENT '使用订单ID',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态: 0-未使用, 1-已使用, 2-已过期',
  `received_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '领取时间',
  `used_at` datetime DEFAULT NULL COMMENT '使用时间',
  `expired_at` datetime NOT NULL COMMENT '过期时间',
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_coupon` (`coupon_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户优惠券表';
```

---

## 6. API 设计

### 6.1 API 规范

#### 请求规范

```
请求格式: JSON
请求方法: RESTful
认证方式: Bearer Token

请求头:
Content-Type: application/json
Authorization: Bearer <token>
X-Request-ID: <uuid>           // 请求追踪ID
X-Timestamp: <unix_timestamp>    // 时间戳
```

#### 响应规范

```json
{
  "code": 0,           // 状态码: 0=成功, 其他=失败
  "message": "success", // 消息
  "data": {},          // 数据
  "request_id": "xxx"   // 请求追踪ID
}
```

#### 状态码定义

| 状态码 | 说明 |
|--------|------|
| 0 | 成功 |
| 1001 | 参数错误 |
| 1002 | 签名错误 |
| 2001 | 用户不存在 |
| 2002 | 密码错误 |
| 2003 | Token 过期 |
| 2004 | 无权限 |
| 3001 | 商品不存在 |
| 3002 | 库存不足 |
| 4001 | 订单不存在 |
| 4002 | 订单状态不允许 |
| 5001 | 支付失败 |
| 5002 | 退款失败 |

### 6.2 API 示例

#### 用户登录

**请求**:
```http
POST /api/auth/login
Content-Type: application/json

{
  "username": "user@example.com",
  "password": "xxxxxx"
}
```

**响应**:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 7200,
    "user": {
      "id": 10001,
      "username": "user@example.com",
      "nickname": "张三",
      "avatar": "https://xxx.com/avatar.jpg",
      "level": 2
    }
  }
}
```

#### 创建订单

**请求**:
```http
POST /api/order/create
Authorization: Bearer <token>
Content-Type: application/json

{
  "address_id": 1001,
  "items": [
    {
      "product_id": 20001,
      "sku_id": 2000101,
      "quantity": 2
    }
  ],
  "coupon_id": 3001,
  "remark": "请尽快发货"
}
```

**响应**:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "order_id": 40001,
    "order_no": "O20260126180000001",
    "pay_amount": "198.00",
    "pay_expire_at": "2026-01-26T18:30:00Z"
  }
}
```

---

## 7. 项目目录结构

### 7.1 整体目录结构

```
ecommerce-backend/
├── cmd/                              # ═══════════════════════════════════
│   ├── api/                         #     入口文件
│   │   └── main.go                  # API 服务入口
│   └── worker/                      # Worker 入口
│       └── main.go                  # 异步任务入口
│
├── config/                           # ═══════════════════════════════════
│   ├── config.yaml                  # 配置文件
│   ├── dev.yaml                     # 开发环境配置
│   ├── test.yaml                    # 测试环境配置
│   └── prod.yaml                    # 生产环境配置
│
├── internal/                         # ═══════════════════════════════════
│   │                                #     内部业务代码 (不对外暴露)
│   ├── api/                        # API 层
│   │   ├── handler/                 # 处理器 (Controller)
│   │   │   ├── user.go
│   │   │   ├── product.go
│   │   │   └── order.go
│   │   ├── middleware/             # 中间件
│   │   │   ├── auth.go
│   │   │   ├── cors.go
│   │   │   ├── logging.go
│   │   │   └── ratelimit.go
│   │   ├── router/                 # 路由
│   │   │   └── router.go
│   │   └── response/               # 响应封装
│   │       └── response.go
│   │
│   ├── service/                     # 服务层 (业务逻辑)
│   │   ├── user/
│   │   │   ├── user_service.go
│   │   │   └── user_dto.go
│   │   ├── product/
│   │   │   ├── product_service.go
│   │   │   └── product_dto.go
│   │   ├── order/
│   │   │   ├── order_service.go
│   │   │   └── order_dto.go
│   │   └── ...
│   │
│   ├── repository/                  # 数据访问层
│   │   ├── user/
│   │   │   └── user_repo.go
│   │   ├── product/
│   │   │   └── product_repo.go
│   │   ├── order/
│   │   │   └── order_repo.go
│   │   └── ...
│   │
│   ├── model/                       # 数据模型层
│   │   ├── user.go
│   │   ├── product.go
│   │   ├── order.go
│   │   └── ...
│   │
│   ├── pkg/                         # 内部工具包
│   │   ├── errors/                  # 错误定义
│   │   ├── validator/              # 参数校验
│   │   └── trace/                  # 链路追踪
│   │
│   └── module/                      # 模块初始化
│       ├── user_module.go
│       ├── product_module.go
│       └── order_module_module.go
│
├── pkg/                             # ═══════════════════════════════════
│   │                                #     公共工具包 (可独立发布)
│   ├── database/                   # 数据库
│   │   ├── mysql.go
│   │   └── redis.go
│   ├── log/                        # 日志
│   │   └── logger.go
│   ├── config/                     # 配置
│   │   └── config.go
│   ├── jwt/                        # JWT
│   │   └── jwt.go
│   ├── oss/                        # 对象存储
│   │   └── minio.go
│   ├── sms/                        # 短信
│   │   └── sms.go
│   └── utils/                      # 工具函数
│       ├── md5.go
│       ├── uuid.go
│       └── time.go
│
├── third_party/                    # ═══════════════════════════════════
│   │                                #     第三方依赖
│   ├── google/                     # Google API
│   └── ...
│
├── scripts/                         # ═══════════════════════════════════
│   ├── db/
│   │   ├── init.sql               # 数据库初始化
│   │   └── migration/              # 迁移脚本
│   └── build.sh                    # 构建脚本
│
├── deployments/                    # ═══════════════════════════════════
│   ├── docker/
│   │   └── Dockerfile
│   └── k8s/
│       ├── deployment.yaml
│       └── service.yaml
│
├── go.mod                           # ═══════════════════════════════════
├── go.sum
├── Makefile
├── README.md
└── ARCHITECTURE.md
```

### 7.2 分层职责

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           分层架构详解                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                        API Handler 层                                   │  │
│  │  internal/api/handler/                                                 │  │
│  │                                                                       │  │
│  │  职责：                                                               │  │
│  │  • 接收 HTTP 请求                                                     │  │
│  │  • 参数校验                                                           │  │
│  │  • 调用 Service 层                                                    │  │
│  │  • 封装响应                                                           │  │
│  │                                                                       │  │
│  │  禁止：                                                               │  │
│  │  • 禁止写业务逻辑                                                     │  │
│  │  • 禁止直接操作数据库                                                 │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                        Service 层                                      │  │
│  │  internal/service/                                                     │  │
│  │                                                                       │  │
│  │  职责：                                                               │  │
│  │  • 业务逻辑处理                                                       │  │
│  │  • 事务管理                                                           │  │
│  │  • 调用 Repository 层                                                 │  │
│  │  • 调用其他 Service (跨模块)                                           │  │
│  │                                                                       │  │
│  │  禁止：                                                               │  │
│  │  • 禁止直接处理 HTTP 请求                                             │  │
│  │  • 禁止处理 SQL                                                      │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                       Repository 层                                     │  │
│  │  internal/repository/                                                  │  │
│  │                                                                       │  │
│  │  职责：                                                               │  │
│  │  • 数据库 CRUD 操作                                                   │  │
│  │  • 缓存读写                                                           │  │
│  │  • 数据转换 (DB Model <-> Domain Model)                               │  │
│  │                                                                       │  │
│  │  禁止：                                                               │  │
│  │  • 禁止写业务逻辑                                                     │  │
│  │  • 禁止处理 HTTP 请求                                                │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                         Model 层                                        │  │
│  │  internal/model/                                                       │  │
│  │                                                                       │  │
│  │  职责：                                                               │  │
│  │  • 数据结构定义                                                       │  │
│  │  • 数据库表映射                                                       │  │
│  │                                                                       │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 8. 实现路线

### 8.1 分阶段开发计划

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          阶段一：基础设施 (2周)                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  目标：搭建项目框架、数据库、中间件                                           │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 周 1: 项目初始化                                                    │   │
│  │  □ Go 项目创建，依赖引入                                           │   │
│  │  □ 目录结构创建                                                     │   │
│  │  □ 配置文件加载 (dev/test/prod)                                    │   │
│  │  □ 日志组件封装                                                     │   │
│  │  □ 数据库连接 (MySQL + GORM)                                       │   │
│  │  □ Redis 连接                                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 周 2: 公共组件                                                     │   │
│  │  □ 统一响应封装                                                    │   │
│  │  □ 错误处理封装                                                    │   │
│  │  □ JWT 认证组件                                                    │   │
│  │  □ 中间件 (日志、CORS、限流)                                       │   │
│  │  □ 数据库迁移脚本                                                  │   │
│  │  □ Docker 化                                                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  交付物：可运行的基础项目骨架                                                 │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          阶段二：用户模块 (2周)                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  目标：完成用户注册、登录、权限管理                                           │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 周 3: 用户管理                                                     │   │
│  │  □ 用户表设计                                                     │   │
│  │  □ 注册接口 (手机号/邮箱)                                          │   │
│  │  □ 登录接口 (密码登录)                                             │   │
│  │  □ 获取用户信息                                                    │   │
│  │  □ 更新用户信息                                                    │   │
│  │  □ 收货地址管理 (CRUD)                                            │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 周 4: 权限与安全                                                   │   │
│  │  □ JWT Token 刷新机制                                             │   │
│  │  □ 权限中间件                                                     │   │
│  │  □ 密码加密存储                                                   │   │
│  │  □ 登录限流                                                       │   │
│  │  □ 用户状态管理                                                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  交付物：用户注册登录功能完整可用                                             │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          阶段三：商品模块 (3周)                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  目标：完成商品管理、分类、SKU、库存                                          │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 周 5: 商品基础                                                     │   │
│  │  □ 商品表设计                                                     │   │
│  │  □ 商品分类表设计                                                 │   │
│  │  □ 商品创建/编辑/删除                                            │   │
│  │  □ 商品列表 (分页、筛选、排序)                                    │   │
│  │  □ 商品详情                                                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 周 6: SKU 与规格                                                  │   │
│  │  □ SKU 表设计                                                     │   │
│  │  □ 规格表设计                                                     │   │
│  │  □ SKU 创建/编辑                                                 │   │
│  │  □ 库存管理                                                       │   │
│  │  □ 价格计算                                                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 周 7: 商品查询                                                    │   │
│  │  □ 商品搜索 (关键词)                                              │   │
│  │  □ 热门商品                                                       │   │
│  │  □ 新品推荐                                                       │   │
│  │  □ 分类商品列表                                                   │   │
│  │  □ Elasticsearch 集成 (可选)                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  交付物：完整的商品管理功能                                                   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          阶段四：订单模块 (3周)                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  目标：完成订单全流程                                                        │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 周 8: 订单基础                                                     │   │
│  │  □ 订单表设计                                                     │   │
│  │  □ 订单商品表设计                                                │   │
│  │  □ 创建订单                                                       │   │
│  │  □ 订单列表                                                       │   │
│  │  □ 订单详情                                                       │   │
│  │  □ 订单状态流转                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 周 9: 订单管理                                                   │   │
│  │  □ 取消订单                                                       │   │
│  │  □ 订单发货                                                       │   │
│  │  □ 确认收货                                                       │   │
│  │  □ 物流信息                                                       │   │
│  │  □ 订单超时处理                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 周 10: 退款售后                                                  │   │
│  │  □ 退款申请                                                       │   │
│  │  □ 退款审核                                                       │   │
│  │  □ 退款处理                                                       │   │
│  │  □ 退货流程                                                       │   │
│  │  □ 库存返还                                                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  交付物：完整的订单流程                                                       │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          阶段五：支付模块 (2周)                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  目标：集成第三方支付                                                        │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 周 11: 支付基础                                                   │   │
│  │  □ 支付表设计                                                     │   │
│  │  □ 支付渠道抽象                                                   │   │
│  │  □ 微信支付集成                                                   │   │
│  │  □ 支付宝集成                                                     │   │
│  │  □ 创建支付订单                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 周 12: 支付回调                                                   │   │
│  │  □ 回调通知接收                                                  │   │
│  │  □ 回调验签                                                       │   │
│  │  □ 订单状态更新                                                  │   │
│  │  □ 支付查询                                                       │   │
│  │  □ 对账机制                                                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  交付物：完整支付功能                                                        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          阶段六：营销模块 (2周)                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  目标：完成优惠券、活动功能                                                   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 周 13: 优惠券                                                     │   │
│  │  □ 优惠券表设计                                                  │   │
│  │  □ 用户优惠券表                                                  │   │
│  │  □ 创建优惠券                                                    │   │
│  │  □ 领取优惠券                                                    │   │
│  │  □ 使用优惠券                                                    │   │
│  │  □ 过期处理                                                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 周 14: 活动                                                       │   │
│  │  □ 满减活动                                                       │   │
│  │  □ 秒杀活动                                                       │   │
│  │  □ 限时折扣                                                       │   │
│  │  □ 积分系统                                                       │   │
│  │  □ 活动冲突处理                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  交付物：营销工具完整可用                                                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          阶段七：统计与上线 (2周)                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  目标：数据统计、系统优化、部署上线                                            │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 周 15: 数据统计                                                   │   │
│  │  □ 销售统计 (日/周/月)                                            │   │
│  │  □ 用户统计                                                       │   │
│  │  □ 商品统计                                                       │   │
│  │  □ 运营报表                                                       │   │
│  │  □ 数据看板 API                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 周 16: 优化上线                                                  │   │
│  │  □ 性能优化                                                       │   │
│  │  □ 缓存优化                                                       │   │
│  │  □ 监控告警                                                       │   │
│  │  □ 文档完善                                                       │   │
│  │  □ 生产部署                                                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  交付物：生产可用系统                                                        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 8.2 里程碑

| 阶段 | 时间 | 里程碑 |
|------|------|--------|
| 阶段一 | 第 1-2 周 | ✅ 项目基础设施完成 |
| 阶段二 | 第 3-4 周 | ✅ 用户模块完成 |
| 阶段三 | 第 5-7 周 | ✅ 商品模块完成 |
| 阶段四 | 第 8-10 周 | ✅ 订单模块完成 |
| 阶段五 | 第 11-12 周 | ✅ 支付模块完成 |
| 阶段六 | 第 13-14 周 | ✅ 营销模块完成 |
| 阶段七 | 第 15-16 周 | 🚀 系统上线 |

---

## 9. 开发规范

### 9.1 代码规范

1. **命名规范**
   - 包名：小写、下划线分隔
   - 结构体：PascalCase
   - 变量/函数：camelCase
   - 常量：全大写、下划线分隔

2. **错误处理**
   - 使用自定义错误类型
   - 错误 wrapping
   - 统一错误响应格式

3. **日志规范**
   - 分级：Debug/Info/Warn/Error
   - 包含请求追踪 ID
   - 敏感信息脱敏

### 9.2 Git 规范

```
分支命名：
- main: 主分支
- develop: 开发分支
- feature/xxx: 功能分支
- bugfix/xxx: 修复分支
- release/xxx: 发布分支

提交信息：
<type>(<scope>): <subject>
- feat: 新功能
- fix: 修复
- docs: 文档
- style: 格式
- refactor: 重构
- test: 测试
- chore: 构建
```

### 9.3 API 规范

- RESTful 风格
- 版本控制：`/api/v1/`
- 统一响应格式
- 请求验签
- 接口文档 (Swagger)

---

## 附录

### A. 参考资料

- [Go 语言编码规范](https://go.dev/doc/effective_go)
- [Uber Go 风格指南](https://github.com/uber-go/guide)
- [GORM 文档](https://gorm.io/docs/)
- [Gin 框架文档](https://gin-gonic.com/docs/)

### B. 联系方式

如有问题，请提交 Issue 或联系开发团队。

---

**文档版本**: 1.0.0
**最后更新**: 2026-05-26
