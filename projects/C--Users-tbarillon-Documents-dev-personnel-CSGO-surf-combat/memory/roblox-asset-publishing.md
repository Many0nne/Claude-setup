---
name: roblox-asset-publishing
description: "How to publish Roblox assets (animations, meshes) for this game via Open Cloud; rbxtemp ids don't work in playtest"
metadata:
  node_type: memory
  type: reference
  originSessionId: 6ddb2a04-ce6c-41f9-89a4-193cbb77dd3f
  modified: 2026-10-31T16:15:56.779Z
---

Experience owner = Roblox user 434916384 (place 91817475928288). Assets must be created under that user to play live.

- Open Cloud upload works: POST https://apis.roblox.com/assets/v1/assets multipart (`request` JSON with assetType
  Animation/Model + creationContext.creator.userId, `fileContent=@file.rbxm;type=model/x-rbxm`), then poll
  GET /assets/v1/operations/{id}. Animations approved in seconds (2026-10-31).
- The API key is NOT stored on the machine (no env var); ask via T3 `request_secret` (delivery: file). Suggested
  env var name: ROBLOX_OPEN_CLOUD_KEY (scopes asset:read, asset:write).
- `KeyframeSequenceProvider:RegisterKeyframeSequence` rbxtemp:// ids are refused by the client in playtest: publish
  before testing animations.
- FBX meshes could go through Open Cloud as Model + Studio MCP insert_asset, instead of asking the user to import.

See also [[viewmodel-pipeline-retex]].
