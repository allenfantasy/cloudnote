### CloudNote API Document

#### Data Structure

* Note
    * id (universally unique)
    * body
    * timestamp
    * user_id (optional)

* User [TBD]

#### API

* 请求和返回都是JSON

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
  { // new record
    id: 3,
    body: "Note C",
    timestamp: 1403706681210
  }
]
```
