# MTR Update Analyzer

Load all @mtrupdate tweets and extract data from it.

## Status

## MTR Delay Heatmap

"唔好意思" 究竟港鐡一年大小服務受阻有多少次呢？

![https://raw.github.com/siuying/mtrupdate_analyze/master/heatmap.png](https://raw.github.com/siuying/mtrupdate_analyze/master/heatmap.png)

## Usage

Check http://mtrdelay.reality.hk/

## API

### /data/raw/

Raw json fetched from [@mtrupdate](https://twitter.com/mtrupdate).

##### /data/raw/243329358247366656.json
```json
{
  "id": 243329358247366656,
  "text": "2042 港島綫上環站訊號故障，服務嚴重受阻，可考慮其他交通工具",
  "created_at": "2012-09-05 20:46:54 +0800",
  "lang": "ja",
  "reply_to": null
}
```

### /data/by_date/

Raw json filtered for only tweets related to delay events, grouped by date.

##### /data/by_date/20130905.json
```json
[
  {
    "id": 243329358247366656,
    "text": "港島綫上環站訊號故障，服務嚴重受阻，可考慮其他交通工具",
    "created_at": "2012-09-05T20:46:54+08:00",
    "time": 2042,
    "date": "2012-09-05",
    "delay": "服務嚴重受阻",
    "line": "港島綫"
  },
  {
    "id": 243333409714368512,
    "text": "之前於港島綫發生的訊號障事故，經已處理完成，服務稍有阻延",
    "created_at": "2012-09-05T21:03:00+08:00",
    "time": 2057,
    "date": "2012-09-05",
    "delay": "服務稍有阻延",
    "line": "港島綫"
  },
  {
    "id": 243346540171763712,
    "text": "港島綫列車服務回復正常",
    "created_at": "2012-09-05T21:55:10+08:00",
    "time": 2152,
    "date": "2012-09-05",
    "delay": "回復正常",
    "line": "港島綫"
  }
]
```
