## CloudNote Document

### Data Structure

* Note
    * id (universally unique)
    * body
    * timestamp
    * user_id (optional)

* User [TBD]

### API

* 请求和返回都是JSON

#### 对于设备请求的验证

**[ATTENTION!!!!]**

服务器端在处理**所有**请求之前都会进行请求验证，请客户端每次发起请求时都在Header中带上以下信息：

* Nonce: 随机字符串
* Timestamp: 当前utc时间戳
* Signature: 用TOKEN, Nonce和Timestamp组合加密得到的签名

TOKEN事先硬编码在代码中, service和app共享

【接下来是发起请求的流程】在每次请求时:

1. 获取当前的Timestamp
2. 随机生成一个Nonce字符串
3. 将TOKEN, Timestamp和Nonce按照字典序排列，排列后按顺序拼成一个字符串
4. 将上一步得到的字符串用md5加密，用base64进行编码，得到Signature
5. 将Signature, Timestamp和Nonce都加入请求的Header中，格式为：

```javascript
{
  Signature: ...
  Timestamp: ...
  Nonce: ...
}
```

在后台拿到请求时，会用同样的算法，利用TOKEN和传来的Timestamp和Nonce计算出signature，与传来的Signature比较，如果比较结果相同则验证成功，返回所请求的内容，否则返回以下json：

```javascript
{
  code: 400,
  message: 'authentication failed'
}
```

#### 用户验证 [TBD]

#### POST /notes/sync

* 上传所有NOTE（本来是可以精细点的，不过这样最稳当）
* 返回NOTE类型：
    * type=0 原本就在客户端，但服务器或其他客户端有更新
    * type=1 客户端原来没有的note
    * type=2 客户端刚刚新建并保存到服务器的note，要添加ID
    * type=3 需要删除的note

* 客户端收到之后的处理逻辑应该是：
    * type=0 更新note的body
    * type=1 新建note
    * type=2 用timestamp找到note，添加id
    * type=3 删除note

REQUEST FORMAT

```javascript
[
  {
    id: 1,
    body: "Note A",
    timestamp: 1403706535703 // utc timestamp
  },
  {
    id: 2,
    body: "Note B",
    timestamp: 1403706662095
  },
  { // new record
    body: "Note C",
    timestamp: 1403706681210
  }
]
```

RESPONSE FORMAT
```javascript
[
   {
    id: 1,
    body: "Updated Note A",
    timestamp: 1403706535703,
    type: 0 // updated from other devices
  },
  {
    id: 4,
    body: "Note D",
    timestamp: 1403707914734,
    type: 1 // new note from other devices
  },
  {
    id: 3,
    body: "Note C",
    timestamp: 1403706681210
    type: 2 // server assign id to this note
  },
  {
    id: 2,
    timestamp: 1403706662095,
    type: 3 // should delete this
  }
]
```

#### GET /notes

* 得到当前的所有条目

RESPONSE FORMAT

```javascript
[
  {
    id: 1,
    body: "Note A",
    timestamp: 1403706535703 // utc timestamp
  },
  {
    id: 2,
    body: "Note B",
    timestamp: 1403706662095
  },
  {
    id: 3,
    body: "Note C",
    timestamp: 1403706681210
  }
]
```

#### DELETE /notes/:id

* 删除某个条目 e.g: DELETE /notes/1 即删除id=1的note
* 目前我们的策略（其实这样不是很好，要再讨论）是：在客户端删除某条Note时，**立即** 向服务器发一个DELETE的请求

RESPONSE FORMAT

```javascript
// Assuming the request is: DELETE /notes/1

// success
{
  code: 200,
  id: 1,
  message: 'delete success.'
}

// failed
{
  code: 400,
  id: 1,
  message: 'something fucked up' // maybe be some custom error msg, anyway
}
```


