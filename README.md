# mac-openclaw mission-control-pixel

## ローカル表示
```bash
cd mission-control-pixel
python3 -m http.server 3010
# http://127.0.0.1:3010
```

## ステータス更新（手動）
```bash
node scripts/update-status.js
```

## 5分ごと自動更新（mac launchd）
```bash
bash scripts/install-launchd.sh
```

更新結果は `status.json` に反映され、画面右のチェックリストが自動更新されます。
