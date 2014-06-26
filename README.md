### CloudNote Document

#### Data Structure

* Note
    * id (universally unique)
    * body
    * timestamp
    * user_id (optional)

* User [TBD]

#### API

* 请求和返回都是JSON

##### authentication [TBD]

##### POST /notes/sync

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

##### GET /notes

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

##### DELETE /notes/:id

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

