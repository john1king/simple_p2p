

## 设计思路

* 在每次交易后更新两个用户间结算后的金钱关系记录到 loans 表中，然后从 loans 表中判断用户的交易能否进行、查询两个用户间的借款关系、统计用户的借入借出总金额
* loans 表记录两个用户间的金钱关系，每对用户之间只会保存一条记录。为此始终将 user_id 较小的一方作为借出方(lender)，较大的一方作为借入方(borrower)，正数表示借出金钱、负数表示借入金钱
* 交易金额在数据库中用 decimal 类型表示，取 15 位有效数字在一般规模的系统中都够用，小数点只支持 2 位有效数字。在 API 金额中用 JSON 格式的字符串表示，避免浮点数导致的精度错误。
* 用户余额不能小于 0 的限制用 validation 实现，发生非法的交易时会抛出异常使交易中断。用户间的交易底层都是调用转账方法（ Loan.transfer）完成，理论上只要余额不小于0交易都能进行，因此只在借款、和还款方法中做了是否可执行判断。除了用户不能还款超过借款金额外，还增加了不能向对自己有欠款的用户借钱的限制。
* 在交易完成后会记录交易流水到 tradings 表中。没有这个交易记录或单独使用交易记录都能够实现需求，不过如果考虑到更实际一点的需求，使用交易记录是更合理的方案，同时可能也要做更多的性能优化处理。
* API 方面为了保持调用的清晰，参数统一使用 borrower_id (借入方) 和 lender_id (借出方)。V1 版本的设计是根据需求实现的，主要请求都是两个用户间的交易；V2 版本是基于用户设计的，更适合实现登录用户向其他用户发起借款和还款行为的逻辑。测试请使用 V1 接口


## API 文档

可以到 http://simple_p2p.john1king.com/docs 查看和调用具体的 API

1. POST 请求的 body 为 JSON，请求的 `Content-Type` 需要为 `application/json`
2. Response 的 status code >= 400 时，返回带有 `error` 字段的 JSON，如 `{ "error": "oops" }`

以下为各接口的说明


创建用户接口

```
POST http://simple_p2p.john1king.com/api/v1/users

参数：

1. name: 用户名，可选
2. amount: 初始化金额，默认为0，可选

返回值：

{
  id: 用户ID
}

```


创建借款交易

```
POST http://simple_p2p.john1king.com/api/v1/borrowings

参数：

1. borrower_id: 借入方用户ID
2. lender_id: 借出方用户ID
3. money: 借入金额

无返回值
```


创建还款交易

```
POST http://simple_p2p.john1king.com/api/v1/repayments

参数：

1. borrower_id: 借入方用户ID
2. lender_id: 借出方用户ID
3. money: 借出金额

无返回值
```

查询用户的账户情况

```
GET http://simple_p2p.john1king.com/api/v1/users/{用户ID}/balance

参数：用户ID在请求路径中

返回值：

{
  amount: 用户余额，
  amount_borrowed: 用户借入总金额,
  amount_lend: 用户接出总金额
}
```


查询用户之间的债务情况

```
GET http://simple_p2p.john1king.com/api/v1/borrowings

参数：

1. borrower_id: 借入方用户ID
2. lender_id: 借出方用户ID

返回值

{
  amount_borrowed: 大于 0 表示 borrower 从 lender 借入的金额，小于 0 表示借出的金额
}
```
